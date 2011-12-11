display.setStatusBar( display.HiddenStatusBar )

--[[ to do still
1. get the actual global information and concatenate those on the appropriate db calls, strings, etc.
2. when the user answers all the questions correctly, show a quick animation of the card being shrunk and added to their pack of cards.
3. insert the menubar at the bottom of the screen
4. Show an animation of the transition between answering a new question (onSuccess) and simply going to the bag
]]

module(..., package.seeall)
--init globals
_H = display.contentHeight;
_W = display.contentWidth;
local director = require("director")

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
query = "SELECT topic, dino_card FROM `QuestInfo` WHERE questID = ".._G.questID
for row in questDB:nrows(query) do 
	questInfo.dino = row.dino_card
	questInfo.era = row.topic
end
questInfo.dinoCard = questInfo.era.."/"..questInfo.dino..".jpg"
print("Card is "..questInfo.dinoCard)
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
		else questInfo.completed = 0
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
	if (questInfo.completed ~= 0) then
		local img = display.newImage(puzzleImg)
		img:setReferencePoint(display.CenterReferencePoint)
		img.width = display.contentWidth
		img.height = display.contentHeight
		--now create a mask
		if (questInfo.completed ~= questInfo.totalNum ) then
			print("maskImg= "..maskImg)
			local mask = graphics.newMask(maskImg)
			--apply the mask to the image
			print("we do make it past the mask")
			img:setMask(mask)
		end
		return img
	end
end

function new()
	localGroup = display.newGroup()
			
		--create the puzzle image	
		local picPath = "images/cards/"..questInfo.dinoCard
	--check to see if they've answered all the questions or not --
	if (questInfo.totalNum == questInfo.completed) then
		--the user has answered all the questions, so don't apply a mask to the img.  There's also no need to show the back of the card
		local img = createPuzzlePiece(picPath)
		local msg = "You've earned the "..questInfo.dino.." card!"
		--To Do: make sure to add the card to the user's deck in the datbase
		function showMsg() 
					local msgGrp = display.newGroup()
					msgGrp:setReferencePoint(display.CenterReferencePoint)
					local background = display.newRect(0,0,_W, 50) 
					local msg = display.newText(msg,20,0,native.systemFont,14)
					msg:setTextColor(0,0,0)
					msgGrp:insert(background)
					msgGrp:insert(msg)
					msgGrp.y = _H/2;
					--msgGrp.x = 20;
					localGroup:insert(msgGrp)
						local id = ""
		end
		function goHome()
			director:changeScene("picker")
		end
		
		--create a sound
					local avatar = _G.avatarID
					print("Your avatar is "..avatar)
					if (avatar == 1) then
						id = "Rex"
					elseif (avatar == 2) then
						id = "Spike"
					elseif (avatar == 3) then
						id = "Amber"
					else 
						id = "Ruby"
					end
					
					local mySound = audio.loadSound(string.lower(id).."Congratulations.wav")
					audio.play(mySound)

		
		timer.performWithDelay(500,showMsg)
		timer.performWithDelay(4500,goHome)
	else 
		--show default img (back of the card)
		local defaultCard = display.newImageRect("images/cards/defaultCard.jpg",320,440)
		defaultCard:setReferencePoint(display.TopLeftReferencePoint)
		defaultCard.x = 0;
		defaultCard.y =0;
		localGroup:insert(defaultCard)
		
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