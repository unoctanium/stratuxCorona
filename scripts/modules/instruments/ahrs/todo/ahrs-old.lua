-- Stuff here runs only once
-- Setup dependencies, vars, constants, etc
local composer = require("composer")
local uiElements = require("scripts.modules.uiElements")

--@@ODO Select here
--local deviceSensorsAPI = require("scripts.modules.deviceSensorsAPI")
--local stratuxAPI = require("scripts.modules.stratuxAPI")

local attitude = require("scripts.modules.attitude")


local scene = composer.newScene()


-- Test AHRS with touch

local function onResetDeviceAHRSOrientation(event)
  if event.phase == "ended" then
    deviceSensorsAPI:reset()
  end
end


local function onTestAHRS(event)
  if event.phase == "moved" then
    local roll = -(event.x - event.xStart) * 90 / (display.contentWidth/2)
    local pitch = (event.y - event.yStart) * 90 / (display.contentHeight/2) 
    attitude:update(roll, -pitch, 0)
  elseif event.phase == "ended" then
    attitude:update(0,0)
  end
end



local function onUpdateAttitude( event)
  --print (event.pitch, event.roll, event.yaw)
  attitude:update(event.roll, event.pitch, event.yaw)
  --attitude:debugUpdate(event.pitch , event.roll, event.yaw)
  
end



-- Runs at every scene creation before visible
function scene:create(event)
  local sceneGroup = self.view
  -- pause physics
  -- define groups
  -- define display objects
  -- insert objects/groups into scene view
  -- load scene specific audio
  -- touch handlers
  -- create modules

  --@@ODO Select here
  --deviceSensorsAPI:create()
  --stratuxAPI:create()
end



-- Runs before & after screen shows
function scene:show(event)
  local sceneGroup, phase = self.view, event.phase
  if (phase == "will") then
    -- position elements

    attitude:create(display.contentCenterX, 340, 800, 800)
    --attitude:debugUpdate(0, 0, 0)
    uiElements:create(display.contentCenterX, 100)

  elseif (phase == "did") then
    -- timers, transitions, animations
    -- start physics
    -- play scene specific audio
    -- runtime event listeners
  end
end



-- Runs before & after screen hides
function scene:hide(event)
  local sceneGroup, phase = self.view, event.phase
  if (phase == "will") then
    -- remove native UI objects
    -- remove runtime listeners
    -- pause physics
    -- stop audio, timers, transitions, animations
  elseif (phase == "did") then
    -- composer.removeScene("scene1") -- force screen removal?
  end
end



-- Runs directly before scene removal
function scene:destroy(event)
  local sceneGroup = self.view
  -- destroy scene specific audio
  -- destroy modules

  --@@ODO Select here
  --stratuxAPI:destroy()
  --deviceSensorsAPI:destroy()
end




---
--- Handler for unhandled errors
---
local function onUnhandledError( event )
  local iHandledTheError = true
  if iHandledTheError then
      print( "Handling the unhandled error", event.errorMessage )
  else
      print( "Not handling the unhandled error", event.errorMessage )
  end
  return iHandledTheError
end



-- Add scene event listeners
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)


-- Add ahrs update listeners
Runtime:addEventListener( "ahrsAttitudeDevice", onUpdateAttitude )
Runtime:addEventListener( "ahrsAttitudeStratux", onUpdateAttitude )


-- Add test touch listener
--Runtime:addEventListener( "touch", onResetDeviceAHRSOrientation )
Runtime:addEventListener( "touch", onTestAHRS )



-- Add listener for unhandles runtime errors
Runtime:addEventListener("unhandledError", onUnhandledError)

return scene
