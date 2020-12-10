local FFAStatus = {
    item = "",
    rollActive = false,
    countdown = 0,    
    rolls = {
        -- { player = "bob", roll = 0, lost = false }
    }
}

local Targeted = {
    item = "",
    rollActive = false,
    players = {}
}

local function ResetFFARoll()
    FFAStatus = {
        item = "",
        rollActive = false,
        countdown = 5,    
        rolls = {}
    }
end

local function ResetTargeted()
    Targeted = {
        item = "",
        rollActive = false,
        players = {}
    }
end


function RRIncLoot_StartFFARoll(item, BypassedDistribution)
    local itemLink = item or ""

    
    SendChatMessage(itemLink.." FFA ROLL!","RAID_WARNING","COMMON")
   
    ResetFFARoll()
    FFAStatus.rollActive = true
    FFAStatus.item = itemLink    
    local ticks = CountdownMax + 1
    FFAStatus.countdown = CountdownMax
    local myTicker = C_Timer.NewTicker(2, RRIncLoot_Countdown, CountdownMax) 
    -- end
end

local function StartTargetedRoll()
    Targeted.rollActive = true
    local msgPlayers = ""
    local firstName = true

    for i=1, #Targeted.players do
        -- print("Start: ", i, Targeted.players[i].player)
        if firstName == true then
            msgPlayers = Targeted.players[i].player
            firstName = false
        else
            msgPlayers = msgPlayers..", "..Targeted.players[i].player
        end
        C_Timer.After(1, function() SendChatMessage("You are tied for "..Targeted.item..". Roll again!","WHISPER" ,"COMMON", Targeted.players[i].player) end)
    end

    SendChatMessage(msgPlayers.." are tied for "..Targeted.item.. ". Roll again!","RAID","COMMON")
end

local function PlayerIsAllowedRoll(rolls, player)
    for i=1, #rolls do
        -- print(rolls[i].player, rolls[i].roll, rolls[i].lost)
        if(rolls[i].player == player and (rolls[i].roll > 0 or rolls[i].lost)) then
            return false
        end
    end
    return true
end

local function PlayerSubmitRoll(player, value)
    local rollObject = {
        player = player,
        roll = tonumber(value),
        lost = false
    }
    
    if FFAStatus.rollActive then
        table.insert(FFAStatus.rolls, rollObject)
    end

    if Targeted.rollActive then
        for i=1, #Targeted.players do
            if Targeted.players[i].player ==player then
                Targeted.players[i].roll = tonumber(value)
            end
        end
    end
    -- else
    --     for i=1, #FFAStatus.tiedRolls do
    --         if(FFAStatus.tiedRolls[i].player == player) then
    --             FFAStatus.tiedRolls[i].roll = tonumber(value)
    --         end
    --     end
    -- end
    local msg = "Accepted roll from "..player..": "..value
	SendChatMessage(msg,"RAID","COMMON")
end

local function AllPlayersHaveRolled(players)	
	for i=1, #players do		
		if(players[i].roll == 0 and players[i].lost == false) then -- If roll is 0 they have not rolled yet.
			return false
		end
	end
	return true
end

local function EvaluateRolls()
	print("Evaluating rolls...")
	
	-- Find highest value
	local highestValue = 0
	for i=1, #FFAStatus.rolls do
		if(FFAStatus.rolls[i].roll > 0 and FFAStatus.rolls[i].roll > highestValue) then			
			highestValue = FFAStatus.rolls[i].roll
		end
	end

	-- Count how many has that value
	local highestValueCount = 0
	for i=1, #FFAStatus.rolls do
		if(FFAStatus.rolls[i].roll == highestValue) then
			highestValueCount = highestValueCount + 1			
		else
			FFAStatus.rolls[i].lost = true
		end
	end
	
	if(highestValueCount > 1) then
        -- print("Roll tied!")
        ResetTargeted()        
        SendChatMessage("Roll tied!","RAID","COMMON")
        for i=1, #FFAStatus.rolls do
            if(not FFAStatus.rolls[i].lost) then
                local playerObject = {
                    player = FFAStatus.rolls[i].player,
                    roll = 0,
                    lost = false
                }
                -- print(playerObject.player)
                table.insert(Targeted.players, playerObject)
            end
        end
        Targeted.item = FFAStatus.item
        ResetFFARoll()
        StartTargetedRoll()
        
    elseif (highestValueCount == 1) then
		-- print("someone won")
		for i=1, #FFAStatus.rolls do
			if(FFAStatus.rolls[i].roll == highestValue) then
				FFAStatus.rollActive = false
                SendChatMessage(FFAStatus.rolls[i].player.." won with a roll of "..highestValue..".","RAID","COMMON")
                RRIncLoot_LockVar = false
			end
        end
    else
        SendChatMessage("No rolls, DE.","RAID","COMMON")
        RRIncLoot_LockVar = false
	end
	
end

local function EvaluateTargetedRolls()
	print("Evaluating targeted rolls...")
	
	-- Find highest value
	local highestValue = 0
	for i=1, #Targeted.players do
		if(Targeted.players[i].roll > 0 and Targeted.players[i].roll > highestValue) then			
			highestValue = Targeted.players[i].roll
		end
	end

	-- Count how many has that value
	local highestValueCount = 0
	for i=1, #Targeted.players do
		if(Targeted.players[i].roll == highestValue) then
			highestValueCount = highestValueCount + 1			
		else
			Targeted.players[i].lost = true
		end
	end
	
	if(highestValueCount > 1) then
        -- print("Roll tied, ROLL AGAIN!")       
       
        for i=1, #Targeted.players do
            if(Targeted.players[i].lost == false) then
                Targeted.players[i].roll = 0
            end
	    end
        SendChatMessage("Roll tied again!","RAID","COMMON")        
        
        StartTargetedRoll()
        
    elseif (highestValueCount == 1) then
		-- print("someone won")
		for i=1, #Targeted.players do
			if(Targeted.players[i].roll == highestValue) then
				FFAStatus.rollActive = false
                SendChatMessage(Targeted.players[i].player.." won with a roll of "..highestValue..".","RAID","COMMON")
                RRIncLoot_LockVar = false
			end
        end
    else
        SendChatMessage("No rolls, DE.","RAID","COMMON")
	end
	
end

function RRIncLoot_Countdown()    
    -- print("Countdowncalled.")
    FFAStatus.countdown = FFAStatus.countdown - 1;
    if FFAStatus.countdown > 0 and FFAStatus.rollActive then	
		--SendChatMessage(countdownCurrent .. "..","RAID" ,"COMMON");
		-- print(countdownCurrent .. "..")
        SendChatMessage(FFAStatus.countdown .. "..","RAID" ,"COMMON");	
        -- FFAStatus.countdown = FFAStatus.countdown - 1;  
    else
		if(FFAStatus.rollActive) then
			FFAStatus.rollActive = false
			EvaluateRolls()
		end
    end      
end

local FrameSystemParseFFA = CreateFrame("Frame")
FrameSystemParseFFA:RegisterEvent("CHAT_MSG_SYSTEM")
FrameSystemParseFFA:HookScript("OnEvent", function(self, event, msg) 
    local rangeIdentifier = "(1-100)"

	if(FFAStatus.rollActive or Targeted.rollActive) then
		local system = {strsplit(" ", msg)}
		local name = system[1]
		local action = system[2]
		local value = system[3]
        local range = system[4]        
        
        if FFAStatus.rollActive then
            if(action == "rolls" and range == rangeIdentifier and PlayerIsAllowedRoll(FFAStatus.rolls, name)) then			
                PlayerSubmitRoll(name, value)
            end
        end

        if Targeted.rollActive then
            -- print("targeted roll detected")
            if(action == "rolls" and range == rangeIdentifier and PlayerIsAllowedRoll(Targeted.players, name)) then			
                PlayerSubmitRoll(name, value)
            end

            if AllPlayersHaveRolled(Targeted.players) then
                EvaluateTargetedRolls()
            end
        end
        
	end	
end)