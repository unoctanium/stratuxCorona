local M = {}

---
--- public properties
---

---
--- private properties
---

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
--- Handle Touch events
---
local function onTouch( event )
    DeviceSensors.gx = event.xRotation
    DeviceSensors.gy = event.zRotation
    DeviceSensors.gz = event.yRotation
    calculateDeviceIMU()
end



---
--- Member functions
---

--
-- Must be called by parent upon creation
--
M.create = function() 
    Runtime:addEventListener( "touch", onTouch )
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
end


return M
