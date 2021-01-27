local lootQualityThreshhold = 4

-- Event for looting.
local FrameAnnounceLootOpen = CreateFrame("Frame")
FrameAnnounceLootOpen:RegisterEvent("LOOT_OPENED")
FrameAnnounceLootOpen:SetScript("OnEvent", function(self, event, ...)

	if not rrilOptionAnnounceLoot then
		-- print("Announce loot disabled.")
		return
	else
		local masterlooterRaidID = select(3, GetLootMethod())
		if masterlooterRaidID == nil then
			-- masterlooterRaidID - Returns index of the master looter in the raid (corresponding to a raidX unit), or nil if the player is not in a raid or master looting is not used.
			-- print("Not masterlooter.")
			return
		else 
			local rosterName = select(1, GetRaidRosterInfo(masterlooterRaidID)) 
			local playerName = select(1, UnitName("player"))
			if rosterName ~= playerName then
				-- print("Not masterlooter, but in a raid with one.")
				return
			end
		end	
	end

	local AmountOfLoot = GetNumLootItems()	
	local qualCount = 0

	for i=1, AmountOfLoot, 1 do
		local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(i)
		if lootQuality >= lootQualityThreshhold then
			qualCount = qualCount + 1
		end
	end

	if qualCount > 0 then
		-- print(RRIncLoot_MessagePrefix, "Found some loot:", qualCount)
		SendChatMessage("Found some loot, get ready!","RAID","COMMON")

		for i=1, AmountOfLoot, 1 do
			local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(i)
			local itemLink = GetLootSlotLink(i)
			if lootQuality >= lootQualityThreshhold then
				-- print("|c"..select(4,GetItemQualityColor(lootQuality))..lootName.."|r")
				SendChatMessage(itemLink,"RAID","COMMON")
			end
		end
	end
	
end)