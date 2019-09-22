local M = {}

--local privateVariables
local displayGroup
local x, y, width, height

local contentGroup
local clippingGroup
local lineSpacing = 0
local currentSpeedLabel = nil

-- public parameters
-- white arc from VS0 to VFE
-- green arc from VS1 to VN0
-- yellow arc from VN0 to VNE
-- red line at VNE
M.VS0 = 30
M.VS1 = 37
M.VFE = 100
M.VNO = 120
M.VNE = 140
--
M.VR = 0
M.VX = 0
M.VY = 0

--local privateFunction = function() end


--
-- called by parent upon scene creation
--
M.create = function (self, _displayGroup, _x, _y, _width, _height)
    -- set private variables
    x, y, width, height = _x, _y, _width, _height
    displayGroup = _displayGroup

    -- paint background box
    local box = display.newRect(displayGroup, x, y, width, height)
    box:setFillColor(0,0,0,0.3)
    box:setStrokeColor(0,0,0,0)
    box.strokeWidth = 0

    -- create group for airspeedTape
    contentGroup = display.newGroup()
    --contentGroup.anchorChildren = true

    --create bounding group for clipping and positioning
    clippingGroup = display.newContainer(displayGroup, width, height)
    --clippingGroup.anchorChildren = true
    clippingGroup:translate(x, y)
    clippingGroup:insert( contentGroup )

    -- set Parameters
    local lineLength = width / 4
    lineSpacing = height / 8
    local lineStrokeWidth = 2
    local labelSize = width / 4
    local labelFont = native.systemFont

    -- draw inicator lines and labels
    for i = -35, 4 do
        -- line
        local line = display.newLine(contentGroup, width/8, i * lineSpacing, width/2, i * lineSpacing )
        line:setStrokeColor(1, 1, 1, 1)
        line.strokeWidth = lineStrokeWidth
        -- label
        local label = display.newText( contentGroup, string.format( "%d", -i*10 ), width*1/16, i * lineSpacing, labelFont, labelSize ) 
        label:setFillColor(1, 1, 1, 1)
        label.anchorX = 1
        label.anchorY = 0.5
    end

    -- draw speed arcs
    local redLineStrokeWidth = 6
    if M.VS1>0 and M.VNO>0 then
        -- green arc
        local arcGreen = display.newRect(contentGroup, width/4, -M.VNO/10 * lineSpacing, width/8, (M.VNO-M.VS1)/10 * lineSpacing)
        arcGreen.anchorX = 0.5
        arcGreen.anchorY = 0 
        arcGreen:setFillColor(0,1,0,1)
        arcGreen:setStrokeColor(0,0,0,0)
        arcGreen.strokeWidth = 0
    end
    if M.VNO>0 and M.VNE>0 then
        -- yellow arc and red line
        -- yellow arc
        local arcYellow = display.newRect(contentGroup, width/4, -M.VNE/10 * lineSpacing, width/8, (M.VNE-M.VNO)/10 * lineSpacing)
        arcYellow.anchorX = 0.5
        arcYellow.anchorY = 0 
        arcYellow:setFillColor(1,1,0,1)
        arcYellow:setStrokeColor(0,0,0,0)
        arcYellow.strokeWidth = 0
        -- red line
        local redLine = display.newLine(contentGroup, width/8*1, -M.VNE/10 * lineSpacing, width/8*4, -M.VNE/10 * lineSpacing )
        redLine:setStrokeColor(1, 0, 0, 1)
        redLine.strokeWidth = redLineStrokeWidth
    end
    if M.VS0>0 and M.VFE>0 then
        -- white arc
        local arcWhite = display.newRect(contentGroup, width/8*3, -M.VFE/10 * lineSpacing, width/8, (M.VFE-M.VS0)/10 * lineSpacing)
        arcWhite.anchorX = 0.5
        arcWhite.anchorY = 0 
        arcWhite:setFillColor(1,1,1,1)
        arcWhite:setStrokeColor(0,0,0,0)
        arcWhite.strokeWidth = 0
    end

    -- draw current Speed field
    -- black box
    local lineHeight = height/10
    local box = display.newRect(displayGroup, x-width/8*2, y, width/8*4.5, lineHeight)
    box:setFillColor(0,0,0,1)
    box:setStrokeColor(0,0,0,0)
    box.strokeWidth = 0
    -- speed Marker
    local speedMarkerVertices = { 0,0, 0,lineHeight, lineHeight/2,lineHeight/2 }
    local speedMarker = display.newPolygon(displayGroup, x+width/32*1, y, speedMarkerVertices)
    speedMarker.anchorX=0
    speedMarker:setFillColor(0,0,0,1)
    speedMarker.strokeWidth = 0
    -- Label
    local currentSpeedLabelFont = native.systemFont
    local currentSpeedLabelSize = width/16*5
    currentSpeedLabel = display.newText( displayGroup, string.format( "%d", 0 ), x+width/16*1, y, currentSpeedLabelFont, currentSpeedLabelSize ) 
    currentSpeedLabel:setFillColor(1, 1, 1, 1)
    currentSpeedLabel.anchorX = 1
    currentSpeedLabel.anchorY = 0.5

end



--
-- called by parent to update Modules display content
--
M.update = function (self, speed) 
    -- move tape
    contentGroup.x = 0
    contentGroup.y = 0
    contentGroup.y = (speed/10) * lineSpacing
    currentSpeedLabel.text = string.format( "%d", speed )
end


--
-- called by Parent upon resizing
--
M.resize = function (self, _displayGroup, _x, _y, _width, _height) 
    M:destroy()
    M:create(_displayGroup, _x, _y, _width, _height)
end



--
-- called by parent upom destroy scene
--
M.destroy = function()
    clippingGroup:removeSelf() 
    clippingGroup = nil
    contentGroup = nil
end


return M
