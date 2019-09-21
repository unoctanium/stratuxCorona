local M = {}

--local privateVariables
local displayGroup
local x, y, width, height
--local centerX, centerY

-- display Modules
local attitudeIndicator = require("scripts.modules.instruments.ahrs.attitudeIndicator")
local slipskidIndicator = require("scripts.modules.instruments.ahrs.slipskidIndicator")
local airspeedTape = require("scripts.modules.instruments.ahrs.airspeedTape")
local altitudeTape = require("scripts.modules.instruments.ahrs.altitudeTape")
local selectedSpeedField = require("scripts.modules.instruments.ahrs.selectSpeedField")
local selectedAltitudeField = require("scripts.modules.instruments.ahrs.selectAltitudeField")
local selectedMinAltitudeField = require("scripts.modules.instruments.ahrs.selectMinAltitudeField")
local selectedMinSpeedField= require("scripts.modules.instruments.ahrs.selectMinSpeedField")
local hudOverlay = require("scripts.modules.instruments.ahrs.hudOverlay")


--local privateFunction = function() end

--
-- Event handlers
--
local function onAhrsRollPitchEvent( event )
    attitudeIndicator:update(event.roll, event.pitch)
end

--
-- called by parent upon scene creation
--
M.create = function (self, _displayGroup, _x, _y, _width, _height)

    -- set private variables
    x, y, width, height = _x, _y, _width, _height
    --centerX, centerY = x + width/2, y + height/2
    displayGroup = _displayGroup

    -- paint test box
    -- local box = display.newRect(displayGroup, x, y, width, height)
    -- box:setFillColor(1,0,0,1)
    -- box:setStrokeColor(0,0,0,0)
    -- box.strokeWidth = 0


    -- Add Event Listener
    Runtime:addEventListener("ahrsRollPitch", onAhrsRollPitchEvent)

    -- create displayModules from back to front
    attitudeIndicator:create(displayGroup, x, y, width, height, x, y+height/18, width*5/9, height*6/9, height*5/9) 
    airspeedTape:create(displayGroup, x-width/2+width/9*1, y, width/9*2, height/9*7)
    altitudeTape:create(displayGroup, x+width/2-width/9*1, y, width/9*2, height/9*7)
    slipskidIndicator:create(displayGroup, x, y+height/2-height/9*0.5, width/9*3.75, height/9*1) 
    selectedSpeedField:create(displayGroup, x-width/2+width/9*1, y-height/2+height/9*0.5, width/9*2, height/9*1)
    selectedAltitudeField:create(displayGroup, x+width/2-width/9*1, y-height/2+height/9*0.5, width/9*2, height/9*1)
    selectedMinAltitudeField:create(displayGroup, x-width/2+width/9*1, y+height/2-height/9*0.5, width/9*2, height/9*1)
    selectedMinSpeedField:create(displayGroup, x+width/2-width/9*1, y+height/2-height/9*0.5, width/9*2, height/9*1)
    
    -- top layer:
    hudOverlay:create(displayGroup, x, y, width, height)

end

--
-- Called by parent upon destroy
--
M.destroy = function()
    hudOverlay:destroy()
    selectedMinSpeedFields:destroy()
    selectedMinAltitudeField:destroy()
    selectedSpeedField:destroy()
    selectedAltitudeField:destroy()
    slipskidIndicator:destroy()
    airspeedTape:destroy()
    altitudeTape:destroy()
    attitudeIndicator:destroy()
end

return M
