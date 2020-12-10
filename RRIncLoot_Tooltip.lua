-- Loot Prio Tooltip (stolen from Impact LC)

local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)
local f = CreateFrame("Frame")
local CurrentGuildRoster = {}

local function TooltipFormatTest(text)
	text = text:gsub(",", ", ")
	return text
end





local function FormatTooltipText(text)
	-- local name = "Drstomplol"
	-- local template = "|cff40C7EBNAME|r"
	-- local value = name:gsub(name, "|cff40C7EB"..name.."|r")
	-- print(value)
	-- return value
	-- -- Move this so it runs once when addon loads.
	-- local numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers();

	-- Fails due to not inserting the trailing |r of the color codes. No idea why.


	-- -- example:   "Jolina: 54,Uprorro: 48,Drstomplol: 47,Greenglare: 47"
	-- text = text:gsub(" ", "")
	-- -- "Jolina:54,Uprorro:48,Drstomplol:47,Greenglare:47"
	-- local players = {strsplit(",", text)}
	-- -- Jolina:54 | Uprorro:48 | Drstomplol:47 | Greenglare:47

	-- for i = 1, #players do
	-- 	local nameAndPrio = {strsplit(":", players[i])}
	-- 	-- for j = 0, #players do
	-- 	-- 	print(name[j])
	-- 	-- end
	-- 	print(nameAndPrio[1], nameAndPrio[2])
	-- 	for nr = 1, numTotalGuildMembers do
	-- 		local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class = GetGuildRosterInfo(nr)	
	-- 		name = name:gsub("-ZandalarTribe", "")
	-- 		class = string.lower(class)		
	-- 		-- print(nameAndPrio[1], name, class, classDisplayName)
	-- 		if(nameAndPrio[1] == name) then				
	-- 			-- print(name, class, classDisplayName)
	-- 			if(class == "druid") then
	-- 				-- print(name, class, "|cFF7C0A"..name.."|r")
	-- 				text = text:gsub(name, "|cFF7C0A"..name.."|r")
	-- 			end
	-- 			if(class == "hunter") then
	-- 				-- print(name, class, "|cFF7C0A"..name.."|r")
	-- 				text = text:gsub(name, "|cAAD372"..name.."|r")
	-- 			end
	-- 			if(class == "mage") then
	-- 				-- print(name, class, "|cFF7C0A"..name.."|r")
	-- 				text = text:gsub(name, "|c3FC7EB"..name.."|r")
	-- 			end
	-- 			if(class == "paladin") then
	-- 				-- print(name, class, "|cFF7C0A"..name.."|r")
	-- 				text = text:gsub(name, "|cF48CBA"..name.."|r")
	-- 			end
	-- 			if(class == "priest") then
	-- 				-- print(name, class, "|cFF7C0A"..name.."|r")
	-- 				text = text:gsub(name, "|cFFFFFF"..name.."|r")
	-- 			end
	-- 			if(class == "rogue") then
	-- 				print(name, class, "|cFF7C0A"..name.."|r")
	-- 				text = text:gsub(name, "|cFFF468"..name).."|r"
	-- 			end
	-- 			if(class == "warlock") then
	-- 				-- print(name, class, "|cFF7C0A"..name.."|r")
	-- 				text = text:gsub(name, "|c8788EE"..name).."|r"
	-- 			end
	-- 			if(class == "warrior") then
	-- 				print(name, class, "|cFF7C0A"..name.."|r")
	-- 				text = text:gsub(name, "|cC69B6D"..name).."|r"
	-- 			end
	-- 		end
	-- 	end
	-- end

	text = text:gsub(",", ", ")
	
	return text 
end

local function SetGameToolTipPrice(tt)
	local container = GetMouseFocus()	
	local itemLink = select(2, tt:GetItem())
	if itemLink then
		iteminfo = select(1, GetItemInfo(itemLink))

		if LootData[iteminfo] ~= nil then
			local lootorder = FormatTooltipText(LootData[iteminfo])
			tt:AddDoubleLine("Loot order:")
			tt:AddDoubleLine(lootorder)			
		else 
			-- tt:AddDoubleLine("Loot order:\nFFA")
			--nothing?
		end 
		
		if RRIncLoot_LootIsTrash(iteminfo) then
			tt:AddDoubleLine("RRIncLoot: Autoloot available.")
			
		end

	end
end

GameTooltip:HookScript("OnTooltipSetItem", SetGameToolTipPrice)
ItemRefTooltip:HookScript("OnTooltipSetItem", SetGameToolTipPrice)
f:RegisterEvent("MODIFIER_STATE_CHANGED")
f:SetScript("OnEvent", f.OnEvent)