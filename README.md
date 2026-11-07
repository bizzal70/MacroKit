# MacroKit

Adds ready-made macros for your class and talent spec to your macro list, and keeps them up to date as you learn new spells. An addon for World of Warcraft: Forever (client 1.60.x). It has Paladin macros so far.

## What it does

MacroKit adds macros to your character's own macro list (`/macro`, the character tab) as soon as your character knows the spells they use.

- **It keeps up as you level.** When you level up, train at a trainer or learn a talent, it looks again straight away: macros you can now use are added (or, with automatic adding off, announced once in chat), the window updates, and a red badge on the minimap button counts what is new since you last opened the window. New macros are marked New in the window.
- **It knows your spec from your talents.** Forever has talent trees rather than a specialization choice, so MacroKit spots your tree from its talent spells: Holy Shock, Divine Favor, Oath of Light or Light's Vigil for Holy; Templar's Bulwark, Swift Judgement or Holy Shield for Protection; Seal of Command or Repentance for Retribution. Until you have one, pick your spec in the window's menu; MacroKit remembers it for that character.
- It never overwrites a macro: if you already have one with the same name, yours stays.
- It stops when your character's macro slots are full, and tells you which macros did not fit.
- In combat it waits until the fight is over, because the game does not allow creating macros in combat.

## The MacroKit window

Click the MacroKit button on the minimap, or type `/macrokit`.

- **Top:** your class, in its colour, and a **Spec** menu: Every spec (the macros all specs share), Holy, Protection or Retribution. It follows your talents; before you have any, pick your spec there. You can also pick another spec to look at its macros.
- **Ready to use** tab: macros whose spells you know. Those **in your macros** can be dragged straight onto your action bars (or clicked to pick up); those **ready to add** have an **Add** button.
- **Not learned yet** tab: macros waiting on a spell, each saying which. Learn the spell and the macro moves to Ready to use by itself, even with the window open.
- Hover over a macro to see how it works, in the **How it works** panel under the list and in its tooltip, along with the macro's text. At the bottom: **Add all missing**, **Remove MacroKit's macros**, and the switch for adding new macros by themselves. The buttons are greyed out in combat, when the game does not allow changing macros.

Classes without macros yet are told so. Drag the minimap button round the edge of the minimap to move it.

## Paladin macros

Made for Forever's Paladin, whose spells are mostly the classic ones plus new ones such as Holy Strike, Seal of Fury, Templar's Bulwark and Oath of Light. In Forever, Judgement no longer uses up your seal.

Every spec:

| Macro | What it does |
|---|---|
| Holy Strike | Starts attacking and uses Holy Strike |
| Seal | Seal of Righteousness; hold Shift for Seal of the Crusader |
| Heal | Holy Light on a mouseover friend, your friendly target, else you |
| Quick Heal | Flash of Light, the same way |
| Might | Blessing of Might, the same way |
| Stun | Hammer of Justice on your mouseover target, else your target |
| Protect Ally | Blessing of Protection on a mouseover friend, your friendly target, else you |
| Freedom | Blessing of Freedom, the same way |
| Lay on Hands | The same way |
| Bubble | Divine Shield once you have it (level 34), Divine Protection until then |
| Dispel | Cleanse once you have it (level 42), Purify until then |
| Rez | Redemption on a dead mouseover friend, else your target |
| Exorcism | On your mouseover target, else your target (undead and demons) |

Holy: **Holy Shock** (heals a friend or hits a foe under the mouse), **Big Heal** (Divine Favor, then a sure critical Holy Light), **Oath** (Oath of Light), **Vigil** (Light's Vigil).

Protection: **Tank Up** (Seal of Fury; Shift for Righteous Fury), **Taunt** (Judgement; it taunts while Seal of Fury is up), **Swift Judge** (Swift Judgement), **Bulwark** (Templar's Bulwark).

Retribution: **Command** (Seal of Command; Shift for Seal of the Crusader), **Repent** (Repentance), **Execute** (Hammer of Wrath, on targets under 20% health).

## Commands

| What | How |
|---|---|
| Open the MacroKit window | `/macrokit`, the minimap button, or MacroKit's entry in the minimap's addon list |
| Add the macros you are missing | `/macrokit add` |
| See the macros and whether you have them, in chat | `/macrokit list` |
| Show or hide the minimap button | `/macrokit button` |
| List your spec and spellbook, to report a spell name | `/macrokit spells` |
| Delete the macros MacroKit added | `/macrokit remove` (macros you made yourself stay) |
| Stop adding new macros by themselves (they are announced instead) | `/macrokit auto off` |

## Good to know

- Macros are saved on Blizzard's servers, so once added they follow your character to any computer, even without the addon.
- The spell names are Forever's, checked against a paladin's spellbook and Forever spell lists. If a macro says it needs a spell you know you have, type `/macrokit spells` and please report what it lists.

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
