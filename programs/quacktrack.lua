args = { ... }
if table.getn(args) < 1 then
	term.setTextColor(colors.red)
	print("Usage: quacktrack <player>")
	return
end

local player = args[1]
if quackgps then
	if not quackgps.isOnline(player) then
		term.setTextColor(colors.orange)
		print("Player not online.")
	elseif not quackgps.isInWorld(player) then
		term.setTextColor(colors.orange)
		print("Player not in this dimension.")
	else
		local x, y, z = quackgps.track(player)
		term.setTextColor(colors.green)
		print(player, " is at ", round(x, 1), ", ", round(y, 1), ", ", round(z, 1))
	end
else
	local reply = quacknet.request(39, textutils.serialize({
		command = "track",
		player = player
	}))

	if reply.data and reply.data.success then
		local pos = reply.data
		term.setTextColor(colors.green)
		print(player, " is at ", math.round(pos.x, 1), ", ", math.round(pos.y, 1), ", ", math.round(pos.z, 1))
	else
		term.setTextColor(colors.red)
		print(reply.error)
	end
end
