local quackdnsd = quackserver.create("QuackDNSd", "0.1")

quackdnsd.handleCommand("resolve", function(msg)
	local result = quackdns.resolveLocal(msg.data.hostname)
	if result then
		msg.reply({
			success = true,
			id = result
		})
	else
		msg.reply({
			success = false,
			error = "NXDOMAIN"
		})
	end
end)

quackdnsd.handleCommand("reverse", function(msg)
	local result = quackdns.reverseLocal(msg.data.hostname)
	if result then
		msg.reply({
			success = true,
			hostnames = result
		})
	else
		msg.reply({
			success = false,
			error = "NXDOMAIN"
		})
	end
end)

quackdnsd.start()
