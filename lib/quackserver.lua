local function validate(msg)
	if not msg.data or type(msg.data) ~= "table" or type(msg.data.command) ~= "string" then
		term.setTextColor(colors.orange)
		if server.printOutput then
			print("Invalid request from " .. msg.sender)
		end
		return false
	end
	if not msg.data.service then
		msg.data.service = "default"
	end
	msg.data.command = msg.data.command:lower()
	return true
end

local function checkServer(server, msg)
	for _, id in ipairs(server.ids) do
		if msg.data.service == id then
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
			if server.printOutput then
				print("Unknown command " .. msg.data.command .. " from " .. sender)
			end
			msg.reply({
				success = false,
				error = "Unknown command \"" .. msg.data.command .. "\"!"
			})
		end
	end
end

local function start(server)
	if server.welcome then
		term.setTextColor(colors.yellow)
		print(server.name .. " " .. server.version .. " started")
	end

	while true do
		if server.stopped then
			return
		end
		loop(server)
	end
end

function create(name, version)
	local server = {
		name = name,
		version = version,
		commands = {},
		ids = {},
		stopped = false,
		printOutput = false,
		welcome = false
	}
	server.stop = function()
		server.stopped = true
	end
	server.handleRaw = function(name, func)
		server.commands[name:lower()] = func
	end
	server.handle = function(name, func)
		server.commands[name:lower()] = function(msg)
			local reply = func(msg.data, msg.sender)
			if reply ~= nil then
				msg.reply(reply)
			end
		end
	end
	server.handleEncrypted = function(name, func)
		server.commands[name:lower()] = function(msg)
			local reply = func(msg.data, msg.sender)
			if reply ~= nil then
				msg.reply(reply, true)
			end
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
	server.handle("ping", function(data)
		if data.service ~= "default" then
			return "pong"
		end
		return nil
	end)

	return server
end
