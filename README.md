# MacroKit

Adds a set of ready-made macros for your class and specialization to your macro list. An addon for World of Warcraft: Forever (client 1.60.x). It has Paladin macros so far.

## What it does

The first time you play each spec, MacroKit adds that spec's macros to your character's own macro list (`/macro`, the character tab).

## The MacroKit window

Click the MacroKit button on the minimap, or type `/macrokit`. The window shows your class and spec, in your class colour, and one line for each of its macros:

- **In your macros:** drag the line straight onto your action bars, or click it to pick the macro up.
- **Ready:** click **Add** to put it in your macros.
- **Needs** a spell: you have not learned that spell yet. The macro becomes ready when you do.

Hover over a line to see the macro itself. At the bottom: **Add all missing**, **Remove MacroKit's macros**, and the switch for adding a spec's macros by itself. The buttons are greyed out in combat, when the game does not allow changing macros.

Classes without macros yet are told so. Drag the minimap button round the edge of the minimap to move it.

- It never overwrites a macro: if you already have one with the same name, yours stays.
- It only adds a macro once your character knows its spells. Learn the spell, then click **Add** in the window (or type `/macrokit add`).
- It stops when your character's macro slots are full, and tells you which macros did not fit.
- In combat it waits until the fight is over, because the game does not allow creating macros in combat.

## Paladin macros

Every spec:

| Macro | What it does |
|---|---|
| Interrupt | Rebuke on your focus target, else your mouseover target, else your target |
| Stun | Hammer of Justice on your mouseover target, else your target |
| Freedom | Blessing of Freedom on a mouseover friend, else yourself |
| Protect Ally | Blessing of Protection on a mouseover friend or yourself; hold Shift for Blessing of Sacrifice |
| Lay on Hands | On a mouseover friend, else yourself |
| Bubble | Removes Blessing of Protection, then casts Divine Shield |
| Battle Rez | Intercession on a dead mouseover friend, else your target |
| Steed | Divine Steed; pressing it again does not cancel it |

Holy: **Cleanse**, **Holy Shock** (heals or damages whatever is under the mouse), **Word of Glory**, **Beacon** (Shift puts it on your focus target), **Holy Burst** (Avenging Wrath, top trinket and Holy Shock).

Protection: **Cleanse Toxins**, **Taunt**, **Shield Up** (top trinket, then Shield of the Righteous), **Shield Throw** (Avenger's Shield on your mouseover target), **Self Heal** (Word of Glory on yourself).

Retribution: **Cleanse Toxins**, **Ret Burst** (Avenging Wrath and both trinkets), **Spender** (Templar's Verdict; Divine Storm with Shift held), **Execute** (Hammer of Wrath on your mouseover target), **Word of Glory**.

## Commands

| What | How |
|---|---|
| Open the MacroKit window | `/macrokit`, the minimap button, or MacroKit's entry in the minimap's addon list |
| Add the macros you are missing | `/macrokit add` |
| See the macros and whether you have them, in chat | `/macrokit list` |
| Show or hide the minimap button | `/macrokit button` |
| Delete the macros MacroKit added | `/macrokit remove` (macros you made yourself stay) |
| Stop adding macros by itself for each new spec | `/macrokit auto off` |

## Good to know

- Macros are saved on Blizzard's servers, so once added they follow your character to any computer, even without the addon.
- The spell names are the ones Blizzard uses in the main game. If a macro says it needs a spell you know you have, the name may be different in Forever: please report it.

## More from this author

Other small addons for World of Warcraft: Forever, all free:

- **[GatherTrail](https://github.com/bizzal70/GatherTrail)** remembers ore, herbs, fishing pools, skinning spots, chests and rares across all your characters, and guides you back to the best spots.
- **[MouseTip](https://www.curseforge.com/wow/addons/mousetip)** shows tooltips at your mouse cursor.
- **[RangeShade](https://www.curseforge.com/wow/addons/rangeshade)** shades action buttons red when your target is out of range.
- **[VendorMate](https://github.com/bizzal70/VendorMate)** sells junk and repairs at vendors, and warns when your gear is wearing out.
- **[AltBoard](https://github.com/bizzal70/AltBoard)** shows all your characters at a glance: level, gold, rested and where you left them.
- **[SwiftQuest](https://github.com/bizzal70/SwiftQuest)** accepts quests and hands them in as soon as you talk to the quest giver, without ever choosing a reward for you.
- **[SessionRecap](https://github.com/bizzal70/SessionRecap)** keeps a running tally of your play session: gold, experience per hour, quests, gathering and loot.

## Installing

Copy this folder into `World of Warcraft\_forever_\Interface\AddOns\` as `MacroKit`, restart the game, and enable MacroKit on the character select screen.

## Developing

- `tools\Link-Addon.ps1` links this folder into the game's AddOns folder, so edits are live after `/reload`.
- `python tests/run.py` runs the tests (`pip install lupa` once). They run the addon in real Lua 5.1 against a fake of the game's API.
- `tools\Publish.ps1 -Message "..."` runs the tests and pushes to GitHub. GitHub runs the tests again on every push.
- Macros live in `Data.lua`, by class and specialization ID. Adding another class means adding its table there; the tests check every macro's length, name and spells.

## Releasing

`tools\Publish.ps1 -Message "Release x.y.z" -Tag vx.y.z` publishes and tags. The tag makes GitHub package the addon and attach the zip to a GitHub release, and upload it to CurseForge once `## X-Curse-Project-ID:` is in `MacroKit.toc` and the CurseForge token is in this repository's secrets.

Before each release: raise `## Version:` in `MacroKit.toc` and add the version to `CHANGELOG.md`.

## Licence

MIT. See `LICENSE`.
