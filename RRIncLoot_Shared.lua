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