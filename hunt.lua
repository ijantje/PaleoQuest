--hunt

module(..., package.seeall)

function new()
	local localGroup = display.newGroup()
	
	local click = audio.loadSound("click.wav")
	
	local menuDescr = "Hunt screen"
	local menuInstr = "This is the hunt screen. Here you pick a hunt.  Hunts have different difficulty levels.  Here there is a list of available hunts and saved progress of each attempted hunt for the signed in player on the info screen. Click the placeholder start button as if you had selected a hunt."
	
	local topbar = display.newImageRect("images/topbar320x54.png", 320, 54)
	topbar:setReferencePoint(display.CenterReferencePoint)
	topbar.x = topbar.width/2
	topbar.y = topbar.height/2
	localGroup:insert(topbar)
	
	local bg = display.newImageRect("images/bg320x372.png", 320, 372)
	bg:setReferencePoint(display.CenterReferencePoint)
	bg.x = bg.width/2
	bg.y = bg.height/2 + topbar.height
	localGroup:insert(bg)
	
	local bottombar = display.newImageRect("images/bottombar320x54.png", 320, 54)
	bottombar:setReferencePoint(display.CenterReferencePoint)
	bottombar.x = bottombar.width/2
	bottombar.y = bottombar.height/2 + bg.height + topbar.height
	localGroup:insert(bottombar)
	
	local btn_info = display.newImageRect("images/btn_info68x39.png", 68, 39)
	btn_info:setReferencePoint(display.CenterReferencePoint)
	btn_info.x = bottombar.width/6
	btn_info.y = bottombar.y
	btn_info.scene = "info"
	localGroup:insert(btn_info)
	
	local btn_hunt = display.newImageRect("images/btn_hunt68x39.png", 68, 39)
	btn_hunt:setReferencePoint(display.CenterReferencePoint)
	btn_hunt.x = bottombar.width/2
	btn_hunt.y = bottombar.y
	btn_hunt.scene = "hunt"
	localGroup:insert(btn_hunt)
	
	local btn_minis = display.newImageRect("images/btn_minis68x39.png", 68, 39)
	btn_minis:setReferencePoint(display.CenterReferencePoint)
	btn_minis.x = bottombar.width - bottombar.width/6
	btn_minis.y = bottombar.y
	btn_minis.scene = "minis"
	localGroup:insert(btn_minis)
	
	local btn_start = display.newImageRect("images/btn_start56x25.png", 56, 25)
	btn_start:setReferencePoint(display.CenterReferencePoint)
	btn_start.x = bottombar.width/2
	btn_start.y = 320
	btn_start.scene = "hunting"
	localGroup:insert(btn_start)
	
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
			director:changeScene({questID = 1},event.target.scene)
		end
	end
	
	btn_info:addEventListener("touch", changeScene)
	btn_hunt:addEventListener("touch", changeScene)
	btn_minis:addEventListener("touch", changeScene)
	btn_start:addEventListener("touch", changeScene)
	
	local myDescr = autoWrappedText(menuDescr, native.systemFont, 18, {40, 65, 30}, display.contentWidth - 25);
	myDescr:setReferencePoint(display.CenterReferencePoint)
	myDescr.x = topbar.width/2
	myDescr.y = topbar.height + myDescr.height
	localGroup:insert(myDescr)
	
	local myInstr = autoWrappedText(menuInstr, native.systemFont, 18, {100, 30, 30}, display.contentWidth - 25);
	myInstr:setReferencePoint(display.CenterReferencePoint)
	myInstr.x = topbar.width/2
	myInstr.y = topbar.height + myDescr.height + myInstr.height/2 + 20
	localGroup:insert(myInstr)
	
	return localGroup
end