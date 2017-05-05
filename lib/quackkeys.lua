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
	if width < query:len() + ("Enter "):len() + 6 then
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
	local sendKey = random.string(32)
	local recvKey = random.string(32)
	local computerID = tonumber(ask("B-end ID"))
	keys[computerID] = {
		sendKey = sendKey,
		recvKey = recvKey
	}
	print("Handshake secret: " .. ("%X"):format(randSeed))
	local msg = quacknet.listen(computerID)
	if msg.text == "ping" then
		msg.reply("pong")
		print("Link with " .. computerID .. " formed successfully")
	else
		print("Link forming failed: Unexpected handshake message: " .. message)
	end
end

function handshakeB()
	local computerID = tonumber(ask("A-end ID"))
	local randSeed = tonumber(ask("Handshake secret"), 16)
	math.randomseed(randSeed)
	local recvKey = random.string(32)
	local sendKey = random.string(32)
	keys[computerID] = {
		sendKey = sendKey,
		recvKey = recvKey
	}
	local reply = quacknet.request(computerID, "ping")
	if reply == nil then
		print("Link forming failed: No pong received.")
	elseif reply.text == "pong" then
		print("Link with " .. computerID .. " formed successfully")
	else
		print("Link forming failed: Unexpected handshake message: " .. message)
	end
end
