local addonName, ns = ...

-- The macros MacroKit offers, by class (the game's class file name).
--
-- Each macro has:
--   name    up to 16 characters, the most the game allows
--   desc    one short line saying what it does, shown on its row
--   how     a few sentences on how it works, for the window's How it works
--           panel and the tooltip
--   spells  the spells it needs; it is only added once the character knows
--           all of them, which also catches a spell this client names
--           differently
--   body    the macro itself, at most 255 characters
--
-- A class has:
--   shared      macros for every spec
--   specs       macros for one spec only, by spec ID
--   order       the spec IDs in menu order
--   names       each spec's name
--   treeSpells  spells only one talent tree gives: knowing any of them
--               tells MacroKit which spec the character is. World of
--               Warcraft: Forever has classic-style talent trees (points from
--               level 10) and does not report a chosen specialization.
-- Shared plus any one spec stay within the 18 macros a character can hold.
--
-- Spell names are Forever's: the low-level ones were read from a level 6
-- paladin's spellbook on 2026-11-07 (note "Judgement" with an e); the rest
-- come from Forever spellbook and talent sites (foreverchanges.pro,
-- wowforevertalent.com, talentsforever.com) as of 2026-11-07.

ns.SETS = {}

-- In Forever, Judgement does not use up the seal, so no macro re-seals.
ns.SETS.PALADIN = {
    shared = {
        { name = "Holy Strike", desc = "Starts attacking and uses Holy Strike",
          how = "Turns on your auto-attack and uses Holy Strike in the same press, so one button starts a fight and keeps you swinging. Holy Strike needs a melee weapon and has a 10 second cooldown.",
          spells = { "Holy Strike" }, body = [[
#showtooltip Holy Strike
/startattack
/cast Holy Strike]] },

        { name = "Seal", desc = "Seal of Righteousness; Shift for the Crusader",
          how = "Puts up Seal of Righteousness, which adds Holy damage to your swings. Hold Shift to put up Seal of the Crusader instead, for faster attacks. In Forever, Judgement no longer removes your seal, so you only recast it when it runs out.",
          spells = { "Seal of Righteousness", "Seal of the Crusader" }, body = [[
#showtooltip
/cast [mod:shift] Seal of the Crusader; Seal of Righteousness]] },

        { name = "Heal", desc = "Holy Light on a mouseover friend, target or you",
          how = "Casts Holy Light on the friend under your mouse. With no friend under the mouse it heals your target if it is friendly, otherwise you, so you never need to change target to heal.",
          spells = { "Holy Light" }, body = [[
#showtooltip Holy Light
/cast [@mouseover,help,nodead][help,nodead][@player] Holy Light]] },

        { name = "Quick Heal", desc = "Flash of Light on a mouseover friend, target or you",
          how = "Casts Flash of Light, the faster, smaller heal, on the friend under your mouse, else your friendly target, else you.",
          spells = { "Flash of Light" }, body = [[
#showtooltip Flash of Light
/cast [@mouseover,help,nodead][help,nodead][@player] Flash of Light]] },

        { name = "Might", desc = "Blessing of Might on a mouseover friend, target or you",
          how = "Casts Blessing of Might (more attack power, for 1 hour in Forever) on the friend under your mouse, else your friendly target, else you.",
          spells = { "Blessing of Might" }, body = [[
#showtooltip Blessing of Might
/cast [@mouseover,help,nodead][help,nodead][@player] Blessing of Might]] },

        { name = "Stun", desc = "Hammer of Justice on mouseover or target",
          how = "Casts Hammer of Justice on the enemy under your mouse, else your target. Handy for stunning a second enemy, or a caster, without losing your target.",
          spells = { "Hammer of Justice" }, body = [[
#showtooltip Hammer of Justice
/cast [@mouseover,harm,nodead][] Hammer of Justice]] },

        { name = "Protect Ally", desc = "Blessing of Protection on a mouseover friend, target or you",
          how = "Casts Blessing of Protection on the friend under your mouse, else your friendly target, else you. It stops physical damage but gives Forbearance, so the same person cannot be protected again for a minute.",
          spells = { "Blessing of Protection" }, body = [[
#showtooltip Blessing of Protection
/cast [@mouseover,help,nodead][help,nodead][@player] Blessing of Protection]] },

        { name = "Freedom", desc = "Blessing of Freedom on a mouseover friend, target or you",
          how = "Casts Blessing of Freedom on the friend under your mouse, else your friendly target, else you, freeing them from slows and roots for 10 seconds.",
          spells = { "Blessing of Freedom" }, body = [[
#showtooltip Blessing of Freedom
/cast [@mouseover,help,nodead][help,nodead][@player] Blessing of Freedom]] },

        { name = "Lay on Hands", desc = "On a mouseover friend, target or you",
          how = "Heals the friend under your mouse, else your friendly target, else you, for your full health. It uses up all your mana; the cooldown is 20 minutes in Forever.",
          spells = { "Lay on Hands" }, body = [[
#showtooltip Lay on Hands
/cast [@mouseover,help,nodead][help,nodead][@player] Lay on Hands]] },

        -- Divine Shield once learned (level 34); Divine Protection until then.
        -- Both apply Forbearance, so only one ever goes off.
        { name = "Bubble", desc = "Divine Shield, or Divine Protection before you have it",
          how = "Uses Divine Shield if you have it; until you learn it at level 34, the first line does nothing and Divine Protection goes off instead. Both put Forbearance on you, so only one can ever fire.",
          spells = { "Divine Protection" }, body = [[
#showtooltip
/cast Divine Shield
/cast Divine Protection]] },

        -- Cleanse once learned (level 42); Purify until then.
        { name = "Dispel", desc = "Cleanse (or Purify) a mouseover friend, target or you",
          how = "Cleanses the friend under your mouse, else your friendly target, else you. Until you learn Cleanse at level 42, the first line does nothing and Purify is used instead (poison and disease only).",
          spells = { "Purify" }, body = [[
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Cleanse
/cast [@mouseover,help,nodead][help,nodead][@player] Purify]] },

        { name = "Rez", desc = "Redemption on a dead mouseover friend or target",
          how = "Casts Redemption on a dead friend under your mouse, else on your target. It only works out of combat.",
          spells = { "Redemption" }, body = [[
#showtooltip Redemption
/cast [@mouseover,help,dead][] Redemption]] },

        { name = "Exorcism", desc = "Exorcism on mouseover or target (undead, demons)",
          how = "Casts Exorcism on the enemy under your mouse, else your target. It only works on undead and demons.",
          spells = { "Exorcism" }, body = [[
#showtooltip Exorcism
/cast [@mouseover,harm,nodead][] Exorcism]] },
    },

    order = { 65, 66, 70 },
    names = { [65] = "Holy", [66] = "Protection", [70] = "Retribution" },

    -- Talent spells: active abilities only one tree grants.
    treeSpells = {
        [65] = { "Holy Shock", "Divine Favor", "Oath of Light", "Light's Vigil" },
        [66] = { "Templar's Bulwark", "Swift Judgement", "Holy Shield" },
        [70] = { "Seal of Command", "Repentance" },
    },

    specs = {
        -- Holy
        [65] = {
            { name = "Holy Shock", desc = "Heals a friend or hits a foe under the mouse",
          how = "Casts Holy Shock on whoever is under your mouse, friend or foe: it heals a friend or damages an enemy. With nothing under the mouse it uses your target. Its cooldown is 10 seconds in Forever.",
          spells = { "Holy Shock" }, body = [[
#showtooltip Holy Shock
/cast [@mouseover,exists,nodead][] Holy Shock]] },

            { name = "Big Heal", desc = "Divine Favor, then a sure critical Holy Light",
          how = "Uses Divine Favor (no global cooldown) so your next heal is a sure critical, then casts Holy Light on the friend under your mouse, else your friendly target, else you. Save it for emergencies: Divine Favor has a 2 minute cooldown.",
          spells = { "Divine Favor", "Holy Light" }, body = [[
#showtooltip Divine Favor
/cast Divine Favor
/cast [@mouseover,help,nodead][help,nodead][@player] Holy Light]] },

            { name = "Oath", desc = "Oath of Light on a mouseover friend, target or you",
          how = "Casts Oath of Light on the friend under your mouse, else your friendly target, else you. It makes your heals on them stronger for 5 minutes; only one person can be under your Oath at a time.",
          spells = { "Oath of Light" }, body = [[
#showtooltip Oath of Light
/cast [@mouseover,help,nodead][help,nodead][@player] Oath of Light]] },

            { name = "Vigil", desc = "Light's Vigil on a mouseover friend, target or you",
          how = "Casts Light's Vigil on the friend under your mouse, else your friendly target, else you. Your next Holy Shock on them then has no cooldown and also heals their party.",
          spells = { "Light's Vigil" }, body = [[
#showtooltip Light's Vigil
/cast [@mouseover,help,nodead][help,nodead][@player] Light's Vigil]] },
        },

        -- Protection
        [66] = {
            { name = "Tank Up", desc = "Seal of Fury; Shift for Righteous Fury",
          how = "Puts up Seal of Fury, the tanking seal: your hits do Holy damage and give you an absorb shield while you hold a shield. Hold Shift to cast Righteous Fury instead, which greatly raises your threat for 30 minutes.",
          spells = { "Seal of Fury", "Righteous Fury" }, body = [[
#showtooltip
/cast [mod:shift] Righteous Fury; Seal of Fury]] },

            -- With Seal of Fury up, Judgement taunts.
            { name = "Taunt", desc = "Judgement on mouseover or target; taunts with Seal of Fury",
          how = "Uses Judgement on the enemy under your mouse, else your target. While Seal of Fury is up, this Judgement also taunts the enemy to attack you for 3 seconds, so it doubles as your taunt.",
          spells = { "Judgement" }, body = [[
#showtooltip Judgement
/cast [@mouseover,harm,nodead][] Judgement]] },

            { name = "Swift Judge", desc = "Swift Judgement on mouseover or target",
          how = "Uses Swift Judgement on the enemy under your mouse, else your target: an extra Judgement of your seal that does not share Judgement's cooldown and does not remove the seal.",
          spells = { "Swift Judgement" }, body = [[
#showtooltip Swift Judgement
/cast [@mouseover,harm,nodead][] Swift Judgement]] },

            { name = "Bulwark", desc = "Templar's Bulwark: a big absorb shield on you",
          how = "Uses Templar's Bulwark: a shield on you that absorbs damage equal to your maximum health for 8 seconds. It gives Forbearance, like Divine Shield.",
          spells = { "Templar's Bulwark" }, body = [[
#showtooltip Templar's Bulwark
/cast Templar's Bulwark]] },
        },

        -- Retribution
        [70] = {
            { name = "Command", desc = "Seal of Command; Shift for the Crusader",
          how = "Puts up Seal of Command, whose hits can deal extra Holy damage; its Judgement hits twice as hard on stunned enemies. Hold Shift for Seal of the Crusader instead.",
          spells = { "Seal of Command" }, body = [[
#showtooltip
/cast [mod:shift] Seal of the Crusader; Seal of Command]] },

            { name = "Repent", desc = "Repentance on a mouseover humanoid or target",
          how = "Casts Repentance on the enemy under your mouse, else your target, taking a humanoid out of the fight for up to 6 seconds. Any damage breaks it.",
          spells = { "Repentance" }, body = [[
#showtooltip Repentance
/cast [@mouseover,harm,nodead][] Repentance]] },

            { name = "Execute", desc = "Hammer of Wrath on mouseover or target, under 20%",
          how = "Casts Hammer of Wrath on the enemy under your mouse, else your target. It only works on enemies at 20% health or less, so use it to finish them off.",
          spells = { "Hammer of Wrath" }, body = [[
#showtooltip Hammer of Wrath
/cast [@mouseover,harm,nodead][] Hammer of Wrath]] },
        },
    },
}
