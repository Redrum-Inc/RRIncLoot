
RRIncLoot_Settings = {
	-- whispers = true,
	-- autoloot = true,
	-- trashAssignee = "",
	-- countdownMax = 10
}

-- Lock variable to prevent multiple distributions/rolls.
RRIncLoot_LockVar = false

negativeHistoryText = "lost or passed"
positiveHistoryText = "won or accepted"

local function SetCountdownMax(value)
	local number = tonumber (number)
	if(value ~= nil or value ~= "") then
		RRIncLoot_Settings.countdownMax = value;
		print("RRIncLoot: Counting down from " .. RRIncLoot_Settings.countdownMax);
	else
		print("RRIncLoot: Supply a value for cooldown: /lcfg cd [value]")
	end
    
end

function RRIncLoot_ToggleAutoloot()
	if(RRIncLoot_Settings.autoloot) then
		RRIncLoot_Settings.autoloot = false
		print("RRIncLoot: Autoloot off.")
	else
		RRIncLoot_Settings.autoloot = true
		print("RRIncLoot: Autoloot on.")
	end    
end

local function SetTrashAssignee(name)
	if(name ~= nil or name ~= "") then
		RRIncLoot_Settings.trashAssignee = name
		print("RRIncLoot: Trash will be given to "..name..".")
	else
		print("RRIncLoot: Supply a name for trash assignee: /lcfg trash [name]")
	end
end

local function ListTrashLoot()
	print("RRIncLoot: Trash list:")
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
	print("RRIncLoot: Loaded data from import with timestamp == "..LootDataTimestamp)
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
		C_Timer.After(1, function() print("RRIncLoot loaded. Roll countdown: "..RRIncLoot_Settings.countdownMax..", Autoloot: "..tostring(RRIncLoot_Settings.autoloot)..", Trash assignee: "..RRIncLoot_Settings.trashAssignee) end)	
	end

	if LootDataTimestamp ~= ImportedDataTimestamp then
			C_Timer.After(3, function() print("RRIncLoot: LootData timestamp \""..LootDataTimestamp.."\" differs from imported timestamp \""..ImportedDataTimestamp.."\"!") end)
			C_Timer.After(4, function() print("RRIncLoot: Run command \"/lcfg lootdata\" to re-load imported values.") end)
	end
end

local FrameEnterWorld = CreateFrame("Frame")
FrameEnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
FrameEnterWorld:SetScript("OnEvent", EventEnterWorld)