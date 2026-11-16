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
check(Has(Find("MAGE", "Fire Blast").body, "/startattack [harm,nodead]"), "a caster's attack starts auto-attack too")
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
            if Has(macro.body, "/startattack [") or Has(macro.body, "!Auto Shot") then count = count + 1 end
        end
    end
    Each(set.shared)
    for _, list in pairs(set.specs or {}) do Each(list) end
end
check(count == 70, "70 attack macros gained the line (" .. count .. ")")

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
