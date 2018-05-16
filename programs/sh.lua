term.clear()
term.setTextColor(colors.white)
term.setCursorPos(1, 1)
term.setCursorBlink(true)
print("sh 0.1")
write("$ ")
while true do
	input = read()
	if input == "clear" then
		term.clear()
		term.setCursorPos(1,1)
	elseif input == "exit" then
		return
	elseif input == "shutdown" then
		os.shutdown()
	elseif input == "reboot" then
		os.reboot()
	else
		shell.run(input)
	end
	write("$ ")
end
