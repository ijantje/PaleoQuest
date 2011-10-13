_H = display.contentHeight
_W = display.contentWidth

xValue = _W/3.75
yValue = _H/6.2
print("Y: "..yValue)

-- Make photos draggable


local imageTable = {}
imageTable[4] = "images/triceratops.jpg"
imageTable[1] = "images/sabertoothLive.jpg"
imageTable[2] = "images/trexLive.jpg"
imageTable[3] = "images/raptorLive.jpg"


local button = display.newRect(0,0,44,44)
button.x = _W/2
button.y = _H/1.1

dropTainer = {}
for i = 1,4 do
	-- Create four locations to drop photos

	local dropContainer = display.newImageRect(imageTable[i],_W/2.75,_H/6)
	dropContainer.x = xValue
	dropContainer.y = yValue
	--dropContainer:setFillColor(0)
	dropContainer.strokeWidth=1
	dropContainer:setStrokeColor(250,250,250)
	if (i == 1) or (i == 3) then
		xValue = xValue *2.75
	end
	if (i == 2) then
		xValue = xValue / 2.75
		yValue = yValue *2.1
		
	end
	dropTainer[i] = dropContainer
end
-- Create four photos to match each of the four titles

--xValue = _W/3.75
--yValue = yValue *2.1

function dragPix( event )
	local objectNum = event.target.j
    if event.phase == "began" then
        event.target.markX = event.target.x    -- store x location of object
        event.target.markY = event.target.y    -- store y location of object
		
    elseif event.phase == "moved" then
        local x = (event.x - event.xStart) + event.target.markX
        local y = (event.y - event.yStart) + event.target.markY
        display.getCurrentStage():setFocus(event.target)
		
        event.target.x, event.target.y = x, y    -- move object based on calculations above

-- Snap to correct location		
		if (x/dropTainer[objectNum].x > .8) and (y/dropTainer[objectNum].y > .8) 
			and (x/dropTainer[objectNum].x < 1.2) and (y/dropTainer[objectNum].y < 1.2) then
			event.target.x = dropTainer[objectNum].x
			event.target.y = dropTainer[objectNum].y
			display.getCurrentStage():setFocus(nil)
		end
	elseif event.phase == "ended" and event.target.x ~= dropTainer[objectNum].x and event.target.y ~= dropTainer[objectNum].y then
			event.target.x = event.target.markX
			event.target.y = event.target.markY
			display.getCurrentStage():setFocus(nil)
    end
  return true
end

local skullTable = {}
skullTable[4] = "images/torosaurus.png"
skullTable[1] = "images/sabertooth.jpg"
skullTable[2] = "images/trex.jpg"
skullTable[3] = "images/raptor.jpg"

function placePhotos(event)

local function setPhotos()
 draggables = display.newGroup()
for i = 1,4 do
	print ("Placing photos "..xValue.." and "..i)
	-- Create four droppable photos
	
dragImage = display.newImageRect(skullTable[i],_W/2.75,_H/6)
	print (skullTable[i])
	dragImage.x = xValue
	dragImage.y = yValue*.75
	if (i == 1) or (i == 3) then
		xValue = xValue *2.75
		print("this works".. xValue)
	end
	if (i == 2) then
		xValue = xValue / 2.75
		yValue = yValue *1.35
		print("as does this -- Y value " .. yValue)
	end

	dragImage.j = i
	dragImage.l = "isDraggable"
	print("dragimageJ = "..dragImage.j)
	dragImage:addEventListener( "touch", dragPix )
	draggables:insert(dragImage)
	print("Draggables" .. i .. ": " .. draggables[i].j)
  end
end

--print ("Happens")
if event then

	if event.phase == "began" then
	xValue = _W/3.75
	yValue = yValue / 1.35
	print ("Began")
	for k = draggables.numChildren, 1 , -1 do
		print (k) 
		if(draggables[k].l == "isDraggable") then
			print ("trial "..k.." draggables[k]l = ".. draggables[k].l)
			print ("Removing" .. k)
			print (draggables.x)
			draggables[k]:removeEventListener("touch",dragPix)
			draggables[k]:removeSelf()
			
		end
		
	end
	setPhotos()
	end

else 
xValue = _W/3.75
yValue = yValue *2.1
setPhotos()


end
end
--[[

print("X = "..xValue)
print("Y = "..yValue)
if event then
if(event.phase == "began") then
	for k = 1,4 do
		print (k) 
		if(dragImage.j == k) then
			print ("trial "..k.." Dragimagek = ".. dragImage.j)
		end
		if(dragImage.j == k) then
			print ("Removing" .. k)
			print (dragImage.x)
			dragImage.j = nil
			dragImage.x = nil
			dragImage.y = nil
			dragImage:removeEventListener("touch",dragPix)
			dragImage:removeSelf()
		end
		
	end
end 
end ]]  
	

--end

if (dragImage == nil) then

placePhotos()

end   
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