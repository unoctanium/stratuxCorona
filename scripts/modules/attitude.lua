local M = {}

local skyboxWidth = 1024
local skyboxHeight = 4096
local labelSize = 18
local labelFont = native.systemFont
local labelSpacer = labelSize * 2 -- distance of center of label from end of hairline
local lineWidth10 = 3
local lineWidth05 = 2
local lineWidth25 = 1
local lineLength10 = 200
local lineLength05 = 100
local lineLength25 = 25
local lineSpacing10 = 200 -- should be divideable by 4
local displayGroup = nil
local contentGroup = nil
local pitchScale = lineSpacing10 * 18 / 2 / 90


-- Helper
local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943

--local privateFunction = function() end


M.create = function(self, width, height)

    -- create group for ladder
    contentGroup = display.newGroup()
    contentGroup.anchorChildren = true
    contentGroup.anchorX = 0.5
    contentGroup.anchorY = 0.5

    -- create bounding group for clipping and positioning
    displayGroup = display.newGroup()
    --displayGroup.anchorChildren = true
    --displayGroup.anchorX = 0.5
    --displayGroup.anchorY = 0.5
    displayGroup:insert( contentGroup )


    -- Create ladder

    -- Set ladder parameters
    -- here we have to calculate the dimensions from boundingRect

    -- Skybox
    local skyRect = display.newRect(contentGroup, 0, -skyboxHeight/4, skyboxWidth, skyboxHeight/2)
    skyRect:setFillColor(0/255, 150/255, 201/255, 1)
    skyRect.strokeWidth = 0
    local gndRect = display.newRect(contentGroup, 0, skyboxHeight/4, skyboxWidth, skyboxHeight/2)
    gndRect:setFillColor(151/255, 99/255, 0/255, 1)
    gndRect.strokeWidth = 0
    


    -- Zero line and labels
    local line0 = display.newLine(contentGroup, -lineLength10/2, 0, lineLength10/2, 0)
    line0:setStrokeColor(1, 1, 1, 1)
    line0.strokeWidth = lineWidth10
    
    -- Ladder Lines and labels
    for i = 0, 9 do
        if i ~= 0 then
            local line10 = display.newLine(contentGroup, -lineLength10/2, i * lineSpacing10, lineLength10/2, i * lineSpacing10)
            line10:setStrokeColor(1, 1, 1, 1)
            line10.strokeWidth = lineWidth10
            local line10n = display.newLine(contentGroup, -lineLength10/2, -i * lineSpacing10, lineLength10/2, -i * lineSpacing10)
            line10n:setStrokeColor(1, 1, 1, 1)
            line10n.strokeWidth = lineWidth10
            local leftLabel = display.newText( contentGroup, string.format( "-%d", i*10 ), - lineLength10/2 - labelSpacer , i * lineSpacing10, labelFont, labelSize ) 
            leftLabel:setFillColor(1,1,1)
            leftLabel.anchorX = 0.5
            leftLabel.anchorY = 0.5
            local rightLabel = display.newText( contentGroup, string.format( "-%d", i*10 ), lineLength10/2 + labelSpacer , i * lineSpacing10, labelFont, labelSize ) 
            rightLabel:setFillColor(1,1,1)
            rightLabel.anchorX = 0.5
            rightLabel.anchorY = 0.5
            local leftLabeln = display.newText( contentGroup, string.format( "%d", i*10 ), - lineLength10/2 - labelSpacer , - i * lineSpacing10, labelFont, labelSize ) 
            leftLabeln:setFillColor(1,1,1)
            leftLabeln.anchorX = 0.5
            leftLabeln.anchorY = 0.5
            local rightLabeln = display.newText( contentGroup, string.format( "%d", i*10 ), lineLength10/2 + labelSpacer , - i * lineSpacing10, labelFont, labelSize ) 
            rightLabeln:setFillColor(1,1,1)
            rightLabeln.anchorX = 0.5
            rightLabeln.anchorY = 0.5
            
        end
        
        local line25 = display.newLine(contentGroup, -lineLength25/2, i * lineSpacing10 + lineSpacing10/4, lineLength25/2, i * lineSpacing10 + lineSpacing10/4)
        line25:setStrokeColor(1, 1, 1, 1)
        line25.strokeWidth = lineWidth25
        local line05 = display.newLine(contentGroup, -lineLength05/2, i * lineSpacing10 + lineSpacing10/2, lineLength05/2, i * lineSpacing10 + lineSpacing10/2)
        line05:setStrokeColor(1, 1, 1, 1)
        line05.strokeWidth = lineWidth05
        local line75 = display.newLine(contentGroup, -lineLength25/2, i * lineSpacing10 + lineSpacing10*3/4, lineLength25/2, i * lineSpacing10 + lineSpacing10*3/4)
        line75:setStrokeColor(1, 1, 1, 1)
        line75.strokeWidth = lineWidth25
        local line25n = display.newLine(contentGroup, -lineLength25/2, -i * lineSpacing10 - lineSpacing10/4, lineLength25/2, -i * lineSpacing10 - lineSpacing10/4)
        line25n:setStrokeColor(1, 1, 1, 1)
        line25n.strokeWidth = lineWidth25
        local line05n = display.newLine(contentGroup, -lineLength05/2, -i * lineSpacing10 - lineSpacing10/2, lineLength05/2, -i * lineSpacing10 - lineSpacing10/2)
        line05n:setStrokeColor(1, 1, 1, 1)
        line05n.strokeWidth = lineWidth05
        local line75n = display.newLine(contentGroup, -lineLength25/2, -i * lineSpacing10 - lineSpacing10*3/4, lineLength25/2, -i * lineSpacing10 - lineSpacing10*3/4)
        line75n:setStrokeColor(1, 1, 1, 1)
        line75n.strokeWidth = lineWidth25
        
    end

    displayGroup.x = display.contentCenterX 
    displayGroup.y = display.contentCenterY
end

M.resize = function () end


--
-- Update Attitude pitch and roll deg
--
M.update = function (self, roll, pitch, yaw) 
    displayGroup. x = display.contentCenterX 
    displayGroup. y = display.contentCenterY
    displayGroup.rotation = -roll
    local traX = -math.sin(-roll * deg2Rad) * pitch * pitchScale
    local traY = math.cos(-roll * deg2Rad) * pitch * pitchScale
    displayGroup:translate(traX, traY)
end


--[[
---
--- Debug output
---
local dx = display.newRect(100, display.contentCenterY, 50, 50)
local dy = display.newRect(150, display.contentCenterY, 50, 50)
local dz = display.newRect(200, display.contentCenterY, 50, 50)

M.debugUpdate = function(self, pitch, roll, yaw)
    dx.y=(pitch+360)%360 
    dy.y=(roll+360)%360 
    dz.y=(yaw+360)%360 
end
--]]

M.destroy = function ()
    desplayGroup:removeSelf() 
    displayGroup = nil
end


return M
