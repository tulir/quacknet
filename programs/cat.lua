local args = { ... }

if #args < 1 then
	print("Usage: cat <path>")
end

local file = fs.open(path, "r")
if not file then
	term.setTextColor(colors.red)
	print("No such file")
	return
end

print(file.readAll())
