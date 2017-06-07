args = { ... }
if #args < 2 then
	term.setTextColor(colors.red)
	print("Usage: qsend <target> <message>")
end
target = tonumber(table.remove(args, 1))
local reply = quacknet.request(target, table.concat(args, " "))
if reply.success then
	term.setTextColor(colors.green)
	print(reply.text)
else
	term.setTextColor(colors.orange)
	print(reply.error)
end
