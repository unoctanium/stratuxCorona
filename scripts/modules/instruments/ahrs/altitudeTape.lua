local M = {}

--local privateVariables
local displayGroup
local x, y, width, height

local contentGroup
local clippingGroup
local lineSpacing = 0
local currentAltitudeLabel = nil
-- public parameters

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
    lineSpacing = height / 4
    local lineStrokeWidth = 2
    local labelSize = width / 4
    local labelFont = native.systemFont

    -- draw inicator lines and labels
    for i = -300, 2 do
        -- line
        local line = display.newLine(contentGroup, -width/4, i * lineSpacing, -width/2, i * lineSpacing )
        line:setStrokeColor(1, 1, 1, 1)
        line.strokeWidth = lineStrokeWidth
        for k = 1,4 do
            local l2 = display.newLine(contentGroup, -width*3/8, i * lineSpacing - k*(lineSpacing/4), -width/2, i * lineSpacing - k*(lineSpacing/4))
            l2:setStrokeColor(1, 1, 1, 1)
            l2.strokeWidth = lineStrokeWidth    
        end
        -- label
        local label = display.newText( contentGroup, string.format( "%d", -i*100 ), -width*7/32, i * lineSpacing, labelFont, labelSize ) 
        label:setFillColor(1,1,1.1)
        label.anchorX = 0
        label.anchorY = 0.5
    end

    -- draw current Altitude field
    -- black box
    local lineHeight = height/10
    local box = display.newRect(displayGroup, x+width/8*1, y, width/8*6, lineHeight)
    box:setFillColor(0,0,0,1)
    box:setStrokeColor(0,0,0,0)
    box.strokeWidth = 0
    -- altitude Marker
    local altitudeMarkerVertices = { 0,0, 0,lineHeight, -lineHeight/2,lineHeight/2 }
    local altitudeMarker = display.newPolygon(displayGroup, x-width/32*8, y, altitudeMarkerVertices)
    altitudeMarker.anchorX=1
    altitudeMarker:setFillColor(0,0,0,1)
    altitudeMarker.strokeWidth = 0
    -- Label
    local currentAltitudeLabelFont = native.systemFont
    local currentAltitudeLabelSize = width/16*5
    currentAltitudeLabel = display.newText( displayGroup, string.format( "%d", 9999 ), x-width/16*5, y, currentAltitudeLabelFont, currentAltitudeLabelSize ) 
    currentAltitudeLabel:setFillColor(1, 1, 1, 1)
    currentAltitudeLabel.anchorX = 0
    currentAltitudeLabel.anchorY = 0.5

end



--
-- called by parent to update Modules display content
--
M.update = function (self, altitude) 
    -- move tape
    contentGroup.x = 0
    contentGroup.y = 0
    contentGroup.y = (altitude/100) * lineSpacing
    currentAltitudeLabel.text = string.format( "%d", math.floor((altitude+5)/10)*10 )
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
