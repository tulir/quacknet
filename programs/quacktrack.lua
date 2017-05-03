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

pos = reply.data
print(args[1], " is at ", pos.x, ", ", pos.y, ", ", pos.z)
