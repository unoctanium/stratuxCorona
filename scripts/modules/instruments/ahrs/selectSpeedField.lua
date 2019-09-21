local M = {}

--local privateVariables
local displayGroup
local x, y, width, height

local alertMarker
local fieldValue

--local privateFunction = function() end

--
-- called by parent upon scene creation
--
M.create = function (self, _displayGroup, _x, _y, _width, _height)
    -- set private variables
    x, y, width, height = _x, _y, _width, _height
    displayGroup = _displayGroup

    -- field Background
    local box = display.newRect(displayGroup, x, y, width, height)
    box:setFillColor(0,0,0,1)
    box:setStrokeColor(0,0,0,0)
    box.strokeWidth = 0

    -- field Value


    -- alert Marker
    local alertVertices = {0,0, 0,height, height,0}
    alertMarker = display.newPolygon(displayGroup, x+width/2+height/2, y, alertVertices)
    alertMarker:setFillColor(0,0,0,1)
    alertMarker.strokeWidth = 0

end

--
-- called by parent upom destroy scene
--
M.destroy = function()
end


return M
