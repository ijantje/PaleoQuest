--globals
_H = display.contentHeight
_W = display.contentWidth

display.setStatusBar(display.HiddenStatusBar);

local director = require("director")

local mainGroup = display.newGroup()

local function main()
	mainGroup:insert(director.directorView)
	director:changeScene("menu")
	return true
end

main()