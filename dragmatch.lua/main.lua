-- create object
local myObject = display.newRect( 0, 0, 100, 100 )
myObject:setFillColor( 255 )

-- touch listener function
function myObject:touch( event )
    if event.phase == "began" then

        self.markX = self.x    -- store x location of object
        self.markY = self.y    -- store y location of object

    elseif event.phase == "moved" then

        local x = (event.x - event.xStart) + self.markX
        local y = (event.y - event.yStart) + self.markY
        
        self.x, self.y = x, y    -- move object based on calculations above
    end
    
    return true
end

-- make 'myObject' listen for touch events
myObject:addEventListener( "touch", myObject )