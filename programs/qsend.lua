args = { ... }
if table.getn(args) < 2 then
	term.setTextColor(colors.red)
	print("Usage: qsend <target> <message>")
end
target = tonumber(table.remove(args, 1))
local reply = quacknet.request(target, table.concat(args, " "))
if reply then
	term.setTextColor(colors.green)
	print(reply.text)
else
	term.setTextColor(colors.orange)
	print("No reply received")
end
