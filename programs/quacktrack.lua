args = { ... }
if #args < 1 then
	term.setTextColor(colors.red)
	print("Usage: quacktrack <player>")
	return
end

local player = args[1]
if quackgps.hasAccess() then
	if not quackgps.isOnline(player) then
		term.setTextColor(colors.orange)
		print("Player not online.")
	elseif not quackgps.isInDimension(player) then
		term.setTextColor(colors.orange)
		print("Player not in this dimension.")
	else
		local x, y, z = quackgps.track(player)
		term.setTextColor(colors.green)
		print(string.format("%s is at %.1f, %.1f, %.1f", player, x, y, z))
	end
else
	local reply = quacknet.request("central.gps", {
		command = "track",
		player = player
	})

	if reply.data and reply.data.success then
		local pos = reply.data
		term.setTextColor(colors.green)
		print(string.format("%s is at %.1f, %.1f, %.1f", player, pos.x, pos.y, pos.z))
	else
		term.setTextColor(colors.red)
		print(reply.error)
	end
end
