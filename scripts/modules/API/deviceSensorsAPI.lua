-- try this: https://github.com/ozzmaker/BerryIMU/blob/master/gyro_accelerometer_tutorial03_kalman_filter/gyro_accelerometer_tutorial03.c

local uiElements = require("scripts.modules.uiElements")

--local madgwick = require("scripts.modules.ahrsMadgwick")
local mahony = require("scripts.modules.ahrsMahony")
--local kalman = require("scripts.modules.ahrsKalman")


local M = {}
---
--- public properties
---
M.useDeviceSensors = true

---
--- private properties
---
local DeviceSensors = {
    ax=0, ay=0, az=0, gx=0, gy=0, gz=0, mh=0, th=0,
    frequency = 60
}


---
--- Local functions
---



--
-- call to reset device Orientatios pitch offset
--
local devPitchOffset = 0.0
local function resetDeviceIMU()
    local d = DeviceSensors
    --local roll, pitch, yaw = madgwick.update(d.ax, d.ay, d.az, d.gx, d.gy, d.gz, d.frequency)
    local roll, pitch, yaw = mahony.update(d.ax, d.ay, d.az, d.gx, d.gy, d.gz, d.frequency)
    --local roll, pitch, yaw = kalman.update(d.ax, d.ay, d.az, d.gx, d.gy, d.gz, d.frequency)
    -- iphone roll correction
    roll = (roll + 180) % 360
    if roll > 180 then
        roll = -1 * (360 - roll)
    end
    devPitchOffset = - pitch
end



---
--- calculate IMU based on Device Gyro and accel
---
local function calculateDeviceIMU()
    local d = DeviceSensors
    --local roll, pitch, yaw = madgwick.update(d.ax, d.ay, d.az, d.gx, d.gy, d.gz, d.frequency)
    local roll, pitch, yaw = mahony.update(d.ax, d.ay, d.az, d.gx, d.gy, d.gz, d.frequency)
    --local roll, pitch, yaw = kalman.update(d.ax, d.ay, d.az, d.gx, d.gy, d.gz, d.frequency)
    
    -- iphone roll correction
    roll = (roll + 180) % 360
    if roll > 180 then
        roll = -1 * (360 - roll)
    end
    local attitudeEvent = { 
        name="ahrsAttitudeDevice", 
        roll=roll, 
        pitch=(pitch + devPitchOffset), 
        yaw=yaw 
    }
    Runtime:dispatchEvent( attitudeEvent )    
end

---
--- Handle Device Gyroscope updates
---
local function onGyroscopeUpdate( event )
    DeviceSensors.gx = event.xRotation
    DeviceSensors.gy = event.zRotation
    DeviceSensors.gz = event.yRotation
    calculateDeviceIMU()
end

---
--- Handle Device Accelerometer updates
---
local function onAccelerometerUpdate( event )
    -- swap y and -z for iPhone correction
    DeviceSensors.ax = event.xRaw    
    DeviceSensors.ay = event.zRaw    
    DeviceSensors.az = event.yRaw    
    calculateDeviceIMU()
end


---
--- Member functions
---

--
-- Must be called by parent upon creation
--
M.create = function() 

    -- set up device sensors if required
    if M.useDeviceSensors then
        -- Set up gyroscope if the sensor exists 
        if system.hasEventSource( "gyroscope" ) then
            system.setGyroscopeInterval(DeviceSensors.frequency)
            Runtime:addEventListener("gyroscope", onGyroscopeUpdate)
        else
            uiElements:messageToast("Gyroscope events not supported on this device")
        end
        -- Set up accelerometer if the sensor exists
        if system.hasEventSource( "accelerometer" ) then
            system.setAccelerometerInterval(DeviceSensors.frequency)
            Runtime:addEventListener("accelerometer", onAccelerometerUpdate)
        else
            uiElements:messageToast("Accelerometer events not supported on this device")
        end
    end

    
end

--
-- Must be called by parent upon poll update
--
M.update = function()
end

--
-- reset orientation
--
M.reset = function()
    resetDeviceIMU()
end

--
-- Must be called by parent upon destruction
--
M.destroy = function()
    if M.useDeviceSensors then
        Runtime:removeEventListener("gyroscope", onGyroscopeUpdate)
        Runtime:removeEventListener("accelerometer", onAccelerometerUpdate)
    end
end



return M
