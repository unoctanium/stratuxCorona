local M = {}

--local privateVariables
local displayGroup
local x, y, width, height



--local privateFunction = function() end

--
-- called by parent upon scene creation
--
M.create = function (self, _displayGroup, _x, _y, _width, _height)
    -- set private variables
    x, y, width, height = _x, _y, _width, _height
    displayGroup = _displayGroup

    -- paint test box
    local box = display.newRect(displayGroup, x, y, width, height)
    box:setFillColor(0,0,0,1)
    box:setStrokeColor(0,0,0,0)
    box.strokeWidth = 0

end

--
-- called by parent upom destroy scene
--
M.destroy = function()
end


return M
