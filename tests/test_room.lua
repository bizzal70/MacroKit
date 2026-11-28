-- 0.14.0: a new install starts with adding by itself off; adding by itself
-- keeps slots free; To bar; the Missing Buff macro; key binding; debug.
EditMacro = function(index, name, icon, body)
    assert(not IN_COMBAT, "EditMacro in combat")
    MACROS[index].body = body
end
AURAS = {}
C_UnitAuras = { GetAuraDataBySpellName = function(unit, name) return AURAS[name] end }
IsMounted = function() return false end
UnitIsDeadOrGhost = function() return false end
UnitOnTaxi = function() return false end
IsShiftKeyDown = function() return false end

-- Action buttons on screen: slot 1 has something, slot 2's button is
-- hidden, slot 3 is empty.
local function FakeButton(slot, visible)
    return { action = slot, IsObjectType = function(_, kind) return kind == "Button" end,
        IsVisible = function() return visible end }
end
local BUTTONS = { FakeButton(1, true), FakeButton(2, false), FakeButton(3, true) }
EnumerateFrames = function(after)
    if after == nil then return BUTTONS[1] end
    for i, b in ipairs(BUTTONS) do if b == after then return BUTTONS[i + 1] end end
end
ACTIONS[1] = { kind = "spell", id = 5 }
HasAction = function(slot) return ACTIONS[slot] ~= nil end
ClearCursor = function() PICKED = nil end
PlaceAction = function(slot)
    assert(not IN_COMBAT, "PlaceAction in combat")
    if PICKED then ACTIONS[slot] = { kind = "macro", id = GetMacroIndexByName(PICKED), text = PICKED } end
end

local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Has(name) return GetMacroIndexByName(name) > 0 end
local function Body(name) local i = GetMacroIndexByName(name); return i > 0 and MACROS[i].body end
local function Said(from) return table.concat(PRINTED, " | ", from + 1) end

CLASS, SPEC = "PRIEST", nil
Learn("Power Word: Fortitude", "Inner Fire", "Smite", "Lesser Heal", "Power Word: Shield", "Renew")

-- A new install: nothing is added unasked.
check(MacroKitDB == nil, "(no saved settings: a new install)")
Fire("ADDON_LOADED", "MacroKit")
check(ns.char.auto == false and ns.db.autoDefault == false, "a new install starts with adding by itself off")
local before = #PRINTED
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(#MACROS == 0, "so nothing lands in the macro list unasked")
check(Said(before):find("Has ready-made macros for your class. Open /macrokit", 1, true), "a welcome line says where to find them: " .. Said(before))
before = #PRINTED
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(not Said(before):find("ready-made", 1, true), "only once")
for _, name in ipairs(ns.ReadyNames()) do assert(name ~= "Missing Buff", "Missing Buff is never counted as ready to add") end
check(#ns.ReadyNames() >= 3, "several macros are ready: " .. table.concat(ns.ReadyNames(), ", "))

-- Adding by itself keeps 3 character slots free.
local ready = #ns.ReadyNames()
for i = 1, 18 - ns.RESERVE - (ready - 1) do CreateMacro("Mine " .. i, 1, "/say " .. i, true) end
before = #PRINTED
SlashCmdList.MACROKIT("auto on")
check(ns.db.autoDefault == true, "the choice carries to characters MacroKit hasn't seen yet")
RunAfters()
check(ns.FreeSlots() == ns.RESERVE, "adding by itself stops with 3 slots still free: " .. ns.FreeSlots())
check(not Has("Missing Buff"), "and never adds Missing Buff")
check(Said(before):find("Stopped adding macros by itself, to keep 3 character macro slots free for your own", 1, true),
    "it says which it held back: " .. Said(before))
before = #PRINTED
Fire("SPELLS_CHANGED")
RunAfters()
check(not Said(before):find("Stopped adding", 1, true), "and says it only once")
SlashCmdList.MACROKIT("add")
check(ns.FreeSlots() < ns.RESERVE and Has("Missing Buff"), "adding when asked may still use the free slots, and includes Missing Buff")
DeleteMacro(GetMacroIndexByName("Missing Buff"))

-- Missing Buff: casts the first missing buff, and follows the buffs.
for i = #MACROS, 1, -1 do if MACROS[i].name:find("^Mine") then DeleteMacro(i) end end
check(ns.AddOne(ns.BUFF_MACRO) and Has("Missing Buff"), "Missing Buff can be added from the window")
check(Body("Missing Buff") == "#showtooltip\n/cast [@player] Power Word: Fortitude", "it casts the first missing buff: " .. tostring(Body("Missing Buff")))
AURAS["Power Word: Fortitude"] = { expirationTime = 9999, duration = 1800 }
ns.RefreshBuffs()
check(Body("Missing Buff") == "#showtooltip\n/cast [@player] Inner Fire", "with that one up, the next")
AURAS["Inner Fire"] = { expirationTime = 9999, duration = 600 }
IN_COMBAT = true
ns.RefreshBuffs()
check(Body("Missing Buff"):find("Inner Fire", 1, true), "never rewritten in combat")
IN_COMBAT = false
ns.RefreshBuffs()
check(Body("Missing Buff") == '/run print("MacroKit: no buffs missing")', "with every buff up, it says so")

-- To bar.
ns.ToggleWindow()
local row
for _, f in ipairs(Frames()) do
    if rawget(f, "macro") and f.macro.name == "Missing Buff" and f.__shown then row = f end
end
check(row and row.add.__shown and row.add.label.__text == "To bar", "a macro in the list but not on a bar has To bar")
row.add.__scripts.OnClick(row.add)
check(ACTIONS[3] and ACTIONS[3].text == "Missing Buff" and not ACTIONS[2], "To bar puts it on the first empty button on screen")
check(row.status.__text:find("On your bars", 1, true) and not row.add.__shown, "and the row then says it's on your bars")
before = #PRINTED
ns.ToBar("Missing Buff")
check(Said(before):find("already on your action bars", 1, true), "it isn't put on twice")
BUTTONS[4] = nil
local other = MACROS[1].name ~= "Missing Buff" and MACROS[1].name or MACROS[2].name
before = #PRINTED
check(not ns.ToBar(other) and Said(before):find("no empty action button on screen", 1, true), "with no empty button, it says so")

-- Key binding, debug.
check(BINDING_NAME_MACROKIT_WINDOW and type(MacroKit_ToggleWindow) == "function", "a key binding opens the window")
before = #PRINTED
SlashCmdList.MACROKIT("debug")
check(Said(before):find("PRIEST", 1, true) and Said(before):find("character macros", 1, true), "/macrokit debug prints the key facts: " .. Said(before))
