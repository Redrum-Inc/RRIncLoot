RRIncPrompt_AddonChannel = "RRIncPrompt"

RRIncLoot_AddonName = "|cFF323232RR|r|cFF7F7F7FInc|r |cFF6B0B0BLoot|r"
RRIncLoot_MessagePrefix = RRIncLoot_AddonName..": "

-- Lock variables to prevent multiple distributions/rolls.
RRIncLoot_LockVar = false
RRIncLoot_LootOpen = false


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

-- Config
SLASH_RRINCLOOTOPTIONS1 = '/rrincloot'
SLASH_RRINCLOOTOPTIONS2 = '/rril'
function SlashCmdList.RRINCLOOTOPTIONS(msg)
	local option, value = strsplit(" ",msg)	
    print(msg)
    if(option == "" or option == nil) then
        if ( not InterfaceOptionsFrame:IsShown() ) then
            InterfaceOptionsFrame:Show();
            InterfaceOptionsFrame_OpenToCategory("RRInc Loot");
        end
        return
    end
end

local function EventEnterWorld(self, event, isLogin, isReload)
	-- Set default values. (This might need rework? Not sure how saved variables work in this regard.)
	rrilOptionCountdown = rrilOptionCountdown or 5
	rrilOptionUseAutoloot = rrilOptionUseAutoloot or false
	rrilOptionAutolootTarget = rrilOptionAutolootTarget or ""
	rrilOptionUseWhispers = rrilOptionUseWhispers or true
	rrilOptionUseAddonChannel = rrilOptionUseAddonChannel or true
	rrilOptionGiveLootToWinner = rrilOptionGiveLootToWinner or true
	rrilOptionAnnounceLoot = rrilOptionAnnounceLoot or true
	rrilOptionDisenchant = rrilOptionDisenchant or true
	rrilOptionDisenchantTarget = rrilOptionDisenchantTarget or ""
	rrilOptionDisenchantThreshold = rrilOptionDisenchantThreshold or 2

	RRIncLoot_AddonName = GetAddOnMetadata("RRIncLoot", "Title")	
	RRIncLoot_MessagePrefix = RRIncLoot_AddonName..": "
	local version = GetAddOnMetadata("RRIncLoot", "Version")

	if isLogin then
		C_Timer.After(1, function() print(RRIncLoot_AddonName.." v"..version.." loaded. Roll countdown: "..rrilOptionCountdown..", Autoloot: "..tostring(rrilOptionUseAutoloot)..", Trash assignee: "..rrilOptionAutolootTarget..", Give loot to winner: "..tostring(rrilOptionGiveLootToWinner)) end)
	end

	if isLogin or isReload then
	end

	local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(RRIncPrompt_AddonChannel)
end

local FrameEnterWorld = CreateFrame("Frame")
FrameEnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
FrameEnterWorld:SetScript("OnEvent", EventEnterWorld)