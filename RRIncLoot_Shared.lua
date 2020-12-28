function RRIncLoot_LootCanBeAutolooted(item)
	for i=1, #AutolootData.Items do
		for j=0, #AutolootData.Items[i] do			
			if(item == AutolootData.Items[i][j]) then			
				return true
			end
		end		
	end
	return false
end

function RRIncLoot_PlayerIsMasterlooter()
	local masterlooterRaidID = select(3, GetLootMethod())
	if masterlooterRaidID == nil then
		-- masterlooterRaidID - Returns index of the master looter in the raid (corresponding to a raidX unit), or nil if the player is not in a raid or master looting is not used.
		return false
	else 
		local rosterName = select(1, GetRaidRosterInfo(masterlooterRaidID)) 
		local playerName = select(1, UnitName("player"))
		if rosterName ~= playerName then			
			return false
		end
	end	
	return true
end

local function GiveItem(itemLink, player)

	if not RRIncLoot_LootOpen then
		print(RRIncLoot_MessagePrefix.."Loot is not opened, aborting!")
		return
	end

	local AmountOfLoot = GetNumLootItems()
	--  print("Num loot:", AmountOfLoot)		

	for i=1, AmountOfLoot, 1 do

		local lootIcon, lootName, lootQuantity, rarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
		local currentItemLink = GetLootSlotLink(i)

		local members = GetNumGroupMembers()

		if currentItemLink == itemLink then				
			for j=1, members, 1 do				
				local candidate = GetMasterLootCandidate(i, j);
				if(candidate == player) then
					print(RRIncLoot_MessagePrefix.."Giving "..itemLink.." to "..candidate..".")
					GiveMasterLoot(i, j);
				end
			end
		end
	end
end

function RRIncLoot_GiveLootToPlayer(itemLink, player)

	if not RRIncLoot_LootOpen then
		print(RRIncLoot_MessagePrefix.."Loot is not opened, can't give item!")
		return
	end
	
	StaticPopupDialogs["RRIncLoot_GiveLootPrompt"] = {
		text = itemLink.."\nAre you sure you want to give this item to "..player.."?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			GiveItem(itemLink, player)
		end,
		OnCancel = function()
			print(RRIncLoot_MessagePrefix.."Didn't give item.")
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}

	StaticPopup_Show("RRIncLoot_GiveLootPrompt")

end