term.setTextColor(colors.yellow)
print("QuackGPSd 0.1 started")

while true do
	local msg = quacknet.listen()
	if not msg.data then
		term.setTextColor(colors.orange)
		print("Invalid request from " .. msg.sender)
		msg.reply({
			success = false,
			error = "Invalid data format"
		})
	else
		if msg.data.command == "track" then
			term.setTextColor(colors.cyan)
			print("Request to track " .. msg.data.player .. " from " .. msg.sender)
			local x, y, z = libquackgps.track(msg.data.player)
			msg.reply({success = true, x=x, y=y, z=z})
		elseif data.command == "list" then
			msg.reply(libquackgps.getNames(true))
		else
			term.setTextColor(colors.orange)
			print("Unknown command " .. data.command .. " from " .. sender)
			msg.reply({
				success = false,
				error = "Unknown command!"
			})
		end
	end
end
