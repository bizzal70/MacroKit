-- The MacroKit window and minimap button, for a Retribution paladin who
-- knows most of the spells, then a warrior.
local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Has(name) return GetMacroIndexByName(name) > 0 end

Learn("Rebuke", "Hammer of Justice", "Blessing of Freedom", "Blessing of Protection", "Lay on Hands",
    "Divine Shield", "Divine Steed", "Cleanse Toxins", "Avenging Wrath", "Templar's Verdict", "Word of Glory")
SPELL_IDS["Hammer of Wrath"] = 77      -- the client knows it; this character has not learned it
SPELL_IDS["Intercession"] = 78
CreateMacro("Stun", 1, "/say my own", true)

Fire("ADDON_LOADED", "MacroKit")
check(MacroKitDB and ns.db.minimapButton == true, "account-wide settings start with the minimap button on")
check(MacroKitMinimapButton and MacroKitMinimapButton.__shown, "the minimap button shows")

-- Every font string and texture that belongs to a frame, read back.
local function TextsOf(frame)
    local found = {}
    for _, r in ipairs(regions) do
        if r.__parent == frame and r.__text then found[#found + 1] = r.__text end
    end
    return table.concat(found, " | ")
end
local function AllTexts()
    local found = {}
    for _, r in ipairs(regions) do
        if r.__text and (r.__parent.__shown ~= false) then found[#found + 1] = r.__text end
    end
    return table.concat(found, " | ")
end
-- The window's macro rows: frames made on the window with a macro set.
local function Rows()
    local list = {}
    for _, f in ipairs(Frames()) do
        if rawget(f, "macro") and f.__shown then list[#list + 1] = f end
    end
    return list
end
local function RowFor(name)
    for _, row in ipairs(Rows()) do if row.macro.name == name then return row end end
end

-- Clicking the minimap button opens the window.
MacroKitMinimapButton.__scripts.OnClick(MacroKitMinimapButton)
check(MacroKitWindow:IsShown(), "the minimap button opens the window")
local texts = AllTexts()
check(texts:find("Paladin  -  Retribution", 1, true), "the window names the class and spec: " .. texts)
check(#Rows() == 13, "it lists the 8 shared and 5 Retribution macros, and no others: " .. #Rows())
check(RowFor("Spender") and not RowFor("Holy Shock") and not RowFor("Taunt"), "other specs' macros are not listed")

local spender, execute, stun = RowFor("Spender"), RowFor("Execute"), RowFor("Stun")
check(spender.status.__text:find("Ready", 1, true) and spender.add.__shown, "a macro that can be added says Ready and has an Add button")
check(execute.status.__text:find("Needs Hammer of Wrath", 1, true) and not execute.add.__shown and execute.icon.__desaturated,
    "a macro waiting on a spell says which, has no button, and its icon is greyed")
check(stun.status.__text:find("In your macros", 1, true) and not stun.add.__shown, "one already in the macro list says so")
check(spender.icon.__texture == "icon-Templar's Verdict" and spender.desc.__text:find("Shift for Divine Storm", 1, true),
    "each row shows the spell's icon and what the macro does")

-- Adding one.
spender.add.__scripts.OnClick(spender.add)
check(Has("Spender") and ns.char.made.Spender, "Add puts that one macro in the character's list")
check(spender.status.__text:find("In your macros", 1, true) and not spender.add.__shown, "and the row updates at once")

-- Picking up and dragging onto the bars.
PICKED = nil
spender.__scripts.OnDragStart(spender)
check(PICKED == "Spender", "dragging a row picks the macro up, ready for the action bars")
PICKED = nil
execute.__scripts.OnClick(execute)
check(PICKED == nil, "a macro not yet in the list cannot be picked up")

-- The tooltip shows the macro itself.
spender.__scripts.OnEnter(spender)
local tip = table.concat(TOOLTIP, " | ")
check(tip:find("Spender", 1, true) and tip:find("/cast [mod:shift] Divine Storm; Templar's Verdict", 1, true)
    and tip:find("Drag onto your action bars", 1, true), "hovering a row shows the macro's text and what to do: " .. tip)

-- Add all missing, then remove.
local window = MacroKitWindow
local addAll, remove
for _, f in ipairs(Frames()) do
    if f.label and f.label.__text then
        if f.label.__text:find("^Add all missing") then addAll = f end
        if f.label.__text == "Remove MacroKit's macros" then remove = f end
    end
end
check(addAll.label.__text == "Add all missing (9)", "the Add all button counts the ready macros: " .. addAll.label.__text)
addAll.__scripts.OnClick(addAll)
check(Has("Interrupt") and Has("Ret Burst") and not Has("Execute") and not Has("Battle Rez"), "Add all adds every ready macro and only those")
check(addAll.label.__text == "Add all missing" and addAll.active == false, "and then has nothing left to add")

-- Learning a spell (the game fires SPELLS_CHANGED) brings its macro to Ready.
Learn("Hammer of Wrath")
Fire("SPELLS_CHANGED")
check(execute.status.__text:find("Ready", 1, true) and execute.add.__shown, "learning the spell makes its macro ready, without reopening")

-- In combat the buttons are greyed out and do nothing.
IN_COMBAT = true
Fire("PLAYER_REGEN_DISABLED")
check(execute.add.active == false and remove.active == false, "in combat the buttons are greyed out")
execute.add.__scripts.OnClick(execute.add)
check(not Has("Execute"), "and clicking them does nothing")
IN_COMBAT = false
Fire("PLAYER_REGEN_ENABLED")
check(execute.add.active == true, "they come back after combat")

-- Remove takes back only MacroKit's macros.
remove.__scripts.OnClick(remove)
check(Has("Stun") and not Has("Spender") and not Has("Interrupt"), "Remove deletes only what MacroKit added")
check(spender.add.__shown, "and the rows show them as ready again")

-- The automatic-adding switch.
local auto
for _, f in ipairs(Frames()) do if rawget(f, "tick") then auto = f end end
auto.__scripts.OnClick(auto)
check(ns.char.auto == false and auto.tick.__shown == false, "the tick box turns automatic adding off")
auto.__scripts.OnClick(auto)
check(ns.char.auto == true and auto.tick.__shown == true, "and on again")

-- A spec change redraws the list.
Learn("Hand of Reckoning", "Shield of the Righteous", "Avenger's Shield")
SPEC = 66
Fire("PLAYER_SPECIALIZATION_CHANGED", "player")
check(AllTexts():find("Paladin  -  Protection", 1, true) and RowFor("Taunt") and not RowFor("Spender"), "switching spec shows that spec's macros")

-- A class with no macros yet.
CLASS = "WARRIOR"
Fire("PLAYER_ENTERING_WORLD")
check(#Rows() == 0, "a warrior sees no macro rows")
check(AllTexts():find("There are no macros for Warrior yet", 1, true), "and is told there are none for the class yet")

-- Closing, the slash command and the minimap addon list entry.
SlashCmdList.MACROKIT("")
check(not MacroKitWindow:IsShown(), "/macrokit closes the window")
MacroKit_OnAddonCompartmentClick()
check(MacroKitWindow:IsShown(), "the minimap addon list entry opens it")

-- Hiding the minimap button, and dragging it round the rim.
SlashCmdList.MACROKIT("button")
check(not MacroKitMinimapButton.__shown and ns.db.minimapButton == false, "/macrokit button hides the minimap button")
SlashCmdList.MACROKIT("button")
check(MacroKitMinimapButton.__shown, "and shows it again")
MacroKitMinimapButton.__scripts.OnDragStart(MacroKitMinimapButton)
MacroKitMinimapButton.__scripts.OnUpdate(MacroKitMinimapButton)
check(math.abs(ns.db.minimapAngle - math.pi / 2) < 0.001, "dragging the button moves it round the minimap and remembers where")
