local modem = false
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

if not modem then
	for _, side in ipairs(peripheral.getNames()) do
		if peripheral.getType(side) == "modem" and not modem and peripheral.call(side, "isWireless") then
			modem = side
			local file = fs.open("/.modem", "w")
			file.write(modem)
			file.close()
		end
	end
end

if not modem then
	term.setTextColor(colors.red)
	print("[Quacknet] No modem detected!")
	return
end

local function autorun(directory)
	if directory then
		directory = "/autorun/" .. directory
	else
		directory = "/autorun"
	end
	if fs.exists(directory) and fs.isDir(directory) then
		local files = fs.list(directory)
		table.sort(files)
		for n, file in ipairs(files) do
			if file:sub(1, 1) ~= "." and not fs.isDir(directory .. "/" .. file) then
				shell.run(directory .. "/" .. file)
			end
		end
	end
end

_G["modemSide"] = modem

autorun("preinit")

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.orange)
print("Loading libquacknet...")
os.loadAPI("/lib/quacknet")

autorun("postinit")

shell.setPath(shell.path() .. ":/programs")
quackkeys.load()
quackdns.load()
quacknet.open(modem)
term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.yellow)
print(os.version() .. " with " .. quacknet.version())

autorun()
