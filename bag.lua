display.setStatusBar( display.HiddenStatusBar )

--[[ to do still
1. get the actual global information and concatenate those on the appropriate db calls, strings, etc.
2. when the user answers all the questions correctly, show a quick animation of the card being shrunk and added to their pack of cards.
3. insert the menubar at the bottom of the screen
4. Show an animation of the transition between answering a new question (onSuccess) and simply going to the bag
]]

module(..., package.seeall)

function changeScene(event)
		if(event.phase == "ended") then
			audio.play(click)
			director:changeScene(event.target.scene,"fade")
		end
	end

----------------------------------------------------
--get db info
----------------------------------------------------
require "sqlite3"


--frst, figure out how many questions there are in this quest
local questPath = system.pathForFile("tp_quests.sqlite",system.ResourceDirectory)
questDB = sqlite3.open(questPath)
local query = "SELECT COUNT(question_id) as totalNum FROM `quest_questions` WHERE quest_id = ".._G.questID
local questInfo ={}
for row in questDB:nrows(query) do
	if row.totalNum > 5 then
		questInfo.totalNum = row.totalNum
	else questInfo.totalNum = 6
	end
end
print("there are "..questInfo.totalNum.." questions in this quest")

--also need to know the appropriate card for this db.  Get this once you update the db
questInfo.dinoCard = "erasmasaurus_platysaurus.jpg"
questDB:close()

--now find out how many questions have been answered
	--I first have to grab the progress ID, using the user_id and the quest_id
	local userPath = system.pathForFile("tp_user.sqlite",system.ResourceDirectory)
	userDB = sqlite3.open(userPath)
	query = "SELECT prog_id FROM progress WHERE user_id=1 AND quest_id=1"
	for row in userDB:nrows(query) do 
		questInfo.progress_id = row.prog_id
	end

	--with the prog_id in hand I can now figure out how many questions the user has answered in this quest
	query = "SELECT COUNT(question_completed) as complete FROM questions_completed WHERE progress_id=1"
	for row in userDB:nrows(query) do
		if row.complete > 0 then
			questInfo.completed = row.complete
		else questInfo.completed = 1
		end
	end
	print ("User 1 has answered "..questInfo.completed.." of "..questInfo.totalNum.." questions in this quest")
--
print("the progress ID is:" .. questInfo.progress_id)
userDB:close()
-------------------------// end db stuff //------------------------------

--function to add a mask to a puzzle piece.  
function createPuzzlePiece(puzzleImg,maskImg) 
	--get puzzle image
	local img = display.newImage(puzzleImg)
	img:setReferencePoint(display.CenterReferencePoint)
	img.width = display.contentWidth
	img.height = display.contentHeight
	--now create a mask
	print("maskImg= "..maskImg)
	local mask = graphics.newMask(maskImg)
	--apply the mask to the image
	print("we do make it past the mask")
	img:setMask(mask)
	return img
end

function new()
	localGroup = display.newGroup()
	
	--check to see if they've answered all the questions or not --
	if (questInfo.totalNum == questInfo.completed) then
		--the user has answered all the questions, so don't apply a mask to the img.  There's also no need to show the back of the card
	else 
		--show default img (back of the card)
		local defaultCard = display.newImageRect("images/cards/defaultCard.jpg",320,440)
		defaultCard:setReferencePoint(display.TopLeftReferencePoint)
		defaultCard.x = 0;
		defaultCard.y =0;
		localGroup:insert(defaultCard)
		
		--create the puzzle image	
		local picPath = "images/cards/"..questInfo.dinoCard
		
		print("this is the pic path: "..picPath)
		local puzzlePath = "images/puzzles/"..questInfo.totalNum.."/"..questInfo.completed..".jpg"
		print("this is the puzzlePath: "..puzzlePath)
		local img = createPuzzlePiece(picPath,puzzlePath)
		localGroup:insert(img)
	end
	
	
	
	
	---------------------------
	--btn to return to prev. scene
	---------------------------
	local successMessage = display.newRect(0,0,176,33)
				successMessage.scene = "map"
				local messageLabel = display.newText("Return to Hunt ...", successMessage.width/4,0,"Helvetica",13)
				messageLabel:setTextColor(0,0,0)
	local successGroup = display.newGroup()
				successGroup:insert(successMessage)
				successGroup:insert(messageLabel)
				successGroup:setReferencePoint(display.CenterReferencePoint)
				successGroup.x = _W/2
				successGroup.y = _H/3*2
				successGroup.alpha = 1
				localGroup:insert(successGroup)
				successMessage:addEventListener("touch",changeScene)

	return localGroup
end