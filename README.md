# RRIncLoot
Addon to help RR Inc with loot management.

## Commands

### Configuration
`/lootconfig [command]` or
`/lcfg [command]`

#### Import data
Command removed, data is loaded automatically if timestamp differs.

#### Roll countdown
Sets the countdown (times not seconds) for FFA rolls.

```/lootconfig countdown 5```

```/lcfg cd 5```

#### Autoloot
Toggle autolooting of pre-defined list of items (among other things Scarabs in AQ and Scraps in Naxx, basically anything that's a pain for the ML to assign manually).

```/lcfg autoloot```

#### Autoloot Assignee
Set target of autoloot items. Name is case sensitive!

```/lcfg trash [player name]```


### Usage
```/loot [itemlink]``` or ```/l [itemlink]```
Make sure to shift-click the itemlink into chat for this.
If there is players ranked for the item it will ask them in turn if they want it. If no players are ranked on the item it will go straight to FFA roll.

### History
```/loothistory``` or ```/lh```

Will display all recorded item distributions.

#### Clear history
```/loothistory clear``` 

```/lh clear```

---

## Installation (for easy updates)
1. Download and install [Git](https://git-scm.com/download/win) for Windows (don't worry about settings, just click through installer).
2. Download [RRIncLoot.zip](https://github.com/bo12s/RRIncLoot/releases) and extract to WoW Classic Addons folder:

![release image](https://i.imgur.com/qzhRB9c.png)

Inside the RRIncLoot folder there should be a file named update.ps1:

![update.ps1 file](https://i.imgur.com/f0viGEJ.png)

3. Right click update.ps1 and choose "Run with powershell":

![run with powershell](https://i.imgur.com/SFF8bf6.png)

You should see a Powershell prompt for a short period of time before it dissapears:

![powershell prompt](https://i.imgur.com/jAgYxp7.png)

Once it's gone there should be addon files (.lua and .toc) inside the folder:

![addon files](https://i.imgur.com/G6C2cYr.png)

Important! If the Powershell prompt is stuck and asking about Execution policy: Enter "y" without quotes into the prompt and press Enter. Then it should run as intended.

4. Whenever theres an update, just right-click on the update.ps1 file and choose "Run with powershell" to download the latest files.
