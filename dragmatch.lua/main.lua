_H = display.contentHeight
_W = display.contentWidth

-- Load the relevant LuaSocket modules
local http = require("socket.http")
local ltn12 = require("ltn12")

xValue = _W/3.8
yValue = _H/6.2

print("Y: "..yValue)

-- Make photos draggable

local imageTable = {}
imageTable[4] = "tritop.jpg"
imageTable[1] = "stooth.jpg"
imageTable[2] = "t-rex.jpg"
imageTable[3] = "vraptor.jpg"

for i = 1,4 do

-- Create local file for saving data
local path = system.pathForFile( imageTable[i], system.DocumentsDirectory )
myFile = io.open( path, "w+b" ) 
	-- Request remote file and save data to local file
http.request{
    url = "http://christijandraper.com/coronaImages/"..imageTable[i] ,
    sink = ltn12.sink.file(myFile),
}


 
end

local button = display.newRect(0,0,44,44)
button.x = _W/2
button.y = _H/3*2.7

dropTainer = {}
for i = 1,4 do
	-- Create four locations to drop photos

	local dropContainer = display.newImageRect(imageTable[i],system.DocumentsDirectory,_W/2.75,_H/6)

	dropContainer.x = xValue
	dropContainer.y = yValue
	--dropContainer:setFillColor(0)
	dropContainer.strokeWidth=1
	dropContainer:setStrokeColor(250,250,250)
	if (i == 1) or (i == 3) then
		xValue = xValue *2.8
	end
	if (i == 2) then
		xValue = xValue / 2.8
		yValue = yValue *2.1
		
	end
	dropTainer[i] = dropContainer

	dropTainer[i].ID = imageTable[i]
end
-- Create four photos to match each of the four titles

function dragPix( event )
-- Find the right dropTainer
	local objectNum
	for num = 1,4 do
		if (string.sub(dropTainer[num].ID,1,-5).."Skull" == string.sub(event.target.ID,1,-5)) then
			objectNum = num
		end
	end
    if event.phase == "began" then
        event.target.markX = event.target.x    -- store x location of object
        event.target.markY = event.target.y    -- store y location of object

		
    elseif event.phase == "moved" then
        local x = (event.x - event.xStart) + event.target.markX
        local y = (event.y - event.yStart) + event.target.markY
        display.getCurrentStage():setFocus(event.target)
		
        event.target.x, event.target.y = x, y    -- move object based on calculations above

-- Snap to correct location
		if (x/dropTainer[objectNum].x > .7) and (y/dropTainer[objectNum].y > .7) 
			and (x/dropTainer[objectNum].x < 1.3) and (y/dropTainer[objectNum].y < 1.3) then
			event.target.x = dropTainer[objectNum].x
			event.target.y = dropTainer[objectNum].y
			
			event.target:removeEventListener("touch",dragPix)
			system.vibrate()
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
skullTable[3] = "tritopSkull.jpg"
skullTable[1] = "stoothSkull.jpg"
skullTable[4] = "t-rexSkull.jpg"
skullTable[2] = "vraptorSkull.jpg"

for i = 1,4 do

-- Create local file for saving data
local path = system.pathForFile( skullTable[i], system.DocumentsDirectory )
myFile = io.open( path, "w+b" ) 
	-- Request remote file and save data to local file
http.request{
    url = "http://christijandraper.com/coronaImages/"..skullTable[i] ,
    sink = ltn12.sink.file(myFile),
}
 
end

function placePhotos(event)

local function setPhotos()
 draggables = display.newGroup()
for i = 1,4 do
	print ("Placing photos "..xValue.." and "..i)
	-- Create four droppable photos
	
dragImage = display.newImageRect(skullTable[i],system.DocumentsDirectory,_W/2.8,_H/6)
	print (skullTable[i])
	dragImage.x = xValue
	dragImage.y = yValue*.75
	if (i == 1) or (i == 3) then
		xValue = xValue *2.75
		print("this works".. xValue)
	end
	if (i == 2) then
		xValue = xValue / 2.75
		yValue = yValue *1.33
		print("as does this -- Y value " .. yValue)
	end

	dragImage.j = i
	dragImage.ID = skullTable[i]
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
	xValue = _W/3.8
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
placePhotos()

button:addEventListener("touch",placePhotos)