-- Copyright 2011 Loqheart

--[[
    Module: loq_timeline

    Flash Timeline Animator

    Used in conjuction with Spriteloq SpriteGroups to animate data exported 
    from the Flash timeline using the Loqheart Timeline Exporter

    Supports classic tweens for translation, rotation, scaling with easing and custom eases.

    NOT supported the new motion tween, shape tween, orient to path, skew values.
]]


--Technical: Flash uses 3 eases.  
--Linear for interpolating between values without any ease.
--outQuad for interpolating between values with an ease. Used in conjunction with createPercentEase. 
--createPercentEase mixes a linear ease with an easying function.
--Bezier ease is used for custom eases.

if loq_DeclareGlobals then
    loq_declare('loq_timeline')
end

local TimelineFactory = {}

local function newTimelineFactory(_timelines, _sfactory)
    local tf = {
          sfactory = _sfactory
        , tldata = {}
        , tlnames = {}
        , instances = {}
        , nextId = 2 -- start off at 2 to force hash table
        , prevTime = system.getTimer()
        , enterFrame = TimelineFactory.enterFrame
    }

    local inmeta = {}
    inmeta.__mode = 'v'

    setmetatable(tf.instances, inmeta) -- weak tfinstances to avoid memory leak and dispatch to removed tfinstances

    for i, tlname in ipairs(_timelines) do
        local data = require(tlname)
        tf.tldata[tlname] = data
        table.insert(tf.tlnames, tlname)
        --data.step = 1000 / data.frameRate
    end

    tf.newTimeline = TimelineFactory.newTimeline
    tf.newChildTimeline = TimelineFactory.newChildTimeline
    tf.dispose = TimelineFactory.dispose

    Runtime:addEventListener('enterFrame', tf)

    return tf
end

local Timeline = {}

local function linearEase(t, b, c)
  return c * t + b
end

-- outQuad ease for standard Flash ease
local function createPercentEase(percent)
    percent = percent / 100
    return function (t, s, c)
       return (-c * t * (t - 2) + s) *percent + (c*t + s)*(1-percent)
    end
end

-- for custom eases does a bezier ease
local function customPropertyEaseVal(_t, _instance, _property)
    local propEase = _instance.customEase[_property]
    if #propEase == 0 then
        return _t
    end

    local startdx = _instance.curvedx[_property] * 3 + 1
    local enddx = startdx + 3
    
    if enddx ~= #propEase and _t >= propEase[enddx].x then
        _instance.curvedx[_property] = _instance.curvedx[_property] + 1
        startdx = enddx
        enddx = enddx + 3
    end

    _t = (_t - propEase[startdx].x) / (propEase[enddx].x - propEase[startdx].x)
    
    local p1 = propEase[startdx].y
    local cp1 = propEase[startdx+1].y
    local cp2 = propEase[startdx+2].y
    local p2 = propEase[startdx+3].y

    local bv = bezierValue(_t, p1, cp1, cp2, p2)
    return bv
end


local rotateVec = rotateVec2

function Timeline:animating()
    return self.m_animating
end

function Timeline:blendMode(_blendMode)
    self.blendMode = _blendMode
    error("blendMode is not supported on groups")
end

function Timeline:currentFrame(_frame)
    if _frame ~= nil then
        if _frame > self.data.frameCount then
            self:pause()
            error(self.tlname .. ' ' .. self.element.libraryItemName .. " Frame parameter: " .. _frame .. " is greater than frame count: " .. self.data.frameCount .. ' ' .. self.frameCount)
        else
            self.fdx = _frame
            self:update((self.fdx - 1) * math.ceil(self.step) + self.startTime)
        end
    end
    if self.fdx == nil then
        assert(self.firstFrame, 'first frame nil?')
        self.fdx = self.firstFrame
    end
    assert(self.fdx, 'fdx nil?')
    return self.fdx
end

function Timeline:getTimelineNames()
    return self.tf.tlnames
end

function Timeline:loop(_loop)
    if _loop == nil then
        return self.m_loop
    else 
        self.m_loop = _loop
    end
    return _loop
end

function Timeline:reset(_startTime)
    self.startTime = _startTime
    if self.startTime == nil then
        self.startTime = system.getTimer()
    end
    self.pfdx = nil
    self.fdx = self.firstFrame
end

function Timeline:play(_tlname, _keep, _sameLayering)
    if (_tlname ~= nil) and (not _keep or self:sequence() ~= _tlname) then
        self:prepare(_tlname, _sameLayering)
    end

    if not self.m_animating then
        self.m_animating = true

        self:reset(system.getTimer())
    end
end

function Timeline:pause()
    if self.m_animating then
        self.m_animating = false
    end
end

-- play through the tweens on the timeline onEnterFrame
function Timeline:update(_curTime) 
    local curTime = _curTime
    if _curTime == nil then
        curTime = system.getTimer()
    end

    local elapsed = (curTime - self.startTime) * self.m_timeScale

    self.fdx = math.floor(elapsed / self.step) + self.firstFrame

    --atrace(self.tlname .. " " .. self.fdx .. ' ' .. elapsed) 

    if self.fdx > self.data.frameCount then
        -- animation has finised
        if self.m_loop then
            self:reset(curTime)
            self:dispatchEvent(self.loopEvent)
        else
            self:pause()
            self:dispatchEvent(self.endEvent)
            return
        end
    end

    for idx, instance in pairs(self.instances) do
        local elapsedInstanceTime = (curTime - instance.startTime) * self.m_timeScale

        --interpolate between this and the next frame
        local t = elapsedInstanceTime / instance.duration
        if t > 1 then
            t = 1
        end

        local el = instance.element
        if instance.hasCustomEase then
            local bv

            bv = customPropertyEaseVal(t, instance, 'scale')
            instance.xScale = bv*el.diffXScale + el.xScale
            instance.yScale = bv*el.diffYScale + el.yScale

            bv = customPropertyEaseVal(t, instance, 'rotation')
            instance.rotation = bv*el.diffRotation + el.rotation
            --atrace(t .. ' ' .. bv .. ' ' .. instance.endRotation .. ' ' .. instance.startRotation .. ' ' .. instance.rotation)

            -- update the position based on the rotation and scaling
            bv = customPropertyEaseVal(t, instance, 'position')
            local xdiff = bv*(el.diffTransformX)
            local ydiff = bv*(el.diffTransformY)

            local sx = el.transformationPoint.x * (1-instance.xScale)
            local sy = el.transformationPoint.y * (1-instance.yScale)

            local nx, ny = rotateVec(instance.rotation, el.startX + sx - el.transformX, el.startY + sy - el.transformY)
            instance.x = nx + el.transformX + xdiff
            instance.y = ny + el.transformY + ydiff

            if el.diffAlpha ~= 0 then
                -- untested
                bv = customPropertyEaseVal(t, instance, 'alpha')
                instance.alpha = math.min(1, bv*el.diffAlpha + el.alpha)
            end
        elseif instance.tweenType == 'motion' then
            -- use the regular eases
            local easing = instance.easing

            instance.xScale = easing(t, el.xScale, el.diffXScale)
            instance.yScale = easing(t, el.yScale, el.diffYScale)
    
            instance.rotation = easing(t, el.rotation, el.diffRotation)
            
            -- update the position based on the rotation and scaling
            local xdiff = easing(t, 0, el.diffTransformX)
            local ydiff = easing(t, 0, el.diffTransformY)

            local sx = el.transformationPoint.x * (1-instance.xScale)
            local sy = el.transformationPoint.y * (1-instance.yScale)

            local nx, ny = rotateVec(instance.rotation, el.startX + sx - el.transformX, el.startY + sy - el.transformY)
            instance.x = nx + el.transformX + xdiff
            instance.y = ny + el.transformY + ydiff

            --instance.alpha = math.max(0, math.min(1, easing(t, instance.startAlpha, instance.diffAlpha)))
            instance.alpha = easing(t, el.alpha, el.diffAlpha)
        end


        --atrace('sx, sy ' .. sx .. ', ' .. sy) 
        --atrace(idx .. ' ' .. instance.x .. ' ' .. instance.y);
        
        if elapsedInstanceTime >= instance.duration then 
            if instance.tf ~= nil then
                --atrace('removeSelf ' .. instance.tlname .. ' idx ' .. idx .. ' fdx ' .. self.fdx)
            end
            --test1
            --instance:removeSelf()
            --atrace('remove instance ' .. instance.element.libraryItemName .. ' on fdx:' .. self.fdx .. ' idx:' .. idx)
            self.instances[idx] = nil
        end
    end

    if self.fdx ~= self.pfdx then
        self:dispatchEvent(self.nextEvent)

        local pfdx = self.pfdx
        if pfdx == nil then
            pfdx = 'nil'
        end

        for idx, instance in pairs(self.instances) do
            -- update the animations -- this is somewhat broken
            if instance.tf == nil then
                --if instance.loopType == 'loop' then
                    --local nextFrame = instance:currentFrame() + 1

                    --atrace(idx ..' ' .. instance.element.libraryItemName .. ' next ' .. nextFrame .. ' frameCount ' .. instance.frameCount)

                    --if nextFrame <= instance.frameCount then
                        --instance:currentFrame(nextFrame)
                    --else
                        ----atrace('firstFrame ' .. instance.firstFrame)
                        --instance:currentFrame(instance.firstFrame)
                    --end

                --elseif instance.loopType == 'play once' then
                if instance.loopType == 'play once' then
                    -- there's a bug here: Occasionally, curSprite in instance is like some zombie sprite with a nil sequence and nil currentFrame
                    -- it seems to happen when calling removeSelf 
                    if instance:currentFrame() == nil then
                        -- seems like instance should have been removed aborting the update this frame
                        return
                    end
                    local nextFrame = instance:currentFrame() + 1
                    if nextFrame <= instance.frameCount then
                        instance:currentFrame(nextFrame)
                    end
                end
            end
        end

        local output = false
        -- for each layer
        -- if the next frame exists setup the animation parameters
        for ldx = 1, #self.data.layers do
            local layer = self.data.layers[ldx]
            local frames = layer.frames

            local frame = frames[self.fdx]
            
            if frame == nil and self.firstFrame == self.fdx then
                for kfdx, keyframe in ipairs(frames) do
                    if kfdx < self.fdx then
                        frame = keyframe 
                        break
                    end
                end
            end

            if frame ~= nil then
                if output == false then
                    --atrace('tl: ' .. self.tlname .. ' fdx ' .. self.fdx .. ' pfdx ' .. pfdx, 10)
                    output = true
                end

                local elements = frame.elements
                if #elements > 0 then
                    local element = elements[1]

                    local layer = self.dglayers[ldx]

                    -- check the element.libraryItemName to see if exists in the sfactory or the timelines
                    local sinfo = self.sfactory.spriteInfos[element.libraryItemName]
                    local tldata = self.tf.tldata[element.libraryItemName]

                    if sinfo then
                        self:prepSpriteGroup(layer, element, frame, curTime, ldx)
                    elseif tldata then
                        local sg = self:prepTimeline(layer, element, frame, curTime, ldx)
                    end
                else
                    -- clear this layer
                    local dglayer = self.dglayers[ldx]
                    if dglayer.numChildren > 0 then
                        --atrace('clear ' .. layer.name)
                        local instance = dglayer[1]
                        instance:removeSelf()
                        self.instances[instance.instanceId] = nil
                        instance = nil
                    end
                end -- if elements > 0
            else
                --if output == false then
                    --atrace(self.tlname .. ' frame ' .. self.fdx .. ' nil ' .. ldx)
                    --output = true
                --end
            end -- frame if
        end -- layers for

        for idx, instance in pairs(self.instances) do
            if instance.tf ~= nil and instance.loopType ~= 'single frame' then
                instance:update(_curTime)
            end
        end

        self.pfdx = self.fdx
        self:dispatchEvent({name='timeline', phase='next', target=self})
    end
end

function Timeline:prepSpriteGroup(_layer, _element, _frame, _curTime, _ldx)
    local sg = _layer[1]
    if sg then
        --atrace('nilling sg instance ' .. sg.instanceId .. ' layer ' .. _ldx)
        self.instances[sg.instanceId] = nil
    else
        --atrace('empty layer? ' .. _ldx)
    end

    if sg and sg.spriteFactory == nil then
        -- destroy the timeline
        --atrace(self.tlname .. ' destroy timeline ' .. sg.element.libraryItemName.. ' on sprite layer ' .. _ldx)
        sg:removeSelf()
        sg = nil
    end
    --atrace(self.tlname .. ' new sprite ' .. _element.libraryItemName .. ' ' .. self.nextId)
    if sg == nil then
        sg = self.sfactory:newSpriteGroup(_element.libraryItemName)
        if _element.symbolType == 'movie clip' then
            sg:play()
        end
        _layer:insert(sg)
    end

    _layer.isVisible = true

    sg.instanceId = self.nextId
    self.nextId = self.nextId + 1
    --atrace('assigned sprite instanceId ' .. sg.instanceId)
    self.instances[sg.instanceId] = sg
    
    sg.element = _element

    sg.duration = _frame.duration
    sg.startTime = _curTime
    sg.tweenType = _frame.tweenType

    if _frame.tweenType == 'motion' then
        if _frame.hasCustomEase then
            sg.hasCustomEase = true
            sg.customEase = _frame.customEase
            sg.curvedx = {
                  position = 0
                , rotation = 0
                , scale = 0
                , color = 0
            } 
        else
            if _frame.tweenEasing == 0 then
                sg.easing = linearEase
            else
                sg.easing = createPercentEase(_frame.tweenEasing)
            end
        end
    end

    sg.xScale = _element.xScale
    sg.yScale = _element.yScale

    sg.rotation = _element.rotation
    sg.x = _element.x
    sg.y = _element.y

    sg.alpha = _element.alpha

    sg.frameCount = #(self.sfactory.spriteInfos[_element.libraryItemName].frames)
    --atrace(self.tlname .. ' ' .. _element.libraryItemName .. ' frameCount ' .. sg.frameCount)
    if _element.symbolType == 'movie clip' then
        sg.loopType = 'loop'
        sg:play(_element.libraryItemName, true)
    elseif _element.symbolType == 'graphic' then
        if self.firstFrame > 1 and self.firstFrame <= sg.frameCount then
            sg.firstFrame = self.firstFrame
        else
            sg.firstFrame = _element.firstFrame
        end
        sg:prepare(_element.libraryItemName)
        if (sg.firstFrame == nil) then
            atrace(_element.libraryItemName)
        end
        sg:currentFrame(sg.firstFrame)
        sg.loopType = _element.loop 
        if sg.loopType == 'loop' then
            sg:play(_element.libraryItemName, true)
        end
    end

    if sg.frameCount == 1 then
        sg.loopType = 'play once'
    end
end

function Timeline:prepTimeline(_layer, _element, _frame, _curTime, _ldx)
    local sg = _layer[1]
    if sg then
        --atrace(self.tlname .. ' removing instanceId ' .. sg.instanceId .. ' ' .. sg.element.libraryItemName .. ' layer ' .. _ldx)
        self.instances[sg.instanceId] = nil
    end

    if sg and sg.tf == nil then
        -- destroy the SpriteGroup
        --atrace(self.tlname .. ' destroy spriteGroup ' .. sg.element.libraryItemName.. ' on timeline layer ' .. _ldx)
        sg:removeSelf()
        sg = nil
    end

    --atrace(self.tlname .. ' new timeline ' .. _element.libraryItemName .. ' instanceId ' .. self.nextId)

    if sg == nil then
        --atrace(self.tlname .. ' new timeline ' .. _element.libraryItemName .. ' on empty layer ' .. _ldx)
        sg = self.tf:newChildTimeline(_element.libraryItemName, _element.firstFrame)
        _layer:insert(sg)

        if _element.symbolType == 'movie clip' or _element.loop == 'loop' then
            --atrace(self.tlname .. ' set new timeline to play')
            sg:play(_element.libraryItemName, true, true)
        end
    end

    sg.instanceId = self.nextId
    self.nextId = self.nextId + 1
    self.instances[sg.instanceId] = sg
    
    sg.element = _element

    sg.duration = _frame.duration
    sg.frameDuration = _frame.frameDuration
    sg.startTime = _curTime
    sg.tweenType = _frame.tweenType

    if _frame.tweenType == 'motion' then
        if _frame.hasCustomEase then
            sg.hasCustomEase = true
            sg.customEase = _frame.customEase
            sg.curvedx = {
                  position = 0
                , rotation = 0
                , scale = 0
                , color = 0
            } 
        else
            if _frame.tweenEasing == 0 then
                sg.easing = linearEase
            else
                sg.easing = createPercentEase(_frame.tweenEasing)
            end
        end
    end

    sg.xScale = _element.xScale
    sg.yScale = _element.yScale

    sg.rotation = _element.rotation
    sg.x = _element.x
    sg.y = _element.y

    sg.alpha = _element.alpha

    sg.frameCount = sg.data.frameCount
    
    if _element.symbolType == 'movie clip' then
        sg.loopType = 'loop'
        sg:play(_element.libraryItemName, true, true)
    elseif _element.symbolType == 'graphic' then
        sg.firstFrame = _element.firstFrame
        --atrace('first frame ' .. sg.firstFrame)
        sg.loopType = _element.loop 
        if sg.loopType == 'loop' then
            --atrace('graphic looping ' .. _element.libraryItemName)
            sg:play(_element.libraryItemName)
            --sg:play()
        else
            sg:prepare(_element.libraryItemName)
        end
    end

    if sg.frameCount == 1 then
        sg.loopType = 'play once'
    end
    return sg
end

function Timeline:prepare(_tlname, _sameLayering)
    if _tlname == nil then
        self:pause()
        error('Timeline data parameter is nil')
    end

    self.tlname = _tlname

    -- data variable stores the timeline data
    self.data = self.tf.tldata[_tlname]
    if self.data == nil then
        self:pause()
        error(_tlname .. ' does not have timeline data.')
    end

    -- frame step size
    self.step = self.data.step

    -- previous frame index
    self.pfdx = nil
    -- current frame index
    self.fdx = self.firstFrame

    -- start off at two so we don't use the array
    self.nextId = 2
   
    if not _sameLayering or self.instances == nil then
        if self.instances then
            for i = self.numChildren, 1, -1 do
                self[i]:removeSelf()
            end
        end

        -- the table of spritegroups or timelines
        self.instances = {}
        --atrace(self.tlname .. ' recreate instances')

        -- the layers of our timeline as display groups
        self.dglayers = {}
        for ldx = 1, #self.data.layers do
            --test1
            --self.dglayers[ldx] = self.sfactory:newSpriteGroup()
            self.dglayers[ldx] = display.newGroup()
            self:insert(self.dglayers[ldx])
        end
    else
        if #self.dglayers ~= #self.data.layers then
            self:pause()
            error("Same layering set to true, but layer counts don't match.")
        end
    end

    self.startTime = system.getTimer()
    self:update(self.startTime)
end

function Timeline:sequence()
    return self.tlname
end

function Timeline:timeScale(_timeScale)
    if _timeScale == nil then
        return self.m_timeScale
    else
        self.m_timeScale = _timeScale
    end
    return _timeScale
end

--[[
    Function: dispose
        Destroys the timeline factory and optionally the SpriteFactory passed to it on creation.

    Parameters:
        _clearSpriteFactory A Boolean value that when true destroys the referenced SpriteFactory. (Default: true)
]]
function TimelineFactory:dispose(_clearSpriteFactory)
    Runtime:removeEventListener('enterFrame', self)
    collectgarbage("collect")
    for k, instance in pairs(self.instances) do
        instance:removeSelf() -- sometimes throws an error about being a nil
    end
    self.instances = nil

    if _clearSpriteFactory == nil or _clearSpriteFactory == true then
        self.sfactory:dispose()
    end

    self.sfactory = nil

    for tlname, v in pairs(self.tldata) do
        unrequire(tlname)
    end
    self.tldata = nil
    self.tlnames = nil
end

--[[
    Function: newTimeline

        Creates a new display group that animates timeline data.

    Parameters:
        _tlname Name of the timeline to display
        _firstFrame The first frame to display after creation.

    Returns:
        A display group instance decorated with timeline functions
]]
function TimelineFactory:newTimeline(_tlname, _firstFrame)
    --atrace('new top level timeline ' .. self.nextId)
    local dg = self:newChildTimeline(_tlname, _firstFrame)
    dg.loq_timelineId = self.nextId

    self.instances[dg.loq_timelineId] = dg
    self.nextId = self.nextId + 1
    
    dg.corona_removeSelf = dg.removeSelf
    dg.removeSelf = function() self.instances[dg.loq_timelineId] = nil; dg:corona_removeSelf() end

    return dg
end

function TimelineFactory:newChildTimeline(_tlname, _firstFrame)
    
    -- the container for all the layers
    local dg = display.newGroup()
    loq_listeners(dg)

    dg.endEvent  = {name='timeline', phase='end', target=self}
    dg.loopEvent = {name='timeline', phase='loop', target=self}
    dg.nextEvent = {name='timeline', phase='next', target=self}

    dg.tf = self
    dg.animating = Timeline.animating
    dg.reset = Timeline.reset
    dg.pause = Timeline.pause
    dg.play = Timeline.play
    dg.prepare = Timeline.prepare
    --dg.enterFrame = Timeline.enterFrame
    dg.getTimelineNames = Timeline.getTimelineNames
    dg.update = Timeline.update
    dg.sequence = Timeline.sequence
    dg.timeScale = Timeline.timeScale
    dg.loop = Timeline.loop
    dg.currentFrame = Timeline.currentFrame
    dg.prepSpriteGroup = Timeline.prepSpriteGroup
    dg.prepTimeline = Timeline.prepTimeline

    -- the sprite factory used to create SpriteGroups for the timeline data
    dg.sfactory = self.sfactory
    -- used to speed up or slow down the timeline animation
    -- does not slow down internal SpriteGroups
    dg.m_timeScale = 1 
    dg.m_loop = false
    dg.m_animating = false

    if _tlname == nil then
        _tlname = dg:getTimelineNames()[1]
    end

    if _firstFrame then
        dg.firstFrame = _firstFrame
    else
        dg.firstFrame = 1
    end

    dg:prepare(_tlname)

    return dg
end

function TimelineFactory:enterFrame(_e)
    local curTime = system.getTimer()
    for k, tl in pairs(self.instances) do
        if tl:animating() then
            tl:update(curTime)
        end
    end
end

return {newTimelineFactory = newTimelineFactory}
