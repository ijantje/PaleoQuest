--FIB.lua for Fill-In the Blank Questions

module(..., package.seeall)

--init globals
_H = display.contentHeight
_W = display.contentWidth

if type(params) == "table" then
	print("It is a table.")
	qID = params.questionID
end
	
require "ui"

--change scene function for director
function changeScene(event)
		if(event.phase == "ended") then
			audio.play(click)
			director:changeScene(event.target.scene,"fade")
		end
	end

-- Parameters
local qID


--new group function for director
function new()
	localGroup = display.newGroup()

--[[


	local titleText = display.newText("You are now at the next scene", 0, 0, native.systemFontBold, 14)
	titleText:setTextColor(100, 200, 200)
	titleText.x = display.contentWidth/2
	titleText.y = display.contentHeight/2
	localGroup:insert(titleText)
	
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

	]]

local questionDescription
local correct
--local choices
local answer1 -- forward reference (needed for Lua closure)
local answerText

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

local sqlQuery = "SELECT * FROM type_fill_in_blank WHERE question_id = "..qID

db:exec(sqlQuery)

for row in db:nrows(sqlQuery) do 
	questionDescription = row.stem
 	correct = row.answer
end
 
 print(questionDescription)

local correctSound = audio.loadSound("correct.wav")
local errorSound = audio.loadSound("incorrect.wav")

	-- TextField Listener
local function fieldHandler( getObj )
        
        return function( event )
 
                print( "TextField Object is: " .. tostring( getObj() ) )
                
                if ( "began" == event.phase ) then
                        -- This is the "keyboard has appeared" event
                
                elseif ( "ended" == event.phase ) then
                        -- This event is called when the user stops editing a field:
                        -- for example, when they touch a different field or keyboard focus goes away
                
                        print( "Text entered = " .. tostring( getObj().text ) )         -- display the text entered
						answerText = tostring(getObj().text)
						--answerVerify()
                        
                elseif ( "submitted" == event.phase ) then
                        -- This event occurs when the user presses the "return" key
                        -- (if available) on the onscreen keyboard
                        
                        -- Hide keyboard
                        native.setKeyboardFocus( nil )
						--answerVerify()
                end
                
        end     -- "return function()"
 
end
 
answer1 = native.newTextField( _W/2-100, _H/2, 200, 50,
      fieldHandler( function() return answer1 end ) )
-- passes the text field object


----------------------------------------
-- This correct answer would be retrieved from the database associated with question1
----------------------------------------

--correct1 = "carnivore"

----------------------------------------
-- This function wraps the text on the screen for the stem text
----------------------------------------

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

----------------------------------------
-- This code is the function to verify the answer
----------------------------------------

local answerVerify = function (event)
	answer1.inputType = "default"
	--answerText = "barrel"
	answerText = answer1.text;
	answerText = (string.lower(answerText))
	--print (string.upper(answer1))
	--print(answer1)
	if(correct == answerText) then
		audio.play(correctSound)
		--winLose("right");
		local params = {correctAnswered = qID}
		print(params)
		--director:changeScene(params, "bag")
	end
	if(correct ~= answerText) then
		audio.play(errorSound)
		--winLose("wrong")
	end
end


----------------------------------------
-- loads button on display for answer
----------------------------------------

local answerBtn = ui.newButton{
	default = "btn_answer.png",
	over = "btn_answer1.png",
	x = _W/2,
	y = _H - 75,
	--onPress=answerVerify
	}


----------------------------------------
-- This is the variable to display the stem
----------------------------------------
local askQuestion = autoWrappedText(questionDescription, native.systemFont, 20, {210, 170, 100}, display.contentWidth-10);
askQuestion.x = 10
askQuestion.y = 75

----------------------------------------
-- This code runs the answer verify function when the enter button is tapped
----------------------------------------

answerBtn:addEventListener( "touch", answerVerify )

return localGroup
end
