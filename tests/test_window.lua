-- The MacroKit window and minimap button, for a Forever paladin: first with
-- no talents (picking a spec in the menu), then with Retribution talents,
-- then a warrior.
local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Has(name) return GetMacroIndexByName(name) > 0 end

SPEC = nil
Learn("Seal of Righteousness", "Seal of the Crusader", "Judgement", "Holy Strike", "Holy Light", "Blessing of Might")
SPELL_IDS["Flash of Light"] = 77     -- the client knows it; this character has not learned it
CreateMacro("Heal", 1, "/say my own", true)

Fire("ADDON_LOADED", "MacroKit")
SlashCmdList.MACROKIT("auto off")    -- so the window starts from a clean macro list
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
local function Badge()
    for _, r in ipairs(regions) do
        if r.__parent == MacroKitMinimapButton and r.__text ~= nil then return r.__text end
    end
end

-- The minimap button counts the macros ready to add.
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(Badge() == "3", "the minimap button shows how many macros are ready to add: " .. tostring(Badge()))

-- Opening it, with no talents yet.
Click(MacroKitMinimapButton)
check(MacroKitWindow:IsShown(), "the minimap button opens the window")
check(AllTexts():find("Paladin", 1, true), "the window names the class")
local specButton = Button("^Spec")
check(specButton.__shown and specButton.label.__text == "Spec: Every spec  v", "with no talents yet, the Spec menu starts on Every spec")
check(AllTexts():find("Your spec shows once you learn a talent spell. Until then, pick yours in the Spec menu.", 1, true),
    "and a line explains how the spec is found")

-- The tabs. Known: Holy Strike, Seal, Heal (the player's own), Might.
local readyTab, laterTab = Button("^Ready to use"), Button("^Not learned yet")
check(readyTab.label.__text == "Ready to use (4)" and laterTab.label.__text == "Not learned yet (9)",
    "the tabs count the macros whose spells are known and those still waiting: "
    .. readyTab.label.__text .. ", " .. laterTab.label.__text)
check(readyTab.underline.__shown and not laterTab.underline.__shown, "Ready to use is the tab shown first")
check(#Rows() == 4 and RowFor("Holy Strike") and RowFor("Seal") and not RowFor("Quick Heal"), "it lists the ready macros only")
local strike, heal = RowFor("Holy Strike"), RowFor("Heal")
check(strike.status.__text:find("Ready to add", 1, true) and strike.add.__shown, "a macro that can be added has an Add button")
check(heal.status.__text:find("In your macros", 1, true) and not heal.add.__shown, "one already in the macro list says so")
check(strike.icon.__texture == "icon-Holy Strike" and strike.desc.__text == "Starts attacking and uses Holy Strike",
    "each row shows the spell's icon and what the macro does")

Click(laterTab)
check(laterTab.underline.__shown and #Rows() == 9 and RowFor("Quick Heal") and RowFor("Exorcism"), "Not learned yet lists the macros still waiting")
local quick = RowFor("Quick Heal")
check(quick.status.__text:find("Needs Flash of Light", 1, true) and not quick.add.__shown and quick.icon.__desaturated,
    "and says which spell each needs, greyed, with no button")
Click(readyTab)

-- Adding one, picking it up, the tooltip.
Click(RowFor("Holy Strike").add)
check(Has("Holy Strike") and ns.char.made["Holy Strike"], "Add puts that macro in the character's list")
strike = RowFor("Holy Strike")
check(strike.status.__text:find("In your macros", 1, true) and not strike.add.__shown, "and the row updates at once")
check(Badge() == "2", "and the minimap count goes down: " .. tostring(Badge()))
PICKED = nil
strike.__scripts.OnDragStart(strike)
check(PICKED == "Holy Strike", "dragging a row picks the macro up, ready for the action bars")
check(AllTexts():find("How it works", 1, true) and AllTexts():find("Hover over a macro to see how it works.", 1, true),
    "under the list, a How it works panel invites you to hover a macro")
strike.__scripts.OnEnter(strike)
local tip = table.concat(TOOLTIP, " | ")
check(tip:find("/startattack | /cast Holy Strike", 1, true) and tip:find("Drag onto your action bars", 1, true),
    "hovering a row shows the macro's text and what to do: " .. tip)
check(tip:find("Turns on your auto-attack and uses Holy Strike in the same press", 1, true), "the tooltip explains how it works")
check(AllTexts():find("How Holy Strike works", 1, true) and AllTexts():find("one button starts a fight and keeps you swinging", 1, true),
    "and so does the How it works panel")
local seal = RowFor("Seal")
seal.__scripts.OnEnter(seal)
check(AllTexts():find("How Seal works", 1, true) and AllTexts():find("Hold Shift to put up Seal of the Crusader", 1, true),
    "hovering another macro explains that one")

-- Learning a spell (at a trainer): the window updates by itself, the new
-- macro is announced, and the count rises.
Learn("Flash of Light")
local before = #PRINTED
Fire("TRAINER_CLOSED")
RunAfters()
check(readyTab.label.__text == "Ready to use (5)" and RowFor("Quick Heal"), "a newly learned spell moves its macro to Ready to use while the window is open")
check(table.concat(PRINTED, " | ", before + 1):find("New macro ready: Quick Heal", 1, true), "and it is announced in chat")
check(Badge() == "3", "and the minimap count rises: " .. tostring(Badge()))

-- Picking a spec in the menu before the talents show one.
Click(specButton)
check(MacroKitSpecMenu.__shown, "the Spec button opens its menu")
local labels = {}
for _, o in ipairs(MenuOptions()) do labels[#labels + 1] = o.label.__text end
check(table.concat(labels, ", ") == "Every spec, Holy, Protection, Retribution", "it offers Every spec and the three talent trees: " .. table.concat(labels, ", "))
check(MenuOptions()[1].mark.__shown, "the spec being shown is marked")
Learn("Seal of Fury", "Righteous Fury")
Click(MenuOptions()[3])
RunAfters()
check(not MacroKitSpecMenu.__shown and specButton.label.__text == "Spec: Protection  v" and ns.char.view == 66,
    "choosing Protection closes the menu, shows it, and remembers the choice for this character")
check(RowFor("Tank Up") and RowFor("Taunt") and not RowFor("Command"), "Protection's macros join the list")
check(not AllTexts():find("Your spec shows once", 1, true), "and the line about picking a spec goes")

-- Add all missing, combat, and Remove.
local addAll, remove = Button("^Add all missing"), Button("^Remove MacroKit")
check(addAll.label.__text == "Add all missing (5)", "Add all counts the macros it can add: " .. addAll.label.__text)
IN_COMBAT = true
Fire("PLAYER_REGEN_DISABLED")
check(addAll.active == false and RowFor("Quick Heal").add.active == false, "in combat the buttons are greyed out")
Click(RowFor("Quick Heal").add)
check(not Has("Quick Heal"), "and clicking them does nothing")
IN_COMBAT = false
Fire("PLAYER_REGEN_ENABLED")
RunAfters()
Click(addAll)
check(Has("Seal") and Has("Quick Heal") and Has("Tank Up") and Has("Taunt") and not Has("Exorcism"), "Add all adds every ready macro and only those")
check(addAll.label.__text == "Add all missing" and addAll.active == false and Badge() == "", "and then has nothing left to add, and the count clears")
Click(remove)
check(Has("Heal") and not Has("Seal") and not Has("Tank Up"), "Remove deletes only what MacroKit added")

-- The automatic-adding switch.
local auto
for _, f in ipairs(Frames()) do if rawget(f, "tick") then auto = f end end
check(not auto.tick.__shown, "the tick box shows automatic adding is off")
Click(auto)
RunAfters()
check(ns.char.auto == true and auto.tick.__shown == true and Has("Seal") and Has("Tank Up"),
    "turning it on adds the ready macros at once")
Click(auto)
check(ns.char.auto == false and auto.tick.__shown == false, "and it turns off again")

-- Talents into Retribution: the window follows them.
Learn("Seal of Command")
Fire("CHARACTER_POINTS_CHANGED")
RunAfters()
check(specButton.label.__text == "Spec: Retribution  v" and ns.char.view == nil, "learning a Retribution talent spell switches the window to Retribution")
Click(specButton)
labels = {}
for _, o in ipairs(MenuOptions()) do labels[#labels + 1] = o.label.__text end
check(table.concat(labels, ", ") == "Every spec, Holy, Protection, Retribution (yours)", "and the menu marks it as yours: " .. table.concat(labels, ", "))
Click(MenuOptions()[2])
check(specButton.label.__text == "Spec: Holy  v" and RowFor("Holy Strike"), "another spec can still be looked at")
Click(laterTab)
check(RowFor("Holy Shock"), "with its macros under Not learned yet")
Click(readyTab)

-- A character who knows none of the spells and has no macros.
KNOWN = {}
for i = #MACROS, 1, -1 do DeleteMacro(i) end
ns.char.view = "shared"
Fire("SPELLS_CHANGED")
RunAfters()
check(#Rows() == 0 and AllTexts():find("Nothing ready yet", 1, true) and AllTexts():find("See Not learned yet (13)", 1, true),
    "with nothing ready, it says so and points to the other tab")
Click(laterTab)
check(#Rows() == 13, "where all 13 shared macros are listed")
Click(readyTab)

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
CLASS = "PALADIN"
C_SpellBook = {
    GetNumSpellBookSkillLines = function() return 2 end,
    GetSpellBookSkillLineInfo = function(line)
        if line == 1 then return { itemIndexOffset = 0, numSpellBookItems = 2 } end
        return { itemIndexOffset = 2, numSpellBookItems = 1 }
    end,
    GetSpellBookItemName = function(index) return ({ "Holy Strike", "Judgement", "Holy Light" })[index] end,
}
before = #PRINTED
SlashCmdList.MACROKIT("spells")
local said = table.concat(PRINTED, " | ", before + 1)
check(said:find("spec none chosen", 1, true) and said:find("3 spells: Holy Strike, Judgement, Holy Light", 1, true),
    "/macrokit spells lists the spec and the spellbook: " .. said)
C_SpellBook = nil
before = #PRINTED
SlashCmdList.MACROKIT("spells")
check(table.concat(PRINTED, " | ", before + 1):find("Could not read the spellbook", 1, true), "without a spellbook API it says so instead of erroring")
