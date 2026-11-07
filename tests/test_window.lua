-- The MacroKit window and minimap button, for a Retribution paladin who
-- knows most of the spells, then the same paladin before choosing a spec,
-- then a warrior.
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

-- Reading the window back.
local function AllTexts()
    local found = {}
    for _, r in ipairs(regions) do
        if r.__text and r.__shown ~= false and r.__parent.__shown ~= false then found[#found + 1] = r.__text end
    end
    return table.concat(found, " | ")
end
local function Rows()
    local list = {}
    for _, f in ipairs(Frames()) do
        if rawget(f, "macro") and rawget(f, "status") and f.__shown then list[#list + 1] = f end
    end
    return list
end
local function RowFor(name)
    for _, row in ipairs(Rows()) do if row.macro.name == name then return row end end
end
local function Button(pattern)
    for _, f in ipairs(Frames()) do
        if rawget(f, "label") and f.label.__text and f.label.__text:find(pattern) then return f end
    end
end
local function Click(f) f.__scripts.OnClick(f) end
local function MenuOptions()
    local list = {}
    for _, f in ipairs(Frames()) do
        if rawget(f, "key") ~= nil and f.__shown then list[#list + 1] = f end
    end
    return list
end

-- Opening it.
Click(MacroKitMinimapButton)
check(MacroKitWindow:IsShown(), "the minimap button opens the window")
check(AllTexts():find("Paladin", 1, true), "the window names the class")
local specButton = Button("^Spec: ")
check(specButton and specButton.label.__text == "Spec: Retribution  v", "the Spec menu starts on the character's own spec: " .. tostring(specButton and specButton.label.__text))

-- The tabs.
local readyTab, laterTab = Button("^Ready to use"), Button("^Not learned yet")
check(readyTab.label.__text == "Ready to use (11)" and laterTab.label.__text == "Not learned yet (2)",
    "the tabs count the macros whose spells are known and those still waiting: "
    .. readyTab.label.__text .. ", " .. laterTab.label.__text)
check(readyTab.underline.__shown and not laterTab.underline.__shown, "Ready to use is the tab shown first")
check(#Rows() == 11 and RowFor("Spender") and RowFor("Stun") and not RowFor("Execute"), "it lists the ready macros only")
local spender, stun = RowFor("Spender"), RowFor("Stun")
check(spender.status.__text:find("Ready to add", 1, true) and spender.add.__shown, "a macro that can be added has an Add button")
check(stun.status.__text:find("In your macros", 1, true) and not stun.add.__shown, "one already in the macro list says so")
check(spender.icon.__texture == "icon-Templar's Verdict" and spender.desc.__text:find("Shift for Divine Storm", 1, true),
    "each row shows the spell's icon and what the macro does")

Click(laterTab)
check(laterTab.underline.__shown and #Rows() == 2 and RowFor("Execute") and RowFor("Battle Rez"), "Not learned yet lists the macros still waiting")
local execute = RowFor("Execute")
check(execute.status.__text:find("Needs Hammer of Wrath", 1, true) and not execute.add.__shown and execute.icon.__desaturated,
    "and says which spell each needs, greyed, with no button")
Click(readyTab)

-- Adding one, picking it up, the tooltip.
spender = RowFor("Spender")
Click(spender.add)
check(Has("Spender") and ns.char.made.Spender, "Add puts that macro in the character's list")
spender = RowFor("Spender")
check(spender.status.__text:find("In your macros", 1, true) and not spender.add.__shown, "and the row updates at once")
PICKED = nil
spender.__scripts.OnDragStart(spender)
check(PICKED == "Spender", "dragging a row picks the macro up, ready for the action bars")
spender.__scripts.OnEnter(spender)
local tip = table.concat(TOOLTIP, " | ")
check(tip:find("/cast [mod:shift] Divine Storm; Templar's Verdict", 1, true) and tip:find("Drag onto your action bars", 1, true),
    "hovering a row shows the macro's text and what to do")

-- Learning a spell moves its macro across to Ready to use.
Learn("Hammer of Wrath")
Fire("SPELLS_CHANGED")
check(readyTab.label.__text == "Ready to use (12)" and RowFor("Execute"), "learning a spell moves its macro to Ready to use")

-- Add all missing, combat, and Remove.
local addAll, remove = Button("^Add all missing"), Button("^Remove MacroKit")
check(addAll.label.__text == "Add all missing (10)", "Add all counts the macros it can add: " .. addAll.label.__text)
IN_COMBAT = true
Fire("PLAYER_REGEN_DISABLED")
check(addAll.active == false and RowFor("Execute").add.active == false, "in combat the buttons are greyed out")
Click(RowFor("Execute").add)
check(not Has("Execute"), "and clicking them does nothing")
IN_COMBAT = false
Fire("PLAYER_REGEN_ENABLED")
Click(addAll)
check(Has("Interrupt") and Has("Execute") and not Has("Battle Rez"), "Add all adds every ready macro and only those")
check(addAll.label.__text == "Add all missing" and addAll.active == false, "and then has nothing left to add")
Click(remove)
check(Has("Stun") and not Has("Spender") and not Has("Interrupt"), "Remove deletes only what MacroKit added")

-- The automatic-adding switch.
local auto
for _, f in ipairs(Frames()) do if rawget(f, "tick") then auto = f end end
Click(auto)
check(ns.char.auto == false and auto.tick.__shown == false, "the tick box turns automatic adding off")
Click(auto)
check(ns.char.auto == true, "and on again")

-- The Spec menu: look at another spec's macros.
Click(specButton)
check(MacroKitSpecMenu.__shown, "the Spec button opens its menu")
local options = MenuOptions()
local labels = {}
for _, o in ipairs(options) do labels[#labels + 1] = o.label.__text end
check(table.concat(labels, ", ") == "Every spec, Holy, Protection, Retribution (yours)", "it offers every spec, marking the character's own: " .. table.concat(labels, ", "))
check(options[4].mark.__shown and not options[2].mark.__shown, "the spec being shown is marked")
Click(options[2])
check(not MacroKitSpecMenu.__shown and specButton.label.__text == "Spec: Holy  v", "choosing Holy closes the menu and shows Holy")
Click(laterTab)
check(RowFor("Holy Shock") and RowFor("Beacon") and not RowFor("Spender"), "Holy's macros are listed instead of Retribution's")
Click(specButton); Click(MenuOptions()[1])
check(specButton.label.__text == "Spec: Every spec  v", "Every spec shows only the macros all specs share")
Click(readyTab)
check(not RowFor("Spender") and not RowFor("Holy Shock") and RowFor("Interrupt"), "with no spec's own macros")

-- Changing spec in the game resets the view to the new spec.
Learn("Hand of Reckoning", "Shield of the Righteous", "Avenger's Shield")
SPEC = 66
Fire("PLAYER_SPECIALIZATION_CHANGED", "player")
check(specButton.label.__text == "Spec: Protection  v" and RowFor("Taunt"), "a spec change in the game shows the new spec's macros")

-- Before a spec is chosen.
SPEC = nil
Fire("PLAYER_ENTERING_WORLD")
check(specButton.label.__text == "Spec: Every spec  v" and RowFor("Interrupt") and not RowFor("Taunt"),
    "with no spec chosen, it starts on the shared macros")
check(AllTexts():find("No specialization chosen yet. Use the Spec menu to preview", 1, true), "and a line points to the Spec menu")

-- A low-level character who knows none of the spells and has no macros.
KNOWN = {}
DeleteMacro(GetMacroIndexByName("Stun"))
Fire("SPELLS_CHANGED")
check(#Rows() == 0 and AllTexts():find("Nothing ready yet", 1, true) and AllTexts():find("See Not learned yet (8)", 1, true),
    "with nothing ready, it says so and points to the other tab")
Click(laterTab)
check(#Rows() == 8, "where all 8 are listed")

-- A class with no macros yet.
CLASS = "WARRIOR"
Fire("PLAYER_ENTERING_WORLD")
check(#Rows() == 0 and AllTexts():find("There are no macros for Warrior yet", 1, true), "a warrior is told there are none for the class yet")
check(not specButton.__shown and not readyTab.__shown, "with no Spec menu or tabs")

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

-- /macrokit spells lists the spellbook.
CLASS, SPEC = "PALADIN", 70
C_SpellBook = {
    GetNumSpellBookSkillLines = function() return 2 end,
    GetSpellBookSkillLineInfo = function(line)
        if line == 1 then return { itemIndexOffset = 0, numSpellBookItems = 2 } end
        return { itemIndexOffset = 2, numSpellBookItems = 1 }
    end,
    GetSpellBookItemName = function(index) return ({ "Crusader Strike", "Judgment", "Holy Light" })[index] end,
}
local before = #PRINTED
SlashCmdList.MACROKIT("spells")
local said = table.concat(PRINTED, " | ", before + 1)
check(said:find("spec 70", 1, true) and said:find("3 spells: Crusader Strike, Judgment, Holy Light", 1, true),
    "/macrokit spells lists the spec and the spellbook: " .. said)
C_SpellBook = nil
before = #PRINTED
SlashCmdList.MACROKIT("spells")
check(table.concat(PRINTED, " | ", before + 1):find("Could not read the spellbook", 1, true), "without a spellbook API it says so instead of erroring")
