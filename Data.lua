local addonName, ns = ...

-- The macros MacroKit offers, by class (the game's class file name) and
-- specialization ID.
--
-- Each macro has:
--   name    up to 16 characters, the most the game allows
--   spells  the spells it needs; it is only added once the character knows
--           all of them, which also catches a spell this client names
--           differently
--   body    the macro itself, at most 255 characters
--
-- Spell names are the Retail ones. The client is Retail-based, but its
-- spell list has not been checked against the game yet.

ns.SETS = {}

ns.SETS.PALADIN = {
    -- Every specialization gets these.
    shared = {
        { name = "Interrupt", spells = { "Rebuke" }, body = [[
#showtooltip Rebuke
/cast [@focus,harm,nodead][@mouseover,harm,nodead][] Rebuke]] },

        { name = "Stun", spells = { "Hammer of Justice" }, body = [[
#showtooltip Hammer of Justice
/cast [@mouseover,harm,nodead][] Hammer of Justice]] },

        { name = "Freedom", spells = { "Blessing of Freedom" }, body = [[
#showtooltip Blessing of Freedom
/cast [@mouseover,help,nodead][@player] Blessing of Freedom]] },

        -- Shift turns it into Blessing of Sacrifice, which cannot target you.
        { name = "Protect Ally", spells = { "Blessing of Protection" }, body = [[
#showtooltip
/cast [mod:shift,@mouseover,help,nodead][mod:shift] Blessing of Sacrifice; [@mouseover,help,nodead][@player] Blessing of Protection]] },

        { name = "Lay on Hands", spells = { "Lay on Hands" }, body = [[
#showtooltip Lay on Hands
/cast [@mouseover,help,nodead][@player] Lay on Hands]] },

        -- Blessing of Protection would stop Divine Shield, so it is removed first.
        { name = "Bubble", spells = { "Divine Shield" }, body = [[
#showtooltip Divine Shield
/cancelaura Blessing of Protection
/cast Divine Shield]] },

        { name = "Battle Rez", spells = { "Intercession" }, body = [[
#showtooltip Intercession
/cast [@mouseover,help,dead][] Intercession]] },

        -- The ! stops a second press from cancelling it.
        { name = "Steed", spells = { "Divine Steed" }, body = [[
#showtooltip Divine Steed
/cast [nomounted] !Divine Steed]] },
    },

    -- Order used when the client cannot say which spec the character is.
    order = { 65, 66, 70 },

    specs = {
        -- Holy
        [65] = {
            { name = "Cleanse", spells = { "Cleanse" }, body = [[
#showtooltip Cleanse
/cast [@mouseover,help,nodead][@player] Cleanse]] },

            -- Heals a friend or hits an enemy, whichever is under the mouse.
            { name = "Holy Shock", spells = { "Holy Shock" }, body = [[
#showtooltip Holy Shock
/cast [@mouseover,exists,nodead][] Holy Shock]] },

            { name = "Word of Glory", spells = { "Word of Glory" }, body = [[
#showtooltip Word of Glory
/cast [@mouseover,help,nodead][help,nodead][@player] Word of Glory]] },

            { name = "Beacon", spells = { "Beacon of Light" }, body = [[
#showtooltip Beacon of Light
/cast [mod:shift,@focus][@mouseover,help,nodead][] Beacon of Light]] },

            { name = "Holy Burst", spells = { "Avenging Wrath", "Holy Shock" }, body = [[
#showtooltip Avenging Wrath
/cast Avenging Wrath
/use 13
/cast [@mouseover,help,nodead][] Holy Shock]] },
        },

        -- Protection
        [66] = {
            { name = "Cleanse Toxins", spells = { "Cleanse Toxins" }, body = [[
#showtooltip Cleanse Toxins
/cast [@mouseover,help,nodead][@player] Cleanse Toxins]] },

            { name = "Taunt", spells = { "Hand of Reckoning" }, body = [[
#showtooltip Hand of Reckoning
/cast [@mouseover,harm,nodead][@focus,harm,nodead][] Hand of Reckoning]] },

            -- The trinket goes first so the shield is never lost to it.
            { name = "Shield Up", spells = { "Shield of the Righteous" }, body = [[
#showtooltip Shield of the Righteous
/use 13
/cast Shield of the Righteous]] },

            { name = "Shield Throw", spells = { "Avenger's Shield" }, body = [[
#showtooltip Avenger's Shield
/cast [@mouseover,harm,nodead][] Avenger's Shield]] },

            { name = "Self Heal", spells = { "Word of Glory" }, body = [[
#showtooltip Word of Glory
/cast [@player] Word of Glory]] },
        },

        -- Retribution
        [70] = {
            { name = "Cleanse Toxins", spells = { "Cleanse Toxins" }, body = [[
#showtooltip Cleanse Toxins
/cast [@mouseover,help,nodead][@player] Cleanse Toxins]] },

            { name = "Ret Burst", spells = { "Avenging Wrath" }, body = [[
#showtooltip Avenging Wrath
/cast Avenging Wrath
/use 13
/use 14]] },

            -- Shift for Divine Storm when there are several enemies.
            { name = "Spender", spells = { "Templar's Verdict" }, body = [[
#showtooltip
/cast [mod:shift] Divine Storm; Templar's Verdict]] },

            { name = "Execute", spells = { "Hammer of Wrath" }, body = [[
#showtooltip Hammer of Wrath
/cast [@mouseover,harm,nodead][] Hammer of Wrath]] },

            { name = "Word of Glory", spells = { "Word of Glory" }, body = [[
#showtooltip Word of Glory
/cast [@mouseover,help,nodead][@player] Word of Glory]] },
        },
    },
}
