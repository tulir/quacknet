local function install(name, toFile)
	if not toFile then
		toFile = name .. ".lua"
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
install("lib/rednet-container")
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
install("servers/mpfserver")
install("servers/quackgpssat")
install("servers/quackgpsd")
install("servers/quackdnsd")
install("servers/sshd")

install("programs/qhandshake")
install("programs/qsend")
install("programs/quacktrack")
install("programs/quackdns")
install("programs/nslookup")
install("programs/cat")
install("programs/ssh")
install("programs/sh")
install("programs/mpf")
install("programs/activate-autorun")
install("programs/encrypt")
install("programs/decrypt")
install("programs/quacktrack-ui")
install("programs/door")
install("installer", "programs/update-quacknet.lua")

install("startup")

term.setTextColor(colors.orange)
print("Installation complete! Rebooting...")
os.sleep(1)
os.reboot()
