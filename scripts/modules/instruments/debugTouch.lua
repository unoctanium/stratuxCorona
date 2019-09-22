local M = {}

local x, y, width, height
local displayGroup


local function fireAttitudeEvent(event)
    local roll, pitch = 0, 0
    if event.phase == "moved" then
        roll = (event.x - event.xStart) * 90 / (width/4)
        pitch = -(event.y - event.yStart) * 90 / (height/4)
    elseif event.phase == "ended" then
        roll, pitch = 0 , 0
    end
    local ahrsRollPitchEvent = { 
        name="ahrsRollPitch", 
        roll=roll, 
        pitch=pitch
    }
    Runtime:dispatchEvent( ahrsRollPitchEvent )  
end

local function fireSpeedEvent(event)
    local speed = 0
    if event.phase == "moved" then
        speed = (event.y - event.yStart) * 180 / (height/2)
    elseif event.phase == "ended" or event.phase == "cancelled" then
        speed = 0
    end
    local ahrsSpeedEvent = { 
        name="ahrsSpeed", 
        speed=speed
    }
    Runtime:dispatchEvent( ahrsSpeedEvent )  
end


local function fireAltitudeEvent(event)
    local altitude = 0
    if event.phase == "moved" then
        altitude = (event.y - event.yStart) * 1000 / (height/2)
    elseif event.phase == "ended" or event.phase == "cancelled" then
        altitude = 0
    end
    local ahrsAltitudeEvent = { 
        name="ahrsAltitude", 
        altitude=altitude
    }
    Runtime:dispatchEvent( ahrsAltitudeEvent )  
end


-- Event Handler
local function onDebugTouch(event)
    -- analyze, which event to fire
    if event.y < height/2 then
        -- ahrs
        if event.x > width/4 and event.x < width*3/4 then
            -- pitchroll
            fireAttitudeEvent(event)
        elseif event.x < width/4 then
            -- speed
            fireSpeedEvent(event)
        else
            -- altitude
            fireAltitudeEvent(event)  
        end
    else
        -- hsi
    end
    
end


--
-- called by parent upon scene creation
--
M.create = function (self, _displayGroup, _x, _y, _w, _h)
    displayGroup = _displayGroup
    x, y, width, height = _x, _y, _w, _h 
    Runtime:addEventListener( "touch", onDebugTouch )
end


--
-- called by Parent upon destruction of Module
--
M.destroy = function ()
    Runtime:removeEventListener( "touch", onDebugTouch )
end


return M

