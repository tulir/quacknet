local quackdnsd = quackserver.create("QuackDNSd", "0.1")

quackgpsd.registerServiceID("dns")
quackgpsd.registerDefaultServiceID()

quackdnsd.handle("resolve", function(data)
	local result = quackdns.resolveLocal(data.hostname)
	if result then
		return {
			success = true,
			id = result,
			ttl = 3600
		}
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
			hostnames = result,
			ttl = 3600
		}
	end
	return {
		success = false,
		error = "NXDOMAIN"
	}
end)

quackdnsd.start()
