-- Loot Prio Tooltip (stolen from Impact LC)

local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)
local f = CreateFrame("Frame")
local CurrentGuildRoster = {}

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

local function GetClassFromGuildRoster(targetName)
	local numTotalMembers = select(1, GetNumGuildMembers())
	for i=1, numTotalMembers, 1 do
		local name, rankName, rankIndex, level, classDisplayName, _, publicNote, _, _, status, class, _, _, _, _, _, GUID = GetGuildRosterInfo(i);
		name = name:gsub("-ZandalarTribe","")
		if name == targetName then
			-- print(name, rankName, classDisplayName, level)
			return classDisplayName
		end
	end
	return ""
end

local function GetClassColorInRGB(class)
	local r, g, b = 0,0,0

	if string.lower(class) == "druid" then
		r,g,b=1.00,0.49,0.04
	end

	if string.lower(class) == "hunter" then
		r,g,b=0.67,0.83,0.45
	end

	if string.lower(class) == "mage" then
		r,g,b=0.25,0.78,0.92
	end

	if string.lower(class) == "paladin" then
		r,g,b=0.96,0.55,0.73
	end

	if string.lower(class) == "priest" then
		r,g,b=1.00,1.00,1.00
	end

	if string.lower(class) == "rogue" then
		r,g,b=1.00,0.96,0.41
	end

	if string.lower(class) == "shaman" then
		r,g,b=0.00,0.44,0.87
	end

	if string.lower(class) == "warlock" then
		r,g,b=0.53,0.53,0.93
	end

	if string.lower(class) == "warrior" then
		r,g,b=0.78,0.61,0.43
	end



	return r, g, b
end

local function GetRankColorInRGB(rank)
	local r=0 g=0 b=0

	if rank >= 55 then
		r=0.9 g=0.7 b=0.2
	end

	return r,g,b
end

local function GetCount(array)
	local count = 0
	for i=1, #array do
		count = count + 1
	end
	return count
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
			tt:AddDoubleLine(" ","")
			tt:AddDoubleLine("RRIncLoot:",GetCount(LootData[itemName]).." listed",0.6,0.1,0.1)

			for i=1, #LootData[itemName] do
				local r = 0 g = 0 b = 0
				local r2 = 0 g2 = 0 b2 = 0
				local class = GetClassFromGuildRoster(LootData[itemName][i].name)

				-- print(class)
				if class == nil or class == "" then
					r=0 g=0 b=0
				else
					r, g, b = GetClassColorInRGB(class)
				end

				tt:AddDoubleLine(LootData[itemName][i].name, LootData[itemName][i].ranking, r,g,b,r,g,b)
			end
			-- tt:AddDoubleLine(lootranking)		
		else 
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