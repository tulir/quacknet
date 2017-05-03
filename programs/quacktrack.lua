args = { ... }
if table.getn(args) < 1 then
	term.setTextColor(colors.red)
	print("Usage: quacktrack <player>")
	return
end

-- TODO unhardcode GPS master ID

local player = args[1]
if os.getComputerID() == 39 then
	if not libquackgps.isOnline(player) then
		term.setTextColor(colors.orange)
		print("Player not online.")
	elseif not libquackgps.isInWorld(player) then
		term.setTextColor(colors.orange)
		print("Player not in this dimension.")
	else
		local x, y, z = libquackgps.track(player)
		term.setTextColor(colors.green)
		print(player, " is at ", x, ", ", y, ", ", z)
	end
else
	local reply = quacknet.request(39, textutils.serialize({
		command = "track",
		player = player
	}))

	if reply.data and reply.data.success then
		local pos = reply.data
		term.setTextColor(colors.green)
		print(player, " is at ", pos.x, ", ", pos.y, ", ", pos.z)
	else
		term.setTextColor(colors.red)
		print(reply.error)
	end
end
