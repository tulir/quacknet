local args = { ... }

if #args < 1 then
	term.setTextColor(colors.red)
	print("Usage: mpf <extend/retract>")
	return
end

function print_resp(from, resp)
	if resp.success then
		term.setTextColor(colors.green)
		print(from .. ": " .. resp.text)
	else
		term.setTextColor(colors.orange)
		print(from .. ": " .. resp.error)
	end
end

c = args[1]
if c == "extend" or c == "open" or c == "e" or c == "o" then
	function open_1()
		resp = quacknet.request("mpf-1", {
			service = "mpf",
			command = "extend",
		})
		print_resp("West Controller", resp)
	end
	function open_2()
		resp = quacknet.request("mpf-2", {
			service = "mpf",
			command = "extend",
		})
		print_resp("East Controller", resp)
	end
	parallel.waitForAll(open_1, open_2)
elseif c == "retract" or c == "close" or c == "r" or c == "c" then
	function close_1()
		resp = quacknet.request("mpf-1", {
			service = "mpf",
			command = "retract",
		})
		print_resp("West Controller", resp)
	end
	function close_2()
		resp = quacknet.request("mpf-2", {
			service = "mpf",
			command = "retract",
		})
		print_resp("East Controller", resp)
	end
	parallel.waitForAll(close_1, close_2)
else
	term.setTextColor(colors.red)
	print("Usage: mpf <extend/retract>")
end
