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
	math.randomseed(time.uptime() + time.mcUnix())
	return math.random(2147483647)
end

function handshakeA(noverify, computerID)
	local randSeed = randomSeed()
	math.randomseed(randSeed)
	local sendKey = random.string(32)
	local recvKey = random.string(32)
	randomSeed()
	if computerID == nil then
		computerID = tonumber(ask("B-end ID"))
	end
	keys[computerID] = {
		sendKey = sendKey,
		recvKey = recvKey
	}
	print("Handshake secret: " .. ("%X"):format(randSeed))
	if noverify then
		save()
		print("Link with " .. computerID .. " formed but not verified")
		return
	end
	local msg = quacknet.listen(computerID)
	if msg.text == "ping" then
		msg.reply("pong")
		print("Link with " .. computerID .. " formed successfully")
		save()
	else
		print("Link forming failed: Unexpected handshake message: " .. message)
	end
end

function handshakeB(noverify, computerID, randSeed)
	if computerID == nil then
		computerID = tonumber(ask("A-end ID"))
	end
	if randSeed == nil then
		randSeed = tonumber(ask("Handshake secret"), 16)
	end
	math.randomseed(randSeed)
	local recvKey = random.string(32)
	local sendKey = random.string(32)
	randomSeed()
	keys[computerID] = {
		sendKey = sendKey,
		recvKey = recvKey
	}
	if noverify then
		save()
		print("Link with " .. computerID .. " formed but not verified")
		return
	end
	local reply = quacknet.request(computerID, "ping")
	if not reply.success then
		print("Link forming failed: " .. reply.error)
	elseif reply.text == "pong" then
		print("Link with " .. computerID .. " formed successfully")
		save()
	else
		print("Link forming failed: Unexpected handshake message: " .. reply.text)
	end
end
