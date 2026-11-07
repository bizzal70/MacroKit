local addonName, ns = ...

-- The macros MacroKit offers, by class (the game's class file name).
--
-- Each macro has:
--   name    up to 16 characters, the most the game allows
--   desc    one short line saying what it does, shown in the window
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
        { name = "Holy Strike", desc = "Starts attacking and uses Holy Strike", spells = { "Holy Strike" }, body = [[
#showtooltip Holy Strike
/startattack
/cast Holy Strike]] },

        { name = "Seal", desc = "Seal of Righteousness; Shift for the Crusader", spells = { "Seal of Righteousness", "Seal of the Crusader" }, body = [[
#showtooltip
/cast [mod:shift] Seal of the Crusader; Seal of Righteousness]] },

        { name = "Heal", desc = "Holy Light on a mouseover friend, target or you", spells = { "Holy Light" }, body = [[
#showtooltip Holy Light
/cast [@mouseover,help,nodead][help,nodead][@player] Holy Light]] },

        { name = "Quick Heal", desc = "Flash of Light on a mouseover friend, target or you", spells = { "Flash of Light" }, body = [[
#showtooltip Flash of Light
/cast [@mouseover,help,nodead][help,nodead][@player] Flash of Light]] },

        { name = "Might", desc = "Blessing of Might on a mouseover friend, target or you", spells = { "Blessing of Might" }, body = [[
#showtooltip Blessing of Might
/cast [@mouseover,help,nodead][help,nodead][@player] Blessing of Might]] },

        { name = "Stun", desc = "Hammer of Justice on mouseover or target", spells = { "Hammer of Justice" }, body = [[
#showtooltip Hammer of Justice
/cast [@mouseover,harm,nodead][] Hammer of Justice]] },

        { name = "Protect Ally", desc = "Blessing of Protection on a mouseover friend, target or you", spells = { "Blessing of Protection" }, body = [[
#showtooltip Blessing of Protection
/cast [@mouseover,help,nodead][help,nodead][@player] Blessing of Protection]] },

        { name = "Freedom", desc = "Blessing of Freedom on a mouseover friend, target or you", spells = { "Blessing of Freedom" }, body = [[
#showtooltip Blessing of Freedom
/cast [@mouseover,help,nodead][help,nodead][@player] Blessing of Freedom]] },

        { name = "Lay on Hands", desc = "On a mouseover friend, target or you", spells = { "Lay on Hands" }, body = [[
#showtooltip Lay on Hands
/cast [@mouseover,help,nodead][help,nodead][@player] Lay on Hands]] },

        -- Divine Shield once learned (level 34); Divine Protection until then.
        -- Both apply Forbearance, so only one ever goes off.
        { name = "Bubble", desc = "Divine Shield, or Divine Protection before you have it", spells = { "Divine Protection" }, body = [[
#showtooltip
/cast Divine Shield
/cast Divine Protection]] },

        -- Cleanse once learned (level 42); Purify until then.
        { name = "Dispel", desc = "Cleanse (or Purify) a mouseover friend, target or you", spells = { "Purify" }, body = [[
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Cleanse
/cast [@mouseover,help,nodead][help,nodead][@player] Purify]] },

        { name = "Rez", desc = "Redemption on a dead mouseover friend or target", spells = { "Redemption" }, body = [[
#showtooltip Redemption
/cast [@mouseover,help,dead][] Redemption]] },

        { name = "Exorcism", desc = "Exorcism on mouseover or target (undead, demons)", spells = { "Exorcism" }, body = [[
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
            { name = "Holy Shock", desc = "Heals a friend or hits a foe under the mouse", spells = { "Holy Shock" }, body = [[
#showtooltip Holy Shock
/cast [@mouseover,exists,nodead][] Holy Shock]] },

            { name = "Big Heal", desc = "Divine Favor, then a sure critical Holy Light", spells = { "Divine Favor", "Holy Light" }, body = [[
#showtooltip Divine Favor
/cast Divine Favor
/cast [@mouseover,help,nodead][help,nodead][@player] Holy Light]] },

            { name = "Oath", desc = "Oath of Light on a mouseover friend, target or you", spells = { "Oath of Light" }, body = [[
#showtooltip Oath of Light
/cast [@mouseover,help,nodead][help,nodead][@player] Oath of Light]] },

            { name = "Vigil", desc = "Light's Vigil on a mouseover friend, target or you", spells = { "Light's Vigil" }, body = [[
#showtooltip Light's Vigil
/cast [@mouseover,help,nodead][help,nodead][@player] Light's Vigil]] },
        },

        -- Protection
        [66] = {
            { name = "Tank Up", desc = "Seal of Fury; Shift for Righteous Fury", spells = { "Seal of Fury", "Righteous Fury" }, body = [[
#showtooltip
/cast [mod:shift] Righteous Fury; Seal of Fury]] },

            -- With Seal of Fury up, Judgement taunts.
            { name = "Taunt", desc = "Judgement on mouseover or target; taunts with Seal of Fury", spells = { "Judgement" }, body = [[
#showtooltip Judgement
/cast [@mouseover,harm,nodead][] Judgement]] },

            { name = "Swift Judge", desc = "Swift Judgement on mouseover or target", spells = { "Swift Judgement" }, body = [[
#showtooltip Swift Judgement
/cast [@mouseover,harm,nodead][] Swift Judgement]] },

            { name = "Bulwark", desc = "Templar's Bulwark: a big absorb shield on you", spells = { "Templar's Bulwark" }, body = [[
#showtooltip Templar's Bulwark
/cast Templar's Bulwark]] },
        },

        -- Retribution
        [70] = {
            { name = "Command", desc = "Seal of Command; Shift for the Crusader", spells = { "Seal of Command" }, body = [[
#showtooltip
/cast [mod:shift] Seal of the Crusader; Seal of Command]] },

            { name = "Repent", desc = "Repentance on a mouseover humanoid or target", spells = { "Repentance" }, body = [[
#showtooltip Repentance
/cast [@mouseover,harm,nodead][] Repentance]] },

            { name = "Execute", desc = "Hammer of Wrath on mouseover or target, under 20%", spells = { "Hammer of Wrath" }, body = [[
#showtooltip Hammer of Wrath
/cast [@mouseover,harm,nodead][] Hammer of Wrath]] },
        },
    },
}
