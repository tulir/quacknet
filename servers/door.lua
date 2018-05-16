args = { ... }
inputSide = "right"
outputSide = "left"
if #args > 0 then
	inputSide = args[1]
end
if #args > 1 then
	outputSide = args[2]
end

local prevState = rs.getInput(inputSide)

local doorserver = quackserver.create("Door Server", "1.0")
doorserver.registerServiceID("door")
doorserver.registerDefaultServiceID()

doorserver.handle("open", function(event)
	rs.setOutput(outputSide, true)
	event.reply("Opening door...")
end)

doorserver.handle("close", function(event)
	rs.setOutput(outputSide, false)
	event.reply("Closing door...")
end)

function redstoneListener()
	while true do
		os.pullEvent("redstone")
		if rs.getInput(inputSide) ~= prevState then
			if rs.getInput(inputSide) then
				rs.setOutput(outputSide, not rs.getOutput(outputSide))
			end
			prevState = rs.getInput(inputSide)
		end
	end
end

print("Door server 1.0 running")
term.setTextColor(colors.white)
print("Input:", inputSide)
print("Output:", outputSide)

parallel.waitForAny(doorserver.start, redstoneListener)
