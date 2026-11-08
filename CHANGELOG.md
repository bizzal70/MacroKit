# MacroKit

## 0.6.1

- The window's Controller tab only shows while a controller is connected (a Steam Deck's own controls count). `/macrokit controller` still adds the pack either way, and macros already added stay.

## 0.6.0

- New: the **controller pack**, for playing with a gamepad or on a Steam Deck. In the window's new Controller tab, or with `/macrokit controller`: Heal Me (heals yourself whatever you have targeted), Quest Item (uses the quest item in your bags, and follows your bags as they change), Save Gear and Wear Gear (a gear set), Leave Group, and the Hello, Thanks, Follow Me and Need Help emotes. All but Heal Me are account-wide General macros, so they cost none of a character's macro slots. The pack is only added when you ask.

## 0.5.4

- Fixed: the minimap button could keep following the mouse after a drag, and then move together with another addon's button sitting on top of it. It now stops the moment you let go.

## 0.5.3

- Hovering an action button that holds one of MacroKit's macros now shows what the macro does under the spell's own tooltip. Macros you made yourself are left alone. `/macrokit tooltips` turns this off or on.

## 0.5.2

- The window explains how to put a macro on your action bar (click Add if needed, then drag its line onto a slot), in the panel under the list until you hover a macro. The README has the same steps.

## 0.5.1

- First release on CurseForge. No changes to how the addon works.

## 0.5.0

- Macros for all nine classes (Warrior, Paladin, Hunter, Rogue, Priest, Shaman, Mage, Warlock, Druid), each with shared macros and a set for every talent tree, written for Forever's spells (for example Bane of Agony, Penance, Riptide, Wild Growth, Victory Rush, Shank, Summon Hawk, Frostfire Bolt).
- The spec now comes from your talent points, read the way Forever's own talent window reads them. A respec, a talent reset or a switch between dual-spec talent sets is noticed at once: MacroKit switches to the new spec's macros and says so.
- Macros MacroKit added for your old spec are pointed out, with a Clear them button in the window and `/macrokit clear`. They are never deleted without you asking.
- `/macrokit talents` shows what the game reports about your talents.

## 0.4.2

- The minimap button now has a red badge with a count, on its top edge, whenever there are macros new since you last opened the window: ones MacroKit added by itself as you levelled, and ones ready to add. Before, it only counted macros waiting to be added, so with automatic adding on (the default) levelling up showed nothing, and the small number could hide under the button's ring.
- New macros are marked New in the window; opening it clears the badge. The button's tooltip says what the number means.

## 0.4.1

- Every macro explains how it works: who it targets and in what order, what Shift does, and the game rules behind it. Hover a macro to read it in the new How it works panel under the list, or in its tooltip.

## 0.4.0

- Paladin macros rebuilt for Forever's Paladin: its spells are mostly the classic ones plus new ones (Holy Strike, Seal of Fury, Templar's Bulwark, Swift Judgement, Oath of Light, Light's Vigil), not the modern game's. The old macros used spells Forever does not have, so they never became ready.
- Your spec is worked out from your talents (Forever has talent trees, not a specialization the game reports). Before your first talent spell, pick your spec in the window's menu; it is remembered for that character.
- MacroKit looks again whenever you level up, train or learn a talent: new macros are added by themselves (or announced once, with automatic adding off), the window updates while open, and the minimap button shows how many macros are ready to add.

## 0.3.0

- The window has two tabs: **Ready to use** (macros whose spells you know, in your macros or ready to add) and **Not learned yet** (macros waiting on a spell), each with a count. An empty tab says where to look instead.
- A **Spec** menu at the top: your own spec, Every spec (the shared macros), or any other spec to preview its macros, for example before choosing one at level 10.

## 0.2.1

- Before you choose a specialization, the window lists only the macros every spec shares, with a line saying the spec macros will appear once you choose one. It listed every spec's macros, which made a very tall window.
- The status ("Ready", "Needs ...") now sits on the macro's name line, so it no longer runs into the description.
- `/macrokit spells` lists your spec and the spells in your spellbook, to check MacroKit's spell names against the game.

## 0.2.0

- A MacroKit window, opened from a new minimap button, `/macrokit` or the minimap's addon list. It shows your class and spec and each of their macros: in your macros (drag it onto your bars, or click to pick it up), ready (with an Add button) or waiting on a spell. Hover a line to see the macro. Add all missing, Remove MacroKit's macros and the automatic-adding switch are at the bottom.
- `/macrokit` now opens the window; `/macrokit add` adds the missing macros. `/macrokit button` hides or shows the minimap button.
- Each macro has a one-line description.

## 0.1.0

- First version: Paladin macros for every spec, added to your character's macro list the first time you play each spec. `/macrokit` adds any you are missing, `/macrokit list` shows them, `/macrokit remove` deletes the ones it added.
