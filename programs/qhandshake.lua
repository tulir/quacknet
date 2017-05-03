args = { ... }
if table.getn(args) < 1 then
	term.setTextColor(colors.red)
	print("Usage: qhandshake <a/b>")
elseif args[1] == "a" or args[1] == "A" then
	print("My ID is ", os.getComputerID())
	quacknet.handshakeA()
	quacknet.saveKnownHosts()
elseif args[1] == "b" or args[1] == "B" then
	print("My ID is ", os.getComputerID())
	quacknet.handshakeB()
	quacknet.saveKnownHosts()
else
	term.setTextColor(colors.red)
	print("Usage: qhandshake <a/b>")
end
