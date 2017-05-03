args = { ... }
if table.getn(args) < 1 then
	term.setTextColor(colors.red)
	print("Usage: activate-autorun <file> [args...]")
	return
end

filePath = args[1]
fileName = strings.split(fileName, "/").remove()
file = fs.open("/autorun/" .. fileName, "w")
file.write("shell.run(\"" .. table.join(args, " ") .. "\")")
file.close()
