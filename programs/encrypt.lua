local args = { ... }

if table.getn(args) < 1 then
	term.setTextColor(colors.red)
	print("Usage: encrypt <filename>")
end

local filename = args[1]
term.setTextColor(colors.orange)
print("QuackCrypt 0.1 - Encrypting " .. filename .. "...")
term.setTextColor(colors.cyan)
local file = fs.open(filename, "r")
local content = file.readAll()
file.close()
print("Enter password")
write("> ")
local password = read("*")
file = fs.open(filename, "w")
file.write(base64.encode(aes.encrypt(password, content)))
file.close()
print("File encrypted.")
