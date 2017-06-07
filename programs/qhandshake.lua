args = { ... }
if #args < 1 then
	term.setTextColor(colors.red)
	print("Usage: qhandshake <a/b> [--noverify]")
elseif args[1] == "a" or args[1] == "A" then
	print("My ID is ", os.getComputerID())
	quackkeys.handshakeA(args[2] == "--noverify")
elseif args[1] == "b" or args[1] == "B" then
	print("My ID is ", os.getComputerID())
	quackkeys.handshakeB(args[2] == "--noverify")
else
	term.setTextColor(colors.red)
	print("Usage: qhandshake <a/b>")
end
