# MacroKit

Adds a set of ready-made macros for your class and specialization to your macro list. An addon for World of Warcraft: Forever (client 1.60.x). It has Paladin macros so far.

## What it does

The first time you play each spec, MacroKit adds that spec's macros to your character's own macro list (`/macro`, the character tab).

## The MacroKit window

Click the MacroKit button on the minimap, or type `/macrokit`.

- **Top:** your class, in its colour, and a **Spec** menu. It starts on your own spec; pick **Every spec** for the macros all specs share, or any other spec to preview its macros.
- **Ready to use** tab: macros whose spells you know. Those **in your macros** can be dragged straight onto your action bars (or clicked to pick up); those **ready to add** have an **Add** button.
- **Not learned yet** tab: macros waiting on a spell, each saying which. Learn the spell and it moves to Ready to use by itself.
- Hover over a macro to see its text. At the bottom: **Add all missing**, **Remove MacroKit's macros**, and the switch for adding a spec's macros by itself. The buttons are greyed out in combat, when the game does not allow changing macros.

Before you choose a specialization, the window starts on the shared macros; use the Spec menu to preview each spec's. Classes without macros yet are told so. Drag the minimap button round the edge of the minimap to move it.

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
| List your spec and spellbook, to report a spell name | `/macrokit spells` |
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
