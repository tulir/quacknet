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
	term.clear()
	term.setCursorPos(1, 1)
	oldFg = term.getTextColor()
	oldBg = term.getBackgroundColor()
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.green)
	term.write("Connected to " .. host)
	term.setTextColor(oldFg)
	term.setBackgroundColor(oldBg)
	term.setCursorPos(1, 2)
end

local conn = quackserver.create("QuackSSH client", "0.1")
conn.registerServiceID("ssh-client")

conn.handleEncrypted("write", function(data)
	if type(data) == "table" then
		term.write(data.value)
	end
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
	if type(data) == "table" then
		term.setCursorPos(data.x, data.y + 1)
	end
end)

conn.handleEncrypted("setCursorBlink", function(data)
	if type(data) == "table" then
		term.setCursorBlink(data.value)
	end
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
	if type(data) == "table" then
		term.scroll(data.value)
	end
end)

conn.handleEncrypted("setTextColor", function(data)
	if type(data) == "table" then
		term.setTextColor(data.value)
	end
end)

conn.handleEncrypted("getTextColor", function(data)
	return {
		value = term.getTextColor()
	}
end)

conn.handleEncrypted("setBackgroundColor", function(data)
	if type(data) == "table" then
		term.setBackgroundColor(data.value)
	end
end)

conn.handleEncrypted("getBackgroundColor", function(data)
	return {
		value = term.getBackgroundColor()
	}
end)

conn.handleEncrypted("exit", function(data)
	conn.stop()
end)

conn.welcome = false
conn.printOutput = false

clear()

local passthroughEvents = {
	"char",
	"key",
	"key_up",
	"mouse_click",
	"mouse_drag",
	"mouse_scroll",
	"mouse_up",
	"paste",
	"terminate"
}
term.setTextColor(colors.white)
parallel.waitForAny(
	function()
		while true do
			local data = table.pack(os.pullEventRaw())
			coroutine.resume(coroutine.create(function()
				if table.contains(passthroughEvents, data[1]) then
					quacknet.request(host, {
						command = "raw-event",
						service = "sshd-connection",
						params = data
					}, true)
				end
			end))
		end
	end,
	conn.start)
conn.stop()
term.clear()
print("Connection closed.")
