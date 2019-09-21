local M = {}

local contentGroup = nil
contentGroup = display.newGroup()
contentGroup.anchorChildren = true
contentGroup.anchorX = 0.5
contentGroup.anchorY = 0.5

local privateFunction = function() end

M.create = function(self, x, y)
    contentGroup.x = x
    contentGroup.y = y
    contentGroup:toFront()
end

M.update = function()
end

M.destroy = function()
    contentGroup:removeSelf() 
    contentGroup = nil
end

M.messageBox = function(self, text)
    local msg = display.newText( contentGroup, text, 0, 0, native.systemFontBold, 18 )
    msg.x = display.contentWidth/2		-- center title
    msg:setFillColor( 1,1,1 )
 end

 M.messageToast = function(self, text)
    local msg = display.newText( contentGroup, text, 0, 0, native.systemFontBold, 18 )
    msg.x = display.contentWidth/2		-- center title
    msg:setFillColor( 1,1,1 )
 end







return M
