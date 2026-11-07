local addonName, ns = ...

-- The macros MacroKit offers, by class (the game's class file name) and
-- specialization ID.
--
-- Each macro has:
--   name    up to 16 characters, the most the game allows
--   desc    one short line saying what it does, shown in the window
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
        { name = "Interrupt", desc = "Rebuke your focus, mouseover or target", spells = { "Rebuke" }, body = [[
#showtooltip Rebuke
/cast [@focus,harm,nodead][@mouseover,harm,nodead][] Rebuke]] },

        { name = "Stun", desc = "Hammer of Justice on mouseover or target", spells = { "Hammer of Justice" }, body = [[
#showtooltip Hammer of Justice
/cast [@mouseover,harm,nodead][] Hammer of Justice]] },

        { name = "Freedom", desc = "Blessing of Freedom on a mouseover friend or you", spells = { "Blessing of Freedom" }, body = [[
#showtooltip Blessing of Freedom
/cast [@mouseover,help,nodead][@player] Blessing of Freedom]] },

        -- Shift turns it into Blessing of Sacrifice, which cannot target you.
        { name = "Protect Ally", desc = "Blessing of Protection; Shift for Sacrifice", spells = { "Blessing of Protection" }, body = [[
#showtooltip
/cast [mod:shift,@mouseover,help,nodead][mod:shift] Blessing of Sacrifice; [@mouseover,help,nodead][@player] Blessing of Protection]] },

        { name = "Lay on Hands", desc = "On a mouseover friend, else yourself", spells = { "Lay on Hands" }, body = [[
#showtooltip Lay on Hands
/cast [@mouseover,help,nodead][@player] Lay on Hands]] },

        -- Blessing of Protection would stop Divine Shield, so it is removed first.
        { name = "Bubble", desc = "Drops Blessing of Protection, then Divine Shield", spells = { "Divine Shield" }, body = [[
#showtooltip Divine Shield
/cancelaura Blessing of Protection
/cast Divine Shield]] },

        { name = "Battle Rez", desc = "Intercession on a dead mouseover friend or target", spells = { "Intercession" }, body = [[
#showtooltip Intercession
/cast [@mouseover,help,dead][] Intercession]] },

        -- The ! stops a second press from cancelling it.
        { name = "Steed", desc = "Divine Steed; a second press does not cancel it", spells = { "Divine Steed" }, body = [[
#showtooltip Divine Steed
/cast [nomounted] !Divine Steed]] },
    },

    -- Order used when the client cannot say which spec the character is.
    order = { 65, 66, 70 },
    -- Spec names, in case the client cannot give them.
    names = { [65] = "Holy", [66] = "Protection", [70] = "Retribution" },

    specs = {
        -- Holy
        [65] = {
            { name = "Cleanse", desc = "Cleanse a mouseover friend, else yourself", spells = { "Cleanse" }, body = [[
#showtooltip Cleanse
/cast [@mouseover,help,nodead][@player] Cleanse]] },

            -- Heals a friend or hits an enemy, whichever is under the mouse.
            { name = "Holy Shock", desc = "Heals or hits whatever is under the mouse", spells = { "Holy Shock" }, body = [[
#showtooltip Holy Shock
/cast [@mouseover,exists,nodead][] Holy Shock]] },

            { name = "Word of Glory", desc = "Heals a mouseover friend, else yourself", spells = { "Word of Glory" }, body = [[
#showtooltip Word of Glory
/cast [@mouseover,help,nodead][help,nodead][@player] Word of Glory]] },

            { name = "Beacon", desc = "Beacon of Light; Shift puts it on your focus", spells = { "Beacon of Light" }, body = [[
#showtooltip Beacon of Light
/cast [mod:shift,@focus][@mouseover,help,nodead][] Beacon of Light]] },

            { name = "Holy Burst", desc = "Avenging Wrath, top trinket, then Holy Shock", spells = { "Avenging Wrath", "Holy Shock" }, body = [[
#showtooltip Avenging Wrath
/cast Avenging Wrath
/use 13
/cast [@mouseover,help,nodead][] Holy Shock]] },
        },

        -- Protection
        [66] = {
            { name = "Cleanse Toxins", desc = "Cleanse Toxins on a mouseover friend or you", spells = { "Cleanse Toxins" }, body = [[
#showtooltip Cleanse Toxins
/cast [@mouseover,help,nodead][@player] Cleanse Toxins]] },

            { name = "Taunt", desc = "Hand of Reckoning on mouseover, focus or target", spells = { "Hand of Reckoning" }, body = [[
#showtooltip Hand of Reckoning
/cast [@mouseover,harm,nodead][@focus,harm,nodead][] Hand of Reckoning]] },

            -- The trinket goes first so the shield is never lost to it.
            { name = "Shield Up", desc = "Top trinket, then Shield of the Righteous", spells = { "Shield of the Righteous" }, body = [[
#showtooltip Shield of the Righteous
/use 13
/cast Shield of the Righteous]] },

            { name = "Shield Throw", desc = "Avenger's Shield on mouseover or target", spells = { "Avenger's Shield" }, body = [[
#showtooltip Avenger's Shield
/cast [@mouseover,harm,nodead][] Avenger's Shield]] },

            { name = "Self Heal", desc = "Word of Glory on yourself", spells = { "Word of Glory" }, body = [[
#showtooltip Word of Glory
/cast [@player] Word of Glory]] },
        },

        -- Retribution
        [70] = {
            { name = "Cleanse Toxins", desc = "Cleanse Toxins on a mouseover friend or you", spells = { "Cleanse Toxins" }, body = [[
#showtooltip Cleanse Toxins
/cast [@mouseover,help,nodead][@player] Cleanse Toxins]] },

            { name = "Ret Burst", desc = "Avenging Wrath and both trinkets", spells = { "Avenging Wrath" }, body = [[
#showtooltip Avenging Wrath
/cast Avenging Wrath
/use 13
/use 14]] },

            -- Shift for Divine Storm when there are several enemies.
            { name = "Spender", desc = "Templar's Verdict; Shift for Divine Storm", spells = { "Templar's Verdict" }, body = [[
#showtooltip
/cast [mod:shift] Divine Storm; Templar's Verdict]] },

            { name = "Execute", desc = "Hammer of Wrath on mouseover or target", spells = { "Hammer of Wrath" }, body = [[
#showtooltip Hammer of Wrath
/cast [@mouseover,harm,nodead][] Hammer of Wrath]] },

            { name = "Word of Glory", desc = "Heals a mouseover friend, else yourself", spells = { "Word of Glory" }, body = [[
#showtooltip Word of Glory
/cast [@mouseover,help,nodead][@player] Word of Glory]] },
        },
    },
}
