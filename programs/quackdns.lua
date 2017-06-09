args = { ... }
if #args < 2 then
	term.setTextColor(colors.red)
	print("Usage: quackdns <register/unregister> <domain> [id]")
	return
end
command = table.remove(args, 1):lower()
if command == "register" and #args > 2 then
	quackdns.addHost(args[2], tonumber(args[3]))
	term.setTextColor(colors.green)
	print(args[2], " mapped to ", args[3], " locally")
elseif command == "unregister" then
	quackdns.removeHost(args[2])
	term.setTextColor(colors.green)
	print(args[2], " mapping removed locally")
else
	term.setTextColor(colors.red)
	print("Usage: quackdns <register/unregister> <domain> [id]")
end
