local RRIncLoot = LibStub("AceAddon-3.0"):NewAddon("RRIncLoot")
local AceGUI = LibStub("AceGUI-3.0")
local test = false
local range = 0

local dummy = ""

local rarityThresholds = {}
rarityThresholds[2] = "|c"..select(4,GetItemQualityColor(2)).."Uncommon|r"
rarityThresholds[3] = "|c"..select(4,GetItemQualityColor(3)).."Rare|r"


local function ResetSettings()
	rrilOptionCountdown = 5
	rrilOptionUseAutoloot = false
	rrilOptionAutolootTarget = ""
	rrilOptionUseWhispers = true
	rrilOptionUseAddonChannel = true
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

local function ClearHistory()
	LootHistory = {}
	ReloadUI()
end

local function ClearHistoryPrompt()
	StaticPopupDialogs["RRIncLoot_ClearHistoryPrompt"] = {
		text = "Are you sure you want to clear the history log?\nThis will reload your UI!",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			ClearHistory()
		end,
		OnCancel = function()
			-- print(RRIncLoot_MessagePrefix.."Did not reset settings.")
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}

	StaticPopup_Show("RRIncLoot_ClearHistoryPrompt")
end



local rrinclootOptionsTable = 
{
    type = "group",
    args = 
    {     
        optionResetOptions = 
        {
            name = "Reset",
            order = 1,
            desc = "Reset all settings to default values. Requires reload.",
            type = "execute",
            func = function() ResetSettingsPrompt() end
        },
        general=
        {
            name = "General",
            order = 2,
            type = "group",
            args=
            {
                optionRollCountdown = 
                {
                    name = "Roll countdown",
                    order = 1,
                    desc = "Arbitrary number that the countdown will start on.",
                    type = "range",
                    min = 1,
                    max = 15,
                    step = 1,
                    set = function(info,val) rrilOptionCountdown = val end,
                    get = function(info) return rrilOptionCountdown end
                },
                descriptionSpacer1 = 
                {
                    name = "\n",
                    order = 2,
                    type = "description",
                    fontSize = "medium"
                },
                optionSendWhispers = 
                {
                    name = "Use whispers",
                    order = 3,
                    desc = "When enabled will whisper people whenever needing input from them.",
                    type = "toggle",
                    disabled = true,
                    set = function(info,val) rrilOptionUseWhispers = val end,
                    get = function(info) return rrilOptionUseWhispers  end
                },
                descriptionSpacer2 = 
                {
                    name = "\n",
                    order = 4,
                    type = "description",
                    fontSize = "medium"
                },
                optionSendAddonMessage = 
                {
                    name = "Use addon channel",
                    order = 5,
                    desc = "When enabled will send addon channel messages for the prompt addon.",
                    type = "toggle",
                    disabled = true,
                    set = function(info,val) rrilOptionUseAddonChannel = val end,
                    get = function(info) return rrilOptionUseAddonChannel  end
                },
                descriptionSpacerAnnounceLoot = 
                {
                    name = "\n\n\n\n",
                    order = 6,
                    type = "description",
                    fontSize = "medium"
                },
                optionAnnounceLoot = 
                {
                    name = "Announce loot",
                    order = 7,
                    desc = "When enabled announces any loot above rare quality to raid chat.",
                    type = "toggle",
                    set = function(info,val) rrilOptionAnnounceLoot = val end,
                    get = function(info) return rrilOptionAnnounceLoot  end
                },  
            },
        },
        automation =
        {
            name = "Automation",
            order = 3,
            type = "group",
            args=
            {
                optionGiveLootToWinner = 
                {
                    name = "Give loot to winner",
                    order = 1,
                    desc = "When enabled will try to give loot to the winner. Requires loot frame to be open.",
                    type = "toggle",
                    set = function(info,val) rrilOptionGiveLootToWinner = val end,
                    get = function(info) return rrilOptionGiveLootToWinner  end
                },
                description = 
                {
                    name = "\n\n\nGUILDBANK",
                    order = 2,
                    type = "description",
                    fontSize = "large"
                },
                optionAutolootEnabled = 
                {
                    name = "Use Autoloot",
                    order = 3,
                    desc = "When enabled it will trigger on loot opening if you are the masterlooter. Any items found in a predefined list will be automatically looted to the target (see other option) if possible.",
                    type = "toggle",
                    set = function(info,val) rrilOptionUseAutoloot = val end,
                    get = function(info) return rrilOptionUseAutoloot  end
                },
                optionAutolootTarget = 
                {
                    name = "Autoloot Target",
                    order = 4,
                    desc = "Enter the name of the target player. Case sensitive!",
                    type = "input",
                    set = function(info,val) rrilOptionAutolootTarget = val end,
                    get = function(info) return rrilOptionAutolootTarget  end
                }, 
                descriptionDE = 
                {
                    name = "\n\n\nDISENCHANTING",
                    order = 5,
                    type = "description",
                    fontSize = "large"
                },
                optionDisenchantEnabled = 
                {
                    name = "Autoloot for disenchanting",
                    order = 6,
                    desc = "When enabled it will trigger on loot opening if you are the masterlooter. Any items matching certain quality will be given to the target.",
                    type = "toggle",
                    set = function(info,val) rrilOptionDisenchant = val end,
                    get = function(info) return rrilOptionDisenchant  end
                },
                optionDisenchantTarget = 
                {
                    name = "Enchanter",
                    order = 7,
                    desc = "Enter the name of the target player. Case sensitive!",
                    type = "input",
                    set = function(info,val) rrilOptionDisenchantTarget = val end,
                    get = function(info) return rrilOptionDisenchantTarget  end
                }, 
                optionDisenchantThreshold = 
                {
                    name = "Rarity Threshold",
                    order = 8,
                    desc = "Upper limit of rarity for items to be disenchanted.",
                    type = "select",
                    values = rarityThresholds,
                    set = function(info,val) rrilOptionDisenchantThreshold = val print(val) end,
                    get = function(info) return rrilOptionDisenchantThreshold  end
                }, 
            },
        }, 
        history=
        {
            name = "History",
            order = 4,
            type = "group",
            args=
            {
                outputWon = 
                {
                    name = "Accepted/Won",
                    desc = "History won output",
                    order = 1,
                    type = "input",
                    multiline = true,
                    width = "full",
                    set = function(info,val) 
                    print("You can't set this value.")
                    end,
                    get = function(info) 
                        local historyWon = ""
                        for i = 1, #LootHistory do
                            if string.find(LootHistory[i], "accepted") or string.find(LootHistory[i], "won roll for") then
                                if i == 1 then
                                    historyWon = LootHistory[i]
                                else
                                    historyWon = historyWon.."\n"..LootHistory[i]
                                end
                            end
                        end
                        return historyWon  
                    end
                },
                outputLost = 
                {
                    name = "Passed/Lost",
                    desc = "History lost output",
                    order = 2,
                    type = "input",
                    multiline = true,
                    width = "full",
                    set = function(info,val) 
                        print("You can't set this value.")
                    end,
                    get = function(info) 
                        local historyLost = ""
                        for i = 1, #LootHistory do
                            if string.find(LootHistory[i], "passed") or string.find(LootHistory[i], "lost roll for") then
                                if i == 1 then
                                    historyLost = LootHistory[i]
                                else
                                    historyLost = historyLost.."\n"..LootHistory[i]
                                end
                            end
                        end
                        return historyLost  
                    end
                },
                optionResetOptions = 
                {
                    name = "Clear history",
                    order = 3,
                    desc = "Clear history log.",
                    type = "execute",
                    func = function() 
                        ClearHistoryPrompt()
                    end
                },
            }
        }
    }
}
local AceConfig = LibStub("AceConfig-3.0")
AceConfig:RegisterOptionsTable("RRInc Loot", rrinclootOptionsTable, {"rrinclootconfig", "rrilcfg"})

LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RRInc Loot", "RRInc Loot", nil);