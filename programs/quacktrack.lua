args = { ... }
if table.getn(args) < 1 then
	term.setTextColor(colors.red)
	print("Usage: quacktrack <player>")
	return
end

local reply = quacknet.request(39, textutils.serialize({
	command = "track",
	player = args[1]
}))

if reply.success then
	pos = reply.data
	term.setTextColor(colors.green)
	print(args[1], " is at ", pos.x, ", ", pos.y, ", ", pos.z)
else
	term.setTextColor(colors.red)
	print(reply.error)
end
