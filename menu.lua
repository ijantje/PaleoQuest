module(..., package.seeall)

-- load director module file
local director = require("director");

--Hide status bar
--display.setStatusBar( display.HiddenStatusBar )

--require ui for button over
local ui = require("ui")

--load theme sound to play
local theme = audio.loadSound("theme.wav")

function new()

	localGroup = display.newGroup()


--create variables for images
local screenBg = display.newImage("images/screenBg.png");
local splashBg = display.newImage("images/splashScreen.png");



--Create background and insert photo
local splash = display.newGroup();

splash:insert (screenBg)
splash:insert (splashBg)
localGroup:insert(splash)

--AUDIO TURNED OFF FOR NOW
--play audio theme
--audio.play(theme)

--local bg = display.newGroup();
--bg:insert(screenBg);

--local splashBG = display.newGroup();
--splashBG:insert(splashBg);

--[[
--setup start button
startBtn = ui.newButton{ 
		default = "startButton.png", 
		over = "startButton_over.png", 
		onRelease = startBtnRelease
	}
	
	startBtn.x = _W/2 + startBtn.width
	startBtn.y = _H - 30

function begin(event)
	if(event.phase == "ended" or event.phase == "cancelled") then
			print("Start Button Pushed")
	end
end

startBtn:addEventListener("touch", begin)
]]

function loadPicker()
splash:removeSelf()
splash = nil

--CHANGED TO PICKER TO SPEED DEVELOPMENT
director:changeScene("picker")
print("Splash screen terminated handed off to picker" .. _H .. _W)
end

timer.performWithDelay(1000, loadPicker)

return localGroup
end