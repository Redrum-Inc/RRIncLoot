-- Loot Prio Tooltip (stolen from Impact LC)

local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)
local f = CreateFrame("Frame")
local CurrentGuildRoster = {}

local function TooltipFormatTest(text)
	text = text:gsub(",", ", ")
	return text
end





local function FormatTooltipText(array)
	local firstRank = true
	local text = ""
	local counter = 0
	-- text = text:gsub(",", ", ")
	for i=1, #array do
		if firstRank then
			text = array[i].name.." "..array[i].ranking
			firstRank=false			
		else
			if counter >= 3 then
				counter = 0
				text = text..",\n"..array[i].name.." "..array[i].ranking
			else
				text = text..", "..array[i].name.." "..array[i].ranking
			end
		end
		
		counter = counter + 1		
		
	end
	
	return text 
end

local function SetGameToolTipPrice(tt)
	local container = GetMouseFocus()	
	local itemLink = select(2, tt:GetItem())
	if itemLink then
		itemName = select(1, GetItemInfo(itemLink))

		if LootData[itemName] ~= nil then
			if  next(LootData[itemName]) == nil then
				return 
			end
			
			local lootranking = FormatTooltipText(LootData[itemName])
			tt:AddDoubleLine("Loot ranking:")
			tt:AddDoubleLine(lootranking)			
		else 
			-- tt:AddDoubleLine("Loot order:\nFFA")
			--nothing?
		end 
		
		if RRIncLoot_LootCanBeAutolooted(itemName) then
			tt:AddDoubleLine("RRIncLoot: Autoloot available.")			
		end

	end
end

GameTooltip:HookScript("OnTooltipSetItem", SetGameToolTipPrice)
ItemRefTooltip:HookScript("OnTooltipSetItem", SetGameToolTipPrice)
f:RegisterEvent("MODIFIER_STATE_CHANGED")
f:SetScript("OnEvent", f.OnEvent)