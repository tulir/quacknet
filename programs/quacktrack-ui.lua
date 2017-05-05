monitor = peripheral.wrap("left")
term.redirect(monitor)
while true do
	local hour = math.floor(os.time())
	local minute = math.floor((os.time() % 1) * 60)
	local reply = quacknet.request(39, {command="track_all"})

	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.orange)
	print(string.format("QuackTrack UI 1.0 - Day: %d, Time: %02d:%02d", hour, minute))
	if not reply.data or not reply.data.success then
		term.setTextColor(colors.red)
		print("Failed to track players!")
		if reply.data and reply.data.error then
			print("  ", reply.data.error)
		end
	else
		local darkBlue = false
		print(string.format("%-16s @ %-7s %-5s %-7s", "Player", "x", "y", "z"))
		for name, location in pairs(reply.data.players) do
			if darkBlue then
				term.setTextColor(colors.blue)
			else
				term.setTextColor(colors.lightBlue)
			end
			darkBlue = not darkBlue
			pos = {x = location[1], y = location[2], z = location[3]}
			print(string.format("%-16s @ %-7.1f %-5.1f %-7.1f", name, pos.x, pos.y, pos.z))
		end
	end
	os.sleep(0.25)
end
