-- MacroKit's adding, learning and talent logic, for a Forever paladin:
-- classic-style talent trees, no specialization reported by the game.
local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Has(name) return GetMacroIndexByName(name) > 0 end
local function Said(from) return table.concat(PRINTED, " | ", from + 1) end

-- Every macro in the data fits the game's limits and casts the spells it
-- lists, and shared plus any one spec fits in a character's 18 macros.
local count = 0
for class, set in pairs(ns.SETS) do
    local groups = { set.shared }
    for _, id in ipairs(set.order or {}) do groups[#groups + 1] = set.specs[id] end
    for _, group in ipairs(groups) do
        for _, macro in ipairs(group) do
            count = count + 1
            assert(#macro.name <= ns.MAX_NAME, class .. ": name too long: " .. macro.name)
            assert(#macro.body <= ns.MAX_BODY, class .. ": body too long: " .. macro.name)
            assert(macro.desc and #macro.desc > 0, class .. ": no description for " .. macro.name)
            assert(not macro.body:find("^%s") and not macro.body:find("%s$"), "stray space around " .. macro.name)
            assert(macro.spells and #macro.spells > 0, "no spells listed for " .. macro.name)
            for _, spell in ipairs(macro.spells) do
                assert(macro.body:find(spell, 1, true), macro.name .. " lists " .. spell .. " but does not cast it")
            end
        end
    end
    for _, id in ipairs(set.order or {}) do
        assert(#set.shared + #set.specs[id] <= 18, class .. " spec " .. id .. " needs more than 18 macros")
        assert(set.treeSpells and #set.treeSpells[id] > 0, class .. " spec " .. id .. " has no talent spells to spot it by")
    end
end
check(count >= 24, "all " .. count .. " macros fit the game's limits, and each spec fits in 18 macros")

-- A level 8 paladin: no talents yet, an own macro called "Stun".
SPEC = nil
Learn("Seal of Righteousness", "Seal of the Crusader", "Judgement", "Holy Strike", "Holy Light",
    "Blessing of Might", "Divine Protection", "Hammer of Justice", "Purify")
SPELL_IDS["Flash of Light"] = 5      -- the client knows it; this character has not learned it
CreateMacro("Stun", 1, "/say my own", true)

Fire("ADDON_LOADED", "MacroKit")
check(ns.char.auto == true, "adds macros by itself by default")
check(#MACROS == 1, "nothing is added before the character arrives in the world")

local before = #PRINTED
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(Has("Holy Strike") and Has("Seal") and Has("Heal") and Has("Might") and Has("Bubble") and Has("Dispel"),
    "on arrival, the macros for the spells it knows are added: " .. MacroNames())
check(not Has("Quick Heal") and not Has("Exorcism"), "macros whose spells are not learned yet are held back")
check(not Has("Tank Up") and not Has("Command") and not Has("Holy Shock"), "with no talents yet, no spec's macros are added")
check(MACROS[1].body == "/say my own", "the player's own Stun macro is untouched")
for _, m in ipairs(MACROS) do assert(m.perCharacter, m.name .. " was made account-wide") end
check(ns.char.made.Heal and not ns.char.made.Stun, "it remembers which macros it added")

local total = #MACROS
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(#MACROS == total, "logging in again adds nothing twice")

-- Learning a spell at the trainer: the new macro arrives by itself.
Learn("Flash of Light")
before = #PRINTED
Fire("SPELLS_CHANGED")
Fire("LEARNED_SPELL_IN_SKILL_LINE")
Fire("TRAINER_CLOSED")
check(#AFTERS == 1, "the burst of events from learning a spell leads to one look, not several")
RunAfters()
check(Has("Quick Heal") and Said(before):find("Added 1 macros: Quick Heal", 1, true), "a macro whose spell was just learned is added and announced: " .. Said(before))

-- Levelling up works the same way.
Learn("Redemption")
Fire("PLAYER_LEVEL_UP", 12)
RunAfters()
check(Has("Rez"), "after a level up, newly usable macros are added")

-- Spending talent points into Retribution: the spec is worked out from the
-- talent spell, and its macros follow.
Learn("Seal of Command")
Fire("CHARACTER_POINTS_CHANGED")
RunAfters()
local class, spec = ns.ClassAndSpec()
check(spec == 70 and ns.char.lastSpec == 70, "learning Seal of Command shows the character is Retribution")
check(Has("Command") and not Has("Tank Up"), "and Retribution's macros are added, no other spec's")

-- With automatic adding off, new macros are announced once, not added.
SlashCmdList.MACROKIT("auto off")
Learn("Hammer of Wrath")
before = #PRINTED
Fire("SPELLS_CHANGED")
RunAfters()
check(not Has("Execute") and Said(before):find("New macro ready: Execute", 1, true), "with auto off, a new macro is announced, not added: " .. Said(before))
before = #PRINTED
Fire("SPELLS_CHANGED")
RunAfters()
check(not Said(before):find("New macro", 1, true), "and announced only once")
SlashCmdList.MACROKIT("add")
check(Has("Execute"), "/macrokit add then adds it")
SlashCmdList.MACROKIT("auto on")

-- Learned in combat: it waits until the fight is over.
Learn("Exorcism")
IN_COMBAT = true
Fire("SPELLS_CHANGED")
RunAfters()
check(not Has("Exorcism"), "nothing is made in combat")
IN_COMBAT = false
Fire("PLAYER_REGEN_ENABLED")
RunAfters()
check(Has("Exorcism"), "and the macro is added once combat ends")

before = #PRINTED
SlashCmdList.MACROKIT("list")
check(Said(before):find("Command", 1, true) and Said(before):find("in your macros", 1, true), "/macrokit list shows the macros")

-- A full macro list.
Learn("Blessing of Protection", "Blessing of Freedom", "Lay on Hands", "Repentance")
for i = 1, 18 - select(2, GetNumMacros()) - 2 do CreateMacro("Mine " .. i, 1, "/say " .. i, true) end
before = #PRINTED
SlashCmdList.MACROKIT("add")
check(select(2, GetNumMacros()) == 18, "it never goes past the 18 macros a character can hold")
check(Said(before):find("No room for", 1, true), "and says which did not fit: " .. Said(before))

-- Removing deletes only what it added.
SlashCmdList.MACROKIT("remove")
check(Has("Stun") and Has("Mine 1") and not Has("Heal") and not Has("Command"), "/macrokit remove leaves only the player's own macros")
check(next(ns.char.made) == nil, "and forgets what it had added")
for i = #MACROS, 1, -1 do if MACROS[i].name:find("^Mine ") then DeleteMacro(i) end end

-- A new paladin with no talents who picks Protection in the window's menu:
-- Protection's macros are then wanted.
KNOWN = {}
Learn("Seal of Righteousness", "Seal of the Crusader", "Judgement", "Seal of Fury", "Righteous Fury")
ns.char.lastSpec, ns.char.view = nil, 66
SlashCmdList.MACROKIT("add")
check(Has("Tank Up") and Has("Taunt") and not Has("Command"), "a spec picked in the menu is used until the talents show one")
-- The talents then say Retribution: that wins, and the pick is dropped.
Learn("Repentance")
Fire("PLAYER_TALENT_UPDATE")
RunAfters()
check(ns.char.view == nil and select(2, ns.ClassAndSpec()) == 70 and Has("Repent"), "when the talents show a spec, it takes over from the menu pick")

-- A client that reports a specialization the class has macros for.
KNOWN = {}
Learn("Templar's Bulwark")
SPEC = 70
check(select(2, ns.ClassAndSpec()) == 70, "a specialization reported by the game is used directly, before the talents")
SPEC = 12345
check(select(2, ns.ClassAndSpec()) == 66, "one MacroKit has no macros for is ignored, and the talents decide (Templar's Bulwark: Protection)")
KNOWN = {}
check(select(2, ns.ClassAndSpec()) == nil, "with neither, there is no spec")
SPEC = nil

-- Classes without macros yet.
CLASS = "MAGE"
before = #PRINTED
SlashCmdList.MACROKIT("add")
check(Said(before):find("no macros for your class", 1, true), "another class is told there is nothing yet")
SlashCmdList.MACROKIT("help")
