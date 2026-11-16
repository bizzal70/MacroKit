-- 0.8.0: attack macros also start auto-attack, so a press with no rage,
-- energy or mana still starts swinging. Crowd control that breaks on damage
-- is left alone; hunters' shots start Auto Shot; stealth openers only once
-- out of stealth. Macros already added are brought up to date unless the
-- player changed them.
EditMacro = function(index, name, icon, body)
    assert(not IN_COMBAT, "EditMacro in combat")
    MACROS[index].body = body
end

local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end

local function Find(class, name)
    local set = ns.SETS[class]
    for _, macro in ipairs(set.shared or {}) do if macro.name == name then return macro end end
    for _, list in pairs(set.specs or {}) do
        for _, macro in ipairs(list) do if macro.name == name then return macro end end
    end
end
local function Has(body, text) return body:find(text, 1, true) ~= nil end

-- What the macros say.
check(Has(Find("WARRIOR", "Strike").body, "/startattack [harm,nodead]"), "Heroic Strike starts auto-attack")
local fireBlast = Find("MAGE", "Fire Blast").body
check(Has(fireBlast, "/startattack [harm,nodead,noequipped:Wands]") and fireBlast:sub(-#"/cast [harm,nodead,equipped:Wands] !Shoot") == "/cast [harm,nodead,equipped:Wands] !Shoot",
    "a caster's attack shoots the wand when one is equipped, else swings")
for _, class in ipairs({ "WARRIOR", "ROGUE", "HUNTER", "PALADIN", "SHAMAN", "DRUID" }) do
    for _, list in pairs({ ns.SETS[class].shared, unpack((function() local t = {} for _, l in pairs(ns.SETS[class].specs or {}) do t[#t + 1] = l end return t end)()) }) do
        for _, macro in ipairs(list or {}) do check(not Has(macro.body, "Shoot") or Has(macro.body, "Shot"), class .. " " .. macro.name .. " has no wand line") end
    end
end
for _, cast in ipairs({ { "PRIEST", "Mind Blast" }, { "PRIEST", "Smite" }, { "PRIEST", "Mind Flay" }, { "MAGE", "Frostfire" },
        { "MAGE", "Pyroblast" }, { "WARLOCK", "Immolate" }, { "WARLOCK", "Drain" }, { "WARLOCK", "Corruption" } }) do
    check(not Has(Find(cast[1], cast[2]).body, "Shoot"), cast[2] .. " (cast time or channel) does not start the wand, which would cancel it")
end
for _, instant in ipairs({ { "PRIEST", "SW: Pain" }, { "PRIEST", "SW: Death" }, { "MAGE", "Fire Blast" }, { "MAGE", "Ice Lance" },
        { "WARLOCK", "Agony" }, { "WARLOCK", "Death Coil" }, { "WARLOCK", "Conflagrate" } }) do
    check(Has(Find(instant[1], instant[2]).body, "!Shoot"), instant[2] .. " (instant) starts the wand after the spell")
end
check(not Has(Find("WARLOCK", "Curse").body, "/startattack") and Has(Find("WARLOCK", "Curse").body, "!Shoot"),
    "the warlock's long Curse macro keeps the wand line and drops the melee one, to fit 255 characters")
check(Has(Find("HUNTER", "Arcane Shot").body, "/startattack [harm,nodead]") and not Has(Find("HUNTER", "Arcane Shot").body, "Auto Shot"),
    "a hunter's shot uses /startattack too (Forever, like the current game, starts Auto Shot with it)")
check(Has(Find("ROGUE", "Opener").body, "/startattack [nostealth,harm,nodead]"), "a stealth opener only starts attacking out of stealth")
for _, cc in ipairs({ { "ROGUE", "Sap" }, { "ROGUE", "Blind" }, { "MAGE", "Sheep" }, { "PALADIN", "Repent" },
        { "DRUID", "Hibernate" }, { "DRUID", "Roots" }, { "WARLOCK", "Fear" }, { "WARLOCK", "Banish" },
        { "PRIEST", "Shackle" }, { "HUNTER", "Scatter Shot" } }) do
    local body = Find(cc[1], cc[2]).body
    check(not Has(body, "/startattack") and not Has(body, "Auto Shot"), cc[2] .. " (breaks on damage) does not start attacking")
end
check(not Has(Find("PALADIN", "Heal").body, "/startattack"), "heals do not start attacking")
local count = 0
for class, set in pairs(ns.SETS) do
    local function Each(list)
        for _, macro in ipairs(list or {}) do
            check(#macro.body <= ns.MAX_BODY, class .. " " .. macro.name .. " still fits the game's macro size")
            if Has(macro.body, "/startattack [") or Has(macro.body, "!Shoot") then count = count + 1 end
        end
    end
    Each(set.shared)
    for _, list in pairs(set.specs or {}) do Each(list) end
end
check(count == 74, "74 attack macros start auto-attack (" .. count .. ")")
check(Find("PRIEST", "Mind Blast") and Has(Find("PRIEST", "Mind Blast").body, "/startattack [harm,nodead,noequipped:Wands]"), "every priest has Mind Blast, starting auto-attack")
for _, id in ipairs({ 256, 257 }) do
    local found
    for _, macro in ipairs(ns.SETS.PRIEST.specs[id]) do if macro.name == "Holy Fire" then found = macro end end
    check(found and Has(found.body, "[@mouseover,harm,nodead][] Holy Fire"), "spec " .. id .. " (Discipline, Holy) has Holy Fire")
end
for _, macro in ipairs(ns.SETS.PRIEST.specs[258]) do check(macro.name ~= "Holy Fire", "Shadow does not get Holy Fire (" .. macro.name .. ")") end
check(Find("PRIEST", "Smite") and Has(Find("PRIEST", "Smite").body, "/startattack [harm,nodead,noequipped:Wands]") and Has(Find("PRIEST", "Smite").body, "[@mouseover,harm,nodead][] Smite"), "priests have a Smite macro, on mouseover or target, that starts auto-attack")
for _, id in ipairs(ns.SETS.PRIEST.order) do
    check(#ns.SETS.PRIEST.shared + #(ns.SETS.PRIEST.specs[id] or {}) <= 18, "a priest's shared and spec macros still fit in 18 slots (spec " .. id .. ")")
end

-- Macros already in the list.
SPEC = nil
Learn("Hammer of Justice", "Holy Light", "Holy Strike")
local stun = Find("PALADIN", "Stun")
local oldStun = stun.body:gsub("/startattack %[harm,nodead%]\n", "")
CreateMacro("Stun", 1, oldStun, true)                       -- added by MacroKit 0.7
CreateMacro("Heal", 1, "/say my own heal", true)            -- the player's own
Fire("ADDON_LOADED", "MacroKit")
ns.char.made.Stun = true
local mine = Find("PALADIN", "Exorcism")
CreateMacro("Exorcism", 1, "#showtooltip\n/cast Exorcism\n/say changed by me", true)
ns.char.made.Exorcism = true
local updated = ns.UpgradeMacros()
local function BodyOf(name) return MACROS[GetMacroIndexByName(name)].body end
check(BodyOf("Stun") == stun.body, "a macro MacroKit added before is brought up to date")
check(BodyOf("Exorcism") == "#showtooltip\n/cast Exorcism\n/say changed by me", "one the player changed is left alone")
check(BodyOf("Heal") == "/say my own heal", "and one the player made is never touched")
check(#updated == 1 and updated[1] == "Stun", "only the untouched one is updated")
check(table.concat(PRINTED, " | "):find("so they also start your auto-attack: Stun", 1, true), "and it says so in chat")
check(#ns.UpgradeMacros() == 0, "a second look changes nothing")
IN_COMBAT = true
check(#ns.UpgradeMacros() == 0, "nothing is changed in combat")
IN_COMBAT = false

-- A hunter's shot already updated by 0.8.0 (with !Auto Shot at the end)
-- is switched to /startattack.
CLASS = "HUNTER"
local arcane = Find("HUNTER", "Arcane Shot")
local shot080 = "#showtooltip Arcane Shot\n/cast [@mouseover,harm,nodead][] Arcane Shot\n/cast [harm,nodead] !Auto Shot"
CreateMacro("Arcane Shot", 1, shot080, true)
ns.char.made["Arcane Shot"] = true
ns.UpgradeMacros()
check(BodyOf("Arcane Shot") == arcane.body, "a hunter macro from 0.8.0 is switched from !Auto Shot to /startattack")
CLASS = "PALADIN"

-- A caster macro from 0.8/0.9 (plain /startattack) gets the wand lines.
CLASS = "MAGE"
local fb = Find("MAGE", "Fire Blast")
CreateMacro("Fire Blast", 1, "#showtooltip Fire Blast\n/startattack [harm,nodead]\n/cast [@mouseover,harm,nodead][] Fire Blast", true)
ns.char.made["Fire Blast"] = true
ns.UpgradeMacros()
check(BodyOf("Fire Blast") == fb.body, "a caster macro from 0.9 is switched to the wand lines")
CLASS = "PALADIN"
