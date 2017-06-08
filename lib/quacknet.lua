os.loadAPI("/lib/sha1")
os.loadAPI("/lib/base64")
os.loadAPI("/lib/aes")
os.loadAPI("/lib/strings")
os.loadAPI("/lib/tables")
os.loadAPI("/lib/maths")
os.loadAPI("/lib/random")
os.loadAPI("/lib/time")
os.loadAPI("/lib/quackkeys")
os.loadAPI("/lib/quackdns")
os.loadAPI("/lib/quackserver")

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

function version()
	return "Quacknet 1.1"
end

local function checksum(message, secret, timestamp)
	return sha1.hmac(secret .. timestamp, message)
end

local function compile(message, secret)
	now = time.mcUnix()
	return checksum(message, secret, now) .. ";" .. now .. ";" .. message
end

local function compileEncrypted(message, secret)
	return "c;" .. time.mcUnix() .. ";" .. base64.encode(aes.encrypt(secret, "quacknet-encrypted:" .. message))
end

function request(target, data, encrypt)
	if type(data) == "table" then
		data = textutils.serialize(data)
	end
	if type(target) ~= "number" then
		origTarget = target
		target = quackdns.resolve(target)
		if target == nil then
			return {
				success = false,
				error = "Could not resolve hostname " .. origTarget .. "."
			}
		end
	end
	if type(target) ~= "number" then
		return {
			success = false,
			error = target .. " invalid target type."
		}
	end
	local hostData = quackkeys.get(target)
	if not hostData then
		return {
			success = false,
			error = target .. " has not been linked."
		}
	end
	if not isOpen(modemSide) then
		open(modemSide)
	end
	if encrypt then
		rednet.send(target, compileEncrypted(data, hostData.sendKey))
	else
		rednet.send(target, compile(data, hostData.sendKey))
	end

	timer = os.startTimer(REQUEST_REPLY_TIMEOUT)
	while true do
		if not isOpen(modemSide) then
			open(modemSide)
		end
		local event, sender, reply = os.pullEvent()
		if event == "rednet_message" then
			local success
			sender, reply, success = handleReceived(sender, reply)
			if success == true then
				ok, data = pcall(textutils.unserialize, reply)
				return {
					success = true,
					text = reply,
					data = data
				}
			else
				debug("Failed to receive message from " .. sender .. ": " .. success)
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

function listen(computerID)
	while true do
		if not isOpen(modemSide) then
			open(modemSide)
		end
		local _, sender, message = os.pullEvent("rednet_message")
		data = handleServerReceived(sender, message)
		if data.success and (not computerID or data.sender == computerID) then
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
			text = message,
			data = nil
		}
	end
	ok, data = pcall(textutils.unserialize, message)
	return {
		success = true,
		sender = sender,
		text = message,
		data = data,
		reply = function(data, encrypt)
			if type(data) == "table" then
				data = textutils.serialize(data)
			end
			os.sleep(0.1)
			if encrypt then
				rednet.send(sender, compileEncrypted(data, hostData.sendKey))
			else
				rednet.send(sender, compile(data, hostData.sendKey))
			end
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
	local hash, sendtime
	hash, sendtime, message = table.unpack(string.split(message, ";"))
	sendtime = tonumber(sendtime)
	now = time.mcUnix()
	if now - 3 > sendtime or sendtime > now + 3 then
		return sender, message, "Message too old"
	elseif hash == "c" then
		message = aes.decrypt(hostData.recvKey, base64.decode(message))
		if string.startsWith(message, "quacknet-encrypted:") then
			return sender, message:sub(("quacknet-encrypted:"):len() + 1), true, hostData
		else
			return sender, message, "Invalid encrypted message"
		end
	elseif checksum(message, hostData.recvKey, sendtime) == hash then
		return sender, message, true, hostData
	end
	return sender, message, "Invalid message checksum"
end

open = rednet.open
close = rednet.close
isOpen = rednet.isOpen
