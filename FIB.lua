--Use this for testing your scene changes

module(..., package.seeall)

function changeScene(event)
		if(event.phase == "ended") then
			audio.play(click)
			director:changeScene(event.target.scene,"fade")
		end
	end

function new()
	localGroup = display.newGroup()

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

	return localGroup
end