--自己写的解析JSON的东西。因为网上的那玩意看不懂。总之这个是把JSON字符串解析成一个LUA TABLE的工具。

jsonDecoder = {}

do
	local STATE_READKEY = 1
	local STATE_READEQUAL = 2
	local STATE_READVALUE = 3
	
	local CHAR_N = 110
	local CHAR_T = 116
	local CHAR_F = 102
	
	local CHAR_SY = 34
	local CHAR_DY = 39
	local CHAR_SPL = 44
	local CHAR_SUB = 45
	local CHAR_DOT = 46
	local CHAR_EQ = 58
	local CHAR_LM = 91
	local CHAR_RM = 93
	local CHAR_LL = 123
	local CHAR_RL = 125
	
	local readNumber, readTrue, readFalse, readNil, readString
	local readList, readDict
	
	local function readUntilNotSpace(s, index)
		while true do
			local sbyte = string.byte(s, index)
			if character.isSpace(sbyte) then
				index=index+1
			else
				return index, sbyte
			end
		end
	end
	
	local function readKey(s, index)
		local sbyte = 0
		local key = nil
		index, sbyte = readUntilNotSpace(s, index)
		if sbyte==CHAR_SY or sbyte==CHAR_DY then
			return readString(s, index)
		else
			return -1, nil
		end
	end
	
	local function readSplit(s, index)
		local sbyte = 0
		local key = nil
		index, sbyte = readUntilNotSpace(s, index)
		if sbyte==CHAR_SPL then
			return index+1, true
		elseif sbyte==CHAR_RL or sbyte==CHAR_RM then
			return index, sbyte
		else
			return -1, nil
		end
	end
	
	local function readEq(s, index)
		local sbyte = 0
		local key = nil
		index, sbyte = readUntilNotSpace(s, index)
		if sbyte==CHAR_EQ then
			return index+1, nil
		else
			return -1, nil
		end
	end
	
	local function readValue(s, index)
		local sbyte = 0
		local value = nil
		index, sbyte = readUntilNotSpace(s, index)
		if sbyte==CHAR_SY or sbyte==CHAR_DY then
			return readString(s, index)
		elseif sbyte==CHAR_N then
			return readNil(s, index)
		elseif sbyte==CHAR_F then
			return readFalse(s, index)
		elseif sbyte==CHAR_T then
			return readTrue(s, index)
		elseif sbyte==CHAR_SUB or character.isNum(sbyte) then
			return readNumber(s, index)
		elseif sbyte==CHAR_LM then
			return readList(s, index)
		elseif sbyte==CHAR_LL then
			return readDict(s, index)
		else
			return -1, nil
		end
	end
	
	readNumber = function(s, index)
		local head, tail = index, 0
		head, tail = string.find(s, "%-?%d+", index)
		if head~=index then
			return -1, nil
		end
		local sbyte = string.byte(s, tail+1)
		if sbyte==CHAR_DOT then
			local h2, t2 = 0, 0
			h2, t2 = string.find(s, "%d+", tail+2)
			if h2~=tail+2 then
				return -1, nil
			else
				tail = t2
			end
		end
		local value = tonumber(string.sub(s, head, tail))
		if value == nil then
			return -1, nil
		end
		return tail+1, value
	end
	
	readString = function(s, index)
		local head, tail = index, 0
		local ystr = string.sub(s, index, index)
		head, tail = string.find(s, ystr .. ".-" .. ystr, index)
		if head~=index then
			return -1, nil
		end
		local value = string.sub(s, head+1, tail-1)
		return tail+1, value
	end
	
	readTrue = function(s, index)
		local head, tail = string.find(s, "true", index)
		if head~=index then
			return -1, nil
		end
		return tail+1, true
	end
	
	readFalse = function(s, index)
		local head, tail = string.find(s, "false", index)
		if head~=index then
			return -1, nil
		end
		return tail+1, false
	end
	
	readNil = function(s, index)
		local head, tail = string.find(s, "null", index)
		if head~=index then
			return -1, nil
		end
		return tail+1, nil
	end
	
	readList = function(s, index)
		local list = {}
		local sbyte = 0
		index, sbyte = readUntilNotSpace(s, index+1)
		if sbyte==CHAR_RM then
			return index+1, list
		else
			local listnum = 0
			local value = nil
			while true do
				index, value = readValue(s, index)
				if index==-1 then
					break
				else
					listnum = listnum+1
					list[listnum] = value
				end
				index, value = readSplit(s, index)
				if index==-1 then
					break
				elseif value~=true then
					if value == CHAR_RM then
						return index+1, list
					else
						break
					end
				end
			end
			return -1, nil
		end
	end
	
	readDict = function(s, index)
		local dict = {}
		local sbyte = 0
		index, sbyte = readUntilNotSpace(s, index+1)
		if sbyte == CHAR_RL then
			return index+1, dict
		end
		local key, value = nil, nil
		while true do
			index, key = readKey(s, index)
			if index==-1 then break end
			index, _ = readEq(s, index)
			if index==-1 then break end
			index, value = readValue(s, index)
			if index==-1 then
				break
			else
				dict[key] = value
			end
			index, value = readSplit(s, index)
			if index==-1 then
				break
			elseif value~=true then
				if value == CHAR_RL then
					return index+1, dict
				else
					break
				end
			end
		end
		return -1, nil
	end
	
	jsonDecoder.decode = function(s)
		local index, value = readValue(s, 1)
		if index==-1 then
			return nil
		else
			return value
		end
	end
end

jsonEncoder = {}

do
	local function addString(buffer, s)
		table.insert(buffer, s)
		for i=table.getn(buffer)-1, 1, -1 do
			if string.len(buffer[i]) > string.len(buffer[i+1]) then
				break
			end
			buffer[i] = buffer[i] .. table.remove(buffer)
		end
	end
	
	local writeDict, writeArray 
	
	local function writeValue(buffer, s)
		local suc = true
		local vt = type(s)
		if vt=="number" or vt=="boolean" then
			addString(buffer, tostring(s))
		elseif vt=="nil" then
			addString(buffer, "null")
		elseif vt=="string" then
			addString(buffer, "\"" .. s .. "\"")
		elseif vt=="table" then
			local isArray = false
			if #s>0 then isArray = true end
			if not isArray then
				suc = writeDict(buffer, s)
			else
				suc = writeArray(buffer, s)
			end
		end
		return suc
	end
	
	writeDict = function(buffer, s)
		addString(buffer, "{")
		local suc = true
		local isFirst = true
		for k, v in pairs(s) do
			if not isFirst then
				addString(buffer, ",")
			else
				isFirst = false
			end
			addString(buffer, "\"" .. k .. "\"")
			addString(buffer, ":")
			suc = writeValue(buffer, v)
			if not suc then return false end
		end
		addString(buffer, "}")
		return true
	end
	
	writeArray = function(buffer, s)
		addString(buffer, "[")
		local length = #s
		if length>0 then
			for i=1, length do
				local suc = writeValue(buffer, s[i])
				if not suc then return false end
				if i<length then
					addString(buffer, ",")
				end
			end
		end
		addString(buffer, "]")
		return true
	end
	
	function jsonEncoder.encode(s)
		local buffer = {""}
		local suc = writeValue(buffer, s)
		if suc then
			return table.concat(buffer)
		end
	end
end


json = {decode=jsonDecoder.decode, encode = jsonEncoder.encode}
