function mcUnix()
	return (os.time() * 1000 + 18000) % 24000 + os.day() * 24000
end

function uptime()
	return os.clock()
end
