require('loq_util')

if loq_DeclareGlobals then
    loq_declare("loq_profiler")
end


--[[
    Module: loq_profiler
    Corona frame rate, application memory and texture memory profiler.  Ported from shanem's AS3 com.flashdynamix.utils.SWFProfiler

    Usage: 
>   require("loq_profiler").createProfiler()
]]

local Profiler = {}

local instance

local minFps = 10000000
local maxFps = 0
local minMem = 10000000 
local maxMem = 0

local itvTime
local initTime
local currentTime
local frameCount
local totalCount

local avgInterval
local avgTime
local avgCount
local avgFps

local history = 60
local fpsList = {}
local memList = {}


--[[
    Function: createProfiler

    Creates and returns a display instance of the profiler.

    Usage:
        require("loq_profiler").createProfiler()

    Parameters: 
        - _onTop Forces the profiler to stay on top.  If true stays on top, otherwise can be hidden by other display objects. Default is true.
        - _collect Forces a garbage collection step every frame.  If true forces a collection, otherwise lets the gc run normally.  Default is true.

    Returns:

        A display group instance of the profiler.
]]
local function createProfiler(_onTop, _collect)
    Profiler.onTop = _onTop
    if Profiler.onTop == nil then
        Profiler.onTop = true
    end
    Profiler.collect = _collect
    if Profiler.collect == nil then
        Profiler.collect = true
    end
    return Profiler:initialize()
end

--[[
    Function: destroyProfiler

    Destroys the Profiler removing it from the stage.

    Usage:
        require("loq_profiler").destroyProfiler()

]]
local function destroyProfiler()
    Profiler:destroy()
    Profiler = nil
end

local function bringToTop()
    if Profiler ~= nil then
        local stage = display.getCurrentStage()
        stage:insert(Profiler.container)
    end
end

--[[
    Class: Profiler
        Creates a display group instance that displays graphs for frame rate and memory usage.
]]

--[[
    Group: Methods
]]
function Profiler:initialize()
    self.container = display.newGroup()
    self.foreground = display.newGroup()


    self.infoTxt = display.newText(self.foreground, "Fps", 0, 98, native.systemFont, 11)
    self.infoTxt:setTextColor(0xcc, 0xcc, 0xcc)

    self.minFpsTxt = display.newText(self.foreground, "0", 17, 37, native.systemFont, 9)
    self.minFpsTxt:setTextColor(0xcc, 0xcc, 0xcc)
    self.maxFpsTxt = display.newText(self.foreground, "0", 17, 5, native.systemFont, 9)
    self.maxFpsTxt:setTextColor(0xcc, 0xcc, 0xcc)
    self.minMemTxt = display.newText(self.foreground, "0", 17, 83, native.systemFont, 9)
    self.minMemTxt:setTextColor(0xcc, 0xcc, 0xcc)
    self.maxMemTxt = display.newText(self.foreground, "0", 17, 50, native.systemFont, 9)
    self.maxMemTxt:setTextColor(0xcc, 0xcc, 0xcc)

    self:resize()

    self.container:insert(self.foreground)

    self.fpsGroup = display.newGroup()
    self.memGroup = display.newGroup()

    self.fpsGroup.x = 65
    self.fpsGroup.y = 45

    self.container:insert(self.fpsGroup)

    self.memGroup.x = 65
    self.memGroup.y = 90

    self.container:insert(self.memGroup)

    initTime = system.getTimer()
    itvTime = initTime
    totalCount, frameCount = 0, 0

    avgTime = initTime
    avgCount = 0
    avgFps = 0

    Runtime:addEventListener("enterFrame", self)

    return self
end

function Profiler:destroy()
    self.container:removeSelf()
    Runtime:removeEventListener("enterFrame", self)
end

--[[
    Method: averageFps
    Returns: Average frames per second.
]]
function Profiler:averageFps()
    --return totalCount / self:runningTime()
    return avgFps;
end

--[[
    Method: currentFps
    Returns: 
        Current frames per second.
]]
function Profiler:currentFps()
    return frameCount / self:intervalTime()
end

--[[
    Method: currentMem
    Returns:
        Application memory in kilobytes
]]
function Profiler:currentMem()
    return collectgarbage("count")
end

--[[
    Function: currentTextureMem
    Returns:
        Texture memory used in kilobytes.
]]
function Profiler:currentTextureMem()
    return system.getInfo("textureMemoryUsed") / 1024
end

--[[
    Method: resize
        Resize the Profiler to adjust it to the display's orientation.
]]
function Profiler:resize()
    local back = display.newRect(self.container, 0, 0, display.contentWidth, 120)
    back:setFillColor(0, 0, 0, 128)
    self:backline(65, 45, 65, 10)
    self:backline(65, 45, display.contentWidth -15, 45)
    self:backline(65, 90, 65, 55)
    self:backline(65, 90, display.contentWidth -15, 90)

    self.infoTxt.x =  self.infoTxt.contentWidth / 2 + 10
end

--[[ 
    Method: runningTime
    Returns: 
        Running time of the application in seconds.
]]
function Profiler:runningTime()
    return (currentTime - initTime) / 1000
end

function Profiler:intervalTime()
    return (currentTime - itvTime) / 1000
end

function Profiler:backline(_x1, _y1, _x2, _y2)
    local line = display.newLine(self.container, _x1, _y1, _x2, _y2)
    line:setColor(255, 255, 255, 50)
    line.width = 2
    return line
end

function Profiler:enterFrame(event)
    if self.collect then
        collectgarbage("collect")
    end
    currentTime = system.getTimer()
    frameCount = frameCount + 1
    totalCount = totalCount + 1
   
    avgInterval = currentTime - avgTime 
    if avgInterval >= 5000 then
        avgFps = (totalCount - avgCount) / (avgInterval/1000)
        avgTime = currentTime
        avgCount = totalCount
    end
    
    if self:intervalTime() >= 0.5 then
        table.insert(fpsList, 1, self:currentFps())
        table.insert(memList, 1, self:currentMem())

        if #fpsList > history then
            table.remove(fpsList, #fpsList)
            local min = 1000000
            local max = 0
            for i = 1, #fpsList do
                if fpsList[i] > max then
                    max = fpsList[i]
                end

                if fpsList[i] < min then
                    min = fpsList[i]
                end
            end

            minFps = min
            maxFps = max
        end

        if #memList > history then
            table.remove(memList, #memList)
            local min = 1000000
            local max = 0
            for i = 1, #memList do
                if memList[i] > max then
                    max = memList[i]
                end

                if memList[i] < min then
                    min = memList[i]
                end
            end

            minMem = min
            maxMem = max
        end

        minFps = self:currentFps() < minFps and self:currentFps() or minFps
        self.minFpsTxt.text = string.format("%d Fps", minFps)
        maxFps = self:currentFps() > maxFps and self:currentFps() or maxFps
        self.maxFpsTxt.text = string.format("%d Fps", maxFps)


        minMem = self:currentMem() < minMem and self:currentMem() or minMem
        self.minMemTxt.text = string.format("%d Kb", minMem)
        maxMem = self:currentMem() > maxMem and self:currentMem() or maxMem
        self.maxMemTxt.text = string.format("%d Kb", maxMem)

        -- fps 
        for i = self.fpsGroup.numChildren, 1, -1 do
            self.fpsGroup:remove(i)
        end

        local height = 35
        local width = display.contentWidth - 80
        local inc = width / (history -1)
        local rateRange = maxFps - minFps
        rateRange = rateRange > 0 and rateRange or 1
        local value
        local fpsline

        if #fpsList > 1 then
            local val1 = (fpsList[1] - minFps) / rateRange
            local val2 = (fpsList[2] - minFps) / rateRange
            fpsline = display.newLine(self.fpsGroup, 0, -val1 * height, inc, -val2 * height)
            fpsline:setColor(0x33, 0xcc, 0, 255)
            fpsline.width = 2
        end

        if #fpsList > 2 then
            for i = 3, #fpsList do
                value = (fpsList[i] - minFps) / rateRange
                fpsline:append((i-1)*inc, -value * height)
            end
        end

        -- mem
        for i = self.memGroup.numChildren, 1, -1 do
            self.memGroup:remove(i)
        end

        rateRange = maxMem - minMem
        rateRange = rateRange > 0 and rateRange or 1

        local memline
        if #memList > 1 then
            local val1 = (memList[1] - minMem) / rateRange
            local val2 = (memList[2] - minMem) / rateRange
            memline = display.newLine(self.memGroup, 0, -val1 * height, inc, -val2 * height)
            memline:setColor(0xdd, 0x66, 0x00, 255)
            memline.width = 2
        end

        if #memList > 2 then
            for i = 3, #memList do
                value = (memList[i] - minMem) / rateRange
                memline:append((i-1)*inc, -value * height)
            end
        end

        self.infoTxt.text =  "Avg Fps " .. math.floor(self:averageFps()) .. "  |  Mem " .. math.floor(self:currentMem()) .. " Kb  |  TMem " .. math.floor(self:currentTextureMem()) .. " Kb" .. "  |  Fps " .. math.floor(self:currentFps()) .. "  |  Time " .. formatMS(system.getTimer())
        self.infoTxt.x = self.infoTxt.contentWidth / 2 + 10 
        
        itvTime = currentTime
        frameCount = 0

    else

        self.infoTxt.text =  "Avg Fps " .. math.floor(self:averageFps()) .. "  |  Mem " .. math.floor(self:currentMem()) .. " Kb  |  TMem " .. math.floor(self:currentTextureMem()) .. " Kb" .. "  |  Fps " .. math.floor(self:currentFps()) .. "  |  Time " .. formatMS(system.getTimer())
        self.infoTxt.x = self.infoTxt.contentWidth / 2 + 10 
    end

    if self.onTop then
        (display.getCurrentStage()):insert(Profiler.container)
    end
end

return {createProfiler = createProfiler, destroyProfiler = destroyProfiler }
