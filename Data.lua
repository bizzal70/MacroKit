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
-- Spell names are Forever's. The paladin's low-level ones were read from a
-- level 6 paladin's spellbook on 2026-11-07 (note "Judgement" with an e).
-- Everything else comes from Forever spellbook and talent sites built from
-- the live client, build 70862 (foreverchanges.pro, wowforevertalents.com,
-- talentsforever.com), checked against each other on 2026-11-07. Spec IDs
-- are MacroKit's own keys (borrowed from the main game); the talent trees'
-- order in `order` is the order the game lists them.

ns.SETS = {}

-- A macro: name, one-line description, how it works, spells, body.
local function M(name, desc, how, spells, body)
    return { name = name, desc = desc, how = how, spells = spells, body = body }
end

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

-- Priest: trees Discipline, Holy, Shadow (talent tabs in that order).
ns.SETS.PRIEST = {
    shared = {
        M("Shield", "Power Word: Shield on a mouseover friend, target or you",
          "Casts Power Word: Shield on the friend under your mouse, else your friendly target, else you. The target then gets Weakened Soul for 15 seconds, and in Forever the shield has a 4 second cooldown.",
          { "Power Word: Shield" }, [[
#showtooltip Power Word: Shield
/cast [@mouseover,help,nodead][help,nodead][@player] Power Word: Shield]]),
        M("Renew", "Renew on a mouseover friend, target or you",
          "Casts Renew, a heal over time, on the friend under your mouse, else your friendly target, else you. In Forever, Renew's ticks can be critical.",
          { "Renew" }, [[
#showtooltip Renew
/cast [@mouseover,help,nodead][help,nodead][@player] Renew]]),
        M("Flash Heal", "Flash Heal on a mouseover friend, target or you",
          "Casts Flash Heal, the fast heal, on the friend under your mouse, else your friendly target, else you.",
          { "Flash Heal" }, [[
#showtooltip Flash Heal
/cast [@mouseover,help,nodead][help,nodead][@player] Flash Heal]]),
        M("Big Heal", "Greater Heal, or Heal before you have it",
          "Casts Greater Heal on the friend under your mouse, else your friendly target, else you. Until you learn Greater Heal at level 40, the first line does nothing and Heal is cast instead.",
          { "Heal" }, [[
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Greater Heal
/cast [@mouseover,help,nodead][help,nodead][@player] Heal]]),
        M("Fortitude", "Power Word: Fortitude; Shift for the group version",
          "Casts Power Word: Fortitude on the friend under your mouse, else your friendly target, else you; it lasts an hour in Forever. Hold Shift for Prayer of Fortitude on the whole group once you have it (level 48).",
          { "Power Word: Fortitude" }, [[
#showtooltip
/cast [mod:shift] Prayer of Fortitude; [@mouseover,help,nodead][help,nodead][@player] Power Word: Fortitude]]),
        M("Dispel", "Dispel Magic on whoever is under the mouse, else target, else you",
          "Casts Dispel Magic on whoever is under your mouse: it removes a harmful spell from a friend, or a helpful one from an enemy. With nothing under the mouse it uses your target, else you.",
          { "Dispel Magic" }, [[
#showtooltip Dispel Magic
/cast [@mouseover,exists,nodead][exists,nodead][@player] Dispel Magic]]),
        M("Cure", "Abolish Disease, or Cure Disease before you have it",
          "Removes disease from the friend under your mouse, else your friendly target, else you. Uses Abolish Disease once you have it (level 32), Cure Disease until then.",
          { "Cure Disease" }, [[
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Abolish Disease
/cast [@mouseover,help,nodead][help,nodead][@player] Cure Disease]]),
        M("SW: Pain", "Shadow Word: Pain on mouseover or target",
          "Casts Shadow Word: Pain on the enemy under your mouse, else your target, so you can put it on several enemies without changing target.",
          { "Shadow Word: Pain" }, [[
#showtooltip Shadow Word: Pain
/cast [@mouseover,harm,nodead][] Shadow Word: Pain]]),
        M("SW: Death", "Shadow Word: Death on mouseover or target",
          "Casts Shadow Word: Death, new in Forever, on the enemy under your mouse, else your target. If the target survives you take damage equal to 30% of your health, so save it to finish enemies off.",
          { "Shadow Word: Death" }, [[
#showtooltip Shadow Word: Death
/cast [@mouseover,harm,nodead][] Shadow Word: Death]]),
        M("Fear Ward", "Fear Ward on a mouseover friend, target or you",
          "Casts Fear Ward on the friend under your mouse, else your friendly target, else you. Every race has it in Forever.",
          { "Fear Ward" }, [[
#showtooltip Fear Ward
/cast [@mouseover,help,nodead][help,nodead][@player] Fear Ward]]),
        M("Shackle", "Shackle Undead on mouseover or target",
          "Casts Shackle Undead on the undead enemy under your mouse, else your target.",
          { "Shackle Undead" }, [[
#showtooltip Shackle Undead
/cast [@mouseover,harm,nodead][] Shackle Undead]]),
        M("Rez", "Resurrection on a dead mouseover friend or target",
          "Casts Resurrection on a dead friend under your mouse, else on your target. It only works out of combat.",
          { "Resurrection" }, [[
#showtooltip Resurrection
/cast [@mouseover,help,dead][] Resurrection]]),
    },
    order = { 256, 257, 258 },
    names = { [256] = "Discipline", [257] = "Holy", [258] = "Shadow" },
    treeSpells = {
        [256] = { "Penance", "Power Infusion" },
        [257] = { "Prayer of Mending" },
        [258] = { "Shadowform", "Silence", "Vampiric Embrace" },
    },
    specs = {
        [256] = {
            M("Penance", "Penance on whoever is under the mouse",
              "Channels Penance, new in Forever, on whoever is under your mouse: it heals a friend or damages an enemy, at once and then every second for 2 seconds. With nothing under the mouse it uses your target. 12 second cooldown.",
              { "Penance" }, [[
#showtooltip Penance
/cast [@mouseover,exists,nodead][] Penance]]),
            M("Power Infusion", "Power Infusion on a mouseover friend, target or you",
              "Casts Power Infusion on the friend under your mouse, else your friendly target, else you: 20% more spell damage and healing for 15 seconds.",
              { "Power Infusion" }, [[
#showtooltip Power Infusion
/cast [@mouseover,help,nodead][help,nodead][@player] Power Infusion]]),
            M("Focus Heal", "Inner Focus, then a free Flash Heal",
              "Uses Inner Focus, which makes your next spell free and more likely to be critical, then casts Flash Heal on the friend under your mouse, else your friendly target, else you. Inner Focus has a 3 minute cooldown.",
              { "Inner Focus", "Flash Heal" }, [[
#showtooltip Inner Focus
/cast Inner Focus
/cast [@mouseover,help,nodead][help,nodead][@player] Flash Heal]]),
        },
        [257] = {
            M("Mending", "Prayer of Mending on a mouseover friend, target or you",
              "Casts Prayer of Mending, new in Forever, on the friend under your mouse, else your friendly target, else you. It heals them the next time they are hit or healed, then jumps to another party member, up to 5 times.",
              { "Prayer of Mending" }, [[
#showtooltip Prayer of Mending
/cast [@mouseover,help,nodead][help,nodead][@player] Prayer of Mending]]),
            M("Group Heal", "Prayer of Healing on a mouseover friend's party",
              "Casts Prayer of Healing on the friend under your mouse, else your friendly target, else you. In Forever it heals that person's party (within 40 yards of them), so you can heal another group in a raid.",
              { "Prayer of Healing" }, [[
#showtooltip Prayer of Healing
/cast [@mouseover,help,nodead][help,nodead][@player] Prayer of Healing]]),
        },
        [258] = {
            M("Shadowform", "Shadowform, without turning it off",
              "Enters Shadowform. The ! stops a second press from leaving it, so you can press it freely. In Shadowform you cannot cast healing spells.",
              { "Shadowform" }, [[
#showtooltip Shadowform
/cast !Shadowform]]),
            M("Silence", "Silence on mouseover or target",
              "Casts Silence on the enemy under your mouse, else your target, to stop a caster. 45 second cooldown.",
              { "Silence" }, [[
#showtooltip Silence
/cast [@mouseover,harm,nodead][] Silence]]),
            M("Vamp Embrace", "Vampiric Embrace on mouseover or target",
              "Casts Vampiric Embrace on the enemy under your mouse, else your target; your Shadow damage to it heals your party.",
              { "Vampiric Embrace" }, [[
#showtooltip Vampiric Embrace
/cast [@mouseover,harm,nodead][] Vampiric Embrace]]),
            M("Mind Flay", "Mind Flay on mouseover or target",
              "Channels Mind Flay on the enemy under your mouse, else your target. It also slows them.",
              { "Mind Flay" }, [[
#showtooltip Mind Flay
/cast [@mouseover,harm,nodead][] Mind Flay]]),
        },
    },
}

-- Shaman: trees Elemental, Enhancement, Restoration.
ns.SETS.SHAMAN = {
    shared = {
        M("Heal", "Healing Wave on a mouseover friend, target or you",
          "Casts Healing Wave on the friend under your mouse, else your friendly target, else you.",
          { "Healing Wave" }, [[
#showtooltip Healing Wave
/cast [@mouseover,help,nodead][help,nodead][@player] Healing Wave]]),
        M("Quick Heal", "Lesser Healing Wave on a mouseover friend, target or you",
          "Casts Lesser Healing Wave, the fast heal, on the friend under your mouse, else your friendly target, else you.",
          { "Lesser Healing Wave" }, [[
#showtooltip Lesser Healing Wave
/cast [@mouseover,help,nodead][help,nodead][@player] Lesser Healing Wave]]),
        M("Chain Heal", "Chain Heal on a mouseover friend, target or you",
          "Casts Chain Heal on the friend under your mouse, else your friendly target, else you; it jumps to injured people nearby.",
          { "Chain Heal" }, [[
#showtooltip Chain Heal
/cast [@mouseover,help,nodead][help,nodead][@player] Chain Heal]]),
        M("Interrupt", "Earth Shock on mouseover or target",
          "Casts Earth Shock on the enemy under your mouse, else your target. It interrupts spellcasting, so it is your interrupt.",
          { "Earth Shock" }, [[
#showtooltip Earth Shock
/cast [@mouseover,harm,nodead][] Earth Shock]]),
        M("Flame Shock", "Flame Shock on mouseover or target",
          "Casts Flame Shock on the enemy under your mouse, else your target, so you can put it on several enemies.",
          { "Flame Shock" }, [[
#showtooltip Flame Shock
/cast [@mouseover,harm,nodead][] Flame Shock]]),
        M("Frost Shock", "Frost Shock on mouseover or target",
          "Casts Frost Shock on the enemy under your mouse, else your target, slowing them.",
          { "Frost Shock" }, [[
#showtooltip Frost Shock
/cast [@mouseover,harm,nodead][] Frost Shock]]),
        M("Purge", "Purge on mouseover or target",
          "Casts Purge on the enemy under your mouse, else your target, removing helpful magic from them.",
          { "Purge" }, [[
#showtooltip Purge
/cast [@mouseover,harm,nodead][] Purge]]),
        M("Cure", "Cure Poison; Shift for Cure Disease",
          "Cures poison on the friend under your mouse, else your friendly target, else you. Hold Shift to cure disease instead.",
          { "Cure Poison" }, [[
#showtooltip
/cast [mod:shift,@mouseover,help,nodead][mod:shift,help,nodead][mod:shift,@player] Cure Disease; [@mouseover,help,nodead][help,nodead][@player] Cure Poison]]),
        M("Totems", "Drop your totem set; Shift and Ctrl for sets 2 and 3",
          "Uses Call of the Elements, new in Forever, to drop the totems you set on the Totem Bar. Hold Shift for Call of the Ancestors (your second set, level 30) or Ctrl for Call of the Spirits (third set, level 40).",
          { "Call of the Elements" }, [[
#showtooltip
/cast [mod:ctrl] Call of the Spirits; [mod:shift] Call of the Ancestors; Call of the Elements]]),
        M("Recall", "Totemic Recall; Shift to bring totems to you",
          "Uses Totemic Recall to remove your totems and get some of their mana back. Hold Shift for Totemic Call instead, which moves your totems to where you stand.",
          { "Totemic Recall" }, [[
#showtooltip
/cast [mod:shift] Totemic Call; Totemic Recall]]),
        M("Shield", "Lightning Shield; Shift for Water Shield",
          "Puts up Lightning Shield. Hold Shift for Water Shield instead, if you have it (a Restoration talent). Only one shield can be up at a time.",
          { "Lightning Shield" }, [[
#showtooltip
/cast [mod:shift] Water Shield; Lightning Shield]]),
        M("Ghost Wolf", "Ghost Wolf, without turning it off",
          "Turns you into a Ghost Wolf. The ! stops a second press from turning you back, so you can press it freely.",
          { "Ghost Wolf" }, [[
#showtooltip Ghost Wolf
/cast !Ghost Wolf]]),
        M("Rez", "Ancestral Spirit on a dead mouseover friend or target",
          "Casts Ancestral Spirit on a dead friend under your mouse, else on your target. It only works out of combat.",
          { "Ancestral Spirit" }, [[
#showtooltip Ancestral Spirit
/cast [@mouseover,help,dead][] Ancestral Spirit]]),
    },
    order = { 262, 263, 264 },
    names = { [262] = "Elemental", [263] = "Enhancement", [264] = "Restoration" },
    treeSpells = {
        [262] = { "Lightning Mastery" },
        [263] = { "Stormstrike", "Rage of the Farseer" },
        [264] = { "Riptide", "Nature's Swiftness", "Mana Tide Totem", "Water Shield" },
    },
    specs = {
        [262] = {
            M("Mastery Bolt", "Lightning Mastery, then Lightning Bolt",
              "Uses Lightning Mastery (Forever's new name for Elemental Mastery: faster Lightning Bolts and no Chain Lightning cooldown for 15 seconds), then casts Lightning Bolt on the enemy under your mouse, else your target. 3 minute cooldown.",
              { "Lightning Mastery", "Lightning Bolt" }, [[
#showtooltip Lightning Mastery
/cast Lightning Mastery
/cast [@mouseover,harm,nodead][] Lightning Bolt]]),
            M("Chain Lightning", "Chain Lightning on mouseover or target",
              "Casts Chain Lightning on the enemy under your mouse, else your target; it jumps to two more enemies.",
              { "Chain Lightning" }, [[
#showtooltip Chain Lightning
/cast [@mouseover,harm,nodead][] Chain Lightning]]),
        },
        [263] = {
            M("Stormstrike", "Starts attacking and uses Stormstrike",
              "Turns on your auto-attack and uses Stormstrike, which also makes your next Lightning Bolt, Chain Lightning or Earth Shock on the target hit harder. 6 second cooldown in Forever.",
              { "Stormstrike" }, [[
#showtooltip Stormstrike
/startattack
/cast Stormstrike]]),
            M("Farseer", "Rage of the Farseer and attack",
              "Uses Rage of the Farseer, new in Forever: 30% faster attacks for 25 seconds, 3 minute cooldown. It also starts your auto-attack.",
              { "Rage of the Farseer" }, [[
#showtooltip Rage of the Farseer
/cast Rage of the Farseer
/startattack]]),
        },
        [264] = {
            M("Riptide", "Riptide on a mouseover friend, target or you",
              "Casts Riptide, new in Forever, on the friend under your mouse, else your friendly target, else you: an instant heal over 15 seconds, and your next Chain Heal on them heals 25% more.",
              { "Riptide" }, [[
#showtooltip Riptide
/cast [@mouseover,help,nodead][help,nodead][@player] Riptide]]),
            M("Swift Heal", "Nature's Swiftness, then an instant Healing Wave",
              "Uses Nature's Swiftness so your next nature spell is instant, then casts Healing Wave on the friend under your mouse, else your friendly target, else you. Your emergency heal; 3 minute cooldown.",
              { "Nature's Swiftness", "Healing Wave" }, [[
#showtooltip Nature's Swiftness
/cast Nature's Swiftness
/cast [@mouseover,help,nodead][help,nodead][@player] Healing Wave]]),
        },
    },
}

-- Druid: trees Balance, Feral Combat, Restoration.
ns.SETS.DRUID = {
    shared = {
        M("Heal", "Healing Touch on a mouseover friend, target or you",
          "Casts Healing Touch on the friend under your mouse, else your friendly target, else you.",
          { "Healing Touch" }, [[
#showtooltip Healing Touch
/cast [@mouseover,help,nodead][help,nodead][@player] Healing Touch]]),
        M("Rejuv", "Rejuvenation on a mouseover friend, target or you",
          "Casts Rejuvenation, a heal over time, on the friend under your mouse, else your friendly target, else you.",
          { "Rejuvenation" }, [[
#showtooltip Rejuvenation
/cast [@mouseover,help,nodead][help,nodead][@player] Rejuvenation]]),
        M("Regrowth", "Regrowth on a mouseover friend, target or you",
          "Casts Regrowth on the friend under your mouse, else your friendly target, else you.",
          { "Regrowth" }, [[
#showtooltip Regrowth
/cast [@mouseover,help,nodead][help,nodead][@player] Regrowth]]),
        M("Mark", "Mark of the Wild; Shift for Gift of the Wild",
          "Casts Mark of the Wild on the friend under your mouse, else your friendly target, else you; it lasts an hour in Forever. Hold Shift for Gift of the Wild on the whole group once you have it (level 50).",
          { "Mark of the Wild" }, [[
#showtooltip
/cast [mod:shift] Gift of the Wild; [@mouseover,help,nodead][help,nodead][@player] Mark of the Wild]]),
        M("Thorns", "Thorns on a mouseover friend, target or you",
          "Casts Thorns on the friend under your mouse, else your friendly target, else you.",
          { "Thorns" }, [[
#showtooltip Thorns
/cast [@mouseover,help,nodead][help,nodead][@player] Thorns]]),
        M("Decurse", "Remove Curse on a mouseover friend, target or you",
          "Casts Remove Curse on the friend under your mouse, else your friendly target, else you.",
          { "Remove Curse" }, [[
#showtooltip Remove Curse
/cast [@mouseover,help,nodead][help,nodead][@player] Remove Curse]]),
        M("Cure Poison", "Abolish Poison, or Cure Poison before you have it",
          "Removes poison from the friend under your mouse, else your friendly target, else you. Uses Abolish Poison once you have it (level 26), Cure Poison until then.",
          { "Cure Poison" }, [[
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Abolish Poison
/cast [@mouseover,help,nodead][help,nodead][@player] Cure Poison]]),
        M("Innervate", "Innervate on a mouseover friend, target or you",
          "Casts Innervate on the friend under your mouse, else your friendly target, else you, restoring mana quickly. 6 minute cooldown.",
          { "Innervate" }, [[
#showtooltip Innervate
/cast [@mouseover,help,nodead][help,nodead][@player] Innervate]]),
        M("Battle Rez", "Rebirth on a dead mouseover friend or target",
          "Casts Rebirth on a dead friend under your mouse, else on your target. It works in combat and needs an Ironwood Seed.",
          { "Rebirth" }, [[
#showtooltip Rebirth
/cast [@mouseover,help,dead][] Rebirth]]),
        M("Rez", "Revive on a dead mouseover friend or target",
          "Casts Revive, new in Forever, on a dead friend under your mouse, else on your target. Out of combat only, but it needs no reagent.",
          { "Revive" }, [[
#showtooltip Revive
/cast [@mouseover,help,dead][] Revive]]),
        M("Roots", "Entangling Roots on mouseover or target",
          "Casts Entangling Roots on the enemy under your mouse, else your target, holding them in place.",
          { "Entangling Roots" }, [[
#showtooltip Entangling Roots
/cast [@mouseover,harm,nodead][] Entangling Roots]]),
        M("Hibernate", "Hibernate on mouseover or target",
          "Casts Hibernate on the beast or dragonkin under your mouse, else your target.",
          { "Hibernate" }, [[
#showtooltip Hibernate
/cast [@mouseover,harm,nodead][] Hibernate]]),
        M("Faerie Fire", "Faerie Fire on mouseover or target, in any form",
          "Casts Faerie Fire on the enemy under your mouse, else your target. In Forever it also works in Cat and Bear form (free, 6 second cooldown there); the old Faerie Fire (Feral) is gone.",
          { "Faerie Fire" }, [[
#showtooltip Faerie Fire
/cast [@mouseover,harm,nodead][] Faerie Fire]]),
        M("Moonfire", "Moonfire on mouseover or target",
          "Casts Moonfire on the enemy under your mouse, else your target, so you can put it on several enemies.",
          { "Moonfire" }, [[
#showtooltip Moonfire
/cast [@mouseover,harm,nodead][] Moonfire]]),
    },
    order = { 102, 103, 105 },
    names = { [102] = "Balance", [103] = "Feral Combat", [105] = "Restoration" },
    treeSpells = {
        [102] = { "Moonkin Form", "Insect Swarm" },
        [103] = { "Primal Bite", "Shifting Power", "Lacerate", "Feral Charge" },
        [105] = { "Wild Growth", "Swiftmend", "Nature's Swiftness" },
    },
    specs = {
        [102] = {
            M("Moonkin", "Moonkin Form, without leaving it",
              "Enters Moonkin Form. The ! stops a second press from leaving it. In Forever you can cast every non-healing spell in Moonkin Form.",
              { "Moonkin Form" }, [[
#showtooltip Moonkin Form
/cast !Moonkin Form]]),
            M("Insect Swarm", "Insect Swarm on mouseover or target",
              "Casts Insect Swarm (a Balance talent in Forever) on the enemy under your mouse, else your target.",
              { "Insect Swarm" }, [[
#showtooltip Insect Swarm
/cast [@mouseover,harm,nodead][] Insect Swarm]]),
        },
        [103] = {
            M("Feral Charge", "Feral Charge on mouseover or target",
              "Uses Feral Charge on the enemy under your mouse, else your target. In bear form it charges and roots them; in Forever it also works in cat form, where it leaps behind them.",
              { "Feral Charge" }, [[
#showtooltip Feral Charge
/cast [@mouseover,harm,nodead][] Feral Charge]]),
            M("Lacerate", "Starts attacking and uses Lacerate",
              "Turns on your auto-attack and uses Lacerate, new in Forever: a stacking bleed with high threat, for bear form.",
              { "Lacerate" }, [[
#showtooltip Lacerate
/startattack
/cast Lacerate]]),
            M("Primal Bite", "Starts attacking and uses Primal Bite",
              "Turns on your auto-attack and uses Primal Bite, new in Forever: a high-threat bite in bear form with a 6 second cooldown.",
              { "Primal Bite" }, [[
#showtooltip Primal Bite
/startattack
/cast Primal Bite]]),
        },
        [105] = {
            M("Swiftmend", "Swiftmend on a mouseover friend, target or you",
              "Casts Swiftmend on the friend under your mouse, else your friendly target, else you. It needs your Rejuvenation or Regrowth on them, which it uses up.",
              { "Swiftmend" }, [[
#showtooltip Swiftmend
/cast [@mouseover,help,nodead][help,nodead][@player] Swiftmend]]),
            M("Wild Growth", "Wild Growth on a mouseover friend, target or you",
              "Casts Wild Growth, new in Forever, on the friend under your mouse, else your friendly target, else you: a heal over time on their party. 6 second cooldown.",
              { "Wild Growth" }, [[
#showtooltip Wild Growth
/cast [@mouseover,help,nodead][help,nodead][@player] Wild Growth]]),
            M("Swift Heal", "Nature's Swiftness, then an instant Healing Touch",
              "Uses Nature's Swiftness so your next nature spell is instant, then casts Healing Touch on the friend under your mouse, else your friendly target, else you. Your emergency heal; 3 minute cooldown.",
              { "Nature's Swiftness", "Healing Touch" }, [[
#showtooltip Nature's Swiftness
/cast Nature's Swiftness
/cast [@mouseover,help,nodead][help,nodead][@player] Healing Touch]]),
        },
    },
}

-- Warrior: trees Arms, Fury, Protection. Stances: 1 Battle, 2 Defensive, 3 Berserker.
ns.SETS.WARRIOR = {
    shared = {
        M("Charge", "Charge; Intercept in Berserker Stance",
          "Charges your target in Battle Stance, or uses Intercept in Berserker Stance (level 30). In any other stance it switches you to Battle Stance first, so a second press charges. Charge cannot be used once you are in combat.",
          { "Charge", "Battle Stance" }, [[
#showtooltip
/cast [stance:1] Charge; [stance:3] Intercept; Battle Stance]]),
        M("Victory Rush", "Victory Rush after a kill",
          "Uses Victory Rush, new in Forever: after you kill an enemy worth experience you have 20 seconds to use it for damage and a 10% heal. It needs no stance and no Rage.",
          { "Victory Rush" }, [[
#showtooltip Victory Rush
/cast Victory Rush]]),
        M("Strike", "Heroic Strike; Shift for Cleave",
          "Queues Heroic Strike on your next swing. Hold Shift for Cleave instead (level 20), which hits two enemies.",
          { "Heroic Strike" }, [[
#showtooltip
/cast [mod:shift] Cleave; Heroic Strike]]),
        M("Rend", "Rend on mouseover or target",
          "Uses Rend, a bleed, on the enemy under your mouse, else your target. Battle or Defensive Stance.",
          { "Rend" }, [[
#showtooltip Rend
/cast [@mouseover,harm,nodead][] Rend]]),
        M("Hamstring", "Hamstring on mouseover or target",
          "Uses Hamstring on the enemy under your mouse, else your target, slowing them. Battle or Berserker Stance.",
          { "Hamstring" }, [[
#showtooltip Hamstring
/cast [@mouseover,harm,nodead][] Hamstring]]),
        M("Interrupt", "Pummel in Berserker Stance, else Shield Bash",
          "Interrupts the enemy under your mouse, else your target: Pummel in Berserker Stance (level 38), Shield Bash in Battle or Defensive Stance (needs a shield).",
          { "Shield Bash" }, [[
#showtooltip
/cast [stance:3,@mouseover,harm,nodead][stance:3] Pummel; [@mouseover,harm,nodead][] Shield Bash]]),
        M("Overpower", "Overpower, switching to Battle Stance if needed",
          "Uses Overpower after your target dodges. Outside Battle Stance it switches you to Battle Stance first (Tactical Mastery keeps some Rage); press again to strike.",
          { "Overpower", "Battle Stance" }, [[
#showtooltip Overpower
/cast [nostance:1] Battle Stance; Overpower]]),
        M("Execute", "Execute on a target under 20% health",
          "Uses Execute, which only works on enemies at 20% health or less, in Battle or Berserker Stance.",
          { "Execute" }, [[
#showtooltip Execute
/cast Execute]]),
        M("Taunt", "Taunt, switching to Defensive Stance if needed",
          "Taunts the enemy under your mouse, else your target. Outside Defensive Stance it switches you to Defensive Stance first; press again to taunt.",
          { "Taunt", "Defensive Stance" }, [[
#showtooltip Taunt
/cast [nostance:2] Defensive Stance; [@mouseover,harm,nodead][] Taunt]]),
        M("Shout", "Battle Shout; Shift for Demoralizing Shout",
          "Uses Battle Shout on your party. Hold Shift for Demoralizing Shout instead (level 14), which weakens nearby enemies.",
          { "Battle Shout" }, [[
#showtooltip
/cast [mod:shift] Demoralizing Shout; Battle Shout]]),
    },
    order = { 71, 72, 73 },
    names = { [71] = "Arms", [72] = "Fury", [73] = "Protection" },
    treeSpells = {
        [71] = { "Mortal Strike", "Sweeping Strikes", "Spearing Strike" },
        [72] = { "Bloodthirst", "Death Wish", "Reckless Swings", "Piercing Howl" },
        [73] = { "Shield Slam", "Concussion Blow", "Last Stand" },
    },
    specs = {
        [71] = {
            M("Mortal Strike", "Starts attacking and uses Mortal Strike",
              "Turns on your auto-attack and uses Mortal Strike, which also cuts healing on the target by 50%.",
              { "Mortal Strike" }, [[
#showtooltip Mortal Strike
/startattack
/cast Mortal Strike]]),
            M("Sweeping", "Sweeping Strikes",
              "Uses Sweeping Strikes: your next 5 melee attacks also hit a nearby enemy.",
              { "Sweeping Strikes" }, [[
#showtooltip Sweeping Strikes
/cast Sweeping Strikes]]),
            M("Spearing", "Spearing Strike on mouseover or target",
              "Uses Spearing Strike, new in Forever, on the enemy under your mouse, else your target. It hits harder against giants, dragonkin and riders, and knocks riders off their mounts. Battle Stance.",
              { "Spearing Strike" }, [[
#showtooltip Spearing Strike
/cast [@mouseover,harm,nodead][] Spearing Strike]]),
        },
        [72] = {
            M("Bloodthirst", "Starts attacking and uses Bloodthirst",
              "Turns on your auto-attack and uses Bloodthirst. In Forever it no longer heals; it gives you 10% move speed for 10 seconds. 6 second cooldown.",
              { "Bloodthirst" }, [[
#showtooltip Bloodthirst
/startattack
/cast Bloodthirst]]),
            M("Death Wish", "Death Wish",
              "Uses Death Wish: more physical damage and immunity to fear for 30 seconds, but you take a little more damage.",
              { "Death Wish" }, [[
#showtooltip Death Wish
/cast Death Wish]]),
            M("Whirlwind", "Whirlwind, switching to Berserker Stance if needed",
              "Uses Whirlwind, which in Forever swings both weapons at up to 4 enemies. Outside Berserker Stance it switches you to Berserker Stance first; press again to spin.",
              { "Whirlwind", "Berserker Stance" }, [[
#showtooltip Whirlwind
/cast [nostance:3] Berserker Stance; Whirlwind]]),
        },
        [73] = {
            M("Shield Slam", "Starts attacking and uses Shield Slam",
              "Turns on your auto-attack and uses Shield Slam (needs a shield), which can also strip a magic effect from the target.",
              { "Shield Slam" }, [[
#showtooltip Shield Slam
/startattack
/cast Shield Slam]]),
            M("Revenge", "Revenge, switching to Defensive Stance if needed",
              "Uses Revenge after you block, dodge or parry. Outside Defensive Stance it switches you to Defensive Stance first.",
              { "Revenge", "Defensive Stance" }, [[
#showtooltip Revenge
/cast [nostance:2] Defensive Stance; Revenge]]),
            M("Shield Block", "Shield Block, switching to Defensive Stance if needed",
              "Uses Shield Block: in Forever it blocks your next 2 hits within 7 seconds. Outside Defensive Stance it switches you to Defensive Stance first.",
              { "Shield Block", "Defensive Stance" }, [[
#showtooltip Shield Block
/cast [nostance:2] Defensive Stance; Shield Block]]),
            M("Last Stand", "Last Stand",
              "Uses Last Stand: 30% more maximum health for 20 seconds. In Forever its cooldown is 3 minutes.",
              { "Last Stand" }, [[
#showtooltip Last Stand
/cast Last Stand]]),
        },
    },
}

-- Rogue: trees Assassination, Combat, Subtlety.
ns.SETS.ROGUE = {
    shared = {
        M("Opener", "Ambush from stealth, else Sinister Strike",
          "Uses Ambush while you are in stealth (level 18, from behind, with a dagger), otherwise Sinister Strike, so one button opens and then keeps building combo points.",
          { "Sinister Strike" }, [[
#showtooltip
/cast [stealth] Ambush; Sinister Strike]]),
        M("Stun", "Cheap Shot from stealth, else Kidney Shot",
          "Uses Cheap Shot while you are in stealth, otherwise Kidney Shot (a finisher, level 30).",
          { "Cheap Shot" }, [[
#showtooltip
/cast [stealth] Cheap Shot; Kidney Shot]]),
        M("Interrupt", "Kick on mouseover or target",
          "Uses Kick on the enemy under your mouse, else your target, to interrupt a spell.",
          { "Kick" }, [[
#showtooltip Kick
/cast [@mouseover,harm,nodead][] Kick]]),
        M("Stealth", "Stealth, without leaving it",
          "Enters stealth. The ! stops a second press from taking you out of it.",
          { "Stealth" }, [[
#showtooltip Stealth
/cast !Stealth]]),
        M("Sap", "Sap on mouseover or target",
          "Saps the humanoid under your mouse, else your target. In Forever Sap no longer takes you out of stealth.",
          { "Sap" }, [[
#showtooltip Sap
/cast [@mouseover,harm,nodead][] Sap]]),
        M("Finisher", "Eviscerate; Shift for Slice and Dice",
          "Spends your combo points on Eviscerate. Hold Shift for Slice and Dice instead (level 10).",
          { "Eviscerate" }, [[
#showtooltip
/cast [mod:shift] Slice and Dice; Eviscerate]]),
        M("Shank", "Starts attacking and uses Shank",
          "Turns on your auto-attack and uses Shank, new in Forever: a cheap off-hand stab that gives you Energy back and cannot miss. 10 second cooldown.",
          { "Shank" }, [[
#showtooltip Shank
/startattack
/cast Shank]]),
        M("Blind", "Blind on mouseover or target",
          "Uses Blind on the enemy under your mouse, else your target. Needs Blinding Powder.",
          { "Blind" }, [[
#showtooltip Blind
/cast [@mouseover,harm,nodead][] Blind]]),
    },
    order = { 259, 260, 261 },
    names = { [259] = "Assassination", [260] = "Combat", [261] = "Subtlety" },
    treeSpells = {
        [259] = { "Mutilate", "Cold Blood" },
        [260] = { "Adrenaline Rush", "Blade Flurry", "Riposte" },
        [261] = { "Death Mark", "Ghostly Strike", "Hemorrhage", "Preparation", "Premeditation" },
    },
    specs = {
        [259] = {
            M("Mutilate", "Starts attacking and uses Mutilate",
              "Turns on your auto-attack and uses Mutilate, new in Forever: a strike with both daggers for 2 combo points, harder on poisoned targets.",
              { "Mutilate" }, [[
#showtooltip Mutilate
/startattack
/cast Mutilate]]),
            M("Cold Eviscerate", "Cold Blood, then Eviscerate",
              "Uses Cold Blood (no global cooldown) so your next finisher is a sure critical, then Eviscerate.",
              { "Cold Blood", "Eviscerate" }, [[
#showtooltip Cold Blood
/cast Cold Blood
/cast Eviscerate]]),
        },
        [260] = {
            M("Burst", "Blade Flurry and Adrenaline Rush together",
              "Uses Blade Flurry (faster attacks that also hit a second enemy) and Adrenaline Rush (once you have it, double Energy regeneration) in one press.",
              { "Blade Flurry" }, [[
#showtooltip Blade Flurry
/cast Blade Flurry
/cast Adrenaline Rush]]),
            M("Riposte", "Riposte after a parry",
              "Uses Riposte, which becomes usable after you parry: a heavy hit that also disarms the target.",
              { "Riposte" }, [[
#showtooltip Riposte
/cast Riposte]]),
        },
        [261] = {
            M("Hemorrhage", "Starts attacking and uses Hemorrhage",
              "Turns on your auto-attack and uses Hemorrhage, which also makes your Rupture and Garrote on the target hit harder for 15 seconds.",
              { "Hemorrhage" }, [[
#showtooltip Hemorrhage
/startattack
/cast Hemorrhage]]),
            M("Ghostly Strike", "Starts attacking and uses Ghostly Strike",
              "Turns on your auto-attack and uses Ghostly Strike: damage, more dodge, and your next Ambush or Garrote within 7 seconds works out of stealth.",
              { "Ghostly Strike" }, [[
#showtooltip Ghostly Strike
/startattack
/cast Ghostly Strike]]),
            M("Premeditation", "Premeditation for 2 combo points",
              "Uses Premeditation for 2 combo points on your target. In Forever it no longer needs stealth.",
              { "Premeditation" }, [[
#showtooltip Premeditation
/cast Premeditation]]),
            M("Death Mark", "Death Mark on mouseover or target",
              "Uses Death Mark, new in Forever, on the enemy under your mouse, else your target: a finisher that stores part of your damage and releases it after 6 seconds.",
              { "Death Mark" }, [[
#showtooltip Death Mark
/cast [@mouseover,harm,nodead][] Death Mark]]),
        },
    },
}

-- Hunter: trees Beast Mastery, Marksmanship, Survival.
ns.SETS.HUNTER = {
    shared = {
        M("Mark", "Hunter's Mark on mouseover or target",
          "Puts Hunter's Mark on the enemy under your mouse, else your target.",
          { "Hunter's Mark" }, [[
#showtooltip Hunter's Mark
/cast [@mouseover,harm,nodead][] Hunter's Mark]]),
        M("Sting", "Serpent Sting; Shift for Scorpid Sting",
          "Uses Serpent Sting on the enemy under your mouse, else your target. Hold Shift for Scorpid Sting instead (level 22).",
          { "Serpent Sting" }, [[
#showtooltip
/cast [mod:shift,@mouseover,harm,nodead][mod:shift] Scorpid Sting; [@mouseover,harm,nodead][] Serpent Sting]]),
        M("Arcane Shot", "Arcane Shot on mouseover or target",
          "Uses Arcane Shot on the enemy under your mouse, else your target. In Forever it shares a 6 second cooldown with Summon Hawk.",
          { "Arcane Shot" }, [[
#showtooltip Arcane Shot
/cast [@mouseover,harm,nodead][] Arcane Shot]]),
        M("Aimed Shot", "Aimed Shot on mouseover or target",
          "Uses Aimed Shot, trained by every hunter in Forever (level 20), on the enemy under your mouse, else your target. It shares a 6 second cooldown with Multi-Shot, and your Auto Shot keeps firing while you cast it.",
          { "Aimed Shot" }, [[
#showtooltip Aimed Shot
/cast [@mouseover,harm,nodead][] Aimed Shot]]),
        M("Multi-Shot", "Multi-Shot on mouseover or target",
          "Uses Multi-Shot on the enemy under your mouse, else your target, hitting enemies around it.",
          { "Multi-Shot" }, [[
#showtooltip Multi-Shot
/cast [@mouseover,harm,nodead][] Multi-Shot]]),
        M("Concussive", "Concussive Shot on mouseover or target",
          "Uses Concussive Shot on the enemy under your mouse, else your target, slowing them.",
          { "Concussive Shot" }, [[
#showtooltip Concussive Shot
/cast [@mouseover,harm,nodead][] Concussive Shot]]),
        M("Pet", "Calls, revives or heals your pet",
          "One button for your pet: calls it if it is not out, revives it if it is dead, otherwise heals it with Mend Pet. If Forever names Call Pet after your pet, this macro will wait for that spell; please report it.",
          { "Call Pet" }, [[
#showtooltip
/cast [nopet] Call Pet; [@pet,dead] Revive Pet; Mend Pet]]),
        M("Trap", "Freezing Trap; Shift for Frost, Ctrl for Explosive",
          "Places Freezing Trap. Hold Shift for Frost Trap or Ctrl for Explosive Trap. In Forever traps can be placed in combat and all share one 30 second cooldown.",
          { "Freezing Trap" }, [[
#showtooltip
/cast [mod:ctrl] Explosive Trap; [mod:shift] Frost Trap; Freezing Trap]]),
        M("Melee", "Raptor Strike; Shift for Wing Clip",
          "Starts attacking and uses Raptor Strike for when an enemy reaches you. Hold Shift for Wing Clip instead (level 12) to slow them so you can step away.",
          { "Raptor Strike" }, [[
#showtooltip
/startattack
/cast [mod:shift] Wing Clip; Raptor Strike]]),
        M("Aspect", "Hawk; Shift for Cheetah, Ctrl for Monkey",
          "Uses Aspect of the Hawk. Hold Shift for Aspect of the Cheetah (level 20) or Ctrl for Aspect of the Monkey.",
          { "Aspect of the Hawk" }, [[
#showtooltip
/cast [mod:ctrl] Aspect of the Monkey; [mod:shift] Aspect of the Cheetah; Aspect of the Hawk]]),
        M("Lacerate", "Lacerate on mouseover or target",
          "Uses Lacerate, a melee bleed new for hunters in Forever (level 30), on the enemy under your mouse, else your target.",
          { "Lacerate" }, [[
#showtooltip Lacerate
/cast [@mouseover,harm,nodead][] Lacerate]]),
    },
    order = { 253, 254, 255 },
    names = { [253] = "Beast Mastery", [254] = "Marksmanship", [255] = "Survival" },
    treeSpells = {
        [253] = { "Bestial Wrath", "Intimidation", "Summon Hawk" },
        [254] = { "Sniper Shot", "Scatter Shot", "Trueshot Aura" },
        [255] = { "Strider Kick", "Counterattack", "Deterrence" },
    },
    specs = {
        [253] = {
            M("Bestial Wrath", "Bestial Wrath and send the pet in",
              "Uses Bestial Wrath (your pet does 50% more damage for 18 seconds) and sends your pet to attack your target.",
              { "Bestial Wrath" }, [[
#showtooltip Bestial Wrath
/cast Bestial Wrath
/petattack]]),
            M("Intimidation", "Intimidation",
              "Uses Intimidation: your pet's next hit stuns the target for 3 seconds.",
              { "Intimidation" }, [[
#showtooltip Intimidation
/cast Intimidation]]),
            M("Hawk", "Summon Hawk on mouseover or target",
              "Uses Summon Hawk, new in Forever, on the enemy under your mouse, else your target: a hawk dives at it and keeps attacking for 18 seconds. Shares a cooldown with Arcane Shot.",
              { "Summon Hawk" }, [[
#showtooltip Summon Hawk
/cast [@mouseover,harm,nodead][] Summon Hawk]]),
        },
        [254] = {
            M("Scatter Shot", "Scatter Shot on mouseover or target",
              "Uses Scatter Shot on the enemy under your mouse, else your target, disorienting it for 4 seconds.",
              { "Scatter Shot" }, [[
#showtooltip Scatter Shot
/cast [@mouseover,harm,nodead][] Scatter Shot]]),
            M("Sniper Shot", "Sniper Shot on mouseover or target",
              "Uses Sniper Shot, new in Forever, on the enemy under your mouse, else your target: a long-range shot that also extends the range of your next 3 shots.",
              { "Sniper Shot" }, [[
#showtooltip Sniper Shot
/cast [@mouseover,harm,nodead][] Sniper Shot]]),
        },
        [255] = {
            M("Deterrence", "Deterrence",
              "Uses Deterrence: much more dodge and parry for 10 seconds.",
              { "Deterrence" }, [[
#showtooltip Deterrence
/cast Deterrence]]),
            M("Counterattack", "Counterattack after a parry",
              "Uses Counterattack, which becomes usable after you parry, rooting the enemy in place.",
              { "Counterattack" }, [[
#showtooltip Counterattack
/cast Counterattack]]),
            M("Strider Kick", "Starts attacking and uses Strider Kick",
              "Turns on your auto-attack and uses Strider Kick, new in Forever: a melee hit that makes you 30% faster for 3 seconds, to get back to range.",
              { "Strider Kick" }, [[
#showtooltip Strider Kick
/startattack
/cast Strider Kick]]),
        },
    },
}

-- Mage: trees Arcane, Fire, Frost.
ns.SETS.MAGE = {
    shared = {
        M("Sheep", "Polymorph on mouseover or target; Shift for focus",
          "Polymorphs the enemy under your mouse, else your target. Hold Shift to polymorph your focus target instead, so you can keep them asleep while fighting something else.",
          { "Polymorph" }, [[
#showtooltip Polymorph
/cast [mod:shift,@focus,harm,nodead] Polymorph; [@mouseover,harm,nodead][] Polymorph]]),
        M("Counterspell", "Counterspell on mouseover or target",
          "Uses Counterspell on the enemy under your mouse, else your target, to interrupt a spell.",
          { "Counterspell" }, [[
#showtooltip Counterspell
/cast [@mouseover,harm,nodead][] Counterspell]]),
        M("Decurse", "Remove Lesser Curse on a mouseover friend, target or you",
          "Casts Remove Lesser Curse on the friend under your mouse, else your friendly target, else you. In Forever it removes Banes too.",
          { "Remove Lesser Curse" }, [[
#showtooltip Remove Lesser Curse
/cast [@mouseover,help,nodead][help,nodead][@player] Remove Lesser Curse]]),
        M("Intellect", "Arcane Intellect; Shift for Arcane Brilliance",
          "Casts Arcane Intellect on the friend under your mouse, else your friendly target, else you; it lasts an hour in Forever. Hold Shift for Arcane Brilliance on the whole group once you have it (level 56).",
          { "Arcane Intellect" }, [[
#showtooltip
/cast [mod:shift] Arcane Brilliance; [@mouseover,help,nodead][help,nodead][@player] Arcane Intellect]]),
        M("Conjure", "Conjure Water; Shift for food",
          "Conjures water. Hold Shift to conjure food instead.",
          { "Conjure Water" }, [[
#showtooltip
/cast [mod:shift] Conjure Food; Conjure Water]]),
        M("Fire Blast", "Fire Blast on mouseover or target",
          "Uses Fire Blast, your instant fire spell, on the enemy under your mouse, else your target.",
          { "Fire Blast" }, [[
#showtooltip Fire Blast
/cast [@mouseover,harm,nodead][] Fire Blast]]),
        M("Slow Fall", "Slow Fall on a mouseover friend, target or you",
          "Casts Slow Fall on the friend under your mouse, else your friendly target, else you.",
          { "Slow Fall" }, [[
#showtooltip Slow Fall
/cast [@mouseover,help,nodead][help,nodead][@player] Slow Fall]]),
        M("Frostfire", "Frostfire Bolt on mouseover or target",
          "Casts Frostfire Bolt, new in Forever (level 40), on the enemy under your mouse, else your target. It counts as both Fire and Frost, slows the target and burns over 9 seconds.",
          { "Frostfire Bolt" }, [[
#showtooltip Frostfire Bolt
/cast [@mouseover,harm,nodead][] Frostfire Bolt]]),
    },
    order = { 62, 63, 64 },
    names = { [62] = "Arcane", [63] = "Fire", [64] = "Frost" },
    treeSpells = {
        [62] = { "Arcane Blast", "Arcane Wrath", "Presence of Mind", "Arcane Power" },
        [63] = { "Pyroblast", "Blast Wave", "Combustion" },
        [64] = { "Ice Lance", "Ice Block", "Cold Snap", "Ice Barrier" },
    },
    specs = {
        [62] = {
            M("Arcane Blast", "Arcane Blast on mouseover or target",
              "Casts Arcane Blast, new in Forever, on the enemy under your mouse, else your target. Each cast stacks up to 4 times, raising its damage and its mana cost.",
              { "Arcane Blast" }, [[
#showtooltip Arcane Blast
/cast [@mouseover,harm,nodead][] Arcane Blast]]),
            M("Burst", "Arcane Power and Presence of Mind together",
              "Uses Arcane Power (30% more spell damage for 15 seconds) and, once you have it, Presence of Mind (your next spell is instant) in one press.",
              { "Arcane Power" }, [[
#showtooltip Arcane Power
/cast Arcane Power
/cast Presence of Mind]]),
            M("Quick Blast", "Presence of Mind, then an instant Arcane Blast",
              "Uses Presence of Mind so your next spell is instant, then Arcane Blast on the enemy under your mouse, else your target.",
              { "Presence of Mind", "Arcane Blast" }, [[
#showtooltip Presence of Mind
/cast Presence of Mind
/cast [@mouseover,harm,nodead][] Arcane Blast]]),
        },
        [63] = {
            M("Pyroblast", "Pyroblast on mouseover or target",
              "Casts Pyroblast on the enemy under your mouse, else your target.",
              { "Pyroblast" }, [[
#showtooltip Pyroblast
/cast [@mouseover,harm,nodead][] Pyroblast]]),
            M("Combustion", "Combustion",
              "Uses Combustion, raising your fire critical strike chance.",
              { "Combustion" }, [[
#showtooltip Combustion
/cast Combustion]]),
            M("Blast Wave", "Blast Wave",
              "Uses Blast Wave: fire damage to enemies around you, slowing them by 50% for 6 seconds.",
              { "Blast Wave" }, [[
#showtooltip Blast Wave
/cast Blast Wave]]),
        },
        [64] = {
            M("Ice Lance", "Ice Lance on mouseover or target",
              "Casts Ice Lance, new in Forever, on the enemy under your mouse, else your target. It does triple damage to frozen targets; 8 second cooldown.",
              { "Ice Lance" }, [[
#showtooltip Ice Lance
/cast [@mouseover,harm,nodead][] Ice Lance]]),
            M("Ice Block", "Ice Block; press again to leave it",
              "Uses Ice Block: immune to everything for 10 seconds. Pressing it again while you are in the block takes you out of it early.",
              { "Ice Block" }, [[
#showtooltip Ice Block
/cancelaura Ice Block
/cast Ice Block]]),
            M("Ice Barrier", "Ice Barrier",
              "Uses Ice Barrier, a shield that absorbs damage for up to a minute.",
              { "Ice Barrier" }, [[
#showtooltip Ice Barrier
/cast Ice Barrier]]),
        },
    },
}

-- Warlock: trees Affliction, Demonology, Destruction.
ns.SETS.WARLOCK = {
    shared = {
        M("Corruption", "Corruption on mouseover or target",
          "Casts Corruption on the enemy under your mouse, else your target, so you can spread it without changing target.",
          { "Corruption" }, [[
#showtooltip Corruption
/cast [@mouseover,harm,nodead][] Corruption]]),
        M("Agony", "Bane of Agony on mouseover or target",
          "Casts Bane of Agony (Forever's new name for Curse of Agony) on the enemy under your mouse, else your target. In Forever you can keep one Bane and one Curse on the same target.",
          { "Bane of Agony" }, [[
#showtooltip Bane of Agony
/cast [@mouseover,harm,nodead][] Bane of Agony]]),
        M("Curse", "Curse of Weakness; Shift for Elements, Ctrl for Tongues",
          "Casts Curse of Weakness on the enemy under your mouse, else your target. Hold Shift for Curse of the Elements (level 20) or Ctrl for Curse of Tongues (level 26).",
          { "Curse of Weakness" }, [[
#showtooltip
/cast [mod:ctrl,@mouseover,harm,nodead][mod:ctrl] Curse of Tongues; [mod:shift,@mouseover,harm,nodead][mod:shift] Curse of the Elements; [@mouseover,harm,nodead][] Curse of Weakness]]),
        M("Immolate", "Immolate on mouseover or target",
          "Casts Immolate on the enemy under your mouse, else your target.",
          { "Immolate" }, [[
#showtooltip Immolate
/cast [@mouseover,harm,nodead][] Immolate]]),
        M("Fear", "Fear on mouseover or target",
          "Casts Fear on the enemy under your mouse, else your target.",
          { "Fear" }, [[
#showtooltip Fear
/cast [@mouseover,harm,nodead][] Fear]]),
        M("Banish", "Banish on mouseover or target",
          "Banishes the demon or elemental under your mouse, else your target.",
          { "Banish" }, [[
#showtooltip Banish
/cast [@mouseover,harm,nodead][] Banish]]),
        M("Drain", "Drain Soul; Shift for Drain Life",
          "Channels Drain Soul on your target, which can give you Soul Shards. Hold Shift for Drain Life instead (level 14).",
          { "Drain Soul" }, [[
#showtooltip
/cast [mod:shift] Drain Life; Drain Soul]]),
        M("Death Coil", "Death Coil on mouseover or target",
          "Casts Death Coil on the enemy under your mouse, else your target: it horrifies them and heals you.",
          { "Death Coil" }, [[
#showtooltip Death Coil
/cast [@mouseover,harm,nodead][] Death Coil]]),
    },
    order = { 265, 266, 267 },
    names = { [265] = "Affliction", [266] = "Demonology", [267] = "Destruction" },
    treeSpells = {
        [265] = { "Wrack", "Siphon Life", "Curse of Exhaustion", "Amplify Curse" },
        [266] = { "Soul Link", "Fel Domination", "Demonic Sacrifice" },
        [267] = { "Incinerate", "Bane of Havoc", "Conflagrate", "Shadowburn" },
    },
    specs = {
        [265] = {
            M("Siphon Life", "Siphon Life on mouseover or target",
              "Casts Siphon Life on the enemy under your mouse, else your target, draining their health to you.",
              { "Siphon Life" }, [[
#showtooltip Siphon Life
/cast [@mouseover,harm,nodead][] Siphon Life]]),
            M("Exhaustion", "Curse of Exhaustion on mouseover or target",
              "Casts Curse of Exhaustion on the enemy under your mouse, else your target, slowing them by 30%.",
              { "Curse of Exhaustion" }, [[
#showtooltip Curse of Exhaustion
/cast [@mouseover,harm,nodead][] Curse of Exhaustion]]),
            M("Big Agony", "Amplify Curse, then Bane of Agony",
              "Uses Amplify Curse, then Bane of Agony on the enemy under your mouse, else your target, so the Bane hits harder.",
              { "Amplify Curse", "Bane of Agony" }, [[
#showtooltip Amplify Curse
/cast Amplify Curse
/cast [@mouseover,harm,nodead][] Bane of Agony]]),
            M("Wrack", "Wrack on mouseover or target",
              "Casts Wrack, new in Forever, on the enemy under your mouse, else your target: damage over time that also makes your other shadow effects on them 10% stronger.",
              { "Wrack" }, [[
#showtooltip Wrack
/cast [@mouseover,harm,nodead][] Wrack]]),
        },
        [266] = {
            M("Quick Demon", "Fel Domination, then a demon; Shift Succubus, Ctrl Felhunter",
              "Uses Fel Domination so your next demon summon is fast, then summons your Voidwalker. Hold Shift for the Succubus or Ctrl for the Felhunter instead.",
              { "Fel Domination", "Summon Voidwalker" }, [[
#showtooltip Fel Domination
/cast Fel Domination
/cast [mod:ctrl] Summon Felhunter; [mod:shift] Summon Succubus; Summon Voidwalker]]),
            M("Sacrifice", "Demonic Sacrifice",
              "Uses Demonic Sacrifice: sacrifices your demon for a bonus that depends on which demon it was.",
              { "Demonic Sacrifice" }, [[
#showtooltip Demonic Sacrifice
/cast Demonic Sacrifice]]),
            M("Soul Link", "Soul Link",
              "Uses Soul Link, sharing the damage you take with your demon.",
              { "Soul Link" }, [[
#showtooltip Soul Link
/cast Soul Link]]),
        },
        [267] = {
            M("Conflagrate", "Conflagrate on mouseover or target",
              "Uses Conflagrate on the enemy under your mouse, else your target. It needs your Immolate on them, which it uses up.",
              { "Conflagrate" }, [[
#showtooltip Conflagrate
/cast [@mouseover,harm,nodead][] Conflagrate]]),
            M("Shadowburn", "Shadowburn on mouseover or target",
              "Uses Shadowburn on the enemy under your mouse, else your target. In Forever you get the Soul Shard back.",
              { "Shadowburn" }, [[
#showtooltip Shadowburn
/cast [@mouseover,harm,nodead][] Shadowburn]]),
            M("Havoc", "Bane of Havoc on mouseover or target",
              "Casts Bane of Havoc, new in Forever, on the enemy under your mouse, else your target: 15% of the damage you do to others is copied to it. Put it on a second enemy.",
              { "Bane of Havoc" }, [[
#showtooltip Bane of Havoc
/cast [@mouseover,harm,nodead][] Bane of Havoc]]),
            M("Incinerate", "Incinerate on mouseover or target",
              "Casts Incinerate, new in Forever, on the enemy under your mouse, else your target. It hits harder if your Immolate is on them.",
              { "Incinerate" }, [[
#showtooltip Incinerate
/cast [@mouseover,harm,nodead][] Incinerate]]),
        },
    },
}
