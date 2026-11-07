# MacroKit

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
