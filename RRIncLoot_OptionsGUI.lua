local RRIncPrompt = LibStub("AceAddon-3.0"):NewAddon("RRIncLoot")
local AceGUI = LibStub("AceGUI-3.0")
local test = false
local range = 0

local dummy = ""


local function ResetSettings()
	rrilOptionCountdown = 5
	rrilOptionUseAutoloot = false
	rrilOptionAutolootTarget = ""
	rrilOptionUseWhispers = true
	rrilOptionUseAddonChannel = true
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


myOptionsTable = {
  type = "group",
  args = {     
    optionRollCountdown = {
        name = "Roll countdown",
        order = 11,
        desc = "Arbitrary number that the countdown will start on.",
        type = "range",
        min = 1,
        max = 15,
        step = 1,
        set = function(info,val) rrilOptionCountdown = val end,
        get = function(info) return rrilOptionCountdown end
    },
    descriptionSpacer1 = {
            name = "\n",
            order = 12,
            type = "description",
            fontSize = "medium"
        },
    optionSendWhispers = {
        name = "Use whispers",
        order = 13,
        desc = "When enabled will whisper people whenever needing input from them.",
        type = "toggle",
        disabled = true,
        set = function(info,val) rrilOptionUseWhispers = val end,
        get = function(info) return rrilOptionUseWhispers  end
    },
    descriptionSpacer2 = {
            name = "\n",
            order = 14,
            type = "description",
            fontSize = "medium"
        },
    optionSendAddonMessage = {
        name = "Use addon channel",
        order = 15,
        desc = "When enabled will send addon channel messages for the prompt addon.",
        type = "toggle",
        disabled = true,
        set = function(info,val) rrilOptionUseAddonChannel = val end,
        get = function(info) return rrilOptionUseAddonChannel  end
    },
    descriptionSpacer3 = {
            name = "\n",
            order = 16,
            type = "description",
            fontSize = "medium"
        },
    optionGiveLootToWinner = {
        name = "Give loot to winner",
        order = 17,
        desc = "When enabled will try to give loot to the winner. Requires loot frame to be open.",
        type = "toggle",
        set = function(info,val) rrilOptionGiveLootToWinner = val end,
        get = function(info) return rrilOptionGiveLootToWinner  end
    },
    description = {
        name = "\n\nAutoloot for common gbank items that drop during raids:",
        order = 21,
        type = "description",
        fontSize = "medium"
    },
    optionAutolootEnabled = {
        name = "Use Autoloot",
        order = 22,
        desc = "When enabled it will trigger on loot opening if you are the masterlooter. Any items found in a predefined list will be automatically looted to the target (see other option) if possible.",
        type = "toggle",
        set = function(info,val) rrilOptionUseAutoloot = val end,
        get = function(info) return rrilOptionUseAutoloot  end
    },
    optionAutolootTarget = {
        name = "Autoloot Target",
        order = 23,
        desc = "Enter the name of the target player. Case sensitive!",
        type = "input",
        set = function(info,val) rrilOptionAutolootTarget = val end,
        get = function(info) return rrilOptionAutolootTarget  end
    }, 
    descriptionSpacerReset = {
            name = "\n\n\n\n",
            order = 98,
            type = "description",
            fontSize = "medium"
        },
    optionResetOptions = {
        name = "Reset",
        order = 99,
        desc = "Reset all settings to default values. Requires reload.",
        type = "execute",
        func = function() ResetSettingsPrompt() end
    },
    -- autoloot={
    --   name = "Autoloot",
    --   type = "group",
    --   args={
        
    --   }
    -- }
  }
}

local AceConfig = LibStub("AceConfig-3.0")
AceConfig:RegisterOptionsTable("RRInc Loot", myOptionsTable, {"rrinclootconfig", "rrilcfg"})

LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RRInc Loot", "RRInc Loot", nil);