os.loadAPI("/lib/sha1")
os.loadAPI("/lib/random")
os.loadAPI("/lib/quackkeys")

REQUEST_REPLY_TIMEOUT = 5

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
		return -1, nil
	end
	rednet.send(target, checksum(data, hostData.sendKey) .. data)

	timer = os.startTimer(REQUEST_REPLY_TIMEOUT)
	while true do
		local event, sender, reply = os.pullEvent()
		if event == "rednet_message" then
			local success
			sender, reply, success = handleReceived(sender, reply)
			if success == 1 then
				return {
					text = reply,
					data = pcall(textutils.unserialize, text)
				}
			end
		elseif event == "timer" then
			if sender == timer then
				return nil
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
		end
	end
end

function handleServerReceived(sender, message)
	local success, hostData
	sender, message, success, hostData = handleReceived(sender, message)
	if success ~= 1 then
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

--function receiveOnce(computerID, timeout)
--	local sender, message = rednet.receive(timeout)
--	return handleReceived(sender, message, computerID)
--end

function handleReceived(sender, message, computerID)
	if not knownHosts[sender] then
		return sender, message, -1
	end
	if computerID and computerID >= 0 and computerID ~= sender then
		return sender, message, -2
	end

	local hostData = knownHosts[sender]
	local hash = message:sub(1, 40)
	if checksum(message:sub(41), hostData.recvKey) == hash then
		return sender, message:sub(41), 1, hostData
	end
	return sender, message, -3
end

open = rednet.open
close = rednet.close
isOpen = rednet.isOpen
