os.loadAPI("/lib/sha1")
os.loadAPI("/lib/strings")
os.loadAPI("/lib/random")
os.loadAPI("/lib/quackkeys")

REQUEST_REPLY_TIMEOUT = 5
DEBUG = false

local function debug(message)
	if not DEBUG then
		return
	end
	local oldColor = term.getTextColor()
	term.setTextColor(colors.cyan)
	print("[Debug] ", message)
	term.setTextColor(oldColor)
end

local width, height = term.getSize()

function version()
	return "Quacknet 1.0"
end

local function mapTime()
	return (os.time() * 1000 + 18000) % 24000 + os.day() * 24000
end

local function checksum(message, secret)
	return sha1.hmac(secret .. mapTime(), message)
end

local function randomSeed()
	math.randomseed(mapTime())
	return math.random(2147483647)
end

function request(target, data)
	if type(data) == "table" then
		data = textutils.serialize(data)
	end
	local hostData = quackkeys.get(target)
	if not hostData then
		return {
			success = false,
			error = target .. " has not been linked."
		}
	end
	rednet.send(target, checksum(data, hostData.sendKey) .. data)

	timer = os.startTimer(REQUEST_REPLY_TIMEOUT)
	while true do
		local event, sender, reply = os.pullEvent()
		if event == "rednet_message" then
			local success
			sender, reply, success = handleReceived(sender, reply)
			if success == true then
				return {
					success = true,
					text = reply,
					data = pcall(textutils.unserialize, text)
				}
			end
		elseif event == "timer" then
			if sender == timer then
				return {
					success = false,
					error = "No reply received"
				}
			end
		end
	end
end

function listen()
	while true do
		local _, sender, message = os.pullEvent("rednet_message")
		local success
		data = handleServerReceived(sender, message)
		if data.success then
			return data
		else
			debug("Failed to receive message from " .. data.sender .. ": " .. data.error)
		end
	end
end

function handleServerReceived(sender, message)
	local success, hostData
	sender, message, success, hostData = handleReceived(sender, message)
	if success ~= true then
		return {
			success = false,
			error = success,
			sender = sender,
			text = text,
			data = nil
		}
	end
	return {
		success = true,
		sender = sender,
		text = text,
		data = pcall(textutils.unserialize, text),
		reply = function(data)
			if type(data) == "table" then
				data = textutils.serialize(data)
			end
			os.sleep(0.1)
			rednet.send(sender, checksum(data, hostData.sendKey) .. data)
		end
	}
end

function handleReceived(sender, message, computerID)
	if not quackkeys.get(sender) then
		return sender, message, sender .. " has not been linked"
	end
	if computerID and computerID >= 0 and computerID ~= sender then
		return sender, message, "Invalid computer id (expected " .. computerID .. " got " .. sender .. ")"
	end

	local hostData = quackkeys.get(sender)
	local hash = message:sub(1, 40)
	if checksum(message:sub(41), hostData.recvKey) == hash then
		return sender, message:sub(41), true, hostData
	end
	return sender, message, "Invalid message checksum"
end

open = rednet.open
close = rednet.close
isOpen = rednet.isOpen
