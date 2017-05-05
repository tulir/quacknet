local args = { ... }

if table.getn(args) < 1 then
	term.setTextColor(colors.red)
	print("Usage: decrypt <filename>")
end

local filename = args[1]
term.setTextColor(colors.orange)
print("QuackCrypt 0.1 - Decrypting " .. filename .. "...")
term.setTextColor(colors.cyan)
local file = fs.open(filename, "r")
local content = fs.readAll()
file.close()
print("Enter password")
write("> ")
local password = read("*")
file = fs.open(filename, "w")
file.write(aes.decrypt(password, base64.decode(content)))
file.close()
print("File decrypted.")
