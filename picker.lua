module(..., package.seeall)

print("This in _H in picker: ".._H)
local tableView = require("tableView")
local ui = require("ui")

--include sqlite db
require "sqlite3"

local screenOffsetW = display.contentWidth -  display.viewableContentWidth
local screenOffsetH = display.contentHeight - display.viewableContentHeight

local detailScreen
local myList
local background
local backBtn
local startBtn

local title
local points
local subtitle

local data = {}
local dTitle
local dPoints
local dSubtitle
local dLearn
local dTime
local dTopic
local dLoc
local dDiff
local id


local dText1
local dText2
local dText3
local dText4
local dText5
local dText6
local dText7

local avatar_text
local avatarID_desc = "Rex"
local a_blue
local a_green
local a_orange
local a_red

questID = 0
avatarID = 1
userID = 1

_G.userID = userID


local topBoundary = display.screenOriginY + 40
local bottomBoundary = display.screenOriginY + 0

--set the database path 
local path = system.pathForFile("tp_quests.sqlite",system.ResourceDirectory)

--open dbs
db = sqlite3.open(path)


--handle the applicationExit even to close the db
local function onSystemEvent (event)
	if (event.type == "applicationExit") then
		db:close()
	end
end

local sqlQuery = "SELECT * FROM QuestInfo"

db:exec(sqlQuery)

local q = 1

for row in db:nrows(sqlQuery) do 
	data[q] = {}
	data[q].qTitle = row.title
	data[q].qDesc = row.description
	data[q].qLoc = row.location
	data[q].qDiff = row.difficulty
	data[q].qLearn = row.learningOutcomes
	data[q].qTime = row.time
	data[q].qTopic = row.topic
	data[q].qPoints = row.points
	q = q + 1
 end

local function autoWrappedText(text, font, size, color, width)
	--print("text: " .. text)
	  if text == '' then return false end
	  font = font or native.systemFont
	  size = tonumber(size) or 12
	  color = color or {255, 255, 255}
	  width = width or display.stageWidth
	 
	  local result = display.newGroup()
	  local lineCount = 0
	  -- do each line separately
	  for line in string.gmatch(text, "[^\n]+") do
		local currentLine = ''
		local currentLineLength = 0 -- the current length of the string in chars
		local currentLineWidth = 0 -- the current width of the string in pixs
		local testLineLength = 0 -- the target length of the string (starts at 0)
		-- iterate by each word
		for word, spacer in string.gmatch(line, "([^%s%-]+)([%s%-]*)") do
		  local tempLine = currentLine..word..spacer
		  local tempLineLength = string.len(tempLine)
		  -- test to see if we are at a point to try to render the string
		  if testLineLength > tempLineLength then
			currentLine = tempLine
			currentLineLength = tempLineLength
		  else
			-- line could be long enough, try to render and compare against the max width
			local tempDisplayLine = display.newText(tempLine, 0, 0, font, size)
			local tempDisplayWidth = tempDisplayLine.width
			tempDisplayLine:removeSelf();
			tempDisplayLine=nil;
			if tempDisplayWidth <= width then
			  -- line not long enough yet, save line and recalculate for the next render test
			  currentLine = tempLine
			  currentLineLength = tempLineLength
			  testLineLength = math.floor((width*0.9) / (tempDisplayWidth/currentLineLength))
			else
			  -- line long enough, show the old line then start the new one
			  local newDisplayLine = display.newText(currentLine, 0, (size * 1.3) * (lineCount - 1), font, size)
			  newDisplayLine:setTextColor(color[1], color[2], color[3])
			  result:insert(newDisplayLine)
			  lineCount = lineCount + 1
			  currentLine = word..spacer
			  currentLineLength = string.len(word)
			end
		  end
		end
		-- finally display any remaining text for the current line
		local newDisplayLine = display.newText(currentLine, 0, (size * 1.3) * (lineCount - 1), font, size)
		newDisplayLine:setTextColor(color[1], color[2], color[3])
		result:insert(newDisplayLine)
		lineCount = lineCount + 1
		currentLine = ''
		currentLineLength = 0
	  end
	  result:setReferencePoint(display.TopLeftReferencePoint)
	  return result
	end

function listButtonRelease( event )
		self = event.target
		id = self.id
				print(self.id)
		questID = id
				
		dTitle = data[id].qTitle
		dPoints = data[id].qPoints
		dSubtitle = data[id].qDesc
		dLearn = data[id].qLearn
		dTime = data[id].qTime
		dTopic = data[id].qTopic
		dLoc = data[id].qLoc
		dDiff = data[id].qDiff
 
		dText1 = autoWrappedText(dTitle , native.systemFont, 14, {40,65,30}, display.contentWidth - 24) 
		detailScreen:insert(dText1)
		dText1.x = 12
		dText1.y = 0 + dText1.height + topBoundary
		
		dText2 = autoWrappedText(dSubtitle, native.systemFont, 12, {80,115,165}, display.contentWidth - 24) 
		detailScreen:insert(dText2)
		dText2.x = 12
		dText2.y = dText1.y + dText1.height + 12
		
		dText3.text = "Points: "..dPoints
		dText3:setTextColor(100, 30, 30)
		dText3.x = dText3.width/2 + 12
		dText3.y = dText2.y + dText2.height + dText3.height/2 + 12
		
		dText4 = autoWrappedText("Learning Outcomes: "..dLearn, native.systemFont, 12, {90,145,70}, display.contentWidth - 24)
		detailScreen:insert(dText4)
		dText4.x = 12
		dText4.y = dText3.y + dText3.height
		
		dText5.text = "Estimated time: "..dTime
		dText5:setTextColor(220,140,50)
		dText5.x = dText5.width/2 + 12
		dText5.y = dText4.y + dText4.height + dText5.height/2 + 12
		
		dText6 = autoWrappedText("Locations: "..dLoc, native.systemFont, 12, {180,55,55}, display.contentWidth - 24)
		detailScreen:insert(dText6)
		dText6.x = 12
		dText6.y = dText5.y + dText5.height
		
		dText7.text = "Difficulty: "..dDiff
		dText7:setTextColor(40,60,85)
		dText7.x = dText7.width/2 + 12
		dText7.y = dText6.y + dText6.height + dText7.height/2 + 12

		avatar_text.text = "Select a guide: You guide is named "..avatarID_desc
		avatar_text:setTextColor(80,115,165)
		avatar_text.x = display.contentWidth/2
		avatar_text.y = display.contentHeight - a_blue.height - 12 - avatar_text.height
		
		transition.to(myList, {time=400, x=display.contentWidth*-1, transition=easing.outExpo })
		transition.to(detailScreen, {time=400, x=0, transition=easing.outExpo })
		transition.to(backBtn, {time=400, x=math.floor(backBtn.width/2) + screenOffsetW*.5 + 6, transition=easing.outExpo })
		transition.to(backBtn, {time=1000, alpha=1 })	
		transition.to(startBtn, {time=400, x=-math.floor(startBtn.width/2) + display.contentWidth - 6, transition=easing.outExpo })
		transition.to(startBtn, {time=1000, alpha=1 })	
		delta, velocity = 0, 0
	end

function backBtnRelease( event )
	print("back button released")
	
	detailScreen:remove(dText1)
	detailScreen:remove(dText2)
	detailScreen:remove(dText4)
	detailScreen:remove(dText6)
	
	transition.to(myList, {time=400, x=0, transition=easing.outExpo })
	transition.to(detailScreen, {time=400, x=display.contentWidth, transition=easing.outExpo })
	transition.to(backBtn, {time=400, x=0 - math.floor(backBtn.width/2) - backBtn.width, transition=easing.outExpo })
	transition.to(backBtn, {time=10, alpha=0 })
	transition.to(startBtn, {time=400, x=0 - math.floor(startBtn.width/2) - startBtn.width, transition=easing.outExpo })
	transition.to(startBtn, {time=10, alpha=0 })
	delta, velocity = 0, 0
end

function startBtnRelease(event)
	print("start button released")
	_G.questID = questID
	_G.avatarID = avatarID
	director:changeScene("map") --open map.lua file
end

function avatarChooserBlue(event)
	print("Click")
	avatarID = 1
	avatarID_desc = "Rex"
	avatar_text:setTextColor(80,115,165)
	avatar_text.text = "Select a guide: You guide is named "..avatarID_desc
end
function avatarChooserGreen(event)
	print("Click")
	avatarID = 2
	avatarID_desc = "Spike"
	avatar_text:setTextColor(90,145,70)
	avatar_text.text = "Select a guide: You guide is named "..avatarID_desc
end
function avatarChooserOrange(event)
	print("Click")
	avatarID = 3
	avatarID_desc = "Amber"
	avatar_text:setTextColor(220,140,50)
	avatar_text.text = "Select a guide: You guide is named "..avatarID_desc
end
function avatarChooserRed(event)
	print("Click")
	avatarID = 4
	avatarID_desc = "Ruby"
	avatar_text:setTextColor(180,55,55)
	avatar_text.text = "Select a guide: You guide is named "..avatarID_desc
end

function new()

	localGroup = display.newGroup()
	
	--Add a background
	background = display.newImage("images/screenBg.png")
	localGroup:insert(background)
	
	--detailScreen
	detailScreen = display.newGroup()
		detailScreen.x = display.contentWidth
	
		local detailBg = display.newRect(0,0,display.contentWidth,display.contentHeight-display.screenOriginY)
		detailBg:setFillColor(230,215,180)
		detailScreen:insert(detailBg)

		dText3 = display.newText("Points: ", 0, 0, native.systemFontBold, 12 )
		detailScreen:insert(dText3)
		
		dText5 = display.newText("Estimated time: ", 0, 0, native.systemFontBold, 12 )
		detailScreen:insert(dText5)
		
		dText7 = display.newText("Difficulty: ", 0, 0, native.systemFontBold, 12 )
		detailScreen:insert(dText7)
		
		avatar_text = display.newText("Text", 0, 0, native.systemFontBold, 12 )
			detailScreen:insert(avatar_text)
		
		a_blue = display.newImageRect("images/avatar_blue.png", 83, 67)
			a_blue:setReferencePoint(display.CenterReferencePoint)
			a_blue.x = a_blue.width/2 + 12
			a_blue.y = display.contentHeight - a_blue.height/2 - 12
			a_blue:addEventListener("tap", avatarChooserBlue)
			detailScreen:insert(a_blue)
			
		a_green = display.newImageRect("images/avatar_green.png", 79, 47)
			a_green:setReferencePoint(display.CenterReferencePoint)
			a_green.x = a_blue.width + a_green.width/2 + 12
			a_green.y = display.contentHeight - a_green.height/2 - 12
			a_green:addEventListener("tap", avatarChooserGreen)
			detailScreen:insert(a_green)
			
		a_orange = display.newImageRect("images/avatar_orange.png", 68, 50)
			a_orange:setReferencePoint(display.CenterReferencePoint)
			a_orange.x = a_blue.width + a_green.width + a_orange.width/2 + 22
			a_orange.y = display.contentHeight - a_orange.height/2 - 12
			a_orange:addEventListener("tap", avatarChooserOrange)
			detailScreen:insert(a_orange)
			
		a_red = display.newImageRect("images/avatar_red.png", 64, 58)
			a_red:setReferencePoint(display.CenterReferencePoint)
			a_red.x = a_blue.width + a_green.width + a_orange.width + a_red.width/2 + 20
			a_red.y = display.contentHeight - a_red.height/2 - 12
			a_red:addEventListener("tap", avatarChooserRed)
			detailScreen:insert(a_red)
	
		
		

	localGroup:insert(detailScreen)
	
	--add My List
	myList = tableView.newList{
		data=data,
		default="images/listItemBg_white.png",
		over="images/listItemBg_over.png",
		onRelease=listButtonRelease,
		top=topBoundary,
		bottom=bottomBoundary,
		callback = function( row )
		local g = display.newGroup()
		
		--[[
		local img = display.newImage(row.image)
		g:insert(img)
		img.x = math.floor(img.width/2 + 6)
		img.y = math.floor(img.height/2)
		]]
	
		title =  display.newText( row.qTitle, 0, 0, native.systemFontBold, 14 )
		title:setTextColor(40, 65, 30)
		g:insert(title)
		title.x = title.width/2 + 6
		title.y = 15
		
		
		points =  display.newText( "Points: " ..row.qPoints, 0, 0, native.systemFontBold, 10 )
		points:setTextColor(100, 30, 30)
		g:insert(points)
		points.x = display.contentWidth - points.width/2
		points.y = 15

	
		subtitle = autoWrappedText(row.qDesc, native.systemFont, 12, {0, 0, 0}, display.contentWidth - 24)
		--subtitle:setTextColor(255,255,255)
		g:insert(subtitle)
		subtitle.x = 12
		subtitle.y = title.y + title.height

		
		return g
	end
	}
	localGroup:insert(myList)
	
	-- Add nav bar
	local navBar = ui.newButton{
		default = "images/navBar.png",
		onRelease = scrollToTop
	}
	
	navBar.x = display.contentWidth*.5
	navBar.y = math.floor(display.screenOriginY + navBar.height*0.5)
	
	localGroup:insert(navBar)
	
	
	--Add nav header
	local navHeader = display.newText("Pick an expedition", 0, 0, native.systemFontBold, 16)
	navHeader:setTextColor(255, 255, 255)
	navHeader.x = display.contentWidth*.5
	navHeader.y = navBar.y
	
	localGroup:insert(navHeader)
	
	--Setup the back button
	backBtn = ui.newButton{ 
		default = "images/backButton.png", 
		over = "images/backButton_over.png", 
		onRelease = backBtnRelease
	}
	
	backBtn.x = 0 - math.floor(backBtn.width/2) - backBtn.width
	backBtn.y = navBar.y 
	backBtn.alpha = 0
	
	localGroup:insert(backBtn)
	
	--setup start button
	startBtn = ui.newButton{ 
		default = "images/startButton.png", 
		over = "images/startButton_over.png", 
		onRelease = startBtnRelease
	}
	
	startBtn.x = 0 - math.floor(startBtn.width/2) - startBtn.width
	startBtn.y = navBar.y 
	startBtn.alpha = 0
	
	localGroup:insert(startBtn)

	return localGroup
end

