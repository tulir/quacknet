local args = { ... }

if #args < 1 then
	term.setTextColor(colors.red)
	print("Usage: ssh <host>")
	return
end

local host = args[1]

local reply = quacknet.request(host, {
	command = "connect",
	service = "sshd"
}, true)

if not reply.data or not reply.data.success then
	term.setTextColor(colors.orange)
	print("Connection failed!")
	return
end

local function clear()
	term.setCursorPos(1, 1)
	oldFg = term.getTextColor()
	oldBg = term.getBackgroundColor()
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.green)
	term.print("Connected to " .. host)
	term.setTextColor(oldFg)
	term.setBackgroundColor(oldBg)
	term.setCursorPos(1, 2)
end

clear()
local conn = quackserver.create("QuackSSH client", "0.1")
conn.registerServiceID("ssh-client")

conn.handleEncrypted("write", function(data)
	term.write(data.value)
end)

conn.handleEncrypted("blit", function(data)
	term.blit(data.text, data.fg, data.bg)
end)

conn.handleEncrypted("clear", clear)

conn.handleEncrypted("clearLine", function()
	term.clearLine()
end)

conn.handleEncrypted("getCursorPos", function()
	local x, y = term.getCursorPos()
	return {
		x = x,
		y = y - 1
	}
end)

conn.handleEncrypted("setCursorPos", function(data)
	term.setCursorPos(data.x, data.y + 1)
end)

conn.handleEncrypted("setCursorBlink", function(data)
	term.setCursorBlink(data.value)
end)

conn.handleEncrypted("isColor", function()
	return {
		value = term.isColor()
	}
end)

conn.handleEncrypted("getSize", function()
	local width, height = term.getSize()
	return {
		width = width,
		height = height - 1
	}
end)

conn.handleEncrypted("scroll", function(value)
	term.scroll(data.value)
end)

conn.handleEncrypted("setTextColor", function(data)
	term.setTextColor(data.value)
end)

conn.handleEncrypted("getTextColor", function(data)
	return {
		value = term.getTextColor()
	}
end)

conn.handleEncrypted("setBackgroundColor", function(data)
	term.setBackgroundColor(data.value)
end)

conn.handleEncrypted("getBackgroundColor", function(data)
	return {
		value = term.getBackgroundColor()
	}
end)

conn.handleEncrypted("exit", function(data)
	conn.stop()
end)

parallel.waitForAny(
	function()
		while true do
			local data = table.pack(os.pullEventRaw())
			quacknet.request(host, {
				command = "raw-event",
				service = "sshd-connection",
				params = data
			})
		end
	end,
	conn.start)
