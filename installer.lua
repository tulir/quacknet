local function install(name, toFile)
	if not toFile then
		toFile = name
	end
	local response = http.get("https://raw.githubusercontent.com/tulir/quacknet/master/" .. name .. ".lua?nocache=true")
	local file = fs.open(toFile, "w")
	if response and file then
		file.write(response.readAll())
		file.close()
		response.close()
		print(name .. " installed successfully")
	else
		print("Failed to install " .. name)
	end
end

term.setTextColor(colors.orange)
print("Installing Quacknet...")

fs.makeDir("lib")
fs.makeDir("programs")
fs.makeDir("servers")
fs.makeDir("autorun")

term.setTextColor(colors.yellow)
install("lib/sha1")
install("lib/quacknet")
install("lib/quackkeys")
install("lib/quackgps")
install("lib/random")

install("servers/door")
install("servers/quackgpsd")

install("programs/qhandshake")
install("programs/qsend")
install("programs/quacktrack")
install("programs/activate-autorun")
install("installer", "programs/update-quacknet")

install("startup")

term.setTextColor(colors.orange)
print("Installation complete! Rebooting...")
os.sleep(1)
os.reboot()
