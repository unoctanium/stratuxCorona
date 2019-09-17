-- see: https://github.com/TKJElectronics/Example-Sketch-for-IMU-including-Kalman-filter/blob/master/IMU/MPU6050_HMC5883L/MPU6050_HMC5883L.ino

local Kalman = require("scripts.modules.kalmanFilter")

local M = {}

---
--- private properties
---
local sampleFrequency = 60
local samplePeriod = 1 / sampleFrequency

local retsrictPitch = true -- if false: restrict roll to [-90;+90]

local kalmanXParams = {
    qAngle= 0.001,
    qBias = 0.003,
    rMeasure = 0.03,
    angle = 0.0,
    bias = 0.0,
    rate = 0.0
}

local kalmanYParams = {
    qAngle= 0.001,
    qBias = 0.003,
    rMeasure = 0.03,
    angle = 0.0,
    bias = 0.0,
    rate = 0.0
}

-- local kalmanZParams = {
--     qAngle= 0.001,
--     qBias = 0.003,
--     rMeasure = 0.03,
--     angle = 0.0,
--     bias = 0.0,
--     rate = 0.0
-- }


local kalmanX = Kalman.new(kalmanXParams)
local kalmanY = Kalman.new(kalmanYParams)
--local kalmanZ = Kalman.new(kalmanZParams)

local roll, pitch, yaw; --Roll and pitch are calculated using the accelerometer while yaw is calculated using the magnetometer

---
--- helpers
---
local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943


--
-- Private Methods
--

local function updatePitchRoll(ax, ay, az)
    -- Source: http://www.freescale.com/files/sensors/doc/app_note/AN3461.pdf eq. 25 and eq. 26
    -- atan2 outputs the value of -π to π (radians) - see http://en.wikipedia.org/wiki/Atan2
    --It is then converted from radians to degrees
    if restrictPitch then
        roll = math.atan2(ay, az) * rad2Deg
        pitch = math.atan(-ax / math.sqrt(ay * ay + az * az)) * rad2Deg
    else
        roll = math.atan(ay / math.sqrt(ax * ax + az * az)) * rad2Deg
        pitch = math.atan2(-ax, az) * rad2Deg
    end
end


-- local magGain0, magGain1, magGain2
-- local magOffset0, magOffset1, magOffset2
-- local kalAngleX, kalAngleY, kalAngleZ

--[[
local function updateYaw(mx, my, mz) 
    -- See: http://www.freescale.com/files/sensors/doc/app_note/AN4248.pdf
    mx = mx * -1 -- Invert axis - this it done here, as it should be done after the calibration
    mz = mz * -1

    mx = mx * magGain0
    my = my * magGain1
    mz = mz * magGain2

    mx = mx - magOffset0
    my = my - magOffset1
    mz = mz - magOffset2

    local rollAngle = kalAngleX * deg2Rad
    local pitchAngle = kalAngleY * deg2Rad

    local Bfy = mz * math.sin(rollAngle) - my * math.cos(rollAngle)
    local Bfx = mx * math.cos(pitchAngle) + my * math.sin(pitchAngle) * math.sin(rollAngle) + mz * math.sin(pitchAngle) * math.cos(rollAngle)
    yaw = math.atan2(-Bfy, Bfx) * rad2Deg

    yaw = yaw * -1
end
--]]


--
-- Public Methods
--

--
-- must be called by parent upon creation
--
M.create = function()
    updatePitchRoll(0, 0, 0)
    --updateYaw(0, 0, 0)
    kalmanX:setAngle(roll) -- First set roll starting angle
    kalmanY.setAngle(pitch) -- Then pitch
    --kalmanZ.setAngle(yaw) -- And finally yaw
end


M.update = function(ax, ay, az, gx, gy, gz, f)
    -- Roll and pitch estimation
    updatePitchRoll(ax, ay, az)
    local gyroXrate = gx / 131.0 -- Convert to deg/s
    local gyroYrate = gy / 131.0 -- Convert to deg/s

    local kalAngleX = kalmanX.getAngle(roll, gx, samplePeriod) -- Calculate the angle using a Kalman filter
    local kalAngleY = kalmanY.getAngle(pitch, gy, samplePeriod)
    return roll, pitch, yaw
end


M.delete = function()
end

return M
