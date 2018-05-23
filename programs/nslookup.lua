args = { ... }
if #args < 1 then
	term.setTextColor(colors.red)
	print("Usage: nslookup <hostname/id> [--nocache]")
	return
end

local nocache = args[2] == "--nocache"
local hostname = args[1]
local id = tonumber(hostname)
if id ~= nil then
	local result, source = quackdns.reverse(id, nocache)
	if result ~= nil then
		print("ID:     ", id)
		print("Results:")
		for _, v in ipairs(result) do
			print("  ", v)
		end
		print("Source: ", source)
	else
		print("No hostnames found for ", id)
	end
else
	local result, source = quackdns.resolve(hostname, nocache)
	if result ~= nil then
		print("Name:   ", hostname)
		print("ID:     ", result)
		print("Source: ", source)
	else
		print("Can't find ", hostname)
	end
end
