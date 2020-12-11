-- Auto assigning loot to winners:
-- https://wowwiki.fandom.com/wiki/API_GiveMasterLoot
-- https://wowwiki.fandom.com/wiki/API_GetNumLootItems
-- https://wowwiki.fandom.com/wiki/API_GetMasterLootCandidate
-- https://wowwiki.fandom.com/wiki/World_of_Warcraft_API#Loot

-- Event for looting, check how to parse available loot next.
local FrameAutoloot = CreateFrame("Frame")
FrameAutoloot:RegisterEvent("LOOT_OPENED")
FrameAutoloot:SetScript("OnEvent", function(self, event, ...)
	
	if not RRIncLoot_Settings.autoloot then
		print("Autoloot disabled.")
		return
	end

	local masterlooterRaidID = select(3, GetLootMethod())
	if masterlooterRaidID == nil then
		print("No masterlooter.")
		-- masterlooterRaidID - Returns index of the master looter in the raid (corresponding to a raidX unit), or nil if the player is not in a raid or master looting is not used.
		return
	else 
		local rosterName = select(1, GetRaidRosterInfo(masterlooterRaidID)) 
		local playerName = select(1, UnitName("player"))
		if rosterName ~= playerName then
			print("RRIncLoot: You are not the masterlooter, disabling autoloot.")
			RRIncLoot_ToggleAutoloot()
			return
		end
	end	
	
	local AmountOfLoot = GetNumLootItems()
	print("Num loot:", AmountOfLoot)		

	for i=1, AmountOfLoot, 1 do
		local lootIcon, lootName, lootQuantity, rarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
		local itemLink = GetLootSlotLink(i)
		
		if RRIncLoot_LootCanBeAutolooted(lootName) then
			local members = GetNumGroupMembers()
			
			for j=1, members, 1 do				
				local candidate = GetMasterLootCandidate(i, j);
				if(candidate == RRIncLoot_Settings.trashAssignee) then
					print("RRIncLoot: Trash detected, giving "..itemLink.." to "..candidate..".")
					GiveMasterLoot(i, j);
				end
			end
		end
	end
	
end)