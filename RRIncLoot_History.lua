-- Loot distribution History

LootHistory = {}

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

SLASH_RRINCLOOTHISTORY1 = '/loothistory'
SLASH_RRINCLOOTHISTORY1 = '/lh'
function SlashCmdList.RRINCLOOTHISTORY(msg)
	-- Fix manual controls of adding/changing/removing history
	if(msg == "") then
		print("Passed/Lost:")
		for i = 1, #LootHistory do
			if string.find(LootHistory[i], "passed on") or string.find(LootHistory[i], "lost roll for") then
				print(LootHistory[i])
			end
		end
		print("----------")
		print("Accepted/Won:")
		for i = 1, #LootHistory do
			if string.find(LootHistory[i], "accepted") or string.find(LootHistory[i], "won roll for") then
				print(LootHistory[i])
			end
		end
		print("----------")
	end

	if(msg == "clear") then
		ClearLootHistory()
	end

	if(msg == "add") then
	end
end


-- function InitializeLootHistory()
-- 	local counter = 0
-- 	for i = 1, #LootHistory do
-- 		counter = counter + 1
-- 	end
-- 	if(counter == 0) then
-- 		LootHistory = {}
-- 	end
-- end