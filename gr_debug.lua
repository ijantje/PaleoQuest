if loq_DeclareGlobals then
    loq_declare('gr_debug', {})
    loq_declare('socket', {})
end

module(..., package.seeall)

local mod = {}
local socket = require('socket')
local client
function mod.sinit(_addr, _port)
    client = socket.tcp()
    if _addr == nil then
        _addr = "10.0.0.3"
    end

    if _port == nil then
        _port = 1234
    end
    local res = client:connect(_addr, _port)
    if res == nil then
        client = nil
    end
end

function mod.sdestroy()
    if client then
        client:shutdown()
        client =nil
    end
end

--[[
    Function: strace
        Prints a debugging message to a socket connection with a time stamp and stack trace.

    Parameters:
        - _msg The message to display
]]
function mod.strace(_msg)
    if client then
        if _msg == nil then
            _msg = "nil"
        else
            _msg = tostring(_msg)
        end

        local sysTime = system and ("(" .. formatMS(system.getTimer()) .. ")") or "-"
        client:send(sysTime .. " => " .. _msg .."\n")
    end
end

return mod
