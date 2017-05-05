local modem = false
for _, side in ipairs(peripheral.getNames()) do
	if peripheral.getType(side) == "modem" then
		if peripheral.call(side, "isWireless") then
			modem = side
		elseif type(peripheral.wrap(side).openRemote) == "function" then
			_G["bridge"] = peripheral.wrap(side)
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
