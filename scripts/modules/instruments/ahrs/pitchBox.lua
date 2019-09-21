local M = {}

--local privateVariables
local displayGroup
local x, y, width, height
--local centerX, centerY
local pitchClipX, pitchClipY, pitchClipW, pitchClipH
local pitchLadderWidth

local contentGroup
local clippingGroup
local pitchContentGroup
local pitchClippingGroup

-- parameters
M.skyRectColor = {0/255, 150/255, 201/255, 1}
M.groundRectColor = {151/255, 99/255, 0/255, 1}
M.horizonLineStrokeWidth = 3
M.pitchFOV = 45 -- Field ov view (pitch / hight) in deg
M.debugTouch = true

-- Helper
local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943

-- Event Handler
local function onDebugTouch(event)
    if event.x > pitchClipX+pitchClipH/2 or event.x < pitchClipX-pitchClipH/2 then
        return
    end
    local roll, pitch = 0, 0
    if event.phase == "moved" then
        roll = (event.x - event.xStart) * 90 / (width/2)
        pitch = -(event.y - event.yStart) * 90 / (height/2)
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


--
-- called by parent upon scene creation
--
M.create = function (self, _displayGroup, _x, _y, _width, _height, _pitchClipX, _pitchClipY, _pitchClipW, _pitchClipH, _pitchLadderWidth)
    -- set private variables
    x, y, width, height = _x, _y, _width, _height
    pitchClipX, pitchClipY = _pitchClipX, _pitchClipY
    pitchClipW, pitchClipH = _pitchClipW, _pitchClipH
    pitchLadderWidth = _pitchLadderWidth
    --centerX, centerY = x + width/2, y + height/2
    displayGroup = _displayGroup

    -- create group for horizonBox
    contentGroup = display.newGroup()
    contentGroup.anchorChildren = true

    --create bounding group for clipping and positioning
    clippingGroup = display.newContainer(displayGroup, width, height)
    clippingGroup.anchorChildren = true
    clippingGroup:translate(x, y)
    clippingGroup:insert( contentGroup )

    -- Set Scaling parameters
    local horizonBoxWidth = math.sqrt(width*width + height*height)
    local horizonBoxHeight = horizonBoxWidth *360 / M.pitchFOV

    -- create horizons Skybox
    local skyRect = display.newRect(contentGroup, 0, -horizonBoxHeight/4, horizonBoxWidth, horizonBoxHeight/2)
    skyRect:setFillColor(unpack(M.skyRectColor))
    skyRect.strokeWidth = 0

    -- create horizons Groundbox
    local gndRect = display.newRect(contentGroup, 0, horizonBoxHeight/4, horizonBoxWidth, horizonBoxHeight/2)
    gndRect:setFillColor(unpack(M.groundRectColor))
    gndRect.strokeWidth = 0

    -- Create Horizon line
    local horizonLine = display.newLine(contentGroup, -horizonBoxWidth/2, 0, horizonBoxWidth/2, 0)
    horizonLine:setStrokeColor(1,1,1,1)
    horizonLine.strokeWidth = M.horizonLineStrokeWidth

    -- create group for PitchLadder
    pitchContentGroup = display.newGroup()
    
    --create bounding group for clipping and positioning of Pitch Scale
    pitchClippingGroup = display.newContainer(displayGroup, _pitchClipW, _pitchClipH)
    pitchClippingGroup:translate(_pitchClipX, _pitchClipY)
    pitchClippingGroup:insert( pitchContentGroup )
    pitchContentGroup:translate(x - _pitchClipX, y - _pitchClipY)

    -- set Line Parameters
    local lineLength10 = _pitchLadderWidth / 2
    local lineLength05 = lineLength10 / 2
    local lineLength25 = lineLength05 / 2
    local lineSpacing10 = height * 10 / (M.pitchFOV)
    local lineWidth10 = 3
    local lineWidth05 = 2
    local lineWidth25 = 1
    local labelSize = width / 20
    local labelFont = native.systemFont
    local labelSpacer = labelSize * 1.1 -- distance of center of label from end of hairline

    -- Ladder Lines and labels ( no zero line )
    for i = 0, 9 do

        if i ~= 0 then
            local line10 = display.newLine(pitchContentGroup, -lineLength10/2, i * lineSpacing10, lineLength10/2, i * lineSpacing10)
            line10:setStrokeColor(1, 1, 1, 1)
            line10.strokeWidth = lineWidth10
            local line10n = display.newLine(pitchContentGroup, -lineLength10/2, -i * lineSpacing10, lineLength10/2, -i * lineSpacing10)
            line10n:setStrokeColor(1, 1, 1, 1)
            line10n.strokeWidth = lineWidth10
            local leftLabel = display.newText( pitchContentGroup, string.format( "-%d", i*10 ), - lineLength10/2 - labelSpacer , i * lineSpacing10, labelFont, labelSize ) 
            leftLabel:setFillColor(1,1,1)
            leftLabel.anchorX = 0.5
            leftLabel.anchorY = 0.5
            local rightLabel = display.newText( pitchContentGroup, string.format( "-%d", i*10 ), lineLength10/2 + labelSpacer , i * lineSpacing10, labelFont, labelSize ) 
            rightLabel:setFillColor(1,1,1)
            rightLabel.anchorX = 0.5
            rightLabel.anchorY = 0.5
            local leftLabeln = display.newText( pitchContentGroup, string.format( "%d", i*10 ), - lineLength10/2 - labelSpacer , - i * lineSpacing10, labelFont, labelSize ) 
            leftLabeln:setFillColor(1,1,1)
            leftLabeln.anchorX = 0.5
            leftLabeln.anchorY = 0.5
            local rightLabeln = display.newText( pitchContentGroup, string.format( "%d", i*10 ), lineLength10/2 + labelSpacer , - i * lineSpacing10, labelFont, labelSize ) 
            rightLabeln:setFillColor(1,1,1)
            rightLabeln.anchorX = 0.5
            rightLabeln.anchorY = 0.5
        end
        
        local line25 = display.newLine(pitchContentGroup, -lineLength25/2, i * lineSpacing10 + lineSpacing10/4, lineLength25/2, i * lineSpacing10 + lineSpacing10/4)
        line25:setStrokeColor(1, 1, 1, 1)
        line25.strokeWidth = lineWidth25
        local line05 = display.newLine(pitchContentGroup, -lineLength05/2, i * lineSpacing10 + lineSpacing10/2, lineLength05/2, i * lineSpacing10 + lineSpacing10/2)
        line05:setStrokeColor(1, 1, 1, 1)
        line05.strokeWidth = lineWidth05
        local line75 = display.newLine(pitchContentGroup, -lineLength25/2, i * lineSpacing10 + lineSpacing10*3/4, lineLength25/2, i * lineSpacing10 + lineSpacing10*3/4)
        line75:setStrokeColor(1, 1, 1, 1)
        line75.strokeWidth = lineWidth25
        local line25n = display.newLine(pitchContentGroup, -lineLength25/2, -i * lineSpacing10 - lineSpacing10/4, lineLength25/2, -i * lineSpacing10 - lineSpacing10/4)
        line25n:setStrokeColor(1, 1, 1, 1)
        line25n.strokeWidth = lineWidth25
        local line05n = display.newLine(pitchContentGroup, -lineLength05/2, -i * lineSpacing10 - lineSpacing10/2, lineLength05/2, -i * lineSpacing10 - lineSpacing10/2)
        line05n:setStrokeColor(1, 1, 1, 1)
        line05n.strokeWidth = lineWidth05
        local line75n = display.newLine(pitchContentGroup, -lineLength25/2, -i * lineSpacing10 - lineSpacing10*3/4, lineLength25/2, -i * lineSpacing10 - lineSpacing10*3/4)
        line75n:setStrokeColor(1, 1, 1, 1)
        line75n.strokeWidth = lineWidth25        
    end -- of ladder lines and labels

    -- Reference line
    local referenceLineStrokeWidth = 5
    local referenceLineLeft = display.newLine(displayGroup, x-_pitchLadderWidth/2, y, x-_pitchLadderWidth/4, y)
    referenceLineLeft:setStrokeColor(1,1,0)
    referenceLineLeft.strokeWidth = referenceLineStrokeWidth
    local referenceLineRight = display.newLine(displayGroup, x+_pitchLadderWidth/4, y, x+_pitchLadderWidth/2, y)
    referenceLineRight:setStrokeColor(1,1,0)
    referenceLineRight.strokeWidth = referenceLineStrokeWidth
    local referenceLineCircle = display.newCircle(displayGroup, x, y, lineSpacing10/4)
    referenceLineCircle:setStrokeColor(1,1,0)
    referenceLineCircle:setFillColor(0,0,0,0)
    referenceLineCircle.strokeWidth = referenceLineStrokeWidth

    -- Roll marker
    local rollMarkerWidth = _pitchLadderWidth / 9
    local rollMarkerVertices = { 0,0, -rollMarkerWidth/2,rollMarkerWidth, rollMarkerWidth/2,rollMarkerWidth }
    local rollMarker = display.newPolygon(displayGroup, x, y-height/2/9*6, rollMarkerVertices)
    rollMarker:setFillColor(1,1,1,1)
    rollMarker.strokeWidth = 0

    -- Add Debug Touch Handler
    if M.debugTouch then
        clippingGroup:addEventListener( "touch", onDebugTouch )
    end


end


--
-- called by parent to update Modules display content
--
-- positive roll, pitch == left, up
M.update = function (self, roll, pitch) 
    -- move horizon
    contentGroup.x = 0
    contentGroup.y = 0
    contentGroup.rotation = -roll
    local traX = -math.sin(-roll * deg2Rad) * pitch * height / M.pitchFOV 
    local traY = math.cos(-roll * deg2Rad) * pitch * height / M.pitchFOV 
    contentGroup:translate(traX, traY)
    -- move pitchscale
    pitchContentGroup.x = x - pitchClipX
    pitchContentGroup.y = y - pitchClipY
    pitchContentGroup.rotation = -roll
    pitchContentGroup:translate(traX, traY)
end


--
-- called by Parent upon resizing
--
M.resize = function (self, _displayGroup, _x, _y, _width, _height, _pitchClipX, _pitchClipY, _pitchClipW, _pitchClipH, _pitchLadderWidth) 
    M:destroy()
    M:create(_displayGroup, _x, _y, _width, _height, _pitchClipX, _pitchClipY, _pitchClipW, _pitchClipH, _pitchLadderWidth)
end

--
-- called by Parent upon destruction of Module
--
M.destroy = function ()
    clippingGroup:removeSelf() 
    clippingGroup = nil
    pitchClippingGroup:removeSelf()
    pitchClippingGroup = nil

    -- remove Debug Touch Handler
    if M.debugTouch then
        clippingGroup:removeEventListener( "touch", onDebugTouch )
    end

end

return M