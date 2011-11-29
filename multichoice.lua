--multichoice.lua for multiple choice questions

module(..., package.seeall)

--init globals
_H = display.contentHeight;
_W = display.contentWidth;

local questionDescription
local qID = 1
local correct
local choices

--[[
function new(params)

if type(params) == "table" then
	qID = params.questionID
end
]]

--import the ui file to create buttons
local ui = require("ui")

--include sqlite db
require "sqlite3"

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

local sqlQuery = "SELECT * FROM type_multi_choice WHERE questionID = "..qID

db:exec(sqlQuery)

for row in db:nrows(sqlQuery) do 
	questionDescription = row.stem
 	correct = row.answer
 	choices = {row.answer, row.distractor1, row.distractor2, row.distractor3}
 end
 
 print(questionDescription)


local correct_wav = audio.loadSound("correct.wav")
local incorrect_wav = audio.loadSound("incorrect.wav")


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


local btnEventHandler = function (event)
	print(event.target.id)
	if(correct == event.target.id) then
		audio.play(correct_wav)
		local params = {correctAnswered = qID}
		director:changeScene(params, "bag")
	end
	if(correct ~= event.target.id) then
		audio.play(incorrect_wav)
	end
end

--loop through each item in the array to: (a) loop through the table fed as an argument to load the sound, and (b) create the button 
local function makeBtns(btnList,btnImg,layout,groupXPos,groupYPos)
	--first, let's place all the buttons inside a button group, so we can move them together
	local thisBtnGroup = display.newGroup();
	for index,value in ipairs(btnList) do 
		local img = btnImg 
		local thisBtn = ui.newButton{
			defaultSrc = img, defaultX = 200, defaultY = 50,
			overSrc = img, overX = 180, overY = 50,
			onPress = btnEventHandler,
			text = value,
			size = 14
		}
		thisBtn.id = value
		thisBtnGroup:insert(thisBtn)
		--lay the buttons out either horizontally or vertically
		if (layout == "horizontal") then 
			thisBtn.x = (index -1) * thisBtn.width
		elseif (layout == "vertical") then
			thisBtn.y = (index-1)*thisBtn.height
		end
	end
	thisBtnGroup.x = groupXPos; thisBtnGroup.y = groupYPos
	return thisBtnGroup
end

function new()

	localGroup = display.newGroup()

	local myDescr = autoWrappedText(questionDescription, native.systemFont, 20, {210, 170, 100}, display.contentWidth);
	myDescr.x = 10
	myDescr.y = 75
	localGroup:insert(myDescr)
	
	local myChoices = makeBtns(choices,"images/btn_bg.png","vertical",_W/2,250)
	localGroup:insert(myChoices)

	return localGroup
end