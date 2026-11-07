-- Levelling with automatic adding on: MacroKit adds the new macros by
-- itself, and the minimap badge still says there is something new to see.
local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Has(name) return GetMacroIndexByName(name) > 0 end
local function Badge()
    if not MacroKitMinimapBadge.__shown then return "" end
    return MacroKitMinimapBadge.count.__text
end

SPEC = nil
Learn("Holy Strike", "Holy Light", "Seal of Righteousness", "Seal of the Crusader")
Fire("ADDON_LOADED", "MacroKit")
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(ns.char.auto and Has("Holy Strike") and Has("Heal") and Has("Seal"), "on arrival the known macros are added")
check(Badge() == "3", "and the badge shows the 3 new macros: " .. Badge())

-- Opening the window shows them as New, then the badge clears.
MacroKitMinimapButton.__scripts.OnClick(MacroKitMinimapButton)
local newRows = 0
for _, f in ipairs(Frames()) do
    if rawget(f, "macro") and rawget(f, "status") and f.__shown and f.status.__text:find("New", 1, true) then newRows = newRows + 1 end
end
check(newRows == 3, "opening the window marks the 3 new macros New")
check(Badge() == "" and not MacroKitMinimapBadge.__shown, "the badge is hidden while the window is open")
MacroKitMinimapButton.__scripts.OnClick(MacroKitMinimapButton)
MacroKitWindow.__scripts.OnHide(MacroKitWindow)
check(Badge() == "" and next(ns.char.fresh) == nil, "and closing the window clears what was new")

-- Level 8: Hammer of Justice and Purify. With auto on they are added at
-- once, and the badge lights up again.
Learn("Hammer of Justice", "Purify")
Fire("PLAYER_LEVEL_UP", 8)
Fire("SPELLS_CHANGED")
RunAfters()
check(Has("Stun") and Has("Dispel"), "levelling up adds the new macros by itself")
check(Badge() == "2", "and the badge shows the 2 new macros, though none is waiting to be added: " .. Badge())
MacroKitMinimapButton.__scripts.OnEnter(MacroKitMinimapButton)
check(table.concat(TOOLTIP, " | "):find("2 new macros since you last looked", 1, true), "the button's tooltip says what the number means")

-- A macro the player removes no longer counts as new.
DeleteMacro(GetMacroIndexByName("Dispel"))
ns.char.made.Dispel = nil
ns.char.auto = false
Fire("UPDATE_MACROS")
check(Badge() == "2", "a removed macro that could be added again still counts, as ready to add: " .. Badge())
KNOWN[SPELL_IDS["Purify"]] = nil
Fire("UPDATE_MACROS")
check(Badge() == "1", "and once it cannot be added either, it drops out: " .. Badge())
