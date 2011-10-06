_H = display.contentHeight
_W = display.contentWidth

xValue = _W/3.5
yValue = _H/5
print("Y: "..yValue)

-- Make photos draggable

local imageTable = {}
imageTable[4] = "images/triceratops.jpg"
imageTable[1] = "images/sabertoothLive.jpg"
imageTable[2] = "images/trexLive.jpg"
imageTable[3] = "images/raptorLive.jpg"

local skullTable = {}
skullTable[4] = "images/torosaurus.png"
skullTable[1] = "images/sabertooth.jpg"
skullTable[2] = "images/trex.jpg"
skullTable[3] = "images/raptor.jpg"

local button = display.newRect(0,0,44,44)
button.x = _W/2
button.y = _H/3*2

dropTainer = {}
for i = 1,4 do
	-- Create four locations to drop photos

	local dropContainer = display.newImageRect(imageTable[i],_W/2.5,_H/5)
	dropContainer.x = xValue
	dropContainer.y = yValue
	--dropContainer:setFillColor(0)
	dropContainer.strokeWidth=1
	dropContainer:setStrokeColor(250,250,250)
	if (i == 1) or (i == 3) then
		xValue = xValue *2.5
	end
	if (i == 2) then
		xValue = xValue / 2.5
		yValue = yValue *2.1
		
	end
	dropTainer[i] = dropContainer
end
-- Create four photos to match each of the four titles

xValue = _W/3.5
yValue = yValue *2.1

function dragPix( event )
	local objectNum = event.target.j
    if event.phase == "began" then
        event.target.markX = event.target.x    -- store x location of object
        event.target.markY = event.target.y    -- store y location of object
    elseif event.phase == "moved" then
        local x = (event.x - event.xStart) + event.target.markX
        local y = (event.y - event.yStart) + event.target.markY
        display.getCurrentStage():setFocus(self)
		
        event.target.x, event.target.y = x, y    -- move object based on calculations above

-- Snap to correct location		
		if (x/dropTainer[objectNum].x > .8) and (y/dropTainer[objectNum].y > .8) 
			and (x/dropTainer[objectNum].x < 1.2) and (y/dropTainer[objectNum].y < 1.2) then
			event.target.x = dropTainer[objectNum].x
			event.target.y = dropTainer[objectNum].y
		end
	elseif event.phase == "ended" and event.target.x ~= dropTainer[objectNum].x and event.target.y ~= dropTainer[objectNum].y then
			event.target.x = event.target.markX
			event.target.y = event.target.markY
    end
  return true
end
function placePhotos()
for i = 1,4 do
	-- Create four locations to drop photos

	local dragImage = display.newImageRect(skullTable[i],_W/2.5,_H/5)
	dragImage.x = xValue
	dragImage.y = yValue*.75

	if (i == 1) or (i == 3) then
	xValue = xValue *2.5
end
if (i == 2) then
	xValue = xValue / 2.5
	yValue = yValue *1.35
end

dragImage.j = i
dragImage:addEventListener( "touch", dragPix )

end
end
placePhotos()
button:addEventListener("touch",placePhotos)

-- Recognize if dragged photos are in proximity of matching location

-- Snap photo into correct position if matches

-- Snap back to original position if there is no match


-- When all photos are aligned, display success message.

-- Display buttons that will continue search



-- create object
--[[local myObject = display.newRect( , xValue, yValue )
--myObject:setFillColor( 255 )

-- touch listener function
function myObject:touch( event )
    if event.phase == "began" then

        self.markX = self.x    -- store x location of object
        self.markY = self.y    -- store y location of object

    elseif event.phase == "moved" then

        local x = (event.x - event.xStart) + self.markX
        local y = (event.y - event.yStart) + self.markY
        
        self.x, self.y = x, y    -- move object based on calculations above
    end
    
    return true
end

-- make 'myObject' listen for touch events
myObject:addEventListener( "touch", myObject )

]]--