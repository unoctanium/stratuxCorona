local M = {}

local displayGroup = nil
local ladderGroup = nil
local rollIndicatorGroup = nil
local rollIndicatorContentGroup = nil


-- TODO: I must rework this. 
-- the ladder shall continue at +/90 deg for at least one displayGroup diagonale
-- better approach: work with segmented ladder
-- and I must scale these parameters with respect to creates(x, x, width, height)
-- Todo: SET IN CREATE!!
local skyboxWidth = 0 --math.sqrt(displayGroupWidth*displayGroupWidth + displayGroupHeight*displayGroupHeight)
local skyboxHeight = 0 --4096
local lineSpacing10 = 0 --200 -- should be divideable by 4
local pitchScale = 0 --lineSpacing10 * 18 / 2 / 90

local labelSize = 36
local labelFont = native.systemFont
local labelSpacer = labelSize * 1.1 -- distance of center of label from end of hairline
local lineWidth10 = 4
local lineWidth05 = 3
local lineWidth25 = 2
local lineLength10 = 160
local lineLength05 = 80
local lineLength25 = 40
local lineWidthHorizonLine = 7


-- Helper
local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943

--local privateFunction = function() end


M.create = function(self, x, y, width, height)


    -- create group for ladder
    ladderGroup = display.newGroup()
    ladderGroup.anchorChildren = true

    --create bounding group for clipping and positioning
    displayGroup = display.newContainer(width,height)
    displayGroup.anchorChildren = true
    displayGroup:translate(x, y)
    displayGroup:insert( ladderGroup )

    -- Set Scaling parameters
    skyboxWidth = math.sqrt(width*width + height*height)
    skyboxHeight = 4096
    lineSpacing10 = 200 -- should be divideable by 4
    pitchScale = lineSpacing10 * 18 / 2 / 90


    -- Create ladder

    -- Set ladder parameters
    -- here we have to calculate the dimensions from boundingRect

    -- Skybox
    local skyRect = display.newRect(ladderGroup, 0, -skyboxHeight/4, skyboxWidth, skyboxHeight/2)
    skyRect:setFillColor(0/255, 150/255, 201/255, 1)
    skyRect.strokeWidth = 0
    local gndRect = display.newRect(ladderGroup, 0, skyboxHeight/4, skyboxWidth, skyboxHeight/2)
    gndRect:setFillColor(151/255, 99/255, 0/255, 1)
    gndRect.strokeWidth = 0
    
    
    -- Ladder Lines and labels ( no zero line )
    for i = 0, 9 do

        if i ~= 0 then
            local line10 = display.newLine(ladderGroup, -lineLength10/2, i * lineSpacing10, lineLength10/2, i * lineSpacing10)
            line10:setStrokeColor(1, 1, 1, 1)
            line10.strokeWidth = lineWidth10
            local line10n = display.newLine(ladderGroup, -lineLength10/2, -i * lineSpacing10, lineLength10/2, -i * lineSpacing10)
            line10n:setStrokeColor(1, 1, 1, 1)
            line10n.strokeWidth = lineWidth10
            local leftLabel = display.newText( ladderGroup, string.format( "-%d", i*10 ), - lineLength10/2 - labelSpacer , i * lineSpacing10, labelFont, labelSize ) 
            leftLabel:setFillColor(1,1,1)
            leftLabel.anchorX = 0.5
            leftLabel.anchorY = 0.5
            local rightLabel = display.newText( ladderGroup, string.format( "-%d", i*10 ), lineLength10/2 + labelSpacer , i * lineSpacing10, labelFont, labelSize ) 
            rightLabel:setFillColor(1,1,1)
            rightLabel.anchorX = 0.5
            rightLabel.anchorY = 0.5
            local leftLabeln = display.newText( ladderGroup, string.format( "%d", i*10 ), - lineLength10/2 - labelSpacer , - i * lineSpacing10, labelFont, labelSize ) 
            leftLabeln:setFillColor(1,1,1)
            leftLabeln.anchorX = 0.5
            leftLabeln.anchorY = 0.5
            local rightLabeln = display.newText( ladderGroup, string.format( "%d", i*10 ), lineLength10/2 + labelSpacer , - i * lineSpacing10, labelFont, labelSize ) 
            rightLabeln:setFillColor(1,1,1)
            rightLabeln.anchorX = 0.5
            rightLabeln.anchorY = 0.5
        end
        
        local line25 = display.newLine(ladderGroup, -lineLength25/2, i * lineSpacing10 + lineSpacing10/4, lineLength25/2, i * lineSpacing10 + lineSpacing10/4)
        line25:setStrokeColor(1, 1, 1, 1)
        line25.strokeWidth = lineWidth25
        local line05 = display.newLine(ladderGroup, -lineLength05/2, i * lineSpacing10 + lineSpacing10/2, lineLength05/2, i * lineSpacing10 + lineSpacing10/2)
        line05:setStrokeColor(1, 1, 1, 1)
        line05.strokeWidth = lineWidth05
        local line75 = display.newLine(ladderGroup, -lineLength25/2, i * lineSpacing10 + lineSpacing10*3/4, lineLength25/2, i * lineSpacing10 + lineSpacing10*3/4)
        line75:setStrokeColor(1, 1, 1, 1)
        line75.strokeWidth = lineWidth25
        local line25n = display.newLine(ladderGroup, -lineLength25/2, -i * lineSpacing10 - lineSpacing10/4, lineLength25/2, -i * lineSpacing10 - lineSpacing10/4)
        line25n:setStrokeColor(1, 1, 1, 1)
        line25n.strokeWidth = lineWidth25
        local line05n = display.newLine(ladderGroup, -lineLength05/2, -i * lineSpacing10 - lineSpacing10/2, lineLength05/2, -i * lineSpacing10 - lineSpacing10/2)
        line05n:setStrokeColor(1, 1, 1, 1)
        line05n.strokeWidth = lineWidth05
        local line75n = display.newLine(ladderGroup, -lineLength25/2, -i * lineSpacing10 - lineSpacing10*3/4, lineLength25/2, -i * lineSpacing10 - lineSpacing10*3/4)
        line75n:setStrokeColor(1, 1, 1, 1)
        line75n.strokeWidth = lineWidth25
        
    end -- of ladder lines and labels

    -- -- Zero line and labels
    -- local line0 = display.newLine(ladderGroup, -lineLength10/2, 0, lineLength10/2, 0)
    -- line0:setStrokeColor(1, 1, 1, 1)
    -- line0.strokeWidth = lineWidth10

    -- Horizon line
    local horizonLine = display.newLine(ladderGroup, -skyboxWidth/2, 0, skyboxWidth/2, 0)
    horizonLine:setStrokeColor(1,1,1,1)
    horizonLine.strokeWidth = lineWidthHorizonLine

    -- Reference line
    -- TODO: Parameterize coordinates!!
    local referenceLineLeft = display.newLine(displayGroup, -225, 0, -150, 0)
    referenceLineLeft:setStrokeColor(1,1,0)
    referenceLineLeft.strokeWidth = 7
    local referenceLineRight = display.newLine(displayGroup, 150, 0, 225, 0)
    referenceLineRight:setStrokeColor(1,1,0)
    referenceLineRight.strokeWidth = 7
    local referenceLineCircle = display.newCircle(displayGroup, 0, 0, 45)
    referenceLineCircle:setStrokeColor(1,1,0)
    referenceLineCircle:setFillColor(0,0,0,0)
    referenceLineCircle.strokeWidth = 7

    -- Roll marker
    -- TODO: Parameterize coordinates!!
    local rollMarkerVertices = { 0,0, 20,40, -20,40 }
    local rollMarker = display.newPolygon(displayGroup, 0, - height / 2 + 60, rollMarkerVertices)
    rollMarker:setFillColor(1,1,1,1)
    rollMarker.strokeWidth = 7

    -- Roll indicator
    -- TODO: Parameterize coordinates!!
    local rollIndicatorGroupWidth = 600
    local rollIndicatorGroupHeight = 100
    rollIndicatorGroup = display.newContainer(displayGroup, rollIndicatorGroupWidth,rollIndicatorGroupHeight)
    rollIndicatorGroup:translate(0,-height/2 + rollIndicatorGroupHeight/2)
    rollIndicatorContentGroup = display.newGroup()
    rollIndicatorContentGroup.anchorChildren = true
    rollIndicatorGroup:insert(rollIndicatorContentGroup)
    -- invisible circle to make group big....
    local rollindicatorArcRadius = width/2 * 0.95
    local rollIndicatorArc = display.newCircle(rollIndicatorContentGroup, 0, 0, rollindicatorArcRadius)
    rollIndicatorArc:setStrokeColor(1,1,1,1)
    rollIndicatorArc:setFillColor(0,0,0,0)
    rollIndicatorArc.strokeWidth = 7
    -- markers
    local rollIndicatorSampleMarker = display.newLine(rollIndicatorContentGroup, 0, -rollindicatorArcRadius, 0, -rollindicatorArcRadius + 30)
    rollIndicatorSampleMarker:setStrokeColor(1,1,1)
    rollIndicatorSampleMarker.strokeWidth = 7
    rollIndicatorContentGroup:translate(0,width/2 * 0.95 - 40)
    

    

end

M.resize = function () end


--
-- Update Attitude pitch and roll deg
--
M.update = function (self, roll, pitch, yaw) 
    -- move ladder
    ladderGroup. x = 0
    ladderGroup. y = 0
    ladderGroup.rotation = -roll
    local traX = -math.sin(-roll * deg2Rad) * pitch * pitchScale
    local traY = math.cos(-roll * deg2Rad) * pitch * pitchScale
    ladderGroup:translate(traX, traY)

    -- rotate roll indicator
    rollIndicatorContentGroup.rotation = -roll
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
    displayGroup:removeSelf() 
    displayGroup = nil
end


return M
