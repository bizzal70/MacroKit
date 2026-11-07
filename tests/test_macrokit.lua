local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Has(name) return GetMacroIndexByName(name) > 0 end
local function Said(from) return table.concat(PRINTED, " | ", from + 1) end

-- Every macro in the data fits the game's limits and needs a spell its body uses.
local count = 0
for class, set in pairs(ns.SETS) do
    local groups = { set.shared }
    for _, id in ipairs(set.order) do groups[#groups + 1] = set.specs[id] end
    for _, group in ipairs(groups) do
        for _, macro in ipairs(group) do
            count = count + 1
            assert(#macro.name <= ns.MAX_NAME, class .. ": name too long: " .. macro.name)
            assert(#macro.body <= ns.MAX_BODY, class .. ": body too long: " .. macro.name)
            assert(not macro.body:find("^%s") and not macro.body:find("%s$"), "stray space around " .. macro.name)
            assert(macro.spells and #macro.spells > 0, "no spells listed for " .. macro.name)
            for _, spell in ipairs(macro.spells) do
                assert(macro.body:find(spell, 1, true), macro.name .. " lists " .. spell .. " but does not cast it")
            end
        end
    end
    for _, id in ipairs(set.order) do
        assert(#set.shared + #set.specs[id] <= 18, class .. " spec " .. id .. " needs more than 18 macros")
    end
end
check(count > 20, "all " .. count .. " macros fit the game's name and length limits")

-- A Retribution paladin who has learned everything except Intercession,
-- and already has a macro of their own called "Stun".
local everything = { "Rebuke", "Hammer of Justice", "Blessing of Freedom", "Blessing of Protection",
    "Lay on Hands", "Divine Shield", "Divine Steed", "Cleanse Toxins", "Avenging Wrath",
    "Templar's Verdict", "Hammer of Wrath", "Word of Glory" }
Learn(unpack(everything))
SPELL_IDS["Holy Shock"] = 5        -- the client knows Holy Shock, but this character does not
CreateMacro("Stun", 1, "/say my own", true)

Fire("ADDON_LOADED", "MacroKit")
check(ns.char.auto == true, "adds macros by itself by default")
check(#MACROS == 1, "nothing is added before the character arrives in the world")

local before = #PRINTED
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(Has("Interrupt") and Has("Bubble") and Has("Spender") and Has("Ret Burst") and Has("Cleanse Toxins"),
    "on first login, the shared and Retribution macros are added: " .. MacroNames())
check(not Has("Holy Shock") and not Has("Beacon") and not Has("Taunt"), "other specs' macros are not")
check(not Has("Battle Rez"), "a macro whose spell is not learned yet is held back")
check(MACROS[1].body == "/say my own" and GetNumMacros() == 0, "the player's own Stun macro is untouched")
for _, m in ipairs(MACROS) do assert(m.perCharacter, m.name .. " was made account-wide") end
check(true, "every macro is made for this character only")
check(Said(before):find("Battle Rez (Intercession)", 1, true), "it says which macro waits on which spell: " .. Said(before))
check(ns.char.made.Spender and not ns.char.made.Stun, "it remembers which macros it added")

local total = #MACROS
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(#MACROS == total, "logging in again adds nothing twice")

-- Learning the spell, then asking.
Learn("Intercession")
SlashCmdList.MACROKIT("add")
check(Has("Battle Rez"), "/macrokit adds a macro once its spell is learned")
SlashCmdList.MACROKIT("add")
check(#MACROS == total + 1, "and running it again adds no duplicates")

-- The macro list shows each macro's state.
before = #PRINTED
SlashCmdList.MACROKIT("list")
check(Said(before):find("Spender", 1, true) and Said(before):find("in your macros", 1, true), "/macrokit list shows the macros")

-- Switching to Holy adds Holy's macros on the next look.
Learn("Cleanse", "Holy Shock", "Beacon of Light")
SPEC = 65
Fire("PLAYER_SPECIALIZATION_CHANGED", "party1")
RunAfters()
check(not Has("Holy Shock"), "another unit's spec change is ignored")
Fire("PLAYER_SPECIALIZATION_CHANGED", "player")
RunAfters()
check(Has("Holy Shock") and Has("Beacon") and Has("Cleanse") and Has("Holy Burst"), "switching to Holy adds the Holy macros")

-- In combat, it waits.
SPEC = 66
Learn("Hand of Reckoning", "Shield of the Righteous", "Avenger's Shield")
IN_COMBAT = true
SlashCmdList.MACROKIT("add")
check(not Has("Taunt"), "nothing is made in combat")
IN_COMBAT = false
Fire("PLAYER_REGEN_ENABLED")
check(Has("Taunt"), "and the macros are added once combat ends")

-- A full macro list.
check(select(2, GetNumMacros()) == 18, "this character's macros are now full")
SPEC = nil       -- a client that cannot say the spec: every spec's macros are wanted
before = #PRINTED
SlashCmdList.MACROKIT("add")
check(select(2, GetNumMacros()) == 18, "it never goes past the limit")
check(Said(before):find("No room for", 1, true), "and says which did not fit: " .. Said(before))

-- Removing deletes only what it added.
SlashCmdList.MACROKIT("remove")
check(#MACROS == 1 and MACROS[1].name == "Stun", "/macrokit remove leaves only the player's own macro")
check(next(ns.char.made) == nil, "and forgets what it had added")

-- Switching automatic adding off.
SlashCmdList.MACROKIT("auto off")
SPEC = 70
ns.char.done = {}
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(#MACROS == 1, "with auto off, logging in adds nothing")
SlashCmdList.MACROKIT("auto on")
check(ns.char.auto, "/macrokit auto on switches it back")

-- Classes without macros yet.
CLASS = "MAGE"
before = #PRINTED
SlashCmdList.MACROKIT("add")
check(Said(before):find("no macros for your class", 1, true), "another class is told there is nothing yet")
MacroKit_OnAddonCompartmentClick()
SlashCmdList.MACROKIT("help")
