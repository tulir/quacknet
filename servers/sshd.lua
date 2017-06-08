function createWirelessTerm(receiver)
	local nativeTerm = term.native()
	local term = {
		send = function(command, data)
			if data == nil then
				data = {}
			elseif type(data) ~= "table" then
				data = {
					value = data
				}
			end
			data.service = "ssh-client"
			data.command = command
			quacknet.send(receiver, data, true)
		end,
		request = function(command, data)
			if data == nil then
				data = {}
			elseif type(data) ~= "table" then
				data = {
					value = data
				}
			end
			data.service = "ssh-client"
			data.command = command
			return quacknet.request(receiver, data, true)
		end
	}
	term.createListener = function()
		local conn = quackserver.create("QuackSSHd client connection", "0.1")
		conn.registerServiceID("sshd-connection")
		conn.handleEncrypted("raw-event", function(data)
			if type(data.params) == "table" then
				os.queueEvent(table.unpack(data.params))
			end
		end)
		conn.handleEncrypted("exit", function(data)
			conn.stop()
		end)
		conn.welcome = false
		conn.printOutput = false
		return conn
	end
	term.write = function(text)
		nativeTerm.write(text)
		term.send("write", text)
	end
	term.blit = function(text, fg, bg)
		nativeTerm.blit(text, fg, bg)
		term.send("blit", {
			text = text,
			fg = fg,
			bg = bg
		})
	end
	term.clear = function()
		nativeTerm.clear()
		term.send("clear")
	end
	term.clearLine = function()
		nativeTerm.clearLine()
		term.send("clearLine")
	end
	term.getCursorPos = function()
		local reply = term.request("getCursorPos")
		if type(reply.data) == "table" and type(reply.data.x) == "number" and type(reply.data.y) == "number" then
			return reply.data.x, reply.data.y
		end
		return 1, 1
	end
	term.setCursorPos = function(x, y)
		nativeTerm.setCursorPos(x, y)
		term.send("setCursorPos", {
			x = x,
			y = y
		})
	end
	term.setCursorBlink = function(blink)
		nativeTerm.setCursorBlink(blink)
		term.send("setCursorBlink", blink)
	end
	term.isColor = function()
		local reply = term.request("isColor")
		if reply.data then
			return reply.data.value
		end
		return false
	end
	term.isColour = term.isColor
	term.getSize = function()
		local reply = term.request("getSize")
		if type(reply.data) == "table" and type(reply.data.width) == "number" and type(reply.data.height) == "number" then
			return reply.data.width, reply.data.height
		end
		return 26, 19
	end
	term.scroll = function(lines)
		nativeTerm.scroll(lines)
		term.send("scroll", lines)
	end
	term.setTextColor = function(color)
		nativeTerm.setTextColor(color)
		term.send("setTextColor", color)
	end
	term.setTextColour = term.setTextColor
	term.getTextColor = function()
		local reply = term.request("getTextColor")
		if type(reply.data) == "number" then
			return reply.data.value
		end
		return colors.white
	end
	term.getTextColour = term.getTextColor
	term.setBackgroundColor = function(color)
		nativeTerm.setBackgroundColor(color)
		term.send("setBackgroundColor", color)
	end
	term.setBackgroundColour = term.setBackgroundColor
	term.getBackgroundColor = function()
		local reply = term.request("getBackgroundColor")
		if type(reply.data) == "number" then
			return reply.data.value
		end
		return colors.black
	end
	term.getBackgroundColour = term.getBackgroundColor
	return term
end

local server = quackserver.create("QuackSSHd", "0.1")
server.registerServiceID("sshd")
server.handleRaw("connect", function(msg)
	print("Received connection from " .. msg.sender)
	local wTerm = createWirelessTerm(msg.sender)
	local conn = wTerm.createListener()
	term.clear()
	term.setCursorPos(1, 1)
	term.redirect(wTerm)
	msg.reply({success = true}, true)

	parallel.waitForAny(
		function() shell.run("/rom/programs/shell") end,
		conn.start)
	conn.stop()
	term.redirect(term.native())
	print("Connection from " .. msg.sender .. " closed.")
end)
server.start()
