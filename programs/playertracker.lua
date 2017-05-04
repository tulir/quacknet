monitor = peripheral.wrap("left")
term.redirect(monitor)
while true do
	local hour = math.floor(os.time())
	local minute = math.floor((os.time() % 1) * 60)
	local reply = quacknet.request(39, {command="track_all"})

	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.orange)
	print("Day: ", os.day(), ", Time: ", hour, ":", minute)

	local darkBlue = false
	for name, location in pairs(reply.data.players) do
		if darkBlue then
			term.setTextColor(colors.blue)
		else
			term.setTextColor(colors.lightBlue)
		end
		darkBlue = not darkBlue
		pos = {x = location[1], y = location[2], z = location[3]}
		print(name, " ", math.round(pos.x, 1), ", ", math.round(pos.y, 1), ", ", math.round(pos.z, 1))
	end
	os.sleep(1)
end
