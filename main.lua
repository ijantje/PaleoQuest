--globals
_H = display.contentHeight
_W = display.contentWidth

display.setStatusBar(display.HiddenStatusBar);

local director = require("director")

local mainGroup = display.newGroup()

local function main()
	mainGroup:insert(director.directorView)
	print("breaks after here")
	director:changeScene("picker")
	
	return true
end


main()