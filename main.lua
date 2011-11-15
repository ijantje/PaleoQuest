--set globals
_W = display.contentWidth
_H = display.contentHeight

-- load director module file
local director = require("director");

--Hide status bar
display.setStatusBar( display.HiddenStatusBar )

--create variables for images
local screenBg = display.newImage("images/screenBg.png");
local splashBg = display.newImage("images/splashScreen.png");


--Create background and insert photo
local splash = display.newGroup();

splash:insert (screenBg)
splash:insert (splashBg)

function loadPicker()
splash:removeSelf()
splash = nil
director:changeScene("picker")
end

timer.performWithDelay(3000, loadPicker)