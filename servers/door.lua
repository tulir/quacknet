local prevState = rs.getInput("right")
while true do
	local event, sender, message = os.pullEvent()
	if event == "redstone" and rs.getInput("right") ~= prevState then
		if rs.getInput("right") then
			rs.setOutput("left", not rs.getOutput("left"))
		end
		prevState = rs.getInput("right")
	elseif event == "rednet_message" then
		command = quacknet.handleServerReceived(sender, message)
		if command.success then
			if command.text == "open" then
				rs.setOutput("left", false)
				command.reply("Opening door...")
			elseif message == "close" then
				rs.setOutput("left", true)
				command.reply("Closing door...")
			else
				command.reply("Unknown command \"" .. command.text .. "\"!")
			end
		end
	end
end
