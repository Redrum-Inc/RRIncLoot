-- Loot distribution History

function RRIncLoot_AddLootHistory(player, action, item)
	-- print(player, action, item)
	local timestampformat="%y-%m-%d %H:%M:%S";
	local timestamp = "20"..date(timestampformat);
    table.insert(LootHistory, "["..timestamp.."] "..player.." "..action.." "..item)
end

function ClearLootHistory()
	LootHistory = {}
	print("LootHistory cleared.")
end