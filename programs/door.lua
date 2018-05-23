args = {...}
if #args < 2 then
	term.setTextColor(colors.red)
	print("Not enough arguments!")
	print("Usage: door <open/close> <location>")
	return
end

local resp = quacknet.request(args[2] .. "door", {
	command = args[1],
	service = "door",
})

if resp.success then
	term.setTextColor(colors.green)
	print(resp.text)
else
	term.setTextColor(colors.orange)
	print(resp.error)
end
