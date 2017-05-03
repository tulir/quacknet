function string.split(str, sep)
	local result = {}
	local regex = ("([^%s]+)"):format(sep)
	for each in str:gmatch(regex) do
		table.insert(result, each)
	end
	return result
end

function string.startsWith(str, prefix)
	return str:sub(1, prefix:len()) == prefix
end

function string.endsWith(str, suffix)
	return str:sub(-suffix:len()) == suffix
end

function string.contains(str, char)
	return string.find(str, char, 1, true) ~= nil
end

function string.bytes(str)
	local result = ""
	str:gsub(".", function(c)
		result = result .. tostring(string.byte(c)) .. ","
	end)
	return result
end

function string.unbytes(bytestr)
	local result = ""
	bytestr:gsub("([^,]+)", function(c)
		if string.len(c) == 0 then return end
		local cn = tonumber(c)
		if not cn then return end
		result = result .. string.char(cn)
	end)
	return result
end
