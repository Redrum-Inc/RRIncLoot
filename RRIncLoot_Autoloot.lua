-- Auto assigning loot to winners:
-- https://wowwiki.fandom.com/wiki/API_GiveMasterLoot
-- https://wowwiki.fandom.com/wiki/API_GetNumLootItems
-- https://wowwiki.fandom.com/wiki/API_GetMasterLootCandidate
-- https://wowwiki.fandom.com/wiki/World_of_Warcraft_API#Loot

-- local function LootIsTrash(item)
-- 	-- for i=1, #TrashData.Test do
-- 	-- 	if(item == TrashData.Test[i]) then
-- 	-- 		print("test")
-- 	-- 		return true
-- 	-- 	end
-- 	-- end

-- 	for i=1, #TrashData.AQ do
-- 		if(item == TrashData.AQ[i]) then
-- 			print("aq")
-- 			return true
-- 		end
-- 	end

-- 	for i=1, #TrashData.Naxx do
-- 		print(TrashData.Naxx[i], item)
-- 		if(item == TrashData.Naxx[i]) then
-- 			print("naxx")
-- 			return true
-- 		end
-- 	end

-- 	return false
-- end



-- Event for looting, check how to parse available loot next.
local FrameAutoloot = CreateFrame("Frame")
FrameAutoloot:RegisterEvent("LOOT_OPENED")
FrameAutoloot:SetScript("OnEvent", function(self, event, ...)
	-- print("LOOT EVENT YAY")
	if(RRIncLoot_Settings.autoloot) then
		local AmountOfLoot = GetNumLootItems()
		-- print("Num loot:", AmountOfLoot)

		

		for i=1, AmountOfLoot, 1 do
			-- local lootName = select(2,GetLootSlotInfo(i))
			-- local rarity = select(4,GetLootSlotInfo(i))
			local lootIcon, lootName, lootQuantity, rarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
			local itemLink = GetLootSlotLink(i)
			
			if RRIncLoot_LootIsTrash(lootName) then
				-- print("Trash detected: ",lootName)
				local members = GetNumGroupMembers()
				-- print(members)
				for j=1, members, 1 do				
					local candidate = GetMasterLootCandidate(i, j);
					if(candidate == RRIncLoot_Settings.trashAssignee) then
						print("RRIncLoot: Trash detected, giving "..itemLink.." to "..candidate..".")
						GiveMasterLoot(i, j);
					end
				end
			end
			

			
			-- local itemLink = GetLootSlotLink(i)
			-- -- local info = select(1, GetItemInfo(itemLink))
			-- local info = GetItemInfo(itemLink)
			-- print(info)
			-- print(itemLink)
		end
	end
end)