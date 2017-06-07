local function install(name, toFile)
	if not toFile then
		toFile = name
	end
	local response = http.get("https://raw.githubusercontent.com/tulir/quacknet/master/" .. name .. ".lua")
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
install("lib/aes")
install("lib/base64")
install("lib/quacknet")
install("lib/quackkeys")
install("lib/quackgps")
install("lib/quackserver")
install("lib/quackdns")
install("lib/random")
install("lib/time")
install("lib/maths")
install("lib/strings")
install("lib/tables")

install("servers/door")
install("servers/quackgpsd")
install("servers/quackdnsd")

install("programs/qhandshake")
install("programs/qsend")
install("programs/quacktrack")
install("programs/nslookup")
install("programs/activate-autorun")
install("programs/encrypt")
install("programs/decrypt")
fs.delete("programs/playertracker")
install("programs/quacktrack-ui")
install("installer", "programs/update-quacknet")

install("startup")

term.setTextColor(colors.orange)
print("Installation complete! Rebooting...")
os.sleep(1)
os.reboot()
