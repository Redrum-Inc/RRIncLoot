-- Template:
-- LootDistribution = {
-- 		item = "",
-- 		ranking = "",
-- 		levelIndex = 1,
-- 		levels = {
-- 			level = 50,
-- 			players = {
-- 				{
-- 					name = "bob", 
-- 					rolled = 0, 
-- 					accepted = false, 
-- 					passed = false,
--					lost = false
-- 				}
-- 			}
-- 		}
-- 	}

local LootDistribution = {
	item = "",
	ranking = "",
	active = false,
	rollActive = false,
	levelIndex = 1,
	levels = {
	}
}

-- Debug
local function d(text)
	print("DEBUG  "..text)
end

local function ResetLootDistribution()
	LootDistribution = {
		item = "",
		ranking = "",
		active = false,
		rollActive = false,
		levelIndex = 1,
		levels = {
		}
	}
end

local function GetRankingString(array)
	local firstRank = true
	local text = ""
	for i=1, #array do
		if firstRank then
			text = array[i].name.." "..array[i].ranking
			firstRank = false			
		else
			text = text..", "..array[i].name.." "..array[i].ranking			
		end		
	end	
	return text 
end

local function RemoveLocalRanking(item, name, rank)
	local itemName = select(1, GetItemInfo(item))
	local targetIndex = 0

	for i=1, #LootData[itemName] do
		-- print(LootData[itemName][i].name, LootData[itemName][i].ranking, " | ", name, rank)
		if LootData[itemName][i].name == name and LootData[itemName][i].ranking == rank then
			targetIndex = i
			
		end
	end	

	if targetIndex > 0 then
		table.remove(LootData[itemName], targetIndex) 
		print(RRIncLoot_MessagePrefix.."Removed "..name.." with rank "..rank.." from local loot data. This will not affect the sheets!")
	else
		print(RRIncLoot_MessagePrefix.."ERROR! RemoveLocalRanking cannot find target index!")
	end
end

local function SetupLootDistribution(item)
	-- Start processing linked item.
	LootDistribution.item = item
	local itemName = select(1, GetItemInfo(item))

	if LootData[itemName] == nil then
		RRIncLoot_StartFFARoll(item, true)
		return false	
	end

	if next(LootData[itemName]) == nil then
		RRIncLoot_StartFFARoll(item, true)
		return false
	end

	LootDistribution.ranking = GetRankingString(LootData[itemName])

	-- print(LootDistribution.ranking)

	-- -- Output info about item. TODO: Make this raid message.
	-- print("Item:", LootDistribution.item)
	-- print("Loot ranking:", LootDistribution.ranking)
	
	-- Split ranking into array and loop through, adding each to correct level as we go.
	local RankingArray = LootData[itemName]
	for i = 1, #RankingArray do
		
		local name = RankingArray[i].name
		local level = RankingArray[i].ranking
		local levelObject = {
			name=name, 
			rolled=0, 
			accepted=false, 
			passed=false,
			lost=false
		}
			
		if(UnitInRaid(name)) then -- Check if players are in raid.
			-- Loop through all levels to check if it already exists, if so add a new levelObject.
			local levelExists = false
			for j = 1, #LootDistribution.levels do 
				if(level == LootDistribution.levels[j].level) then
					levelExists = true
					table.insert(LootDistribution.levels[j].players, levelObject)
				end
			end

			-- Level did not exist, add new level and levelObject.
			if(not levelExists) then
				LootDistribution.levels[LootDistribution.levelIndex] = 
				{ 
					level = level,
					players = {}
				}		
				table.insert(LootDistribution.levels[LootDistribution.levelIndex].players, levelObject)
				LootDistribution.levelIndex = LootDistribution.levelIndex + 1 -- Increment levelIndex.
			end
		end
	end

	-- Debug printing to check data.
	-- for i = 1, #LootDistribution.levels do 
	-- 	d(LootDistribution.levels[i].level..":")
	-- 	for j = 1, #LootDistribution.levels[i].players do 
	-- 		local player = LootDistribution.levels[i].players[j]
	-- 		d(player.name, player.rolled, player.accepted, player.passed)
	-- 	end
	-- 	d("--------")
	-- end

	return true
end

local function AnnounceLoot()
	-- print("Distributing:", LootDistribution.item)
	-- print("Current ranking:", LootDistribution.ranking)
	SendChatMessage("Distributing: "..LootDistribution.item,"RAID","COMMON");
	SendChatMessage("Ranking ("..LootDataTimestamp.."): "..LootDistribution.ranking:sub(0,200),"RAID","COMMON"); -- Added substring to prevent 
	SendChatMessage(LootDistribution.item,"RAID_WARNING","COMMON");	
end

local function PromptNext()
	local msgPrompt = ""
	local players = LootDistribution.levels[LootDistribution.levelIndex].players
	for i=1, #players do
		if(i==1) then
			msgPrompt = players[i].name
		else
			msgPrompt = msgPrompt..", "..players[i].name
		end
	end

	msgPrompt = msgPrompt.." next in line for "..LootDistribution.item.."! Do you want it? (yes/no)"

	SendChatMessage(msgPrompt,"RAID","COMMON");

	if(rrilOptionUseWhispers) then
		for i=1, #players do
			C_Timer.After(1, function() SendChatMessage("You are next in line for "..LootDistribution.item.."! RESPOND IN RAID CHAT, NOT WHISPER!","WHISPER" ,"COMMON", players[i].name) end)
		end
	end

	if rrilOptionUseAddonChannel and C_ChatInfo.IsAddonMessagePrefixRegistered(RRIncPrompt_AddonChannel) then
		-- print("sending addon msg")
		for i=1, #players do
			C_ChatInfo.SendAddonMessage(RRIncPrompt_AddonChannel, players[i].name.."_".."next".."_"..LootDistribution.item, "RAID");
		end
	end
end

local function PromptRoll()
	local msgPrompt = ""
	local players = LootDistribution.levels[LootDistribution.levelIndex].players
	local firstName = true
	for i=1, #players do
		if(players[i].accepted and not players[i].lost) then
			if(firstName) then
				msgPrompt = players[i].name
				firstName = false
			else
				msgPrompt = msgPrompt..", "..players[i].name
			end
		end
	end

	msgPrompt = msgPrompt.." you are tied: ROLL!"

	C_Timer.After(0, function() SendChatMessage(msgPrompt,"RAID","COMMON") end)
	if(rrilOptionUseWhispers) then
		for i=1, #players do
			if(players[i].accepted) then
				C_Timer.After(1, function() SendChatMessage("You are tied for "..LootDistribution.item..": ROLL!","WHISPER" ,"COMMON", players[i].name) end)
			end
		end
	end

	if rrilOptionUseAddonChannel and C_ChatInfo.IsAddonMessagePrefixRegistered(RRIncPrompt_AddonChannel) then		
		for i=1, #players do
			C_ChatInfo.SendAddonMessage(RRIncPrompt_AddonChannel, players[i].name.."_".."roll".."_"..LootDistribution.item, "RAID");
		end
	end
end

local function GetMaxStep()
	local count = 0
	for i=1, #LootDistribution.levels do
		count = count + 1
	end
	return count
end

local function StepLootDistribution()
	LootDistribution.levelIndex = LootDistribution.levelIndex + 1 -- Step the index forward.
	if(LootDistribution.levelIndex <= GetMaxStep()) then
		-- d("Stepping...")
		PromptNext()
	else
		-- d("Go to FFA ROLL!")
		RRIncLoot_StartFFARoll(LootDistribution.item, false)
		ResetLootDistribution()
	end
end

local function StartLootDistribution()
	if(LootDistribution.item == nil or LootDistribution.item == "") then		
		print("StartLootDistribution: Missing item.")
		return
	end

	AnnounceLoot()
	LootDistribution.levelIndex = 0 -- Reset the level index so we can start stepping through it.
	LootDistribution.active = true
	StepLootDistribution()
end

local function PlayerHaveResponded(players, player)
	for i=1, #players do
		if(players[i].name == player) then
			if(players[i].accepted or players[i].passed) then
				return true
			end
		end
	end
	return false
end

local function AllPlayersHaveResponded(players)	
	for i=1, #players do
		if(players[i].accepted == false and players[i].passed == false) then -- Check if players have neither accepted nor passed.
			-- print("Have responded: ",i, players[i].player)
			return false
		end
	end
	return true
end

local function PlayerIsRelevant(players, player)
	for i=1, #players do
		if(players[i].name == player) then
			return true
		end
	end
	return false
end

local function PlayerSubmitRespone(player, action)
	for i=1, #LootDistribution.levels[LootDistribution.levelIndex].players do
		if(LootDistribution.levels[LootDistribution.levelIndex].players[i].name == player) then
			if(action=="accept") then
				LootDistribution.levels[LootDistribution.levelIndex].players[i].accepted = true
			end
			if(action=="pass") then
				LootDistribution.levels[LootDistribution.levelIndex].players[i].passed = true
				RRIncLoot_AddLootHistory(player, "passed on", LootDistribution.item)
			end
		end
	end
end

local function ResetRolls()
	for i=1, #LootDistribution.levels[LootDistribution.levelIndex].players do
		if(LootDistribution.levels[LootDistribution.levelIndex].players[i].lost == false) then
			LootDistribution.levels[LootDistribution.levelIndex].players[i].rolled = 0
		end
	end
end

local function StartRoll()
	LootDistribution.rollActive = true
	ResetRolls()
	PromptRoll()
end

local function EvaluateResponses()
	-- d("Evaluating responses...")

	local players = LootDistribution.levels[LootDistribution.levelIndex].players
	local acceptedCount = 0

	for i=1, #players do
		if(players[i].accepted) then
			acceptedCount = acceptedCount + 1
		end
	end
	
	if(acceptedCount > 1) then
		-- d("Multiple accepted, ROLL!")
		StartRoll()
	elseif(acceptedCount == 1) then
		-- d("One accepted, GZ!")
		for i=1, #players do
			if(players[i].accepted) then
				-- SendChatMessage(players[i].name.." accepted.","RAID","COMMON")
				SendChatMessage("Gz "..players[i].name.."!","RAID_WARNING","COMMON")
				RRIncLoot_AddLootHistory(players[i].name, "accepted", LootDistribution.item)
				RRIncLoot_LockVar = false;
				RemoveLocalRanking(LootDistribution.item, players[i].name, LootDistribution.levels[LootDistribution.levelIndex].level)
				RRIncLoot_GiveLootToPlayer(LootDistribution.item, players[i].name)
			end
		end
	elseif(acceptedCount < 1) then
		-- d("None accepted, NEXT!")
		StepLootDistribution()
	end
	
end

local FrameRaidParse = CreateFrame("Frame")
FrameRaidParse:RegisterEvent("CHAT_MSG_RAID")
FrameRaidParse:RegisterEvent("CHAT_MSG_RAID_LEADER")
FrameRaidParse:HookScript("OnEvent", function(self, event, msg, author) 	
	if not LootDistribution.active then		
		return	
	end

	local cleanedAuthor = author:gsub("-ZandalarTribe","")
	local cleanedMsg = msg:lower()		

	if(PlayerIsRelevant(LootDistribution.levels[LootDistribution.levelIndex].players, cleanedAuthor)) then -- Check if player is among those in line for item.
		
		if(not PlayerHaveResponded(LootDistribution.levels[LootDistribution.levelIndex].players, cleanedAuthor)) then -- Make sure player has not already responded.
			if(cleanedMsg=="yes") then
				PlayerSubmitRespone(cleanedAuthor, "accept")
				-- d("accept")
			end			

			if(cleanedMsg=="no" or cleanedMsg=="pass") then
				PlayerSubmitRespone(cleanedAuthor, "pass")
				-- d("pass")
			end	
			
			if(AllPlayersHaveResponded(LootDistribution.levels[LootDistribution.levelIndex].players)) then -- All players have responded, move on.
				EvaluateResponses()
			end
		end
	end

end)

local function PlayerIsAllowedRoll(players, player)
	for i=1, #players do
		-- Find player name in level. Check that they accepted. Check that they have not rolled before.
		if(players[i].name == player and players[i].accepted and players[i].rolled == 0 and players[i].lost == false) then 
			return true
		end
	end
	return false
end

local function PlayerSubmitRoll(player, value)
	local msg = "Accepted roll from "..player..": "..value
	-- d(msg)
	-- C_Timer.After(0, function() SendChatMessage(msg,"RAID","COMMON") end)
	SendChatMessage(msg,"RAID","COMMON")
	
	for i=1, #LootDistribution.levels[LootDistribution.levelIndex].players do
		if(LootDistribution.levels[LootDistribution.levelIndex].players[i].name == player) then
			LootDistribution.levels[LootDistribution.levelIndex].players[i].rolled = tonumber(value)
		end
	end
end

local function AllPlayersHaveRolled(players)	
	for i=1, #players do
		-- If players have accepted, not lost and rolled is not 0 then they have not rolled yet.
		if(players[i].accepted == true and players[i].lost == false and players[i].rolled == 0) then 
			return false
		end
	end
	return true
end

local function EvaluateRolls()
	-- d("Evaluating rolls...")

	local players = LootDistribution.levels[LootDistribution.levelIndex].players
	
	-- Find highest value
	local highestValue = 0
	for i=1, #players do
		if(players[i].rolled > 0 and players[i].rolled > highestValue) then			
			highestValue = players[i].rolled
		end
	end

	-- Count how many has that value
	local highestValueCount = 0
	for i=1, #players do
		if(players[i].rolled == highestValue) then
			highestValueCount = highestValueCount + 1			
		else
			LootDistribution.levels[LootDistribution.levelIndex].players[i].lost = true
			RRIncLoot_AddLootHistory(players[i].name, "lost roll for", LootDistribution.item)
		end
	end
	
	if(highestValueCount > 1) then
		-- d("Roll tied, ROLL AGAIN!")
		SendChatMessage("Roll tied!","RAID","COMMON")
		StartRoll()
	else
		-- d("someone won")
		for i=1, #players do
			if(players[i].rolled == highestValue) then
				LootDistribution.rollActive = false
				LootDistribution.active = false
				SendChatMessage(players[i].name.." won with a roll of "..highestValue..".","RAID","COMMON")
				SendChatMessage("Gz "..players[i].name.."!","RAID_WARNING","COMMON")
				RRIncLoot_AddLootHistory(players[i].name, "won roll for", LootDistribution.item)
				RRIncLoot_LockVar = false
				RemoveLocalRanking(LootDistribution.item, players[i].name, LootDistribution.levels[LootDistribution.levelIndex].level)
				RRIncLoot_GiveLootToPlayer(LootDistribution.item, players[i].name)
			end
		end
	end
	
end

local FrameSystemParse = CreateFrame("Frame")
FrameSystemParse:RegisterEvent("CHAT_MSG_SYSTEM")
FrameSystemParse:HookScript("OnEvent", function(self, event, msg) 
	if(LootDistribution.rollActive) then
		local system = {strsplit(" ", msg)}
		local name = system[1]
		local action = system[2]
		local value = system[3]
		local range = system[4]

		if(action == "rolls" and range == "(1-100)" and PlayerIsAllowedRoll(LootDistribution.levels[LootDistribution.levelIndex].players, name)) then			
			PlayerSubmitRoll(name, value)		
			
			if(AllPlayersHaveRolled(LootDistribution.levels[LootDistribution.levelIndex].players)) then
				EvaluateRolls()
			end
		end
	end	
end)



SLASH_RRINCLOOT1 = '/l'
SLASH_RRINCLOOT2 = '/loot'
function SlashCmdList.RRINCLOOT(item)
	if not RRIncLoot_PlayerIsMasterlooter() then
		print("RRIncLoot: You need to be the masterlooter.")
		return
	end

	if(RRIncLoot_LockVar) then
		print("RRIncLoot: Distribution or roll in progress, finish before starting a new one!")
		return
	end

	if(item == nil or item == "") then		
		print("RRIncLoot: Missing item, try /l [ItemLink]")
		return
	end

	RRIncLoot_LockVar = true

	ResetLootDistribution()
	local setupSuccessful = SetupLootDistribution(item)
	if setupSuccessful then
		StartLootDistribution()
	end
end

-- SLASH_RRINCTEST1 = '/t'
-- SLASH_RRINCTEST2 = '/test'
-- function SlashCmdList.RRINCTEST(item)
-- 	-- print("'"..LootDistribution.item.."'")
-- end