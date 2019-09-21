local M = {}

--local privateVariables
local displayGroup
local x, y, width, height
local centerX, centerY



--local privateFunction = function() end

--
-- called by parent upon scene creation
--
M.create = function (self, _displayGroup, _x, _y, _width, _height)
    -- set private variables
    x, y, width, height = _x, _y, _width, _height
    centerX, centerY = x + width/2, y + height/2
    displayGroup = _displayGroup

    ---- paint test box
    -- local box = display.newRect(displayGroup, x, y, width/2, height/2)
    -- box:setFillColor(1,1,1,0.5)
    -- box:setStrokeColor(0,0,0,0)
    -- box.strokeWidth = 0




end

return M
