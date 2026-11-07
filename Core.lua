local addonName, ns = ...

-- Adds the macros in Data.lua to the character's own macro list, the first
-- time each specialization is played, and from the window (Window.lua).
--
-- It only ever adds a macro under a name the character does not already
-- use, so macros you made or changed yourself are never overwritten.
-- /macrokit remove deletes only the macros MacroKit added.

local ICON = 134400      -- the question mark: with #showtooltip, the macro shows the spell it will cast
local MAX_NAME, MAX_BODY = 16, 255

-- Shared by all characters: where the minimap button sits.
local accountDefaults = {
    minimapButton = true,
    minimapAngle = 5.4,
}

local defaults = {
    auto = true,   -- add macros by itself on a spec's first login
    done = {},     -- spec ID (or "any") -> true once it has been offered
    made = {},     -- macro name -> true for each macro MacroKit added
}

function ns.Print(msg)
    print("|cffd9a066MacroKit|r: " .. tostring(msg))
end

-- Whether this character knows a spell, by name. A name the client does
-- not recognise counts as not known.
function ns.Knows(name)
    if not (C_Spell and C_Spell.GetSpellInfo) then return true end
    local ok, info = pcall(C_Spell.GetSpellInfo, name)
    if not ok then return true end           -- the client refused to answer: do not hold it back
    if type(info) ~= "table" or not info.spellID then return false end
    if type(IsPlayerSpell) == "function" then
        local ok2, known = pcall(IsPlayerSpell, info.spellID)
        if ok2 and known ~= nil then return known and true or false end
    end
    return true
end

-- The character's class and specialization ID (nil if the client cannot say).
function ns.ClassAndSpec()
    local _, class = UnitClass("player")
    local spec
    if type(GetSpecialization) == "function" and type(GetSpecializationInfo) == "function" then
        local ok, index = pcall(GetSpecialization)
        if ok and type(index) == "number" and index > 0 then
            local ok2, id = pcall(GetSpecializationInfo, index)
            if ok2 and type(id) == "number" then spec = id end
        end
    end
    return class, spec
end

-- The class's name as the game shows it, and the spec's name, for the
-- window's title. Either may be nil.
function ns.ClassAndSpecNames()
    local className = UnitClass("player")
    local specName
    if type(GetSpecialization) == "function" and type(GetSpecializationInfo) == "function" then
        local ok, index = pcall(GetSpecialization)
        if ok and type(index) == "number" and index > 0 then
            local ok2, _, name = pcall(GetSpecializationInfo, index)
            if ok2 and type(name) == "string" then specName = name end
        end
    end
    return className, specName
end

-- The macros for this character: the class's shared ones, then the spec's.
-- If the spec is unknown, every spec's macros are offered and the spell
-- check keeps out the ones this character cannot use.
function ns.Wanted()
    local class, spec = ns.ClassAndSpec()
    local set = ns.SETS[class]
    if not set then return nil, class, spec end
    local list, seen = {}, {}
    local function Add(macros)
        for _, macro in ipairs(macros or {}) do
            if not seen[macro.name] then
                seen[macro.name] = true
                list[#list + 1] = macro
            end
        end
    end
    Add(set.shared)
    if spec and set.specs[spec] then
        Add(set.specs[spec])
    elseif not spec then
        for _, id in ipairs(set.order) do Add(set.specs[id]) end
    end
    return list, class, spec
end

-- A spec's name: the client's, else the one in Data.lua.
function ns.SpecName(class, id)
    if type(GetSpecializationInfoByID) == "function" then
        local ok, _, name = pcall(GetSpecializationInfoByID, id)
        if ok and type(name) == "string" then return name end
    end
    local set = ns.SETS[class]
    return set and set.names and set.names[id] or tostring(id)
end

-- The choices for the window's spec menu: "Every spec" (the macros all
-- specs share) and each spec, as { key =, label = } with key "shared" or a
-- spec ID. Also returns the choice to start on: the character's own spec,
-- or "shared" before one is chosen. Nil for a class without macros.
function ns.SpecChoices()
    local class, spec = ns.ClassAndSpec()
    local set = ns.SETS[class]
    if not set then return nil end
    local choices = { { key = "shared", label = "Every spec" } }
    for _, id in ipairs(set.order) do
        local label = ns.SpecName(class, id)
        if id == spec then label = label .. " (yours)" end
        choices[#choices + 1] = { key = id, label = label }
    end
    return choices, spec or "shared"
end

-- What the window lists for a view: "shared" for the macros every spec
-- has, or a spec ID for those plus that spec's own. Nil means the
-- character's own spec, or "shared" before one is chosen.
function ns.WindowList(view)
    local class, spec = ns.ClassAndSpec()
    local set = ns.SETS[class]
    if not set then return nil, class end
    view = view or spec or "shared"
    if view ~= "shared" and not set.specs[view] then view = spec or "shared" end
    local list, seen = {}, {}
    local function Add(macros)
        for _, macro in ipairs(macros or {}) do
            if not seen[macro.name] then
                seen[macro.name] = true
                list[#list + 1] = macro
            end
        end
    end
    Add(set.shared)
    if view ~= "shared" then Add(set.specs[view]) end
    return list, class, view
end

-- Prints the character's spec and every spell in its spellbook, to check
-- the spell names in Data.lua against this client.
function ns.ListSpells()
    local class, spec = ns.ClassAndSpec()
    local count = "?"
    if type(GetNumSpecializations) == "function" then
        local ok, n = pcall(GetNumSpecializations)
        if ok then count = tostring(n) end
    end
    ns.Print(("Class %s, spec %s (the game offers %s specs)."):format(tostring(class), tostring(spec or "none chosen"), count))
    local names = {}
    local ok = pcall(function()
        local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or 0
        for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
            local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
            if info and not info.shouldHide then
                for index = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
                    local name = C_SpellBook.GetSpellBookItemName(index, bank)
                    if name then names[#names + 1] = name end
                end
            end
        end
    end)
    if not ok or #names == 0 then
        ns.Print("Could not read the spellbook on this client.")
        return
    end
    ns.Print(#names .. " spells: " .. table.concat(names, ", "))
end

local function Exists(name)
    local ok, index = pcall(GetMacroIndexByName, name)
    return ok and type(index) == "number" and index > 0
end
ns.Exists = Exists

local function FreeSlots()
    local max = MAX_CHARACTER_MACROS or 18
    local ok, _, perCharacter = pcall(GetNumMacros)
    if not ok or type(perCharacter) ~= "number" then return max end
    return max - perCharacter
end

-- The first spell a macro needs that this character does not know.
local function MissingSpell(macro)
    for _, spell in ipairs(macro.spells or {}) do
        if not ns.Knows(spell) then return spell end
    end
end

-- Where a macro stands for this character: "have" (in the macro list),
-- "needs" (a spell it uses is not learned yet; also returns that spell) or
-- "ready" (can be added).
function ns.Status(macro)
    if Exists(macro.name) then return "have" end
    local missing = MissingSpell(macro)
    if missing then return "needs", missing end
    return "ready"
end

-- Adds a single macro, from the window. Returns whether it was added.
function ns.AddOne(macro)
    if InCombatLockdown() then
        ns.Print("Macros cannot be added in combat.")
        return false
    end
    if ns.Status(macro) ~= "ready" then return false end
    if FreeSlots() <= 0 then
        ns.Print("Your character macros are full, so " .. macro.name .. " was not added.")
        return false
    end
    local ok, index = pcall(CreateMacro, macro.name, ICON, macro.body, true)
    if ok and index then
        ns.char.made[macro.name] = true
        ns.Print("Added " .. macro.name .. ". Drag it from this window or /macro to your bars.")
        ns.RefreshWindow()
        return true
    end
    ns.Print("The game would not create " .. macro.name .. ".")
    return false
end

-- Adds the macros this character is missing. With quiet, says nothing
-- unless something was added.
function ns.Install(quiet)
    if InCombatLockdown() then
        ns.pending = true
        ns.Print("Your macros will be added when combat ends.")
        return
    end
    local list = ns.Wanted()
    if not list then
        if not quiet then ns.Print("There are no macros for your class yet.") end
        return
    end
    local added, kept, unknown, noRoom, failed = {}, {}, {}, {}, {}
    local free = FreeSlots()
    for _, macro in ipairs(list) do
        local missing = MissingSpell(macro)
        if Exists(macro.name) then
            kept[#kept + 1] = macro.name
        elseif missing then
            unknown[#unknown + 1] = macro.name .. " (" .. missing .. ")"
        elseif free <= 0 then
            noRoom[#noRoom + 1] = macro.name
        else
            local ok, index = pcall(CreateMacro, macro.name, ICON, macro.body, true)
            if ok and index then
                added[#added + 1] = macro.name
                ns.char.made[macro.name] = true
                free = free - 1
            else
                failed[#failed + 1] = macro.name
            end
        end
    end

    if #added > 0 then
        ns.RefreshWindow()
        ns.Print("Added " .. #added .. " macros: " .. table.concat(added, ", ") .. ". Drag them from /macrokit or /macro to your bars.")
    elseif not quiet then
        ns.Print("No new macros to add.")
    end
    if quiet and #added == 0 then return end
    if #kept > 0 and not quiet then
        ns.Print("Already have: " .. table.concat(kept, ", ") .. ".")
    end
    if #unknown > 0 then
        ns.Print("Not added yet, spell not known: " .. table.concat(unknown, ", ") .. ". Type /macrokit once you have learned them.")
    end
    if #noRoom > 0 then
        ns.Print("No room for: " .. table.concat(noRoom, ", ") .. ". Your character macros are full.")
    end
    if #failed > 0 then
        ns.Print("The game would not create: " .. table.concat(failed, ", ") .. ".")
    end
end

-- Deletes the macros MacroKit added. Any you made yourself stay.
function ns.Remove()
    if InCombatLockdown() then
        ns.Print("Macros cannot be removed in combat.")
        return
    end
    local removed = {}
    for name in pairs(ns.char.made) do
        if Exists(name) then
            local ok = pcall(DeleteMacro, GetMacroIndexByName(name))
            if ok then removed[#removed + 1] = name end
        end
        ns.char.made[name] = nil
    end
    table.sort(removed)
    ns.RefreshWindow()
    if #removed > 0 then
        ns.Print("Removed " .. #removed .. " macros: " .. table.concat(removed, ", ") .. ".")
    else
        ns.Print("There were no MacroKit macros to remove.")
    end
end

-- Lists each macro for this character and whether it is there.
function ns.List()
    local list, class, spec = ns.Wanted()
    if not list then
        ns.Print("There are no macros for your class yet.")
        return
    end
    ns.Print("Macros for your " .. (spec and "spec" or "class") .. ":")
    for _, macro in ipairs(list) do
        local missing = MissingSpell(macro)
        local status
        if Exists(macro.name) then status = "|cff40ff40in your macros|r"
        elseif missing then status = "|cff999999needs " .. missing .. "|r"
        else status = "|cffffd100will be added|r" end
        ns.Print("  " .. macro.name .. " - " .. status)
    end
end

-- Adds this spec's macros the first time it is played.
function ns.AutoInstall()
    if not ns.char or not ns.char.auto then return end
    local list, _, spec = ns.Wanted()
    if not list then return end
    local key = spec or "any"
    if ns.char.done[key] then return end
    ns.char.done[key] = true
    ns.Install(true)
end

SLASH_MACROKIT1 = "/macrokit"
SlashCmdList.MACROKIT = function(msg)
    local command, rest = (msg or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
    if command == "" or command == "window" then
        ns.ToggleWindow()
    elseif command == "install" or command == "add" then
        ns.Install(false)
    elseif command == "button" then
        ns.db.minimapButton = not ns.db.minimapButton
        ns.UpdateMinimapButton()
        ns.Print("Minimap button " .. (ns.db.minimapButton and "shown." or "hidden."))
    elseif command == "list" then
        ns.List()
    elseif command == "spells" then
        ns.ListSpells()
    elseif command == "remove" then
        ns.Remove()
    elseif command == "auto" then
        if rest == "on" then ns.char.auto = true
        elseif rest == "off" then ns.char.auto = false
        else ns.char.auto = not ns.char.auto end
        ns.Print(ns.char.auto and "Will add macros by itself the first time you play each spec."
            or "Will only add macros when you ask.")
        ns.RefreshWindow()
    else
        ns.Print("/macrokit - open the MacroKit window")
        ns.Print("/macrokit add - add the macros you are missing")
        ns.Print("/macrokit list - show the macros and whether you have them, in chat")
        ns.Print("/macrokit remove - delete the macros MacroKit added")
        ns.Print("/macrokit auto on|off - add macros by itself for each new spec")
        ns.Print("/macrokit button - show or hide the minimap button")
        ns.Print("/macrokit spells - list your spec and spellbook, to report spell names")
    end
end

-- Entry in the minimap's addon list.
function MacroKit_OnAddonCompartmentClick()
    ns.ToggleWindow()
end

-- Exposed for the tests.
ns.MAX_NAME, ns.MAX_BODY = MAX_NAME, MAX_BODY

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg)
    if event == "ADDON_LOADED" then
        if arg ~= addonName then return end
        MacroKitCharDB = MacroKitCharDB or {}
        for key, value in pairs(defaults) do
            if MacroKitCharDB[key] == nil then
                MacroKitCharDB[key] = type(value) == "table" and {} or value
            end
        end
        ns.char = MacroKitCharDB
        MacroKitDB = MacroKitDB or {}
        for key, value in pairs(accountDefaults) do
            if MacroKitDB[key] == nil then MacroKitDB[key] = value end
        end
        ns.db = MacroKitDB
        ns.UpdateMinimapButton()
        self:UnregisterEvent("ADDON_LOADED")
        -- Registering an event this client does not have throws, hence pcall.
        for _, name in ipairs({ "PLAYER_ENTERING_WORLD", "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_REGEN_ENABLED",
                "PLAYER_REGEN_DISABLED", "UPDATE_MACROS", "SPELLS_CHANGED" }) do
            pcall(self.RegisterEvent, self, name)
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        ns.RefreshWindow()
        if ns.pending then
            ns.pending = nil
            ns.Install(false)
        end
    elseif event == "PLAYER_REGEN_DISABLED" or event == "UPDATE_MACROS" or event == "SPELLS_CHANGED" then
        -- The window's buttons and states follow these.
        ns.RefreshWindow()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" and arg and arg ~= "player" then
        return
    else
        ns.RefreshWindow()
        -- Spells can still be loading on arrival, so it waits a moment.
        C_Timer.After(3, ns.AutoInstall)
    end
end)
