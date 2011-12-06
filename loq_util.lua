-- Copyright 2011 Loqheart

--[[
    Module: loq_util
        Utility functions used by other modules. 

    Usage:
        require("loq_util")
]]

-- Some utilities for better debugging, print_r taken from Corona's CodeExchange

--[[
    Group: Debugging
]]

--[[
    Function: atrace
        Prints a debugging message with a time stamp and stack trace.

    Parameters:
        - _msg The message to display, can be a string, function, or table
        - _depth The depth of the stack.  Defaults to 1.
]]
function atrace(_msg, _depth) 
    if _msg == nil then
        _msg = "nil"
    else
        if type(_msg) == 'function' then
            _msg = functionInfo(_msg)
        elseif type(_msg) == 'table' then
            _msg = xinspect(_msg)
        else
            _msg = tostring(_msg)
        end
    end

    _depth = _depth or 1

    local sysTime = system and ("(" .. formatMS(system.getTimer()) .. ") ") or "- "
    print(" = > atrace " .. sysTime .. _msg)
    local res = debug.traceback():split("\n")

    local counter = 1
    for i, v in ipairs(res) do
        counter = counter + 1
        if counter > 3 and counter < (3+_depth+1) then
            print(tostring(v))
        end

    end
    --print(table.concat(res, "\n", 3, _depth + 2)) 
    -- sometimes gets an error that some table values in res aren't strings
    print()
end

--[[
    Function: formatMS
        Format milliseconds into a string HH:MM:SS:MS

    Parameters:
        - _ms Milliseconds from a call like system.getTimer()

    Returns:
        A string in the format HH:MM:SS:MS where HH is hours, MM is minutes, SS is seconds, and MS is milliseconds
]]
function formatMS(_ms)
    if not _ms then
        return ""
    end

    local ms = _ms % 1000
    local secs = math.floor(_ms / 1000)
    local mins = math.floor(secs / 60)
    local hours = math.floor(mins / 60)
    secs = secs % 60
    mins = mins % 60
    hours = hours % 24
    return string.format("%02d:%02d:%02d:%03d", hours, mins, secs, ms)
end

--[[
    Function: functionInfo
        Returns the file and line numbers for a function's definition

    Parameters:
        - _func The function

    Returns:
        A string with the file and line numbers for the function's definition.  If not a valid function then returns nil.
]]
function functionInfo(_func)
    if type(_func) == 'function' then
        local info = debug.getinfo(_func)
        return 'function ' ..  info.source .. ':[' .. info.linedefined .. ', ' .. info.lastlinedefined .. ']'
    else
        return nil
    end
end

--[[ 
    Function: loq_declare
        Used to declare global values. If loq_DeclareGlobals is true before the loq_util module is loaded, 
        then global values used without loq_declare() throw an error.  From kam187 on the Corona Code Exchange

        Parameters:
            - _name Name of the global variable.
            - _initval Initial value of the variable.

        Usage:
        (start code)
            local loq_DeclareGlobals = true
            require('loq_util')
            loq_declare("MyGlobal", {})
        (end)
]]
function loq_declare (_name, _initval)
    rawset(_G, _name, _initval or {})
end

--[[
    Function: loq_undeclared
        Checks if a string name of a variable has been declared as a global.

    Parameters:
        - _name Name of the global variable.

    Returns: 
        - true if the variable name is undeclared with loq_declare.
        - false if the variable has been declared with loq_declare.
]]
function loq_undeclared(_name)
    return rawget(_G, _name) == nil
end

--[[ 
    Function: xinspect
        Returns a nicely formated string with the properties and contents listed of the parameter passed in.
    
    Parameters:
        - _t A value.
    
    Returns:
        A nicely formated string with the properties and contents listed.

    Usage:
    (start code)
        local values = { a = 1, b = 'hello' }
        atrace(xinspect(values))
    (end)
]]
function xinspect( _t )
    local status, retval = pcall(print_r, _t)
    return retval
end

function print_r ( t ) 
    local out = {}
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            table.insert(out, indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        table.insert(out, indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        table.insert(out, indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        table.insert(out, indent.."["..pos..'] => "'..val..'"')
                    else
                        table.insert(out, indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                table.insert(out, indent..tostring(t))
            end
        end
    end

    if (t["__tostring"]) then
        table.insert(out, tostring(t))
    elseif (type(t)=="table") then
        table.insert(out, tostring(t).." {")
        sub_print_r(t,"  ")
        table.insert(out, "}")
    else
        sub_print_r(t,"  ")
    end

    return table.concat(out, "\n")
end

--[[
    Group: String
]]

--[[ 
    Function: string:split
        Splits the string using with a separator

    Parameters: 
        - sSeparator A string separator.

    Returns:
        A table of strings.
]]
function string:split(sSeparator, nMax, bRegexp)
	--assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)

	local aRecord = {}

    if sSeparator == '' then
        for i = 1, #self do
            aRecord[i] = self:sub(i, i)
        end
    elseif self:len() > 0 then
		local bPlain = not bRegexp
		nMax = nMax or -1

		local nField, nStart = 1, 1
		local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
		end
		aRecord[nField] = self:sub(nStart)
	end

	return aRecord
end

--[[
    Group: Table
]]

-- supports older versions of Corona
if not table.indexOf then
--[[
    Function: table.indexOf
        Searches a table for an item and returns its index or nil if not found

    Parameters:
        - _t The table.
        - _item The item to find.

    Returns: 
        The index or nil if not found.

    NOTE: This is only defined if table.indexOf does not already exist in the runtime environment.  
    It is added only for compatibility with older versions of the Corona SDK.
]]
    function table.indexOf(_t, _item)
        for i, v in ipairs(_t) do
            if _item == v then
                return i
            end 
        end 
        return nil
    end
end
 
-- supports older versions of Corona
if not table.copy then
--[[
    Function: table.copy
        Returns a shallow copy of array, i.e. the portion of the array (table) with integer keys. 
        A variable number of additional arrays can be passed in as optional arguments. 
        If an array has a hole (a nil entry), copying in a given source array stops at the 
        last consecutive item prior to the hole.

    Parameters:
        - ... Optional, one or more tables.

    Returns: 
        Returns a shallow copy of combined arrays.

    NOTE: This is only defined if table.copy does not already exist in the runtime environment.  
    It is added only for compatibility with older versions of the Corona SDK.
]]
    function table.copy(...)
        local t = {}
         for adx, tb in ipairs(arg) do
             for i = 1, #tb do
                 table.insert(t, tb[i])
             end
         end
         return t
    end
end

--[[
    Function: table.removeItem
        Searches a table for an item and removes it if present.

    Parameters:
        - _t The table.
        - _item The item to remove.
]]
function table.removeItem(_t, _item)
    local i = table.indexOf(_t, _item)
    if i ~= nil then
        table.remove(_t, i)
    end
end

--[[
    Group: Math
]]

function bezierValue(_t, _a, _b, _c, _d)
    return (_t*_t*(_d-_a) + 3*(1-_t)*(_t*(_c-_a) + (1-_t)*(_b-_a)))*_t + _a;
end

--[[
    Function: rotateVec2
        Rotates vector components x, y through an angle.

    Parameters:
        _degrees The angle in degrees
        _x X component of 2D vector
        _y Y component of 2D vector

    Returns:
        The rotated x and y values.
]]
function rotateVec2(_degrees, _x, _y)
    local angle = math.rad(_degrees)
    local ct = math.cos(angle)
    local st = math.sin(angle)
    return (_x*ct - _y*st), (_x*st + _y*ct)
end


loq_declare('socket')

function testNetworkConnection(_url)
    assert(_url, "URL cannon be nil")
    local nc = require('socket').connect(_url, 80)
    if nc == nil then
        return false
    end
    nc:close()
    return true
end

function loq_addEventListener(self, _name, _listener)
    if self.__listeners[_name] == nil then
        self.__listeners[_name] = { _listener }
    else
        local index = table.indexOf(self.__listeners[_name], _listener)
        if (index == nil) then
            table.insert(self.__listeners[_name], _listener)
        end
    end
end

function loq_removeEventListener(self, _name, _listener)
    if self.__listeners[_name] ~= nil then
        table.removeItem(self.__listeners[_name], _listener)
    end
end

function loq_clearListeners(self, _name)
    if _name == nil then
        self.__listeners = {}
    elseif type(_name) == 'string' then
        self.__listeners[_name] = nil
    end
end

function loq_dispatchEvent(self, _e)
    local name = _e.name
    local ret = false
    if self.__listeners[name] ~= nil then
        local listeners = self.__listeners[name]
        for i = 1, #listeners do
            local l = listeners[i]
            if type(l) == 'function' then
                ret = l(_e)
            elseif type(l) == 'table' and type(l[name]) == 'function' then
                local f = l[name]
                ret = f(l, _e)
            end
            if ret then
                break
            end
        end
    end
    return ret
end

--[[
    Group: Events
]]

--[[
    Function: loq_listeners
        Uses adds event dispatching to the object.  Can be used to replace the event dispatching
        functions (addEventListener, removeEventListener, dispatchEvent) for display objects or 
        to add event dispatching to regular objects. Also adds clearListeners for remove all 
        event listeners or event listeners of a certain type.

    Parameters:
        - _obj A table.

    NOTE: loq_listeners is used in SpriteGroups to replace the Corona display object event dispatching 
    system in order to prevent misbehavior in the Corona event dispatching API.
]]
function loq_listeners(_obj)
    _obj.__listeners = {}
    if _obj.addEventListener then
        _obj:addEventListener('collision', function() end)
    end
    _obj.addEventListener = loq_addEventListener
    _obj.removeEventListener = loq_removeEventListener
    _obj.dispatchEvent = loq_dispatchEvent
    _obj.clearListeners = loq_clearListeners
end

--[[
    Group: Modules
]]

--[[
   Function: unrequire
        Removes a required lua file from the loaded packages to free up application memory.

   Parameters:
       - _filename The name of a lua file to be removed from the loaded packages to clear up application memory.
]]

function unrequire(m)
    package.loaded[m] = nil
    rawset(_G, m, nil)

    -- Search for the shared library handle in the registry and erase it
    local registry = debug.getregistry()
    local nMatches, mKey, mt = 0, nil, registry['_LOADLIB']

    for key, ud in pairs(registry) do
        if type(key) == 'string' and type(ud) == 'userdata' and getmetatable(ud) == mt and string.find(key, "LOADLIB: .*" .. m) then
            nMatches = nMatches + 1
            if nMatches > 1 then
                return false, "More than one possible key for module '" .. m .. "'. Can't decide which one to erase."
            end
            mKey = key
        end
    end

    if mKey then
        registry[mKey] = nil
    end

    return true
end


if loq_DeclareGlobals then
    setmetatable(_G, {
        __newindex = function(_ENV, var, val)
            if var ~= 'tableDict' then
                error(("attempt to set undeclared global\"%s\""):format(tostring(var)), 2)
            else
                rawset(_ENV, var, val)
            end
        end,
        __index = function(_ENV, var)
            if var ~= 'tableDict' then
                error(("attempt to read undeclared global\"%s\""):format(tostring(var)), 2)
            end
        end,
    })
end

--[[
    Section: Examples

    Example: Using atrace and xinspect for debugging

        Using atrace and xinspect for debugging.  You might use print to get debugging info from the Corona terminal.
        You can use atrace where you would use print to get extra information like line numbers, timings, and a stack trace.

        atrace can check if the value passed in is a function or a table and attempt to print it out.  You can use xinspect
        on tables and functionInfo on functions if you need to concatenate their values to a string. 

    (start code)
    require('loq_util')

    -- print out a message
    atrace('This works like print, but you get a time, file, line number, and function')

    -- print out a value
    local myvar = 10
    atrace(myvar)

    local mytable = {a = 100}
    atrace(mytable) -- that's better!

    --atrace('mytable ' .. mytable) -- Throws an error.  Can't convert a table to a string
   
    -- Use xinspect on mytable
    atrace('mytable ' .. xinspect(mytable)) -- that's better


    local function myfunc()
        atrace('inside a function')
        
        local function anotherfunc()
            atrace("notice that atrace prints the function you're in!")
            atrace("let's print the stack 2 deep", 2)

            local function funcInFunc()
                atrace("let's print the stack 2 deep again", 2)
                atrace('now all the way', 10)
            end

            funcInFunc()

            atrace('assigning the function to a variable in lua we lose the original name')
            local renameMyFunc = funcInFunc
            renameMyFunc()

            atrace("we can get some info about the function renameMyFunc points to")
            atrace(renameMyFunc)
        end

        anotherfunc()
    end

    myfunc()
    (end)
]]

--[[
    Example: Global declaration of variables before usage
    
        Global declaration of variables before usage.

        If you want to force declarations of globals before usage set a variable loq_DeclareGlobals to true before requiring 'loq_util'.
        Then you can use the loq_declare declare the global variable before using it.  You can also use loq_undeclared to check whether
        a variable has been declare before accessing it.

        NOTE: With loq_DeclareGlobals enabled, some Corona modules you require must be declared first because they create globals (e.g. 'physics', 'sprite')

        main.lua -- using loq_DeclareGlobals in main.lua sets the option for you application
    (start code)
        loq_DeclareGlobals = true -- if nil or false then globals don't require declarations
        require('loq_util')

        loq_declare('physics')
        require('physics') -- The Corona physics module must be declared because it creates a global.
        
        loq_declare('myglobal')
        myglobal = 10

        atrace(loq_undeclared('myUndeclaredGlobal'))

        atrace(myUndeclaredGlobal) -- throws an error
    (end)


        yourmodule.lua -- Using the module function creates a global value.  You need to declare the module if loq_DeclareGlobals is true.
    (start code)
        if loq_DeclareGlobals then
            loq_declare('yourmodule')
        end

        module(..., package.seeall) -- this globally defines your module when required
        --  the rest of the module
    (end)
]]

--[[
    Example: Unloading modules from application memory with unrequire.
        
        Unloading modules from application memory with unrequire.  Loading a module with the standard 'require' function creates a global variable.
        And loads the module into global memory.  If you're temporarily using a module, then this is basically a form of a memory leak.

        You can reclaim some of the application memory by calling 'unrequire' on the required module.  Try commmenting and uncommenting
        your require and unrequire calls with the loq_profiler to see the difference in your application memory usage.

    (start code)
    require('loq_util')         
    -- instantiate to keep an eye on application memory
    require('loq_profiler').createProfiler() 

    local myModule = require('myModule')
    -- ... some processing here, don't need the module anymore
    unrequire('myModule') -- removes the module from the global packages and reclaims some app memory
    (end)
]]
