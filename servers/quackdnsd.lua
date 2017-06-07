local quackdnsd = quackserver.create("QuackDNSd", "0.1")

quackdnsd.handle("resolve", function(data)
	local result = quackdns.resolveLocal(data.hostname)
	if result then
		return {
			success = true,
			id = result
		})
	end
	return {
		success = false,
		error = "NXDOMAIN"
	}
end)

quackdnsd.handle("reverse", function(data)
	local result = quackdns.reverseLocal(data.hostname)
	if result then
		return {
			success = true,
			hostnames = result
		}
	end
	return {
		success = false,
		error = "NXDOMAIN"
	}
end)

quackdnsd.start()
