local M = {}

local kp = 1.0
local ki = 0.0

local sampleFreq = 60 -- sample frequency in Hz
M.sampleFreq = sampleFreq
local recipSampleFreq = 1 / sampleFreq

local twoKp = 2.0 * kp -- 2 * proportional gain (Kp)
local twoKi = 2.0 * ki -- 2 * integral gain (Ki)
local q0 = 1.0
local q1 = 0.0
local q2 = 0.0
local q3 = 0.0 -- quaternion of sensor frame relative to auxiliary frame
local integralFBx = 0.0
local integralFBy = 0.0
local integralFBz = 0.0 -- integral error terms scaled by Ki

local initialized = true

local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943


local doBruteForceInitialisation = function (ax, ay, az)
    initalised = true
    local twoKpOrig = twoKp
    twoKp = 2.5
    for i = 0, 9 do
      M.updateIMU(0.0, 0.0, 0.0, ax, ay, az, 1.0)
    end
    twoKp = twoKpOrig;
end


local pi = math.pi
local half_pi = pi * 0.5
local two_pi = 2 * pi
local negativeFlip = -0.0001
local positiveFlip = two_pi - 0.0001
	
local function SanitizeEuler(x, y, z)	
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
M.toEulerAngles = function()
	local x = q0
	local y = q1
	local z = q2
	local w = q3
		
	local check = 2 * (y * z - w * x)
	
	if check < 0.999 then
		if check > -0.999 then
			local ox =  -math.asin(check)
			local oy = math.atan2(2 * (x * z + w * y), 1 - 2 * (x * x + y * y))
			local oz = math.atan2(2 * (x * y + w * z), 1 - 2 * (x * x + z * z))
            ox, oy, oz = SanitizeEuler(ox, oy, oz)
            ox = ox * rad2Deg
            oy = oy * rad2Deg
            oz = oz * rad2Deg
			return ox, oy, oz
		else
            local ox = half_pi
            local oy = math.atan2(2 * (x * y - w * z), 1 - 2 * (y * y + z * z))
            local oz = 0
			ox, oy, oz = SanitizeEuler(ox, oy, oz)
            ox = ox * rad2Deg
            oy = oy * rad2Deg
            oz = oz * rad2Deg
			return ox, oy, oz
		end
	else
        local ox = -half_pi
        local oy = math.atan2(-2 * (x * y - w * z), 1 - 2 * (y * y + z * z))
        local oz = 0
		ox, oy, oz = SanitizeEuler(ox, oy, oz)
        ox = ox * rad2Deg
        oy = oy * rad2Deg
        oz = oz * rad2Deg
        return ox, oy, oz	
	end
end




M.updateIMU = function(gx, gy, gz, ax, ay, az, dt)
    local recipNorm
    local halfvx
    local halfvy
    local halfvz
    local halfex
    local halfey
    local halfez

    if dt > 0 then -- dt in sec
        recipSampleFreq = dt
    else
        recipSampleFreq = 1 / sampleFreq
    end

    if not initalised then
        doBruteForceInitialisation(ax, ay, az)
    end

    -- Compute feedback only if accelerometer measurement valid (NaN in accelerometer normalisation)
    if (ax ~= 0 and ay ~= 0 and az ~= 0) then
      -- Normalise accelerometer measurement
      recipNorm = (ax * ax + ay * ay + az * az) ^ -0.5
      ax = ax * recipNorm
      ay = ay * recipNorm
      az = az * recipNorm

      -- Estimated direction of gravity and vector perpendicular to magnetic flux
      halfvx = q1 * q3 - q0 * q2
      halfvy = q0 * q1 + q2 * q3
      halfvz = q0 * q0 - 0.5 + q3 * q3

      -- Error is sum of cross product between estimated and measured direction of gravity
      halfex = ay * halfvz - az * halfvy
      halfey = az * halfvx - ax * halfvz
      halfez = ax * halfvy - ay * halfvx

      -- Compute and apply integral feedback if enabled
      if (twoKi > 0.0) then
        integralFBx = integralFBx + twoKi * halfex * recipSampleFreq -- integral error scaled by Ki
        integralFBy = integralFBy + twoKi * halfey * recipSampleFreq
        integralFBz = integralFBz + twoKi * halfez * recipSampleFreq
        gx = gx + integralFBx --apply integral feedback
        gy = gy + integralFBy
        gz = gz + integralFBz
      else
        integralFBx = 0.0 -- prevent integral windup
        integralFBy = 0.0
        integralFBz = 0.0
      end
      -- Apply proportional feedback
      gx = gx + twoKp * halfex
      gy = gy + twoKp * halfey
      gz = gz + twoKp * halfez
    end

    -- Integrate rate of change of quaternion
    gx = gx * 0.5 * recipSampleFreq -- pre-multiply common factors
    gy = gy * 0.5 * recipSampleFreq
    gz = gz * 0.5 * recipSampleFreq
    local qa = q0
    local qb = q1
    local qc = q2
    q0 = q0 + (-qb * gx - qc * gy - q3 * gz)
    q1 = q1 + (qa * gx + qc * gz - q3 * gy)
    q2 = q2 + (qa * gy - qb * gz + q3 * gx)
    q3 = q3 + (qa * gz + qb * gy - qc * gx)

    -- Normalise quaternion
    recipNorm = (q0 * q0 + q1 * q1 + q2 * q2 + q3 * q3) ^ -0.5
    q0 = q0 * recipNorm
    q1 = q1 * recipNorm
    q2 = q2 * recipNorm
    q3 = q3 * recipNorm

    -- return values
    return q0, q1, q2, q3

end

return M




