
RRIncLoot_Settings = {
	-- whispers = true,
	-- autoloot = true,
	-- trashAssignee = "",
	-- countdownMax = 10
}

local nameGradient = "|cFF323232RR|r|cFF7F7F7FInc|r|cFFB2B2B2Loot|r"
RRIncLoot_Prefix = nameGradient..": "

-- Lock variable to prevent multiple distributions/rolls.
RRIncLoot_LockVar = false

negativeHistoryText = "lost or passed"
positiveHistoryText = "won or accepted"

local function SetCountdownMax(value)
	local number = tonumber (number)
	if(value ~= nil or value ~= "") then
		RRIncLoot_Settings.countdownMax = value;
		print(RRIncLoot_Prefix.."Counting down from " .. RRIncLoot_Settings.countdownMax);
	else
		print(RRIncLoot_Prefix.."Supply a value for cooldown: /lcfg cd [value]")
	end
    
end

function RRIncLoot_ToggleAutoloot()
	if(RRIncLoot_Settings.autoloot) then
		RRIncLoot_Settings.autoloot = false
		print(RRIncLoot_Prefix.."Autoloot off.")
	else
		RRIncLoot_Settings.autoloot = true
		print(RRIncLoot_Prefix.."Autoloot on.")
	end    
end

local function SetTrashAssignee(name)
	if(name ~= nil or name ~= "") then
		RRIncLoot_Settings.trashAssignee = name
		print(RRIncLoot_Prefix.."Trash will be given to "..name..".")
	else
		print(RRIncLoot_Prefix.."Supply a name for trash assignee: /lcfg trash [name]")
	end
end

local function ListTrashLoot()
	print(RRIncLoot_Prefix.."Trash list:")
	for i=1, #AutolootData do
		print(i)
		for j=1, #AutolootData[i] do
			print(AutolootData[i][j])
		end
	end
	print("---------------")
end

local function LoadLootData()
	LootData = ImportedData		
	LootDataTimestamp = ImportedDataTimestamp
	print(RRIncLoot_Prefix.."Loaded data from import with timestamp \"|cFF00B200"..LootDataTimestamp.."|r\".")
end

-- Loot Config

SLASH_RRINCLOOTCFG1 = '/lootconfig'
SLASH_RRINCLOOTCFG2 = '/lcfg'
function SlashCmdList.RRINCLOOTCFG(msg)
	local option, value = strsplit(" ",msg)	

	if(option == "cd" or option == "countdown") then
		SetCountdownMax(value)
	end

	if(option=="autoloot") then
		RRIncLoot_ToggleAutoloot()
	end

	if(option=="trash") then
		SetTrashAssignee(value)
	end

	if(option=="trashlist") then
		ListTrashLoot()
	end

	if(option=="lootdata") then
		LoadLootData()
	end
end

local function EventEnterWorld(self, event, isLogin, isReload)
	-- Set default values. (This might need rework? Not sure how saved variables work in this regard.)
	RRIncLoot_Settings.countdownMax = RRIncLoot_Settings.countdownMax or 10
	RRIncLoot_Settings.autoloot = RRIncLoot_Settings.autoloot or false
	RRIncLoot_Settings.trashAssignee = RRIncLoot_Settings.trashAssignee or "NULL"
	RRIncLoot_Settings.whispers = RRIncLoot_Settings.whispers or true

	if isLogin then
		C_Timer.After(1, function() print(nameGradient.." loaded. Roll countdown: "..RRIncLoot_Settings.countdownMax..", Autoloot: "..tostring(RRIncLoot_Settings.autoloot)..", Trash assignee: "..RRIncLoot_Settings.trashAssignee) end)	
	end

	if LootDataTimestamp ~= ImportedDataTimestamp then
			C_Timer.After(3, function() print(RRIncLoot_Prefix.."|cFFFF0000LootData timestamp \""..LootDataTimestamp.."\" differs from imported timestamp \""..ImportedDataTimestamp.."\"!|r") end)
			-- C_Timer.After(4, function() print(RRIncLoot_Prefix.."Run command \"/lcfg lootdata\" to re-load imported values.") end)
			C_Timer.After(4, function() LoadLootData() end)
	else
		C_Timer.After(3, function() print(RRIncLoot_Prefix.."Using LootData with timestamp \""..LootDataTimestamp.."\".") end)
	end
end

local FrameEnterWorld = CreateFrame("Frame")
FrameEnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
FrameEnterWorld:SetScript("OnEvent", EventEnterWorld)