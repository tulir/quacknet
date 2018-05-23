local args = { ... }

if #args < 1 then
	term.setTextColor(colors.red)
	print("Usage: mpf <extend/retract>")
	return
end

c = args[1]
if c == "extend" or c == "open" or c == "e" or c == "o" then
	function open_1()
		return quacknet.request("mpf-1", {
			service = "mpf",
			command = "extend",
		})
	end
	function open_2()
		return quacknet.request("mpf-2", {
			service = "mpf",
			command = "extend",
		})
	end
	resp = parallel.waitForAll(open_1, open_2)
	print(resp)
elseif c == "retract" or c == "close" or c == "r" or c == "c" then
	function close_1()
		return quacknet.request("mpf-1", {
			service = "mpf",
			command = "retract",
		})
	end
	function close_2()
		return quacknet.request("mpf-2", {
			service = "mpf",
			command = "retract",
		})
	end
	resp = parallel.waitForAll(close_1, close_2)
	print(resp)
else
	term.setTextColor(colors.red)
	print("Usage: mpf <extend/retract>")
end
