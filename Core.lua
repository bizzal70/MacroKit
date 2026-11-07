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
    auto = true,   -- add macros by itself as their spells are learned
    view = nil,    -- the spec picked in the window's menu, before talents show it
    lastSpec = nil, -- the spec last worked out, so a change resets the view
    seen = {},     -- macro name -> true once announced as newly ready
    fresh = {},    -- macro name -> true: new since the window was last opened
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

-- Whether the character has certainly learned a spell (unlike ns.Knows,
-- an unanswered question counts as no).
function ns.Learned(name)
    if not (C_Spell and C_Spell.GetSpellInfo) or type(IsPlayerSpell) ~= "function" then return false end
    local ok, info = pcall(C_Spell.GetSpellInfo, name)
    if not ok or type(info) ~= "table" or not info.spellID then return false end
    local ok2, known = pcall(IsPlayerSpell, info.spellID)
    return ok2 and known == true
end

-- Talent points in each tree, from the trait system, the way Forever's own
-- talent frame draws its tree headers (Blizzard_PlayerSpells/Camelot,
-- ClassTalentsFrameMixin:RefreshTreeHeaders, build 70862): the class tree's
-- groups are the three talent trees, and each group's first currency says
-- how many points are spent in it.
local function TraitPoints()
    if not (C_ClassTalents and C_ClassTalents.GetActiveConfigID and C_Traits and C_Traits.GetConfigInfo
        and C_Traits.GetGroupDisplayInfoByTreeID and C_Traits.GetGroupCurrencyInfo) then return nil end
    local ok, points, names = pcall(function()
        local configID = C_ClassTalents.GetActiveConfigID()
        if not configID and C_SpecializationInfo and C_SpecializationInfo.GetCombatConfigIDForSpecGroup
            and C_SpecializationInfo.GetActiveSpecGroup then
            configID = C_SpecializationInfo.GetCombatConfigIDForSpecGroup(C_SpecializationInfo.GetActiveSpecGroup())
        end
        if not configID then return nil end
        local config = C_Traits.GetConfigInfo(configID)
        local treeID = config and config.treeIDs and config.treeIDs[1]
        if not treeID then return nil end
        local displays = C_Traits.GetGroupDisplayInfoByTreeID(treeID)
        if type(displays) ~= "table" or #displays == 0 then return nil end
        local ids = {}
        for _, display in ipairs(displays) do ids[#ids + 1] = display.groupID end
        local infos = C_Traits.GetGroupCurrencyInfo(configID, ids) or {}
        local spent, labels = {}, {}
        for index, display in ipairs(displays) do
            spent[index] = 0
            labels[index] = display.displayName
            for _, info in ipairs(infos) do
                if info.traitNodeGroupID == display.groupID and info.currencyInfos and info.currencyInfos[1] then
                    spent[index] = tonumber(info.currencyInfos[1].spent) or 0
                end
            end
        end
        return spent, labels
    end)
    if ok and points then return points, names end
end

-- Talent points spent in each tree, in the game's order, with each tree's
-- name where the game gives one. Nil if this client reports neither way.
-- The trait system first (Forever); then the classic talent functions,
-- which Forever no longer has but older clients do, in either layout:
-- (name, icon, points, ...) or (id, name, description, icon, points, ...).
function ns.TalentPoints()
    local points, names = TraitPoints()
    if points then return points, names end
    if type(GetNumTalentTabs) ~= "function" or type(GetTalentTabInfo) ~= "function" then return nil end
    local ok, count = pcall(GetNumTalentTabs)
    if not ok or type(count) ~= "number" or count < 1 then return nil end
    local points, names = {}, {}
    for tab = 1, count do
        local ok2, a, b, c, d, e = pcall(GetTalentTabInfo, tab)
        if not ok2 then return nil end
        local spent, name
        if type(a) == "number" then spent, name = e, b else spent, name = c, a end
        points[tab] = type(spent) == "number" and spent or 0
        names[tab] = type(name) == "string" and name or nil
    end
    return points, names
end

-- The character's class and spec ID, and how the spec was found:
--   "game"          a specialization the game reports (and MacroKit has macros for)
--   "talent points" the tree with the most points (Forever: classic talent trees)
--   "talent spell"  a talent spell only one tree gives, if points cannot be read
-- The spec is nil while none of these says.
function ns.ClassAndSpec()
    local _, class = UnitClass("player")
    local set = ns.SETS[class]
    local specs = set and set.specs or {}
    if type(GetSpecialization) == "function" and type(GetSpecializationInfo) == "function" then
        local ok, index = pcall(GetSpecialization)
        if ok and type(index) == "number" and index > 0 then
            local ok2, id = pcall(GetSpecializationInfo, index)
            if ok2 and type(id) == "number" and specs[id] then return class, id, "game" end
        end
    end
    if set and set.order and #set.order > 0 then
        local points, names = ns.TalentPoints()
        if points then
            local best, most = nil, 0
            for tab, spent in ipairs(points) do
                if spent > most then best, most = tab, spent end
            end
            if best then
                -- The tree's name decides when it matches one of the class's;
                -- otherwise its position does.
                local name = names and names[best]
                if type(name) == "string" and set.names then
                    for id, specName in pairs(set.names) do
                        if specName:lower() == name:lower() or specName:lower():find(name:lower(), 1, true) == 1 then
                            return class, id, "talent points"
                        end
                    end
                end
                if set.order[best] then return class, set.order[best], "talent points" end
            end
        end
    end
    if set and set.treeSpells then
        for _, id in ipairs(set.order or {}) do
            for _, spell in ipairs(set.treeSpells[id] or {}) do
                if ns.Learned(spell) then return class, id, "talent spell" end
            end
        end
    end
    return class, nil
end

-- Macros MacroKit added for a spec the character is no longer: still in the
-- macro list, but no longer among the macros wanted now.
function ns.StaleMacros()
    local class = ns.ClassAndSpec()
    local set = ns.SETS[class]
    if not set or not set.specs or not ns.char then return {} end
    local wanted = {}
    for _, macro in ipairs(ns.Wanted() or {}) do wanted[macro.name] = true end
    local stale = {}
    for _, id in ipairs(set.order or {}) do
        for _, macro in ipairs(set.specs[id] or {}) do
            if ns.char.made[macro.name] and not wanted[macro.name] and ns.Exists(macro.name) then
                stale[#stale + 1] = macro.name
            end
        end
    end
    table.sort(stale)
    return stale
end

-- Deletes the macros MacroKit added for the old spec.
function ns.ClearStale()
    if InCombatLockdown() then
        ns.Print("Macros cannot be removed in combat.")
        return
    end
    local stale = ns.StaleMacros()
    for _, name in ipairs(stale) do
        pcall(DeleteMacro, GetMacroIndexByName(name))
        ns.char.made[name] = nil
    end
    if #stale > 0 then
        ns.Print("Cleared " .. #stale .. " macro" .. (#stale > 1 and "s" or "") .. " from your old spec: " .. table.concat(stale, ", ") .. ".")
    else
        ns.Print("There are no macros from an old spec to clear.")
    end
    ns.RefreshWindow()
end

-- Says what the game reports about talents, to check spec detection.
function ns.ListTalents()
    local class, spec, how = ns.ClassAndSpec()
    local set = ns.SETS[class]
    local points, names = ns.TalentPoints()
    if points then
        local parts = {}
        for tab, spent in ipairs(points) do
            parts[#parts + 1] = (names and names[tab] or ("tree " .. tab)) .. " " .. spent
        end
        ns.Print("Talent points: " .. table.concat(parts, ", ") .. ".")
    else
        ns.Print("This client does not report talent points to addons.")
    end
    local group, groups
    if C_SpecializationInfo and C_SpecializationInfo.GetActiveSpecGroup then
        local ok, value = pcall(C_SpecializationInfo.GetActiveSpecGroup)
        if ok then group = value end
        if type(GetNumSpecGroups) == "function" then
            local ok2, count = pcall(GetNumSpecGroups)
            if ok2 then groups = count end
        end
    elseif type(GetActiveTalentGroup) == "function" then
        local ok, value = pcall(GetActiveTalentGroup)
        if ok then group = value end
        if type(GetNumTalentGroups) == "function" then
            local ok2, count = pcall(GetNumTalentGroups)
            if ok2 then groups = count end
        end
    end
    if group then ns.Print("Active talent set: " .. tostring(group) .. (groups and (" of " .. groups) or "") .. ".") end
    ns.Print("Spec: " .. (spec and ns.SpecName(class, spec) or "none yet") .. (how and (" (from " .. how .. ")") or "") .. ".")
end

-- The spec whose macros to use: the one worked out from the game or the
-- talents, else the one picked in the window's menu. Nil: shared only.
function ns.ActiveSpec()
    local class, spec = ns.ClassAndSpec()
    if spec then return spec end
    local set = ns.SETS[class]
    local view = ns.char and ns.char.view
    if set and set.specs and type(view) == "number" and set.specs[view] then return view end
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
    local class = ns.ClassAndSpec()
    local spec = ns.ActiveSpec()
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
    local specs = set.specs or {}
    if spec and specs[spec] then Add(specs[spec]) end
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
    -- A class whose macros are all shared (every class in Forever, which
    -- has no specializations) gets no menu.
    if not set or not set.order or #set.order == 0 then return nil end
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
    local specs = set.specs or {}
    if view ~= "shared" and not specs[view] then view = "shared" end
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
    if view ~= "shared" then Add(specs[view]) end
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
    if quiet and #added == 0 then return added end
    if #kept > 0 and not quiet then
        ns.Print("Already have: " .. table.concat(kept, ", ") .. ".")
    end
    if #unknown > 0 then
        ns.Print("Not added yet, spell not known: " .. table.concat(unknown, ", ") .. ". They are ready once you learn the spell.")
    end
    if #noRoom > 0 then
        ns.Print("No room for: " .. table.concat(noRoom, ", ") .. ". Your character macros are full.")
    end
    if #failed > 0 then
        ns.Print("The game would not create: " .. table.concat(failed, ", ") .. ".")
    end
    return added
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

-- How many macros are new since the window was last opened, and how many
-- are ready to add, for the minimap button.
function ns.Counts()
    if not ns.char then return 0, 0 end
    local ready = ns.ReadyNames()
    local isReady, total = {}, 0
    for _, name in ipairs(ready) do isReady[name] = true end
    for name in pairs(ns.char.fresh) do
        -- Only macros still on offer: one removed since then no longer counts.
        if isReady[name] or ns.Exists(name) then total = total + 1 else ns.char.fresh[name] = nil end
    end
    for name in pairs(isReady) do
        if not ns.char.fresh[name] then total = total + 1 end
    end
    local new = 0
    for _ in pairs(ns.char.fresh) do new = new + 1 end
    return new, #ready, total
end

-- The macros that could be added right now.
function ns.ReadyNames()
    local names = {}
    for _, macro in ipairs(ns.Wanted() or {}) do
        if ns.Status(macro) == "ready" then names[#names + 1] = macro.name end
    end
    return names
end

-- Looks again at what the character knows: after a level, a trainer visit,
-- a talent, or logging in. Macros whose spells have just been learned are
-- added (with automatic adding on) or announced once (with it off). The
-- window and the minimap button's count follow. On first arrival
-- (quietStart) nothing is announced, only remembered.
function ns.CheckSpells(quietStart)
    if not ns.char then return end
    local class, spec = ns.ClassAndSpec()
    local old = ns.char.lastSpec
    if spec ~= old then
        -- The talents now show a spec, a different one (a respec, or a
        -- switch to the other talent set), or none (a reset): follow them.
        ns.char.lastSpec = spec
        ns.char.view = nil
        if not quietStart then
            if spec and old then
                ns.Print("Talents changed: you are now " .. ns.SpecName(class, spec) .. " (was " .. ns.SpecName(class, old) .. ").")
            elseif spec then
                ns.Print("Your talents show you are " .. ns.SpecName(class, spec) .. ": its macros are now on offer.")
            else
                ns.Print("Your talents were reset. Only the macros every spec shares are on offer until you spend points again.")
            end
        end
    end
    local ready = ns.ReadyNames()
    if #ready > 0 and not InCombatLockdown() then
        if ns.char.auto then
            for _, name in ipairs(ns.Install(true) or {}) do
                ns.char.fresh[name] = true
            end
        else
            local fresh = {}
            for _, name in ipairs(ready) do
                if not ns.char.seen[name] then
                    ns.char.seen[name] = true
                    ns.char.fresh[name] = true
                    fresh[#fresh + 1] = name
                end
            end
            if #fresh > 0 and not quietStart then
                ns.Print("New macro" .. (#fresh > 1 and "s" or "") .. " ready: " .. table.concat(fresh, ", ")
                    .. ". Type /macrokit or click the minimap button to add " .. (#fresh > 1 and "them." or "it."))
            end
        end
    end
    -- Macros MacroKit added for the old spec are pointed out, once per change.
    if spec ~= old and not quietStart then
        local stale = ns.StaleMacros()
        if #stale > 0 then
            ns.Print(#stale .. " macro" .. (#stale > 1 and "s" or "") .. " from your old spec no longer fit: "
                .. table.concat(stale, ", ") .. ". Clear them with the button in /macrokit, or /macrokit clear.")
        end
    end
    ns.RefreshWindow()
    ns.UpdateBadge()
end

-- Several spell events arrive together when a spell is learned, so the
-- check waits a moment and runs once.
local checkPending = false
function ns.ScheduleCheck(quietStart)
    if checkPending then return end
    checkPending = true
    C_Timer.After(1, function()
        checkPending = false
        ns.CheckSpells(quietStart)
    end)
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
    elseif command == "talents" then
        ns.ListTalents()
    elseif command == "clear" then
        ns.ClearStale()
    elseif command == "spells" then
        ns.ListSpells()
    elseif command == "remove" then
        ns.Remove()
    elseif command == "auto" then
        if rest == "on" then ns.char.auto = true
        elseif rest == "off" then ns.char.auto = false
        else ns.char.auto = not ns.char.auto end
        ns.Print(ns.char.auto and "Will add new macros by itself as you learn their spells."
            or "Will tell you about new macros, and add them only when you ask.")
        ns.RefreshWindow()
        if ns.char.auto then ns.ScheduleCheck() end
    else
        ns.Print("/macrokit - open the MacroKit window")
        ns.Print("/macrokit add - add the macros you are missing")
        ns.Print("/macrokit list - show the macros and whether you have them, in chat")
        ns.Print("/macrokit remove - delete the macros MacroKit added")
        ns.Print("/macrokit auto on|off - add new macros by itself as you learn their spells")
        ns.Print("/macrokit button - show or hide the minimap button")
        ns.Print("/macrokit spells - list your spec and spellbook, to report spell names")
        ns.Print("/macrokit talents - what the game reports about your talents")
        ns.Print("/macrokit clear - delete the macros MacroKit added for a spec you are no longer")
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
                "PLAYER_REGEN_DISABLED", "UPDATE_MACROS", "SPELLS_CHANGED", "PLAYER_LEVEL_UP", "TRAINER_CLOSED",
                "LEARNED_SPELL_IN_SKILL_LINE", "LEARNED_SPELL_IN_TAB", "CHARACTER_POINTS_CHANGED",
                "PLAYER_TALENT_UPDATE", "TRAIT_CONFIG_UPDATED", "ACTIVE_TALENT_GROUP_CHANGED",
                "CONFIRM_TALENT_WIPE", "TALENT_GROUP_ROLE_CHANGED", "TRAIT_NODE_CHANGED",
                "TRAIT_TREE_CURRENCY_INFO_UPDATED", "ACTIVE_COMBAT_CONFIG_CHANGED",
                "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" }) do
            pcall(self.RegisterEvent, self, name)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Spells can still be loading on arrival, so it waits a moment.
        ns.RefreshWindow()
        C_Timer.After(3, function() ns.CheckSpells(true) end)
    elseif event == "PLAYER_REGEN_ENABLED" then
        if ns.pending then
            ns.pending = nil
            ns.Install(false)
        end
        -- Anything learned during the fight is looked at now.
        ns.ScheduleCheck()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "UPDATE_MACROS" then
        -- The window's buttons and states follow these.
        ns.RefreshWindow()
        ns.UpdateBadge()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" and arg and arg ~= "player" then
        return
    else
        -- A spell, level, trainer or talent change: look at what is new.
        ns.ScheduleCheck()
    end
end)
