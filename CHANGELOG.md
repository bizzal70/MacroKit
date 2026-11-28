# MacroKit

## 0.14.0

- **Keeps room for your own macros:** adding macros by itself now always leaves 3 of your 18 character macro slots free, for macros you make and other addons' (GamepadMacros' Heal Me, Heal Nearest and Buff Nearest). It says once which macros it held back; add them from the window if you want them.
- **To bar:** a macro in your list but not on your bars has a To bar button that puts it on the first empty action button on screen. No dragging, which is the hard part with a controller. Rows say "On your bars" once it's there.
- **New macro, Missing Buff:** casts whatever the missing-buffs row would cast first; press it again for the next. Put it on one controller button and buffing is one button. It's offered in every class's list and only added when you ask.
- **New installs start with adding by itself off,** so nothing lands in a new player's macro list unasked; existing players keep their setting. A one-time welcome line says what MacroKit does.
- **Remove asks you to press it twice,** so a slip can't delete your macros.
- The window remembers where you put it, and shrinks to fit a small screen.
- MacroKit is listed in Options > AddOns, and has a key binding to open its window.
- `/macrokit debug` prints the version and key facts for a bug report.

## 0.13.0

- **Starting attacks for every class:** new macros for the first attack each class learns: **Lightning Bolt** (shaman), **Fireball**, **Frostbolt** and **Missiles** (mage), **Shadow Bolt** (warlock, also sends your demon in), **Wrath** (druid) and **Shoot** (hunter: Auto Shot plus your pet). Like the others, they cast on the enemy under your mouse, else your target, and start your auto-attack. If you have no enemy targeted, they target the nearest one first, so one button starts a fight; handy on a controller. Warriors, rogues and paladins already had theirs (Strike, Opener, Holy Strike).
- **Priests:** Smite targets the nearest enemy in the same way, and **Big Heal** now works from level 1: Lesser Heal until you learn Heal (16), then Heal until Greater Heal (40). Macros you already have are brought up to date unless you changed them.

## 0.12.1

- **Controller:** when a fight starts, B goes straight back to its usual job, even with a MacroKit window open (it used to stay on closing the window until the fight ended). It closes the window again once the fight is over.

## 0.12.0

- **Gathering tracking in the missing-buffs row:** Find Herbs, Find Minerals, Find Fish and Find Treasure, whichever you have learned, show in the row whenever their minimap tracking is switched off. Click (or tap) one to switch it back on. Any class.

## 0.11.9

- **Controller:** the B button now closes MacroKit's window, like the X and Escape. While one is open, B closes it; once it is closed, B does whatever you have it set to again.

## 0.11.8

- MacroKit now remembers the exact text it gave each macro it added, so any later improvement to a macro reaches yours: when you log in (and after levelling, training or a respec), each one still exactly as MacroKit last wrote it is brought up to date, and chat says which. A macro you have changed yourself is still left alone. Before, only the 0.8.0 auto-attack change could be carried over this way.

## 0.11.7

- The missing-buffs icons now show the cooldown sweep in combat too. In combat the game hides cooldowns from addons, so MacroKit hands them straight to the sweep, which can still draw them. Greying out and ignoring taps stay out of combat only: the game does not allow either in combat.

## 0.11.6

- Fixed: the missing-buffs icons did not grey out or show the cooldown sweep. Forever does not report the global cooldown on its own (spell 61304 does not exist there), so each icon now reads its own buff spell's cooldown, which includes the global cooldown. A buff with a cooldown of its own also stays greyed until it is ready.

## 0.11.5

- The missing-buffs icons show the global cooldown sweep, and out of combat they are greyed and ignore taps while it runs, so a tap too soon no longer makes an icon vanish with "Spell is not ready yet". In combat the game does not let addons switch them off, so only the sweep shows; wait for it before tapping. They are always switched back on as combat starts.

## 0.11.4

- A tapped buff icon whose cast fails ("Spell is not ready yet", out of mana, interrupted) now comes straight back out of combat, instead of a few seconds later. In combat the game does not let addons show it again, so it comes back when the fight ends.

## 0.11.3

- An icon in the missing-buffs row now disappears as soon as you click (or tap) it, in combat too, so you can see what is left to cast. If the cast did not work (out of mana, too soon), the icon comes back after combat, or within a few seconds out of combat.

## 0.11.2

- Fixed: clicking an icon in the missing-buffs row did nothing. The game's "cast on key down" setting (on by default) makes click-to-cast buttons ignore a release on its own; the icons now take the press too.

## 0.11.1

- The missing-buffs row can be moved with a gamepad: the new **Position** button in the MacroKit window (or `/macrokit buffs move`) steps it through set spots on screen: above the middle, below the middle, the top, the bottom above the bars, left and right of the middle. After each step the row shows for a few seconds, even with no buff missing, so you can see where it is. Shift-drag still places it anywhere with a mouse.

## 0.11.0

- New: **missing buffs**. A row of glowing icons near the middle of the screen shows the self-buffs your class should have up but does not (for example Inner Fire and Power Word: Fortitude, Arcane Intellect and an armor, an aspect, Battle Shout, a shaman's shield and weapon imbue), or that have under 2 minutes left (30 seconds for short buffs). Click an icon to cast it on yourself. Only learned spells are asked for, any version of a buff counts (any armor, the group Fortitude), and it stays quiet while mounted, dead or on a flight. In combat it waits, as the game allows no changes then. Shift-drag to move it; turn it off with the new tick box in the window or `/macrokit buffs`.

## 0.10.2

- The wand lines from 0.10.0 and 0.10.1 are gone again: they got in the way of a caster's rotation. Caster attack macros are back to a plain `/startattack`; put your wand (Shoot) on a key of its own. Macros already in your list go back the next time you log in, unless you changed them.

## 0.10.1

- Fixed: the wand line cancelled spells with a cast time or a channel (Mind Blast, Smite, Holy Fire, Mind Flay, Penance, Frostfire Bolt, Arcane Blast, Pyroblast, Corruption, Immolate, Drain, Wrack, Incinerate), because starting Shoot interrupts a spell still being cast. Only instant attack macros start the wand now; the others still swing in melee when no wand is equipped. Macros already in your list are updated the next time you log in, unless you changed them.

## 0.10.0

- Mages, priests and warlocks: attack macros now shoot your **wand** (Shoot) when one is equipped, and swing your melee weapon only when none is. In Forever, `/startattack` swings the melee weapon even with a wand equipped. The warlock's Curse macro only shoots the wand, since both lines would take it past the game's 255 characters. Caster macros already in your list are updated the next time you log in, unless you changed them.

## 0.9.2

- Priests get **Mind Blast** (every spec) and **Holy Fire** (Discipline and Holy; Shadow priests rarely use it, and it would take a Shadow priest past 18 macros). Both cast on the enemy under your mouse, else your target, and start your auto-attack.

## 0.9.1

- Priests get a **Smite** macro: Smite on the enemy under your mouse, else your target, starting your auto-attack like the other attack macros.

## 0.9.0

- The hunter's **Pet** macro now feeds your pet when it is not happy. MacroKit switches the macro to Feed Pet with the best food in your bags (hold Shift to Mend Pet instead), and back to call, revive or mend once the pet is happy. A food your pet refuses is remembered for that pet and skipped. The macro is only changed outside combat, and only while it is still as MacroKit added it.

## 0.8.1

- Hunters' shots now use `/startattack` like every other class: in World of Warcraft: Forever, as in the current game, it starts Auto Shot at range. The `!Auto Shot` line from 0.8.0 is gone, and hunter macros already updated by 0.8.0 are switched over the next time you log in (unless you changed them).

## 0.8.0

- Every attack macro now also starts your auto-attack (`/startattack`), so a press still starts you swinging when you are out of rage, energy or mana. Hunters' shots start Auto Shot instead. Stealth openers only start attacking once you are out of stealth, so a swing never breaks stealth first. Crowd control that breaks on damage (Sap, Blind, Polymorph, Repentance, Hibernate, Entangling Roots, Fear, Banish, Shackle Undead, Scatter Shot) is left alone, as are heals and buffs.
- Macros MacroKit already added are updated the next time you log in, unless you changed them yourself.

## 0.7.0

- The controller pack has moved to its own addon, **GamepadMacros**, with its own Gamepad macros window. MacroKit is back to class and spec macros only. Gamepad macros MacroKit 0.6 added stay in your macro list, and GamepadMacros takes them over.

## 0.6.2

- The Controller tab now shows once you actually use a controller (a button or a stick), not merely when one is connected: some PCs report controllers that are not being used.

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
