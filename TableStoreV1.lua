--tablestore module by P4UL

local Store = {}

local DataStoreService = game:GetService("DataStoreService")

local ERROR = Instance.new("BindableEvent")

local function correctType(VALUE, TYPE)
	if TYPE == "number" then
		return tonumber(VALUE)
	elseif TYPE == "string" then
		return VALUE
	elseif TYPE == "boolean" then
		return (VALUE == "true")
	elseif TYPE == "nil" then
		return nil
	end
end

function Store.new(NAME, TYPE)--make a new store
	return setmetatable({
		_Name = NAME;
		_Error = ERROR.Event;
		_Object = DataStoreService:GetDataStore(NAME);
		_Type = TYPE or "REGULAR";
	}, Store)
end

function Store:__index(index)--standard index function idk lol
	if Store[index] then
		return Store[index]
	end
end

function Store:Save(KEY, DATA)--saves data in a string
	local SAVE = ""
	local ITERATIONS = 0
	
	for i, v in DATA do
		ITERATIONS += 1
	end
	
	if self._Type == "DICTIONARY" then
		for i, v in pairs(DATA) do
			SAVE = SAVE..i.."="..tostring(tostring(v))
			
			SAVE = SAVE..":"..tostring(typeof(v))
			
			ITERATIONS -= 1
			if ITERATIONS > 0 then
				SAVE = SAVE..","
			end
		end
	else
		for i, v in ipairs(DATA) do
			SAVE = SAVE..tostring(v)
			
			SAVE = SAVE..":"..tostring(typeof(v))
			
			ITERATIONS -= 1
			if ITERATIONS > 0 then
				SAVE = SAVE..","
			end
		end
	end
	
	local SUCCESS, ERROR_MESSAGE = pcall(function()
		self._Object:SetAsync(KEY, SAVE)
	end)
	
	if not SUCCESS then
		ERROR:Fire(ERROR_MESSAGE)
	end
end

function Store:Export(KEY)--extracts data using string.split() and returns the result
	local SUCCESS, DATA = pcall(function()
		return self._Object:GetAsync(KEY)
	end)
	
	if SUCCESS then
		local SEPARATED = string.split(DATA, ",")
		local EXPORT = {}
		
		for i, v in SEPARATED do
			if string.match(v, "=") then
				local SEGMENTS1 = string.split(v, "=")
				local OBJ = SEGMENTS1[1]
				local SEGMENTS2 = string.split(SEGMENTS1[2], ":")
				local VALUE = SEGMENTS2[1]
				local TYPE = SEGMENTS2[2]
				
				EXPORT[OBJ] = correctType(VALUE, TYPE)
			else
				local SEGMENTS = string.split(v, ":")
				local VALUE = SEGMENTS[1]
				local TYPE = SEGMENTS[2]
				
				table.insert(EXPORT, correctType(VALUE, TYPE))
			end
		end
		
		return EXPORT
	end
	
	return nil
end

return Store