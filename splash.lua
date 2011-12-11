--Use this for testing your scene changes

module(..., package.seeall)

function new()
	localGroup = display.newGroup()

	local titleText = display.newText("You are now at the next scene", 0, 0, native.systemFontBold, 14)
	titleText:setTextColor(100, 200, 200)
	titleText.x = display.contentWidth/2
	titleText.y = display.contentHeight/2
	localGroup:insert(titleText)

	return localGroup
end