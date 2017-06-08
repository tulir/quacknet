local function validate(msg)
	if not msg.data or type(msg.data) ~= "table" or not msg.data.command then
		term.setTextColor(colors.orange)
		print("Invalid request from " .. msg.sender)
		return false
	end
	if not msg.data.server then
		msg.data.server = "default"
	end
	return true
end

local function checkServer(server, msg)
	for _, id in ipairs(server.ids) do
		if msg.data.server == id then
			return true
		end
	end
	return false
end

local function loop(server)
	local msg = quacknet.listen()
	if validate(msg) and checkServer(server, msg) then
		local command = server.commands[msg.data.command]
		if command ~= nil then
			command(msg)
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

local function start(server)
	term.setTextColor(colors.yellow)
	print(server.name .. " " .. server.version .. " started")

	while true do
		loop(server)
	end
end

function create(name, version)
	local server = {
		name = name,
		version = version,
		commands = {},
		ids = {},
	}
	server.handleRaw = function(name, func)
		server.commands[name] = func
	end
	server.handle = function(name, func)
		server.commands[name] = function(msg)
			msg.reply(func(msg.data, msg.sender))
		end
	end
	server.handleEncrypted = function(name, func)
		server.commands[name] = function(msg)
			msg.reply(func(msg.data, msg.sender), true)
		end
	end
	server.registerServiceID = function(id)
		server.ids[#server.ids+1] = id
	end
	server.registerDefaultServiceID = function()
		server.ids[#server.ids+1] = "default"
	end
	server.removeHandler = function(name)
		server.commands[name] = nil
	end
	server.start = function()
		start(server)
	end

	return server
end
