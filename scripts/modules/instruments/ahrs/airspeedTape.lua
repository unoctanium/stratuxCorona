local M = {}

--local privateVariables
local displayGroup
local x, y, width, height

local contentGroup
local clippingGroup

-- public parameters
M.lineSpacing = 0

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
    M.lineSpacing = height / 8
    local lineStrokeWidth = 2
    local labelSize = width / 4
    local labelFont = native.systemFont

    -- draw inicator lines and labels
    for i = -35, 4 do
        -- line
        local line = display.newLine(contentGroup, width/8, i * M.lineSpacing, width/2, i * M.lineSpacing )
        line:setStrokeColor(1, 1, 1, 1)
        line.strokeWidth = lineStrokeWidth
        -- label
        local label = display.newText( contentGroup, string.format( "%d", -i*10 ), width*1/16, i * M.lineSpacing, labelFont, labelSize ) 
        label:setFillColor(1,1,1.1)
        label.anchorX = 1
        label.anchorY = 0.5
    end

end



--
-- called by parent to update Modules display content
--
M.update = function (self, speed) 
    -- move tape
    contentGroup.x = 0
    contentGroup.y = 0
    contentGroup.y = (speed/10) * M.lineSpacing
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
