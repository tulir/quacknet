local sensor = peripheral.find("playerSensor")

if sensor == nil then
	term.setTextColor(colors.red)
	print("Player sensor not connected!")
	return
end

local args = { ... }
if #args ~= 2 then
	term.setTextColor(colors.red)
	print("Usage: servers/quackgpssat <X-coordinate> <Z-coordinate>")
	print("For accurate results, the player sensor must be at Y=250")
	return
end

local pos = {
	x = tonumber(args[1]),
	y = tonumber(args[2])
}

local quackgpssat = quackserver.create("QuackGPS Satellite Server", "0.1")

quackgpssat.registerServiceID("gps-sat")
quackgpssat.registerDefaultServiceID()

quackgpssat.handleEncrypted("distances", function(_, sender)
	term.setTextColor(colors.cyan)
	print("Request to get data from " .. sender)
	return {
		success = true,
		distances = sensor.getNearbyPlayers(),
		from = pos
	}
end)

quackgpssat.handleEncrypted("names", function(data, sender)
	term.setTextColor(colors.cyan)
	print("Request to get player names from " .. sender)
	return {
		success = true,
		players = sensor.getAllPlayers(data.inDimension)
	}
end)

quackgpssat.start()
