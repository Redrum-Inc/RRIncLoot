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