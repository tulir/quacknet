local quackgpsd = quackserver.create("QuackGPSd", "0.1")

quackgpsd.registerServiceID("gps")
quackgpsd.registerDefaultServiceID()

quackgpsd.handleEncrypted("track", function(data, sender)
	term.setTextColor(colors.cyan)
	print("Request to track " .. data.player .. " from " .. sender)
	local x, y, z = quackgps.track(data.player)
	return {
		success = true,
		x = x,
		y = y,
		z = z
	}
end)

quackgpsd.handleEncrypted("track_all", function()
	term.setTextColor(colors.cyan)
	print("Request to track all players in dimension")
	return {
		success = true,
		players = quackgps.trackAll()
	}
end)

quackgpsd.handle("list", function()
	return quackgps.getNames(true)
end)

quackgpsd.start()
