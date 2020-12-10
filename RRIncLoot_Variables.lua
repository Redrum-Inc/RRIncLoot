-- Event for looting, check how to parse available loot next.
-- local MyTestFrame = CreateFrame("Frame")
-- MyTestFrame:RegisterEvent("LOOT_OPENED")
-- MyTestFrame:SetScript("OnEvent", function(self, event, ...)
-- 	print("LOOT EVENT YAY")
-- end)

-- Auto assigning loot to winners:
-- https://wowwiki.fandom.com/wiki/API_GiveMasterLoot
-- https://wowwiki.fandom.com/wiki/API_GetNumLootItems
-- https://wowwiki.fandom.com/wiki/API_GetMasterLootCandidate
-- https://wowwiki.fandom.com/wiki/World_of_Warcraft_API#Loot

-- Saved variables saving/loading:
-- https://www.wowinterface.com/forums/showthread.php?p=261244



-- Variables
RRIncLoot_Settings = {
	-- whispers = true,
	-- autoloot = true,
	-- trashAssignee = "",
}

-- Lock variable to not allow multiple distributions/rolls.
RRIncLoot_LockVar = false

negativeHistoryText = "lost or passed"
positiveHistoryText = "won or accepted"

local function SetCountdownMax(value)
	local number = tonumber (number)
	if(value ~= nil or value ~= "") then
		CountdownMax = value;
		print("RRIncLoot: Counting down from " .. CountdownMax);
	else
		print("RRIncLoot: Supply a value for cooldown: /lcfg cd [value]")
	end
    
end

local function ToggleAutoloot()
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
	for i=1, #TrashData do
		print(i)
		for j=1, #TrashData[i] do
			print(TrashData[i][j])
		end
	end
	print("---------------")
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
		ToggleAutoloot()
	end

	if(option=="trash") then
		SetTrashAssignee(value)
	end

	if(option=="trashlist") then
		ListTrashLoot()
	end

end

local function EventEnterWorld(self, event, isLogin, isReload)
	-- Set default values. (This might need rework? Not sure how saved variables work in this regard.)
	CountdownMax = CountdownMax or 10
	RRIncLoot_Settings.autoloot = RRIncLoot_Settings.autoloot or false
	RRIncLoot_Settings.trashAssignee = RRIncLoot_Settings.trashAssignee or "NULL"
	RRIncLoot_Settings.whispers = RRIncLoot_Settings.whispers or true

	if isLogin then
		C_Timer.After(1, function() print("RRIncLoot loaded. Roll countdown: "..CountdownMax..", Autoloot: "..tostring(RRIncLoot_Settings.autoloot)..", Trash assignee: "..RRIncLoot_Settings.trashAssignee) end)
	end
end

local FrameEnterWorld = CreateFrame("Frame")
FrameEnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
FrameEnterWorld:SetScript("OnEvent", EventEnterWorld)