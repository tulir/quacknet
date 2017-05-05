local modem = false
local bridgeWrapped = false
if fs.exists("/.modem") then
	local file = fs.open("/.modem", "r")
	modem = file.readLine()
	file.close()
	if peripheral.getType(modem) ~= "modem" or not peripheral.call(modem, "isWireless") then
		term.setTextColor(colors.red)
		print("[Quacknet] Side set in /.modem does not contain a wireless modem! Removing file...")
		os.sleep(2)
		fs.delete("/.modem")
		modem = false
	end
end

if fs.exists("/.bridge") then
	local file = fs.open("/.bridge", "r")
	local bridge = file.readLine()
	if peripheral.getType(bridge) == "modem" and type(peripheral.wrap(bridge).openRemote) == "function" then
		_G["bridge"] = peripheral.wrap(bridge)
		bridgeWrapped = true
	else
		term.setTextColor(colors.red)
		print("[Quacknet] Side set in /.bridge does not contain a wireless bridge! Removing file...")
		os.sleep(2)
		fs.delete("/.bridge")
	end
end

if not modem or not bridgeWrapped then
	for _, side in ipairs(peripheral.getNames()) do
		if peripheral.getType(side) == "modem" then
			if not modem and peripheral.call(side, "isWireless") then
				modem = side
				local file = fs.open("/.modem", "w")
				file.write(modem)
				file.close()
			elseif not bridgeWrapped and type(peripheral.wrap(side).openRemote) == "function" then
				_G["bridge"] = peripheral.wrap(side)
				local file = fs.open("/.bridge", "w")
				file.write(side)
				file.close()
				bridgeWrapped = true
			end
		end
	end
end

if not modem then
	term.setTextColor(colors.red)
	print("[Quacknet] No modem detected!")
	return
end

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.orange)
print("Loading libquacknet...")
os.loadAPI("/lib/quacknet")
if _G["bridge"] then
	print("Loading libquackgps")
	os.loadAPI("/lib/quackgps")
end

if fs.exists("/autorun") and fs.isDir("/autorun") then
	local files = fs.list("/autorun")
	table.sort(files)
	for n, file in ipairs(files) do
		if file:sub(-3) == "pre" and file:sub(1, 1) ~= "." and not fs.isDir("autorun/" .. file) then
			shell.run("/autorun/" .. file)
		end
	end
end

shell.setPath(shell.path() .. ":/programs")
quackkeys.load()
quacknet.open(modem)
term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.yellow)
print(os.version() .. " with " .. quacknet.version())

if fs.exists("/autorun") and fs.isDir("/autorun") then
	local files = fs.list("/autorun")
	table.sort(files)
	for n, file in ipairs(files) do
		if file:sub(-3) ~= "pre" and file:sub(1, 1) ~= "." and not fs.isDir("autorun/" .. file) then
			shell.run("/autorun/" .. file)
		end
	end
end
