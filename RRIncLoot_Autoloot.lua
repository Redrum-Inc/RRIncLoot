-- Auto assigning loot to winners:
-- https://wowwiki.fandom.com/wiki/API_GiveMasterLoot
-- https://wowwiki.fandom.com/wiki/API_GetNumLootItems
-- https://wowwiki.fandom.com/wiki/API_GetMasterLootCandidate
-- https://wowwiki.fandom.com/wiki/World_of_Warcraft_API#Loot

-- Event for looting, check how to parse available loot next.
local FrameAutolootOpen = CreateFrame("Frame")
FrameAutolootOpen:RegisterEvent("LOOT_OPENED")
FrameAutolootOpen:SetScript("OnEvent", function(self, event, ...)
	-- print("even fired")
	RRIncLoot_LootOpen = true

	if not rrilOptionUseAutoloot then
		-- print("Autoloot disabled.")
		return
	end

	local masterlooterRaidID = select(3, GetLootMethod())
	if masterlooterRaidID == nil then
		-- masterlooterRaidID - Returns index of the master looter in the raid (corresponding to a raidX unit), or nil if the player is not in a raid or master looting is not used.
		return
	else 
		local rosterName = select(1, GetRaidRosterInfo(masterlooterRaidID)) 
		local playerName = select(1, UnitName("player"))
		if rosterName ~= playerName then
			print(RRIncLoot_MessagePrefix.."You are not the masterlooter, disabling autoloot.")
			rrilOptionUseAutoloot = false
			return
		end
	end	
	
	local AmountOfLoot = GetNumLootItems()
	--  print("Num loot:", AmountOfLoot)		

	for i=1, AmountOfLoot, 1 do
		local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(i)
		local itemLink = GetLootSlotLink(i)
		
		local members = GetNumGroupMembers()
		if RRIncLoot_LootCanBeAutolooted(lootName) then	
			for j=1, members, 1 do				
				local candidate = GetMasterLootCandidate(i, j);
				if(candidate == rrilOptionAutolootTarget) then
					print(RRIncLoot_MessagePrefix.."Trash detected, giving "..itemLink.." to "..candidate..".")
					GiveMasterLoot(i, j);
					break
				end
			end
		else
			if rrilOptionDisenchant and IsEquippableItem(itemLink) and (lootQuality >= 2 and lootQuality <= rrilOptionDisenchantThreshold) then
				print(RRIncLoot_MessagePrefix.."Diesnchant detected!")
				for j=1, members, 1 do				
					local candidate = GetMasterLootCandidate(i, j);
					if(candidate == rrilOptionDisenchantTarget) then
						print(RRIncLoot_MessagePrefix.."Disenchant detected, giving "..itemLink.." to "..candidate..".")
						GiveMasterLoot(i, j);
						break
					end
				end
			end
		end
	end
	
end)

local FrameAutolootClosed = CreateFrame("Frame")
FrameAutolootClosed:RegisterEvent("LOOT_CLOSED")
FrameAutolootClosed:SetScript("OnEvent", function(self, event, ...)
	RRIncLoot_LootOpen = false
end)