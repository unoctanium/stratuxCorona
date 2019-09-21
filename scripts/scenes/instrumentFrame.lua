local composer = require("composer")
local scene = composer.newScene()

local ahrs = require("scripts.modules.instruments.ahrs.display")
local hsi = require("scripts.modules.instruments.hsi.display")

local M={}

--
-- Calculate all Metrics
--
local function calculateMetrics()

  M.width = display.safeActualContentWidth
  M.height = display.safeActualContentHeight
  
  -- Manage extra long devices: insert letterbox
  if M.height / 2 >  M.width then
    local letterBoxFiller = M.height/2 - M.width
    M.height = M.height - letterBoxFiller
    M.top = display.safeScreenOriginY + letterBoxFiller
  else
    M.top = display.safeScreenOriginY
  end
  
  M.bottom = M.top + M.height
  M.left = display.safeScreenOriginX
  M.right = M.left + M.width

  M.halfWidth = M.width / 2
  M.halfHeight = M.height / 2
  M.centerX = M.left + M.halfWidth
  M.centerY = M.top + M.halfHeight

  -- Debug Output
  -- print (M.left, M.top, M.right, M.bottom)
  -- print (M.width, M.height)
  -- print(M.halfWidth, M.halfHeight, M.centerX, M.centerY)
end



--
-- Runs at every scene creation before visible
--
function scene:create(event)
  local sceneGroup = self.view
  -- calculate screen metrics for adaptive layout
  calculateMetrics()
  -- define groups
  -- define display objects
  -- insert objects/groups into scene view
  ahrs:create(sceneGroup, M.centerX, M.centerY - M.halfHeight/2, M.width, M.halfHeight)
  hsi:create(sceneGroup, M.left, M.centerY, M.width, M.halfHeight)

  -- load scene specific audio
  -- touch handlers



  

end



--
-- Runs before & after screen shows
--
function scene:show(event)
  local sceneGroup, phase = self.view, event.phase
  if (phase == "will") then
    -- position elements
  elseif (phase == "did") then
    -- timers, transitions, animations
    -- play scene specific audio
    -- runtime event listeners
  end
end



--
-- Runs before & after screen hides
--
function scene:hide(event)
  local sceneGroup, phase = self.view, event.phase
  if (phase == "will") then
    -- remove native UI objects
    -- remove runtime listeners
    -- stop audio, timers, transitions, animations
  elseif (phase == "did") then
    -- composer.removeScene("scene1") -- force screen removal?
  end
end



--
-- Runs directly before scene removal
--
function scene:destroy(event)
  local sceneGroup = self.view
  
end



--
-- Add Event Listeners for Scene Management
--
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
return scene
