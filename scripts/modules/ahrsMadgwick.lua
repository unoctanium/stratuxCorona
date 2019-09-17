-- source: https://github.com/softwarenerd
-- source https://github.com/xioTechnologies/Open-Source-AHRS-With-x-IMU
-- https://github.com/psiphi75/ahrs

local M = {}


---
--- private properties
---
local _sampleFrequency = 60
local _samplePeriod = 1.0 / _sampleFrequency

-- 2 * proportional gain - lower numbers are smoother, but take longer to get to correct attitude.
local _beta = 0.6045997880780726 -- algo gain parameter
--local _beta = 0.4 -- algo gain parameter


--
-- AHRS Quaternion
--
local _q0 = 1
local _q1 = 0
local _q2 = 0
local _q3 = 0


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

    local w2 = _q0 * _q0
    local x2 = _q1 * _q1
    local y2 = _q2 * _q2
    local z2 = _q3 * _q3
    local unitLength = w2 + x2 + y2 + z2     -- Normalised == 1, otherwise correction divisor.
    local abcd = _q0 * _q1 + _q2 * _q3
    local eps = 1e-7                        -- TODO: pick from your math lib instead of hardcoding.
    if abcd > (0.5 - eps) * unitLength then
        roll = 0.0
        pitch = math.pi
        yaw = 2.0 * math.atan2(_q2, _q0)
    elseif abcd < (-0.5 + eps) * unitLength then
        roll  = 0.0
        pitch = -math.pi
        yaw   = -2.0 * math.atan2(_q2, _q0)
    else
        local adbc = _q0 * _q3 - _q1 * _q2
        local acbd = _q0 * _q2 - _q1 * _q3
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

    local ax, ay, az = _ax, _ay, _az
    local gx, gy, gz = _gx, _gy, _gz

    local norm
    local s0, s1, s2, s3
    local qDot1, qDot2, qDot3, qDot4
    local _2q0, _2q1, _2q2, _2q3, _4q0, _4q1, _4q2 ,_8q1, _8q2, q0q0, q1q1, q2q2, q3q3

    -- Rate of change of quaternion from gyroscope
    qDot1 = 0.5 * (-_q1 * gx - _q2 * gy - _q3 * gz)
    qDot2 = 0.5 * (_q0 * gx + _q2 * gz - _q3 * gy)
    qDot3 = 0.5 * (_q0 * gy - _q1 * gz + _q3 * gx)
    qDot4 = 0.5 * (_q0 * gz + _q1 * gy - _q2 * gx)

    -- Normalise accelerometer measurement
    norm = math.sqrt(ax * ax + ay * ay + az * az)

    -- only calculate if norm != 0 to avoid NaN
    if norm ~=0 then
        norm = 1.0 / norm -- use reciprocal for division
        ax = ax * norm
        ay = ay * norm
        az = az * norm

        -- Auxiliary variables to avoid repeated arithmetic
        _2q0 = 2.0 * _q0
        _2q1 = 2.0 * _q1
        _2q2 = 2.0 * _q2
        _2q3 = 2.0 * _q3
        _4q0 = 4.0 * _q0
        _4q1 = 4.0 * _q1
        _4q2 = 4.0 * _q2
        _8q1 = 8.0 * _q1
        _8q2 = 8.0 * _q2
        q0q0 = _q0 * _q0
        q1q1 = _q1 * _q1
        q2q2 = _q2 * _q2
        q3q3 = _q3 * _q3
    
        -- Gradient decent algorithm corrective step
        s0 = _4q0 * q2q2 + _2q2 * ax + _4q0 * q1q1 - _2q1 * ay
        s1 = _4q1 * q3q3 - _2q3 * ax + 4.0 * q0q0 * _q1 - _2q0 * ay - _4q1 + _8q1 * q1q1 + _8q1 * q2q2 + _4q1 * az
        s2 = 4.0 * q0q0 * _q2 + _2q0 * ax + _4q2 * q3q3 - _2q3 * ay - _4q2 + _8q2 * q1q1 + _8q2 * q2q2 + _4q2 * az
        s3 = 4.0 * q1q1 * _q3 - _2q1 * ax + 4.0 * q2q2 * _q3 - _2q2 * ay

        -- normalise step magnitude
        norm = math.sqrt(s0 * s0 + s1 * s1 + s2 * s2 + s3 * s3)
        norm = 1.0 / norm
        s0 = s0 * norm
        s1 = s1 * norm
        s2 = s2 * norm
        s3 = s3 * norm
 
        -- Apply feedback step
        qDot1 = qDot1 - _beta * s0
        qDot2 = qDot1 - _beta * s1
        qDot3 = qDot1 - _beta * s2
        qDot4 = qDot1 - _beta * s3
    end

    -- Integrate rate of change of quaternion to yield quaternion
    _q0 = _q0 + qDot1 * _samplePeriod
    _q1 = _q1 + qDot2 * _samplePeriod
    _q2 = _q2 + qDot3 * _samplePeriod
    _q3 = _q3 + qDot4 * _samplePeriod

    -- Normalise quaternion
    norm = math.sqrt(_q0 * _q0 + _q1 * _q1 + _q2 * _q2 + _q3 * _q3)
    norm = 1.0 / norm
    _q0 = _q0 * norm
    _q1 = _q1 * norm
    _q2 = _q2 * norm
    _q3 = _q3 * norm
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
