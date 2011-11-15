--multichoice

module(..., package.seeall)

function new(params)
if type(params) == "table" then
	print ("Param table exists")
	question_ID = params.questionID
end

	local localGroup = display.newGroup()
	
	local click = audio.loadSound("click.wav")
	
	local menuDescr = "Multiple choice activity"
	local menuInstr = "What is in the paleontologist's hand?"
	
	local bg = display.newImageRect("images/bg320x372.png", 320, 372)
	bg:setReferencePoint(display.CenterReferencePoint)
	bg.x = bg.width/2
	bg.y = bg.height/2
	localGroup:insert(bg)
	
	
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

	
	function changeScene(event)
		if(event.phase == "ended") then
			audio.play(click)
			director:changeScene(event.target.scene)
			print(event.target.scene)
		end
	end
	
	local myDescr = autoWrappedText(menuDescr, native.systemFont, 18, {40, 65, 30}, display.contentWidth - 25);
	myDescr:setReferencePoint(display.CenterReferencePoint)
	myDescr.x = bg.width/2
	myDescr.y = myDescr.height
	localGroup:insert(myDescr)
	
	local myInstr = autoWrappedText(menuInstr, native.systemFont, 18, {100, 30, 30}, display.contentWidth - 25);
	myInstr:setReferencePoint(display.CenterReferencePoint)
	myInstr.x = bg.width/2
	myInstr.y = myDescr.height + myInstr.height/2 + 20
	localGroup:insert(myInstr)
	
	--copy your code here
	
	--import the ui file to create buttons
	local ui = require("ui")
	
	local choices = {"A long knife", "A shovel", "Three eggs", "His hat"}
	correct = "A shovel"
	local correct_wav = audio.loadSound("correct.wav")
	local incorrect_wav = audio.loadSound("incorrect.wav")
	
	local btnEventHandler = function (event)
	print(event.target.id)
	if(correct == event.target.id) then
		audio.play(correct_wav)
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
				default = img, defaultX = 200, defaultY = 50,
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


	local myChoices = makeBtns(choices,"images/btn_choice.png","vertical",_W/2,230)
	
	
	return localGroup
end