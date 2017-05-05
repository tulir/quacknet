local args = { ... }

local radar = table.contains(args, "--radar")
local list = table.contains(args, "--list") or not radar
local small = table.contains(args, "--small")

os.loadAPI("/quacktrackdata")

RADAR_CHUNKS = 32

local monitor = peripheral.wrap("left")
term.redirect(monitor)

local playerSensor = peripheral.wrap("bottom")

if not playerSensor and radar then
	term.setTextColor(colors.red)
	print("Player sensor not installed!")
	return
end

if small then
	monitor.setTextScale(0.5)
end

function printList(data)
	local darkBlue = false
	print(string.format("%-16s @ %-7s %-5s %-7s", "Player", "x", "y", "z"))
	for name, location in pairs(data.players) do
		if darkBlue then
			term.setTextColor(colors.blue)
		else
			term.setTextColor(colors.lightBlue)
		end
		darkBlue = not darkBlue
		pos = {x = location[1], y = location[2], z = location[3]}
		print(string.format("%-16s @ %-7.1f %-5.1f %-7.1f", name, pos.x, pos.y, pos.z))
	end
end

function printRadar(data)
	local offsetX, offsetY = term.getCursorPos()
	local width, height = term.getSize()
	width = width - offsetX
	height = height - offsetY

	paintutils.drawFilledBox(
		width / 2 - 1 + offsetX,
		height / 2 - 1 + offsetY,
		width / 2 + 1 + offsetX,
		height / 2 + 1 + offsetY,
		colors.cyan)

	local radarDistance = RADAR_CHUNKS * 16
	local playerDistances = playerSensor.getNearbyPlayers(radarDistance)
	for player, distance in pairs(table.mapify(playerDistances, "player", "distance")) do
		local color = colors.red
		if table.contains(quacktrackdata.team, player) then
			color = colors.lime
		elseif table.contains(quacktrackdata.allies, player) then
			color = colors.green
		end
		if distance < radarDistance then
			paintutils.drawPixel(
				(quacktrackdata.mypos.x - data.players[player][1]) / 16 + offsetX,
				(quacktrackdata.mypos.z - data.players[player][3]) / 16 + offsetY,
				color
			)
		end
	end
	term.setBackgroundColor(colors.black)
end

while true do
	local hour = math.floor(os.time())
	local minute = math.floor((os.time() % 1) * 60)
	local reply = quacknet.request(39, {command="track_all"})

	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.orange)
	print(string.format("QuackTrack UI 1.0 - Day: %d, Time: %02d:%02d", os.day(), hour, minute))

	if not reply.data or not reply.data.success then
		term.setTextColor(colors.red)
		print("Failed to track players!")
		if reply.error then
			print("  ", reply.error)
		end
		if reply.data and reply.data.error then
			print("  ", reply.data.error)
		end
	else
		if list then
			printList(reply.data)
		end

		if radar then
			printRadar(reply.data)
		end
	end
	os.sleep(0.25)
end
