# MacroKit

Adds ready-made macros for your class and talent spec to your macro list, and keeps them up to date as you level, train and respec. An addon for World of Warcraft: Forever (client 1.60.x), with macros for all nine classes.

## What it does

MacroKit adds macros to your character's own macro list (`/macro`, the character tab) as soon as your character knows the spells they use.

- **It keeps up as you level.** When you level up, train at a trainer or learn a talent, it looks again straight away: macros you can now use are added (or, with automatic adding off, announced once in chat), the window updates, and a red badge on the minimap button counts what is new since you last opened the window. New macros are marked New in the window.
- **It knows your spec from your talents.** Forever has talent trees rather than a specialization choice, so MacroKit reads how many points you have in each tree (the same way the game's own talent window does) and takes the tree with the most. Before your first talent point, pick your spec in the window's menu; MacroKit remembers it for that character.
- **It follows a respec, a reset and a dual-spec switch.** It switches to the new spec's macros and says so in chat. The macros it added for your old spec are not deleted by themselves: the window offers a **Clear them** button (or type `/macrokit clear`).
- It never overwrites a macro: if you already have one with the same name, yours stays.
- It stops when your character's macro slots are full, and tells you which macros did not fit.
- In combat it waits until the fight is over, because the game does not allow creating macros in combat.

## The MacroKit window

Click the MacroKit button on the minimap, or type `/macrokit`.

- **Top:** your class, in its colour, and a **Spec** menu: Every spec (the macros all specs share), Holy, Protection or Retribution. It follows your talents; before you have any, pick your spec there. You can also pick another spec to look at its macros.
- **Ready to use** tab: macros whose spells you know. Those **in your macros** can be dragged straight onto your action bars (or clicked to pick up); those **ready to add** have an **Add** button.
- **Not learned yet** tab: macros waiting on a spell, each saying which. Learn the spell and the macro moves to Ready to use by itself, even with the window open.
- **Controller** tab: the controller pack (see below).
- Hover over a macro to see how it works, in the **How it works** panel under the list and in its tooltip, along with the macro's text. At the bottom: **Add all missing**, **Remove MacroKit's macros**, and the switch for adding new macros by themselves. The buttons are greyed out in combat, when the game does not allow changing macros.

Classes without macros yet are told so. Drag the minimap button round the edge of the minimap to move it.

## Getting a macro onto your action bar

1. Click the MacroKit button on the minimap (or type `/macrokit`).
2. On the **Ready to use** tab, find the macro. If it says *Ready to add*, click **Add**: it goes into your macro list and then says *In your macros*.
3. Drag that line from the MacroKit window onto any action bar slot. You can also click it once to pick it up, then click the slot.
4. You can also open the game's own macro window with `/macro`: MacroKit's macros are on the **character** tab, and you drag them from there the same way.

With "Add new macros by themselves" on (the default), step 2 is already done for you; just drag.

The window shows these steps too, in its panel under the list, until you hover over a macro.

Once a macro is on your bar, hovering its button shows the spell's tooltip as usual, with MacroKit's explanation of what the macro does underneath. Turn that off with `/macrokit tooltips`.

## Controller pack

For playing with a gamepad or on a Steam Deck: macros for things a controller makes awkward. Put one on your gamepad's action bar and it is one button. Open the window's **Controller** tab and click **Add the pack**, or type `/macrokit controller`. It is never added by itself.

| Macro | What it does |
|---|---|
| Heal Me | Heals yourself, whatever you have targeted (Holy Light, Lesser Heal or Heal, Healing Touch, Healing Wave; paladins, priests, druids and shamans) |
| Quest Item | Uses the quest item in your bags: one that starts a quest first, else a quest item you can use. MacroKit keeps it pointing at the right item as your bags change |
| Save Gear | Saves what you are wearing as the gear set "MacroKit" |
| Wear Gear | Puts that gear set back on (not in combat) |
| Leave Group | Leaves your party or raid |
| Hello, Thanks, Follow Me, Need Help | The /wave, /thank, /followme and /helpme emotes |

All but Heal Me are account-wide General macros, so they use none of a character's 18 macro slots and every character shares them. **Remove MacroKit's macros** removes the pack too.

## Macros for every class

Each class has macros for every spec, plus a few for each talent tree. Hover a macro in the window to read exactly how it works. Most use the same pattern: a heal or buff goes on the friend under your mouse, else your friendly target, else you; an attack goes on the enemy under your mouse, else your target.

**Warrior**

- Every spec: Charge, Victory Rush, Strike, Rend, Hamstring, Interrupt, Overpower, Execute, Taunt, Shout.
- Arms: Mortal Strike, Sweeping, Spearing.
- Fury: Bloodthirst, Death Wish, Whirlwind.
- Protection: Shield Slam, Revenge, Shield Block, Last Stand.

**Paladin**

- Every spec: Holy Strike, Seal, Heal, Quick Heal, Might, Stun, Protect Ally, Freedom, Lay on Hands, Bubble, Dispel, Rez, Exorcism.
- Holy: Holy Shock, Big Heal, Oath, Vigil.
- Protection: Tank Up, Taunt, Swift Judge, Bulwark.
- Retribution: Command, Repent, Execute.

**Hunter**

- Every spec: Mark, Sting, Arcane Shot, Aimed Shot, Multi-Shot, Concussive, Pet, Trap, Melee, Aspect, Lacerate.
- Beast Mastery: Bestial Wrath, Intimidation, Hawk.
- Marksmanship: Scatter Shot, Sniper Shot.
- Survival: Deterrence, Counterattack, Strider Kick.

**Rogue**

- Every spec: Opener, Stun, Interrupt, Stealth, Sap, Finisher, Shank, Blind.
- Assassination: Mutilate, Cold Eviscerate.
- Combat: Burst, Riposte.
- Subtlety: Hemorrhage, Ghostly Strike, Premeditation, Death Mark.

**Priest**

- Every spec: Shield, Renew, Flash Heal, Big Heal, Fortitude, Dispel, Cure, SW: Pain, SW: Death, Fear Ward, Shackle, Rez.
- Discipline: Penance, Power Infusion, Focus Heal.
- Holy: Mending, Group Heal.
- Shadow: Shadowform, Silence, Vamp Embrace, Mind Flay.

**Shaman**

- Every spec: Heal, Quick Heal, Chain Heal, Interrupt, Flame Shock, Frost Shock, Purge, Cure, Totems, Recall, Shield, Ghost Wolf, Rez.
- Elemental: Mastery Bolt, Chain Lightning.
- Enhancement: Stormstrike, Farseer.
- Restoration: Riptide, Swift Heal.

**Mage**

- Every spec: Sheep, Counterspell, Decurse, Intellect, Conjure, Fire Blast, Slow Fall, Frostfire.
- Arcane: Arcane Blast, Burst, Quick Blast.
- Fire: Pyroblast, Combustion, Blast Wave.
- Frost: Ice Lance, Ice Block, Ice Barrier.

**Warlock**

- Every spec: Corruption, Agony, Curse, Immolate, Fear, Banish, Drain, Death Coil.
- Affliction: Siphon Life, Exhaustion, Big Agony, Wrack.
- Demonology: Quick Demon, Sacrifice, Soul Link.
- Destruction: Conflagrate, Shadowburn, Havoc, Incinerate.

**Druid**

- Every spec: Heal, Rejuv, Regrowth, Mark, Thorns, Decurse, Cure Poison, Innervate, Battle Rez, Rez, Roots, Hibernate, Faerie Fire, Moonfire.
- Balance: Moonkin, Insect Swarm.
- Feral Combat: Feral Charge, Lacerate, Primal Bite.
- Restoration: Swiftmend, Wild Growth, Swift Heal.

## Commands

| What | How |
|---|---|
| Open the MacroKit window | `/macrokit`, the minimap button, or MacroKit's entry in the minimap's addon list |
| Add the macros you are missing | `/macrokit add` |
| Add the controller pack | `/macrokit controller` |
| See the macros and whether you have them, in chat | `/macrokit list` |
| Show or hide the minimap button | `/macrokit button` |
| Explain MacroKit's macros in action button tooltips, on or off | `/macrokit tooltips` |
| List your spec and spellbook, to report a spell name | `/macrokit spells` |
| See what the game reports about your talents | `/macrokit talents` |
| Delete the macros MacroKit added for a spec you are no longer | `/macrokit clear` |
| Delete the macros MacroKit added | `/macrokit remove` (macros you made yourself stay) |
| Stop adding new macros by themselves (they are announced instead) | `/macrokit auto off` |

## Good to know

- Macros are saved on Blizzard's servers, so once added they follow your character to any computer, even without the addon.
- The spell names are Forever's, from spell lists built from the live game and checked against each other. Only the paladin's early spells have been checked in game so far. If a macro says it needs a spell you know you have, type `/macrokit spells` and please report what it lists.

## More from this author

Other small addons for World of Warcraft: Forever, all free:

- **[GatherLog](https://github.com/bizzal70/GatherLog)** remembers ore, herbs, fishing pools, skinning spots, chests and rares across all your characters, and guides you back to the best spots.
- **[MouseTip](https://www.curseforge.com/wow/addons/mousetip)** shows tooltips at your mouse cursor.
- **[RangeShade](https://www.curseforge.com/wow/addons/rangeshade)** shades action buttons red when your target is out of range.
- **[JunkMate](https://github.com/bizzal70/JunkMate)** sells junk and repairs at vendors, and warns when your gear is wearing out.
- **[AltGlance](https://github.com/bizzal70/AltGlance)** shows all your characters at a glance: level, gold, rested and where you left them.
- **[SwiftQuest](https://github.com/bizzal70/SwiftQuest)** accepts quests and hands them in as soon as you talk to the quest giver, without ever choosing a reward for you.
- **[SessionRecap](https://github.com/bizzal70/SessionRecap)** keeps a running tally of your play session: gold, experience per hour, quests, gathering and loot.
- **[ZoomPad](https://github.com/bizzal70/ZoomPad)** puts big + and - buttons on screen that zoom the camera, made for the Steam Deck touchscreen.

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
