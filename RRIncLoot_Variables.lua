
RRIncLoot_Settings = {
	-- whispers = true,
	-- autoloot = true,
	-- trashAssignee = "",
	-- countdownMax = 10
	-- useAddonChannel = true
	-- giveLootPrompt = true
}

RRIncPrompt_AddonChannel = "RRIncPrompt"

RRIncLoot_AddonName = "|cFF323232RR|r|cFF7F7F7FInc|r |cFF6B0B0BLoot|r"
RRIncLoot_MessagePrefix = RRIncLoot_AddonName..": "

-- Lock variable to prevent multiple distributions/rolls.
RRIncLoot_LockVar = false

RRIncLoot_LootOpen = false

negativeHistoryText = "lost or passed"
positiveHistoryText = "won or accepted"

local function SetCountdownMax(value)
	local number = tonumber (number)
	if(value ~= nil or value ~= "") then
		RRIncLoot_Settings.countdownMax = value;
		print(RRIncLoot_MessagePrefix.."Counting down from " .. RRIncLoot_Settings.countdownMax);
	else
		print(RRIncLoot_MessagePrefix.."Supply a value for cooldown: /lcfg cd [value]")
	end
    
end

function RRIncLoot_ToggleAutoloot()
	if(RRIncLoot_Settings.autoloot) then
		RRIncLoot_Settings.autoloot = false
		print(RRIncLoot_MessagePrefix.."Autoloot off.")
	else
		RRIncLoot_Settings.autoloot = true
		print(RRIncLoot_MessagePrefix.."Autoloot on.")
	end    
end

local function SetTrashAssignee(name)
	if(name ~= nil or name ~= "") then
		RRIncLoot_Settings.trashAssignee = name
		print(RRIncLoot_MessagePrefix.."Trash will be given to "..name..".")
	else
		print(RRIncLoot_MessagePrefix.."Supply a name for trash assignee: /lcfg trash [name]")
	end
end

local function ListTrashLoot()
	print(RRIncLoot_MessagePrefix.."Trash list:")
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
	print(RRIncLoot_MessagePrefix.."Loaded data from import with timestamp \"|cFF00B200"..LootDataTimestamp.."|r\".")
end

local function ResetSettings()
	RRIncLoot_Settings.countdownMax = 5
	RRIncLoot_Settings.autoloot = false
	RRIncLoot_Settings.trashAssignee = "NULL"
	RRIncLoot_Settings.whispers = true
	RRIncLoot_Settings.useAddonChannel = true
	LootDataTimestamp = "0000-00-00 00:00:00"
	ReloadUI()
end

local function ResetSettingsPrompt()
	StaticPopupDialogs["RRIncLoot_ResetSettingsPrompt"] = {
		text = "Are you sure you want to reset the settings?\nThis will reload your UI!",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			ResetSettings()
		end,
		OnCancel = function()
			print(RRIncLoot_MessagePrefix.."Did not reset settings.")
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}

	StaticPopup_Show("RRIncLoot_ResetSettingsPrompt")
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

	if(option=="reset") then
		ResetSettingsPrompt()
	end
end

local function EventEnterWorld(self, event, isLogin, isReload)
	-- Set default values. (This might need rework? Not sure how saved variables work in this regard.)
	RRIncLoot_Settings.countdownMax = RRIncLoot_Settings.countdownMax or 5
	RRIncLoot_Settings.autoloot = RRIncLoot_Settings.autoloot or false
	RRIncLoot_Settings.trashAssignee = RRIncLoot_Settings.trashAssignee or "NULL"
	RRIncLoot_Settings.whispers = RRIncLoot_Settings.whispers or true
	RRIncLoot_Settings.useAddonChannel = RRIncLoot_Settings.useAddonChannel or true
	RRIncLoot_Settings.giveLootToWinner = RRIncLoot_Settings.giveLootToWinner or true
	LootDataTimestamp = LootDataTimestamp or "0000-00-00 00:00:00"

	RRIncLoot_AddonName = GetAddOnMetadata("RRIncLoot", "Title")
	RRIncLoot_MessagePrefix = RRIncLoot_AddonName..": "

	if isLogin then
		C_Timer.After(1, function() print(RRIncLoot_AddonName.." loaded. Roll countdown: "..RRIncLoot_Settings.countdownMax..", Autoloot: "..tostring(RRIncLoot_Settings.autoloot)..", Trash assignee: "..RRIncLoot_Settings.trashAssignee..", Give loot to winner: "..RRIncLoot_Settings.giveLootToWinner) end)
	end

	if isLogin or isReload then
		if LootDataTimestamp ~= ImportedDataTimestamp then
				C_Timer.After(3, function() print(RRIncLoot_MessagePrefix.."|cFFFF0000LootData timestamp \""..LootDataTimestamp.."\" differs from imported timestamp \""..ImportedDataTimestamp.."\"!|r") end)
				C_Timer.After(4, function() LoadLootData() end)
		else
			C_Timer.After(3, function() print(RRIncLoot_MessagePrefix.."Using LootData with timestamp \""..LootDataTimestamp.."\".") end)
		end
	end
	
	local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(RRIncPrompt_AddonChannel)
end

local FrameEnterWorld = CreateFrame("Frame")
FrameEnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
FrameEnterWorld:SetScript("OnEvent", EventEnterWorld)