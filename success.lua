--to do 
--1. need to run a timer and then move on to the bag, letting itknow I'm coming from success.

module(..., package.seeall)

display.setStatusBar( display.HiddenStatusBar )
_H = display.contentHeight;
_W = display.contentWidth;

local director = require('director')

--get the info for sprites from spriteloq
loq_DeclareGlobals = true
require('loq_util')
local sf = require('loq_sprite').newFactory('sheet')

local function moveOn() 
	local params = {success=1}
	print("success: "..params.success)
	director:changeScene(params,"bag")
end
timer.performWithDelay(2000, moveOn)

function new(params)

	localGroup = display.newGroup()
	local id = ""
	local avatar = _G.avatarID
	print("Your avatar is "..avatar)
	if (avatar == 1) then
		id = "Rex"
	elseif (avatar == 2) then
		id = "Spike"
	elseif (avatar == 3) then
		id = "Amber"
	else 
		id = "Ruby"
	end
	
	local dino = sf:newSpriteGroup(id)
	dino:translate(_W/2,_H/2+80)
	dino.xScale = .8; dino.yScale = .8
	dino:play()
	
	localGroup:insert(dino)
	
	return localGroup
end
	
	