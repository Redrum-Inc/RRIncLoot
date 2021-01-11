# RRIncLoot
Addon to help RR Inc with loot management.

## Config

Commands have been replaced by Interface Options:

![interface options image](https://i.imgur.com/FqF55Lp.png)

## Usage
### Loot distribution
```/loot [itemlink]``` or ```/l [itemlink]```
Make sure to shift-click the itemlink into chat for this.
Players ranked for the item will be asked in turn if they want it. If no players are ranked on the item it will go straight to FFA roll.

If the "Give loot to winner" option is checked it will try to give loot to winners automatically if you have the loot window open (assigned through master looter). There will be a prompt asking if you would like to give them the item.

Currently there is no way to abort a distribution, should you need to do so or if you just need to reset it do: ```/reload```

### Autoloot
Enable this option and enter the name of the desired target player (case sensitive). Things like Scraps, Scarabs, Word of Thawing and Coffer Keys will be given to the target as soon as you open the loot window (through master looter, so make sure it's set to Common items).

### History
```/loothistory``` or ```/lh```

Will display all recorded item distributions.

### Clear history
```/loothistory clear``` 

```/lh clear```

---

## Installation (for easy updates)
1. Download and install [Git](https://git-scm.com/download/win) for Windows (don't worry about settings, just click through installer).
2. Download [RRIncLoot.zip](https://github.com/bo12s/RRIncLoot/releases) and extract to WoW Classic Addons folder:

![release image](https://i.imgur.com/qzhRB9c.png)

Inside the RRIncLoot folder there should be a file named update_v5.ps1:

![update.ps1 file](https://i.imgur.com/f0viGEJ.png)

3. Right click update_v5.ps1 and choose "Run with powershell":

![run with powershell](https://i.imgur.com/SFF8bf6.png)

You should see a Powershell prompt for a short period of time before it dissapears:

![powershell prompt](https://i.imgur.com/jAgYxp7.png)

Once it's gone there should be addon files (.lua and .toc) inside the folder:

![addon files](https://i.imgur.com/G6C2cYr.png)

Important! If the Powershell prompt is stuck and asking about Execution policy: Enter "y" without quotes into the prompt and press Enter. Then it should run as intended.

4. Whenever theres an update, just right-click on the update.ps1 file and choose "Run with powershell" to download the latest files.
