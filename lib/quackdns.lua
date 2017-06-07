hosts = {}
cache = {}
SERVER = nil

function save()
	file = fs.open("/hosts", "w")
	file.write(textutils.serialize(hosts))
	file.close()
end

function load()
	file = fs.open("/hosts", "r")
	if not file then
		keys = {}
		return
	end
	hosts = textutils.unserialize(file.readAll())
	file.close()
	if resolveLocal("dns") then
		SERVER = resolveLocal("dns")
	end
end

function addHost(name, id)
	hosts[name] = id
	if name == "dns" then
		SERVER = id
	end
	save()
end

function removeHost(name)
	hosts[name] = nil
	if name == "dns" then
		SERVER = nil
	end
	save()
end

function resolveLocal(name)
	return hosts[name]
end

function resolveCached(name)
	local cached = cache[name]
	if cached ~= nil then
		if cached.expired() then
			cache[name] = nil
		else
			return cached.id
		end
	end
	return nil
end

function resolveServer(name)
	if not SERVER then
		return nil
	end

	local reply = quacknet.request(SERVER, {
		command = "resolve",
		hostname = name
	})
	if reply.data and reply.data.success then
		local cacheEntry = {
			expiry = time.mcUnix() + reply.data.ttl,
			id = reply.data.id
		}
		cacheEntry.expired = function()
			return cacheEntry.expiry > time.mcUnix()
		end
		cached[name] = cacheEntry
		return reply.data.id
	end
	return nil
end

function resolve(name)
	local localResult = resolveLocal(name)
	if localResult ~= nil then
		return localResult, "LOCAL"
	end
	local cacheResult = resolveCached(name)
	if cacheResult ~= nil then
		return cacheResult, "CACHE"
	end
	local serverResult = resolveServer(name)
	if serverResult ~= nil then
		return serverResult, "SERVER"
	end
	return nil, nil
end

function reverseLocal(id)
	local names = {}
	for hostname, hostid in pairs(hosts) do
		if hostid == id then
			names[#names+1] = hostname
		end
	end
	return names
end

function reverseCached(id)
	local names = {}
	for hostname, data in pairs(cache) do
		if data.expired() then
			cache[name] = nil
		elseif data.id == id then
			names[#names+1] = hostname
		end
	end
	return names
end

function reverseServer(id)
	if not SERVER then
		return nil
	end

	local reply = quacknet.request(SERVER, {
		command = "reverse",
		id = id
	})
	if reply.data and reply.data.success then
		for _, hostname in ipairs(reply.data.hostnames) do
			local cacheEntry = {
				expiry = time.mcUnix() + reply.data.ttl,
				id = id
			}
			cacheEntry.expired = function()
				return cacheEntry.expiry > time.mcUnix()
			end
			cached[hostname] = cacheEntry
		end
		return reply.data.hostnames
	end
	return nil
end

function reverse(id)
	local localResult = reverseLocal(id)
	if #localResult > 0 then
		return localResult, "LOCAL"
	end
	local cacheResult = reverseCached(id)
	if #cacheResult > 0 then
		return cacheResult, "CACHE"
	end
	local serverResult = reverseServer(id)
	if #serverResult > 0 then
		return serverResult, "SERVER"
	end
	return nil, nil
end
