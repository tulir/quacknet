monitor = peripheral.wrap("left")
term.redirect(monitor)
while true do
	local hour = math.floor(os.time())
	local minute = math.floor((os.time() % 1) * 60)
	local reply = quacknet.request(39, {command="track_all"})

	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.orange)
	print("QuackTrack 1.0 - Day: ", os.day(), ", Time: ", string.format("%02d", hour), ":", string.format("%02d", minute))
	print("")
	if not reply.data or not reply.data.success then
		term.setTextColor(colors.red)
		print("Failed to track players!")
		if reply.data and reply.data.error then
			print("  ", reply.data.error)
		end
	else
		term.setTextColor(colors.cyan)
		print("Player           @ position (x, y, z)")
		local darkBlue = false
		for name, location in pairs(reply.data.players) do
			if darkBlue then
				term.setTextColor(colors.blue)
			else
				term.setTextColor(colors.lightBlue)
			end
			darkBlue = not darkBlue
			pos = {x = location[1], y = location[2], z = location[3]}
			print(string.format("%-16s", name), " @ ", math.round(pos.x, 1), ", ", math.round(pos.y, 1), ", ", math.round(pos.z, 1))
		end
	end
	os.sleep(0.25)
end