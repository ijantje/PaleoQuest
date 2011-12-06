if loq_DeclareGlobals then
    if loq_undeclared('json') then
        loq_declare('json')
        loq_declare('Chipmunk')
    end
end

require('json')

--Does a file Exist in the given path?
local function doesFileExist( theFile )
    local datafile		
    datafile = io.open ( theFile )
    if datafile == nil then
        return false
    else
        datafile:close()
        return true
    end
end

-- Returns a valid object to work with
-- params.fileName will specify a fileName to use instead of "defaults"
local function init ( _fileName, _base )
	local g = {}
	local _properties={}
	local filePath = system.pathForFile( _fileName or "defaults", _base or system.DocumentsDirectory )
	
	--SET Properties
	function g:set ( name, value )
	 	_properties[name] = value
	end

	--GET Properties	
	function g:get ( name, _defaultValue )
		local defaultValue = _defaultValue
		
		if _properties[name] == nil and defaultValue then
			g:set( name, defaultValue)	
		end
		 
		return _properties[name]
	end

	--Useful for debugging, Prints all the tables
	function g:printTable ()
       atrace(_properties)
	end	


	--Save the properties to a file
	function g:save ()
		local datafile, errStr
		datafile, errStr = io.open( filePath, "w+" )
        if not errStr == nil then
            atrace ( "Error occurred" )
        else
            datafile:write(json.encode(_properties))
        end
		datafile:close()
	end


	--Load defaults from a file
	function g:load  ()
		local datafile, errStr, line
		
		datafile, errStr = io.open ( filePath )
		if datafile == nil then
			atrace ( "err " .. errStr )
			return nil
		else
            _properties = json.decode(datafile:read("*a"))
			datafile:close()
		end
		
	end
------------END OF ALL HELPER FUNCTIONS ---------------------

	--Load from the File, if the file exists
	if doesFileExist ( filePath ) then
		g:load()
	end

	return g
end

local function clearFile(_filename)
    if _filename then
        local path = system.pathForFile(_filename , system.DocumentsDirectory )
        local res, eMsg = os.remove(path)
        if res == nil then
            atrace(eMsg)
        end
    end
end

return {init = init, clearFile = clearFile}
