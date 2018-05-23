local mpfcontroller = quackserver.create("Megaplatform Controller", "1.0")
mpfcontroller.registerServiceID("mpf")
mpfcontroller.registerDefaultServiceID()

mpfcontroller.handle("extend", function()
	rs.setOutput("top", true)
	rs.setOutput("back", true)
	return "Extending platform..."
end)

mpfcontroller.handle("retract", function()
	rs.setOutput("back", false)
	os.sleep(4.8)
	rs.setOutput("top", false)
	return "Retracting platform..."
end)

mpfcontroller.start()
