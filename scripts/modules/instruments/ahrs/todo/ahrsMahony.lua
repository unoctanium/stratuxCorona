-- source: https://github.com/softwarenerd
-- source https://github.com/xioTechnologies/Open-Source-AHRS-With-x-IMU
-- https://github.com/psiphi75/ahrs

local M = {}


---
--- private properties
---
local sampleFrequency = 60
local samplePeriod = 1 / sampleFrequency
local kp = 2.0 * 9.5 -- proportional gain
local ki = 2.0 * 0.05 -- integral gain
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
    -- roll, pitch,yaw = phi, theta, psi
    --print(roll, pitch, yaw)
    return roll * rad2Deg, pitch * rad2Deg, yaw * rad2Deg
end


--
-- Update IMU with Mahony
--
local function updateIMU(_ax, _ay, _az, _gx, _gy, _gz, freq)
    local norm
    local vx, vy, vz
    local ex, ey, ez
    local pa, pb, pc

    local ax, ay, az = _ax, _ay, _az
    local gx, gy, gz = _gx, _gy, _gz
    
    -- Normalise accelerometer measurement
    norm = math.sqrt(ax * ax + ay * ay + az * az)

    -- only calculate if norm != 0 to avoid NaN
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
