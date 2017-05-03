print("QuackGPSd 0.1 started")

while true do
  local sender, message = quacknet.receive()
  local data = textutils.unserialize(message)
  if not data then
    print("Invalid request from " .. sender)
    quacknet.send(sender,
      textutils.serialize({
        error = "Invalid data format"
      }))
  else
    if data.command == "track" then
      print("Request to track " .. data.player .. " from " .. sender)
      local x, y, z = libquackgps.track(data.player)
      quacknet.send(sender,
        textutils.serialize({x=x, y=y, z=z}))
    elseif data.command == "list" then
      quacknet.send(sender, textutils.serialize(libquackgps.getNames(true)))
    else
      print("Unknown command " .. data.command .. " from " .. sender)
      quacknet.send(sender,
        textutils.serialize({
          error = "Unknown command!"
        }))
    end
  end
end