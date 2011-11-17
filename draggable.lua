module(..., package.seeall)

new = function (params)

local photosPlaced = 0
local successGroup = display.newGroup()
successGroup.alpha = 0
-- Parameters
local question_ID

if type(params) == "table" then
	print("It is a table.")
	question_ID = params.questionID
end
	

--function new()
	local localGroup = display.newGroup()
function changeScene(event)
		if(event.phase == "ended") then
			audio.play(click)
			director:changeScene({correctAnswered = question_ID},event.target.scene,"fade")
		end
	end
print ("Map question passed: "..question_ID)	

-- Load the relevant LuaSocket modules
local http = require("socket.http")
local ltn12 = require("ltn12")

-- include sqlite library
require "sqlite3"

--set the database path
local dbpath = system.pathForFile("tp_quests.sqlite")

--open dbs
database = sqlite3.open(dbpath)

--handle the applicationExit to close the db
local function onSystemEvent(event)
	if(event.type == "applicationExit") then
		database:close()
	end
end

--get image names
local sql = "SELECT * FROM type_draggable WHERE question_id = "..question_ID
print (sql)
local imageTable = {}
local skullTable = {}
local stem
for row in database:nrows(sql) do	
	imageTable[1] = row.item_1
	imageTable[2] = row.item_2
	imageTable[3] = row.item_3
	imageTable[4] = row.item_4
	skullTable[3] = row.item_3_match
	skullTable[1] = row.item_1_match
	skullTable[4] = row.item_4_match
	skullTable[2] = row.item_2_match
	stem = row.stem

end

xValue = _W/3.8
yValue = _H/6.2

print("Beginning Y value: "..yValue)

for i = 1,4 do

-- Create local file for saving data
local path = system.pathForFile( imageTable[i], system.DocumentsDirectory )
myFile = io.open( path, "w+b" ) 

	-- Request remote file and save data to local file
http.request{
    url = "http://christijandraper.com/coronaImages/"..imageTable[i] ,
    sink = ltn12.sink.file(myFile),
}

print("got here")
 
end

dropTainer = {}
for i = 1,4 do
	-- Create four locations to drop photos

	local dropContainer = display.newImageRect(imageTable[i],system.DocumentsDirectory,_W/2.75,_H/6)
localGroup:insert(dropContainer)
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
print("Next Y value: "..yValue)
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
			
			photosPlaced = photosPlaced + 1

-- Check for success in matching parts
			if photosPlaced == 4 then
				local win = audio.loadSound("win.wav")
				audio.play(win)
				print("4 photos placed")
				
-- Mark progress for this question in database
				--set the database path
					local user_dbpath = system.pathForFile("tp_user.sqlite")

				--open dbs
					local database2 = sqlite3.open(user_dbpath)

				--handle the applicationExit to close the db
					local function onSystemEvent(event)
						if(event.type == "applicationExit") then
							database2:close()
						end
					end

-- Submit progress to database
					local sql = "INSERT INTO questions_completed (progress_id, question_completed) VALUES (".._G.prog_id..","..question_ID..")"
					database2:exec(sql)
					print (sql)

				local successMessage = display.newRect(0,0,176,33)
				successMessage.scene = "bag"
				local messageLabel = display.newText("Return to Hunt ...", successMessage.width/4,0,"Helvetica",13)
				messageLabel:setTextColor(0,0,0)

				successGroup:insert(successMessage)
				successGroup:insert(messageLabel)
				successGroup:setReferencePoint(display.CenterReferencePoint)
				successGroup.x = _W/2
				successGroup.y = _H/3*2
				successGroup.alpha = 1
				localGroup:insert(successGroup)
				successMessage:addEventListener("touch",changeScene)
			end

		end

	elseif event.phase == "ended" and event.target.x ~= dropTainer[objectNum].x and event.target.y ~= dropTainer[objectNum].y then
			event.target.x = event.target.markX
			event.target.y = event.target.markY
			display.getCurrentStage():setFocus(nil)
	
    end
  return true
end


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
 local randomNumber = math.random(4)
for i = 1,4 do

-- Create four droppable photos
	
dragImage = display.newImageRect(skullTable[randomNumber],system.DocumentsDirectory,_W/2.8,_H/6)
	dragImage.x = xValue
	dragImage.y = yValue*.75
	if (i == 1) or (i == 3) then
		xValue = xValue *2.75
	end
	if (i == 2) then
		xValue = xValue / 2.75
		yValue = yValue *1.33
	end

	dragImage.j = randomNumber
	dragImage.ID = skullTable[randomNumber]
	dragImage.l = "isDraggable"
	dragImage:addEventListener( "touch", dragPix )
	draggables:insert(dragImage)
	if(randomNumber < 4) then
			randomNumber = randomNumber+1
		else
			randomNumber = 1
		end
  end
  localGroup:insert(draggables)
end

if event then

	if event.phase == "began" then
	
	for k = draggables.numChildren, 1 , -1 do
		if(draggables[k].l == "isDraggable") then
			draggables[k]:removeEventListener("touch",dragPix)
			draggables[k]:removeSelf()
			
		end
	end
	successGroup.alpha = 0
	photosPlaced = 0
	xValue = _W/3.75
	yValue = yValue/1.33
	setPhotos()
	end

else 
xValue = _W/3.75
yValue = yValue *2.1
setPhotos()


end
end
placePhotos()

local buttonGroup = display.newGroup()
local button = display.newRect(0,0,88,33)

buttonLabel = display.newText("Reset", button.width/3,0,"Helvetica",13)
buttonLabel:setTextColor(0,0,0)

buttonGroup:insert(button)
buttonGroup:insert(buttonLabel)
buttonGroup:setReferencePoint(display.CenterReferencePoint)
buttonGroup.x = _W/2
buttonGroup.y = _H/3*2.85
stemLabel = display.newText(stem,30,_H/3*2.5,"Helvetica",16)
stemLabel:setTextColor(255,255,255)

localGroup:insert(buttonGroup)
button:addEventListener("touch",placePhotos)
	return localGroup
end