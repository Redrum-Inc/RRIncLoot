function RRIncLoot_LootIsTrash(item)
	for i=1, #TrashData.Items do
		for j=0, #TrashData.Items[i] do
			if(item == TrashData.Items[i][j]) then
				return true
			end
		end		
	end
	return false
end