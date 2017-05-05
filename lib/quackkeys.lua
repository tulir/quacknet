local keys = {}

local width, height = term.getSize()

function save()
	file = fs.open("/authorized_keys", "w")
	file.write(textutils.serialize(keys))
	file.close()
end

function load()
	file = fs.open("/authorized_keys", "r")
	if not file then
		keys = {}
		return
	end
	keys = textutils.unserialize(file.readAll())
	file.close()
end

function get(target)
	return keys[target]
end

local function ask(query)
	if width < query:len() + 6 then
		print("Enter ", query)
	else
		term.write("Enter ")
		term.write(query)
	end
	term.write("> ")
	return read()
end

local function randomSeed()
	math.randomseed(os.clock() + (os.time() * 1000 + 18000) % 24000 + os.day() * 24000)
	return math.random(2147483647)
end

function handshakeA()
	local randSeed = randomSeed()
	math.randomseed(randSeed)
	local sendKey = randomKey()
	local recvKey = randomKey()
	local computerID = tonumber(ask("B-end ID"))
	knownHosts[computerID] = {
		sendKey = sendKey,
		recvKey = recvKey,
	}
	print("Handshake secret: " .. ("%X"):format(randSeed))
	local _, message, success = receiveOnce(computerID)
	send(computerID, "pong")
	if success == 1 and message == "ping" then
		print("Link with " .. computerID .. " formed successfully")
	else
		print("Link forming failed: Unexpected handshake message: " .. message)
	end
end

function handshakeB()
	local computerID = tonumber(ask("A-end ID"))
	local randSeed = tonumber(ask("Handshake secret"), 16)
	math.randomseed(randSeed)
	local recvKey = randomKey()
	local sendKey = randomKey()
	knownHosts[computerID] = {
		sendKey = sendKey,
		recvKey = recvKey,
	}
	send(computerID, "ping")
	local _, message, success = receiveOnce(computerID)
	if success == 1 and message == "pong" then
		print("Link with " .. computerID .. " formed successfully")
	else
		print("Link forming failed: Unexpected handshake message: " .. message)
	end
end
