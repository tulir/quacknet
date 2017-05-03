args = { ... }
if table.getn(args) < 1 then
	term.setTextColor(colors.red)
	print("Usage: quacktrack <player>")
	return
end

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- TODO unhardcode GPS master ID

local player = args[1]
if os.getComputerID() == 39 then
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
		print(player, " is at ", round(pos.x, 1), ", ", round(pos.y, 1), ", ", round(pos.z, 1))
	else
		term.setTextColor(colors.red)
		print(reply.error)
	end
end
