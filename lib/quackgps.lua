local function contains(array, element)
	for _, value in ipairs(array) do
		if value == element then
			return true
		end
	end
	return false
end

local function getSatelliteData(id)
	local reply = quacknet.request(id, {
		command = "distances",
		service = "gps-sat"
	})
	if reply.data and reply.data.success then
		return {
			posX = reply.data.from.x,
			posY = reply.data.from.y,
			data = reply.data.distances
		}
	end
	return nil
end

local function getSatelliteOutput()
	return {
		getSatelliteData("sat1.gps"),
		getSatelliteData("sat2.gps"),
		getSatelliteData("sat3.gps")
	}
end

local function calculate(satellites)
	local r1 = math.pow(satellites[1].dist, 2)
	local r2 = math.pow(satellites[2].dist, 2)
	local r3 = math.pow(satellites[3].dist, 2)
	local d = math.abs(satellites[1].x - satellites[2].x)
	local dSq = math.pow(d, 2)
	local i = math.abs(satellites[1].x - satellites[3].x)
	local iSq = math.pow(i, 2)
	local j = math.abs(satellites[1].y - satellites[3].y)
	local jSq = math.pow(j, 2)

	local x = (r1 - r2 + dSq) / (2 * d)
	local y = (r1 - r3 + iSq + jSq) / (2 * j)
					- (i / j) * x
	local zSq = r1 - math.pow(x, 2) - math.pow(y, 2)
	local z
	if zSq > 0 then
		z = math.sqrt(zSq)
		if z < 0 then
			z = -z
		end
	elseif zSq < 0 then
		z = NaN
	else
		z = 0
	end

	return -x + satellites[1].x, -z + 250, -y + satellites[1].y
end

function getPlayers(inDimension)
	if type(inDimension) ~= "boolean" then
		inDimension = false
	end
	local reply = quacknet.request("sat-main.gps", {
		command = "names",
		inDimension = inDimension,
		service = "gps-sat"
	})
	if reply.data and reply.data.success then
		return reply.data.players
	end
	return nil
end

function getPlayersInDimension()
	return getPlayers(true)
end

function isInDimension(player)
	return contains(getPlayersInDimension(), player)
end

function isOnline(player)
	return contains(getPlayers(), player)
end

function trackAll()
	local rawdata = getSatelliteOutput()
	local data = {}
	for index, entry in ipairs(rawdata) do
		for _, playerEntry in ipairs(entry.data) do
			if data[playerEntry.player] == nil then
				data[playerEntry.player] = {}
			end
			data[playerEntry.player][index] = {}
			data[playerEntry.player][index].x = entry.posX
			data[playerEntry.player][index].y = entry.posY
			data[playerEntry.player][index].dist = playerEntry.distance
		end
	end

	local positions = {}
	for name, playerEntry in pairs(data) do
		local x, y, z = calculate(playerEntry)
		positions[name] = { x, y, z }
	end
	return positions
end

function track(player)
	local rawdata = getSatelliteOutput()
	local data = {}
	for index, entry in ipairs(rawdata) do
		data[index] = {}
		data[index].x = entry.posX
		data[index].y = entry.posY
		found = false
		for _, playerEntry in ipairs(entry.data) do
			if playerEntry.player == player then
				data[index].dist = playerEntry.distance
				found = true
				break
			end
		end
		if not found then
			return nil, nil, nil
		end
	end

	return calculate(data)
end
