local function validate(msg)
	if not msg.data or type(msg.data) ~= "table" or not msg.data.command then
		term.setTextColor(colors.orange)
		print("Invalid request from " .. msg.sender)
		msg.reply({
			success = false,
			error = "Invalid data format"
		})
		return false
	end
	return true
end

function create(name, version)
	local server = {
		name = name,
		version = version,
		commands = {}
	}
	server.handleCommand = function(name, func)
		server.commands[name] = func
	end
	server.removeCommand = function(name)
		server.commands[name] = nil
	end

	server.start = function()
		term.setTextColor(colors.yellow)
		print(server.name .. " " .. server.version .. " started")

		while true do
			local msg = quacknet.listen()
			if msg.validate() then
				local command = server.commands[msg.data.command]
				if command ~= nil then
					command(msg.data)
				else
					term.setTextColor(colors.orange)
					print("Unknown command " .. msg.data.command .. " from " .. sender)
					msg.reply({
						success = false,
						error = "Unknown command \"" .. msg.data.command .. "\"!"
					})
				end
			end
		end
	end
end
