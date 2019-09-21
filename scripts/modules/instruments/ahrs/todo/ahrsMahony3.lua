local M = {}


---
--- private properties
---
local sampleFrequency = 60
local samplePeriod = 1 / sampleFrequency
local kp = 2.0 * 1.5 -- proportional gain
local ki = 2.0 * 0.2 -- integral gain
local eIntx, eInty, eIntz = 0, 0, 0 -- integral error

--
-- AHRS Quaternion
--
local qx = 1
local qy = 0
local qz = 0
local qw = 0


---
--- helpers
---
local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943


---
--- Converts data to ZYX Euler angles (in degrees).
---
local function convertToEulerAngles2()
    phi = math.atan2(2 * (qz * qw - qx * qy), 2 * qx * qx - 1 + 2 * qw * qw)
    theta = -math.atan((2.0 * (qy * qw + qx * qz)) / math.sqrt(1.0 - math.pow((2.0 * qy * qw + 2.0 * qx * qz), 2.0)))
    psi = math.atan2(2 * (qy * qz - qx * qw), 2 * qx * qx - 1 + 2 * qy * qy)
    --print(phi, theta, psi)
    return phi * rad2Deg, theta * rad2Deg, psi * rad2Deg 
end



local pi = math.pi
local half_pi = pi * 0.5
local two_pi = 2 * pi
local negativeFlip = -0.0001
local positiveFlip = two_pi - 0.0001
	
local function sanitizeEuler(x, y, z)	
	if x < negativeFlip then
		x = x + two_pi
	elseif x > positiveFlip then
		x = x - two_pi
	end

	if y < negativeFlip then
		y = y + two_pi
	elseif y > positiveFlip then
		y = y - two_pi
	end

	if z < negativeFlip then
		z = z + two_pi
	elseif z > positiveFlip then
		z = z + two_pi
    end
    
    return x, y, z
end


--Order of rotations: YXZ
local function convertToEulerAngles3()

    local x, y, z
	local check = 2 * (qy * qz - qw * qx)
	
	if check < 0.999 then
		if check > -0.999 then
			x =  -math.asin(check)
			y = math.atan2(2 * (qx * qz + qw * qy), 1 - 2 * (qx * qx + qy * qy))
			z = math.atan2(2 * (qx * qy + qw * qz), 1 - 2 * (qx * qx + qz * qz))
		else
            x = half_pi
            y = math.atan2(2 * (qx * qy - qw * qz), 1 - 2 * (qy * qy + qz * qz))
            z = 0
		end
	else
        x = -half_pi
        y = math.atan2(-2 * (qx * qy - qw * qz), 1 - 2 * (qy * qy + qz * qz))
        z = 0
    end
    x, y, z = sanitizeEuler(x, y, z)
	return x * rad2Deg, y * rad2Deg, z * rad2Deg
end


local function convertToEulerAngles()

    local roll, pitch, yaw = 0,0,0

    local w2 = qx * qx
    local x2 = qy * qy
    local y2 = qz * qz
    local z2 = qw * qw
    local unitLength = w2 + x2 + y2 + z2     -- Normalised == 1, otherwise correction divisor.
    local abcd = qx * qy + qz * qw
    local eps = 1e-7                        -- TODO: pick from your math lib instead of hardcoding.
    if abcd > (0.5 - eps) * unitLength then
        roll = 0.0
        pitch = math.pi
        yaw = 2.0 * math.atan2(qz, qx)
    elseif abcd < (-0.5 + eps) * unitLength then
        roll  = 0.0
        pitch = -math.pi
        yaw   = -2.0 * math.atan2(qz, qx)
    else
        local adbc = qx * qw - qy * qz
        local acbd = qx * qz - qy * qw
        roll  = math.atan2(2.0 * acbd, 1.0 - 2.0 * (y2 + x2))
        pitch = math.asin(2.0 * abcd / unitLength)
        yaw   = math.atan2(2.0 * adbc, 1.0 - 2.0 * (z2 + x2))
    end
    return roll * rad2Deg, pitch * rad2Deg, yaw * rad2Deg
end






local function updateIMU2(_ax, _ay, _az, _gx, _gy, _gz, freq)
    local norm
    local vx, vy, vz
    local ex, ey, ez
    local pa, pb, pc

    local ax, ay, az = _ax, _ay, _az
    local gx, gy, gz = _gx, _gy, _gz
    
    -- Normalise accelerometer measurement
    norm = math.sqrt(ax * ax + ay * ay + az * az)
    if norm == 0 then
        return -- handle NaN
    end
    norm = 1 / norm -- use reciprocal for division
    ax = ax * norm
    ay = ay * norm
    az = az * norm

    -- Estimated direction of gravity
    vx = 2.0 * (qy * qw - qx * qz)
    vy = 2.0 * (qx * qy + qz * qw)
    vz = qx * qx - qy * qy - qz * qz + qw * qw

    --Error is cross product between estimated direction and measured direction of gravity
    ex = (ay * vz - az * vy)
    ey = (az * vx - ax * vz)
    ez = (ax * vy - ay * vx)
    if ki > 0 then
        eIntx = eIntx +ex       -- accumulate integral error
        eInty = eInty +ey
        eIntz = eIntz +ez
    else
        eIntx = 0.0     -- prevent integral wind up
        eInty = 0.0
        eIntz = 0.0
    end

    -- Apply feedback terms
    gx = gx + kp * ex + ki * eIntx
    gy = gy + kp * ey + ki * eInty
    gz = gz + kp * ez + ki * eIntz

    -- Integrate rate of change of quaternion
    pa = qy
    pb = qz
    pc = qw

    qx = qx + (-qy * gx - qz * gy - qw * gz) * (0.5 * samplePeriod)
    qy = pa + (qx * gx + pb * gz - pc * gy) * (0.5 * samplePeriod)
    qz = pb + (qx * gy - pa * gz + pc * gx) * (0.5 * samplePeriod)
    qw = pc + (qx * gz + pa * gy - pb * gx) * (0.5 * samplePeriod)

    -- Normalise quaternion
    norm = math.sqrt(qx * qx + qy * qy + qz * qz + qw * qw)
    norm = 1.0 / norm
    qx = qx * norm
    qy = qy * norm
    qz = qz * norm
    qw = qw * norm
end



local function updateIMU(_ax, _ay, _az, _gx, _gy, _gz, freq)
    local norm
    local vx, vy, vz
    local ex, ey, ez
    local pa, pb, pc

    local ax, ay, az = _ax, _ay, _az
    local gx, gy, gz = _gx, _gy, _gz
    
    -- Normalise accelerometer measurement
    norm = math.sqrt(ax * ax + ay * ay + az * az)
    if norm ~=0 then
        norm = 1 / norm -- use reciprocal for division
        ax = ax * norm
        ay = ay * norm
        az = az * norm

        -- Estimated direction of gravity
        vx = qy * qw - qx * qz
        vy = qx * qy + qz * qw
        vz = qx * qx - 0.5 + qw * qw

        --Error is cross product between estimated direction and measured direction of gravity
        ex = (ay * vz - az * vy)
        ey = (az * vx - ax * vz)
        ez = (ax * vy - ay * vx)
        if ki > 0 then
            eIntx = eIntx + ex * samplePeriod       -- accumulate integral error
            eInty = eInty + ey * samplePeriod
            eIntz = eIntz + ez * samplePeriod
            gx = gx + eIntx
            gy = gy + eInty
            gz = gz + eIntz     
        else
            eIntx = 0.0     -- prevent integral wind up
            eInty = 0.0
            eIntz = 0.0
        end

        -- Apply feedback terms
        gx = gx + kp * ex 
        gy = gy + kp * ey
        gz = gz + kp * ez
    end

    -- Integrate rate of change of quaternion

    gx = gx * (0.5 * samplePeriod)		-- pre-multiply common factors
    gy = gy * (0.5 * samplePeriod)
    gz = gz * (0.5 * samplePeriod)
    pa = qx
    pb = qy
    pc = qz
    qx = qx + (-pb * gx - pc * gy - qw * gz)
    qy = qy + (pa * gx + pc * gz - qw * gy)
    qz = qz + (pa * gy - pb * gz + qw * gx)
    qw = qw + (pa * gz + pb * gy - pc * gx)

    -- Normalise quaternion
    norm = math.sqrt(qx * qx + qy * qy + qz * qz + qw * qw)
    if norm ~= 0 then
        norm = 1.0 / norm
        qx = qx * norm
        qy = qy * norm
        qz = qz * norm
        qw = qw * norm
    end
end






--
-- must be called by parent upon creation
--
M.create = function()
end


M.update = function(ax, ay, az, gx, gy, gz, f)
    updateIMU(ax, ay, az, gx, gy, gz, f)
    return convertToEulerAngles()
end


M.delete = function()
end

return M
