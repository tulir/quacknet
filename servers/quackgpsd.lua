local quackgpsd = quackserver.create("QuackGPSd", "0.1")

quackgpsd.handleCommand("track", function(msg)
	term.setTextColor(colors.cyan)
	print("Request to track " .. msg.data.player .. " from " .. msg.sender)
	local x, y, z = quackgps.track(msg.data.player)
	msg.reply({success = true, x=x, y=y, z=z}, true)
end)

quackgpsd.handleCommand("track_all", function(msg)
	term.setTextColor(colors.cyan)
	print("Request to track all players in dimension")
	msg.reply({success = true, players = quackgps.trackAll()}, true)
end)

quackgpsd.handleCommand("list", function(msg)
	msg.reply(quackgps.getNames(true))
end)

quackgpsd.start()
