function rednet.isContainerModem( side )
    return peripheral.getType( side ) == "peripheralContainer" and table.contains( peripheral.call( side, "getContainedPeripherals" ), "modem" )
end

function rednet.isModem( side )
    return peripheral.getType( side ) == "modem" or rednet.isContainerModem( side )
end

function rednet.wrap( side )
    modem = peripheral.wrap( side )
    if rednet.isContainerModem( side ) then
        modem = modem.wrapPeripheral( "modem" )
    end
    return modem
end

function rednet.open( side )
    if type( side ) ~= "string" then
        error( "bad argument #1 (expected string, got " .. type( side ) .. ")", 2 )
    end
    if not rednet.isModem( side ) then 
        error( "No such modem: "..sModem, 2 )
    end
    modem = rednet.wrap( side )
    modem.open( os.getComputerID() )
    modem.open( rednet.CHANNEL_BROADCAST )
end

function rednet.isOpen( side )
    if side then
        -- Check if a specific modem is open
        if type( side ) ~= "string" then
            error( "bad argument #1 (expected string, got " .. type( side ) .. ")", 2 )
        end
        if rednet.isModem( side ) then
            modem = rednet.wrap( side )
            return modem.isOpen( os.getComputerID() ) and modem.isOpen( rednet.CHANNEL_BROADCAST )
        end
    else
        -- Check if any modem is open
        for n, sModem in ipairs( peripheral.getNames() ) do
            if isOpen( sModem ) then
                return true
            end
        end
    end
    return false
end

function rednet.close( side )
    if side then
        -- Close a specific modem
        if type( side ) ~= "string" then
            error( "bad argument #1 (expected string, got " .. type( side ) .. ")", 2 )
        end
        if not rednet.isModem( side ) then
            error( "No such modem: "..sModem, 2 )
        end
        modem = rednet.wrap( side )
        modem.close( os.getComputerID() )
        modem.close( rednet.CHANNEL_BROADCAST )
    else
        -- Close all modems
        for n,sModem in ipairs( peripheral.getNames() ) do
            if rednet.isOpen( sModem ) then
                rednet.close( sModem )
            end
        end
    end
end


function rednet.send( nRecipient, message, sProtocol )
    if type( nRecipient ) ~= "number" then
        error( "bad argument #1 (expected number, got " .. type( nRecipient ) .. ")", 2 )
    end
    if sProtocol ~= nil and type( sProtocol ) ~= "string" then
        error( "bad argument #3 (expected string, got " .. type( sProtocol ) .. ")", 2 )
    end
    -- Generate a (probably) unique message ID
    -- We could do other things to guarantee uniqueness, but we really don't need to
    -- Store it to ensure we don't get our own messages back
    local nMessageID = math.random( 1, 2147483647 )
    tReceivedMessages[ nMessageID ] = true
    tReceivedMessageTimeouts[ os.startTimer( 30 ) ] = nMessageID

    -- Create the message
    local nReplyChannel = os.getComputerID()
    local tMessage = {
        nMessageID = nMessageID,
        nRecipient = nRecipient,
        message = message,
        sProtocol = sProtocol,
    }

    if nRecipient == os.getComputerID() then
        -- Loopback to ourselves
        os.queueEvent( "rednet_message", nReplyChannel, message, sProtocol )

    else
        -- Send on all open modems, to the target and to repeaters
        local sent = false
        for n,sModem in ipairs( peripheral.getNames() ) do
            if isOpen( sModem ) then
                modem = rednet.wrap( sModem )
                modem.transmit( nRecipient, nReplyChannel, tMessage )
                modem.transmit( CHANNEL_REPEAT, nReplyChannel, tMessage )
                sent = true
            end
        end
    end
end
