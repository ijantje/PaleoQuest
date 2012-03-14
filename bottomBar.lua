--this is the tab bar at the bottom of the screen.  


--init globals
_H = display.contentHeight;
_W = display.contentWidth;



local barGroup = display.newGroup()


local bottombar = display.newImageRect("images/bottombar320x54.png", 320, 54)
bottombar:setReferencePoint(display.CenterReferencePoint)
bottombar.x = bottombar.width/2
bottombar.y = _H - 27
barGroup:insert(bottombar)


local btn_picker = display.newImageRect("images/btn_picker44x44.png", 44, 44)
btn_picker:setReferencePoint(display.CenterReferencePoint)
btn_picker.x = bottombar.width/6
btn_picker.y = bottombar.y
btn_picker.scene = "picker"
barGroup:insert(btn_picker)

local btn_map= display.newImageRect("images/btn_map44x44.png", 44,44)
btn_map:setReferencePoint(display.CenterReferencePoint)
btn_map.x = bottombar.width/2
btn_map.y = bottombar.y
btn_map.scene = "map"
barGroup:insert(btn_map)

local btn_bag = display.newImageRect("images/btn_bag44X44.png", 44,44)
btn_bag:setReferencePoint(display.CenterReferencePoint)
btn_bag.x = bottombar.width - bottombar.width/6
btn_bag.y = bottombar.y
btn_bag.scene = "bag"
barGroup:insert(btn_bag)