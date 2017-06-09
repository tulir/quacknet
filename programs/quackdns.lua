args = { ... }
if #args < 2 then
	term.setTextColor(colors.red)
	print("Not enough arguments!")
	print("Usage: quackdns <register/unregister> <domain> ...")
	return
end
command = table.remove(args, 1):lower()
if command == "register" then
	if #args > 2 then
		quackdns.addHost(args[2], tonumber(args[3]))
		term.setTextColor(colors.green)
		print(args[2], " mapped to ", args[3], " locally")
	else
		term.setTextColor(colors.red)
		print("Missing domain target ID!")
		print("Usage: quackdns register <domain> <id>")
	end
elseif command == "unregister" then
	quackdns.removeHost(args[2])
	term.setTextColor(colors.green)
	print(args[2], " mapping removed locally")
else
	term.setTextColor(colors.red)
	print("Unknown command!")
	print("Usage: quackdns <register/unregister> <domain> ...")
end
