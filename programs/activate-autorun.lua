local args = { ... }
if table.getn(args) < 1 then
	term.setTextColor(colors.red)
	print("Usage: activate-autorun <file> [args...]")
	return
end

local filePath = args[1]
local fileName = table.remove(filePath:split("/"))
local file = fs.open("/autorun/" .. fileName, "w")
file.write("shell.run(\"" .. table.concat(args, " ") .. "\")")
file.close()
