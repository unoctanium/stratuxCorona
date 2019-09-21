-- Stuff here runs only once
-- Setup dependencies, vars, constants, etc
local composer = require("composer")
local Mahony = require("scripts.modules.mahony")

local scene = composer.newScene()

local target
local xValueLabel
local yValueLabel
local zValueLabel
local fpsValueLabel


-- Text parameters
local labelx = 50
local x = 240
local y = 110
local fontSize = 24


-- used to update our Text Color (once per frame)
local frameUpdate = false



-- Runs at every scene creation before visible
function scene:create(event)
  local sceneGroup = self.view
  -- pause physics
  -- define groups
  -- define display objects
  -- insert objects/groups into scene view
  
  -- Draw X and Y axes.
  local xAxis = display.newLine(0, display.contentHeight / 2 + 1, display.contentWidth, display.contentHeight / 2 + 1)
  xAxis:setStrokeColor( 0, 1, 1,255/255 )
  local yAxis = display.newLine(display.contentWidth / 2 + 1, 0, display.contentWidth / 2 + 1, display.contentHeight)
  yAxis:setStrokeColor( 0, 1, 1, 128/255 )

  -- Displays App title
  local title = display.newText( "Gyroscope", 0, 35, native.systemFontBold, 20 )
  title.x = display.contentWidth / 2
  title:setFillColor( 1, 1, 0 )

  target = display.newRect(0,0,150,150)
  target.strokeWidth = 3
  target:setFillColor( 0.8 , 0.2, 0.2, 0.5)
  target:setStrokeColor( 1, 0, 0 )
  target.x = display.contentCenterX
  target.y = display.contentCenterY

  local xHeaderLabel = display.newText( "x rotation = ", labelx, y, native.systemFont, fontSize ) 
  xHeaderLabel:setFillColor(1,1,1)
  xHeaderLabel.anchorX = 0.0

  xValueLabel = display.newText( "0.0", x, y, native.systemFont, fontSize ) 
  xValueLabel:setFillColor(1,1,1)
  y = y + 25
  
  local yHeaderLabel = display.newText( "y rotation = ", labelx, y, native.systemFont, fontSize ) 
  yHeaderLabel.anchorX = 0.0
  
  yValueLabel = display.newText( "0.0", x, y, native.systemFont, fontSize ) 
  yHeaderLabel:setFillColor(1,1,1)
  yValueLabel:setFillColor(1,1,1)
  y = y + 25
  
  local zHeaderLabel = display.newText( "z rotation = ", labelx, y, native.systemFont, fontSize ) 
  zHeaderLabel.anchorX = 0.0
  
  zValueLabel = display.newText( "0.0", x, y, native.systemFont, fontSize ) 
  zHeaderLabel:setFillColor(1,1,1)
  zValueLabel:setFillColor(1,1,1)
  y = y + 25

  local fpsHeaderLabel = display.newText("FPS = ", labelx, y, native.systemFont, fontSize)
  fpsHeaderLabel.anchorX = 0.0

  fpsValueLabel = display.newText( "0", x, y, native.systemFont, fontSize ) 
  fpsHeaderLabel:setFillColor(1,1,1)
  fpsValueLabel:setFillColor(1,1,1)
  y = y + 25

  --[[
  local screenTouchBox = display.newRect(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
  screenTouchBox.isVisible = false
  screenTouchBox.isHitTestable = true
  screenTouchBox:addEventListener("tap", pushCircle)
  --]]
  
  -- Set up the above function to receive gyroscope events if the sensor exists
  if system.hasEventSource( "gyroscope" ) then
    system.setGyroscopeInterval(Mahony.sampleFreq)
  else
    local msg = display.newText( "Gyroscope events not supported on this device", 0, 70, native.systemFontBold, 13 )
	  msg.x = display.contentWidth/2		-- center title
	  msg:setFillColor( 1,1,1 )
  end
  
  
  -- load scene specific audio
  -- touch handlers
end



-- Runs before & after screen shows
function scene:show(event)
  local sceneGroup, phase = self.view, event.phase
  if (phase == "will") then
    -- position elements

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
end


function pushTarget(event)
  target.x = display.contentCenterX
  target.y = display.contentCenterY
  target.rotation = 0
end



local function gameLoop(event)
  -- my looping actions go here
  --myCircle.x = myCircle.x + 1
  fpsValueLabel.text = string.format( "%d", display.fps )
end




-- Display the Gyroscope Values
-- Update the text color once a frame based on sign of the value
local function xyzFormat( obj, value )

	obj.text = string.format( "%1.3f", value )
	
	-- Exit if not time to update text color
	if not frameUpdate then return end
	
	if value < 0.0 then
		-- Only update the text color if the value has changed
		if obj.positive ~= false then 
			obj:setFillColor( 1, 0, 0 )      -- red if negative
			obj.positive = false
			--print("[---]")
		end
	else

		if obj.positive ~= true then 
			obj:setFillColor( 1, 1, 1)   -- white if postive
			obj.positive = true
			--print("+++")
		end

	end
end






-- Called when a gyroscope measurement has been received.
local function XonGyroscopeUpdate( event )

	-- Format and display the measurement values.
	xyzFormat(xValueLabel, event.xRotation)
	xyzFormat(yValueLabel, event.yRotation)
	xyzFormat(zValueLabel, event.zRotation)
	
	-- Move our object based on the measurement values.
  local deltaRadiansY = event.xRotation * event.deltaTime
  local deltaRadiansX = event.yRotation * event.deltaTime
  
  target.x = target.x + deltaRadiansX * display.contentWidth / math.pi
  target.y = target.y + deltaRadiansY * display.contentHeight / math.pi

	-- Rotate the object based based on the degrees rotated around the z-axis.
	local deltaRadiansZ = event.zRotation * event.deltaTime
	local deltaDegreesZ = deltaRadiansZ * (180 / math.pi)
  target:rotate(deltaDegreesZ)

end




-- Called when a gyroscope measurement has been received.
local function XonAccelerometerUpdate( event )

	-- Format and display the measurement values.
	xyzFormat(xValueLabel, event.xGravity)
	xyzFormat(yValueLabel, event.yGravity)
	xyzFormat(zValueLabel, event.zGravity)
  
  local deltaGravityX = event.xRaw * event.deltaTime
  local deltaGravityY = event.zRaw * event.deltaTime

  --target.x = deltaGravityX * display.contentWidth + (display.contentWidth/2)
  target.y = event.zGravity * (display.contentHeight / 2) + (display.contentHeight / 2)
  target.rotation = event.xGravity * -90

  --target.x = display.contentWidth * (1 + event.xGravity) / 2
  --target.y = display.contentHeight * ( 1 + event.zGravity) / 2


end


local hasAccUpdated = false
local hasGyroUpdated = false

local ax, ay, az = 0, 0, 0
local gx, gy, gz = 0, 0, 0
local dta, dtg = 0, 0

local function onImuUpdate ()
  local dt = (dta + dtg) / 2
  Mahony.updateIMU(gx, gy, gz, ax, ay, az, 0)

  local x, y, z
  x, y, z = Mahony.toEulerAngles()
	xyzFormat(xValueLabel, x)
	xyzFormat(yValueLabel, y)
	xyzFormat(zValueLabel, z)

  target.x = z - 180 + display.actualContentWidth / 2
  target.y = y -180 + display.contentHeight / 2
  target.rotation = x

  hasAccUpdated = false
  hasGyroUpdated = false
  ax, ay, az = 0, 0, 0
  gx, gy, gz = 0, 0, 0
  dta, dtg = 0, 0
end

local function onGyroscopeUpdate (event)
  --[[
  dtg = dtg + event.deltaTime
  gx = gx + event.xRotation
  gy = gy + event.yRotation
  gz = gz + event.zRotation
  hasGyroUpdated = true
  if hasAccUpdated then
    onImuUpdate()
  end
  --]]
  gx = event.xRotation
  gy = event.yRotation
  gz = event.zRotation
  onImuUpdate()
end


local function onAccelerometerUpdate (event)
  --[[
  dta = dta + event.deltaTime
  ax = ax + event.xRaw
  ay = ax + event.yRaw
  az = ax + event.zRaw
  hasAccUpdated = true
  if hasGyroUpdated then
    onImuUpdate()
  end
  --]]
  ax = event.xRaw
  ay = event.yRaw
  az =event.zRaw
  onImuUpdate()
end







scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

Runtime:addEventListener("enterFrame", gameLoop)

-- Add Target Push Listener
Runtime:addEventListener( "touch", pushTarget )

-- Add gyroscope listeners
Runtime:addEventListener("gyroscope", onGyroscopeUpdate)
Runtime:addEventListener("accelerometer", onAccelerometerUpdate)




return scene
