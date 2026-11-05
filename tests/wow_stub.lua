-- Minimal fake of the WoW API: just enough to run MacroKit end to end.
local frames = {}
local printed = {}
_G.PRINTED = printed

local function Stub()
    local o = { __scripts = {}, __events = {} }
    return setmetatable(o, { __index = function(_, k)
        if type(k) ~= "string" or not k:match("^%u") then return nil end
        if k == "SetScript" then return function(self, ev, fn) self.__scripts[ev] = fn end end
        if k == "RegisterEvent" then return function(self, ev)
            assert(not UNKNOWN_EVENTS or not UNKNOWN_EVENTS[ev], "no such event " .. ev)
            self.__events[ev] = true
        end end
        if k == "UnregisterEvent" then return function(self, ev) self.__events[ev] = nil end end
        return function() end
    end })
end

function CreateFrame(_, name) local f = Stub(); frames[#frames + 1] = f; if name then _G[name] = f end; return f end
SlashCmdList = {}
print = function(m) printed[#printed + 1] = m end
IN_COMBAT = false
InCombatLockdown = function() return IN_COMBAT end

AFTERS = {}          -- delayed callbacks, run by the tests with RunAfters()
C_Timer = { After = function(_, fn) AFTERS[#AFTERS + 1] = fn end }
function RunAfters()
    local list = AFTERS
    AFTERS = {}
    for _, fn in ipairs(list) do fn() end
end

-- The character.
CLASS, SPEC = "PALADIN", 70
UnitClass = function() return "Paladin", CLASS, 2 end
GetSpecialization = function() return SPEC and 1 or nil end
GetSpecializationInfo = function() return SPEC, "Spec" end

-- Spells: SPELL_IDS are spells the client has heard of; KNOWN are the ones
-- this character has learned.
SPELL_IDS, KNOWN = {}, {}
C_Spell = { GetSpellInfo = function(name)
    local id = SPELL_IDS[name]
    if id then return { name = name, spellID = id } end
end }
IsPlayerSpell = function(id) return KNOWN[id] or false end
local nextID = 1000
function Learn(...)
    for _, name in ipairs({ ... }) do
        if not SPELL_IDS[name] then nextID = nextID + 1; SPELL_IDS[name] = nextID end
        KNOWN[SPELL_IDS[name]] = true
    end
end

-- Macros, like the game: account-wide and per-character lists, looked up
-- by name, not allowed to change in combat.
MACROS = {}
MAX_CHARACTER_MACROS = 18
GetNumMacros = function()
    local account, character = 0, 0
    for _, m in ipairs(MACROS) do
        if m.perCharacter then character = character + 1 else account = account + 1 end
    end
    return account, character
end
GetMacroIndexByName = function(name)
    for i, m in ipairs(MACROS) do if m.name == name then return i end end
    return 0
end
CreateMacro = function(name, icon, body, perCharacter)
    assert(not IN_COMBAT, "CreateMacro in combat")
    assert(#name <= 16, "macro name too long: " .. name)
    assert(#body <= 255, "macro body too long: " .. name)
    local _, character = GetNumMacros()
    assert(not perCharacter or character < MAX_CHARACTER_MACROS, "character macros full")
    MACROS[#MACROS + 1] = { name = name, icon = icon, body = body, perCharacter = perCharacter }
    return #MACROS
end
DeleteMacro = function(index)
    assert(not IN_COMBAT, "DeleteMacro in combat")
    assert(MACROS[index], "no macro at " .. tostring(index))
    table.remove(MACROS, index)
end
function MacroNames()
    local names = {}
    for _, m in ipairs(MACROS) do names[#names + 1] = m.name end
    return table.concat(names, ",")
end

function Fire(event, ...)
    for _, f in ipairs(frames) do
        if f.__events[event] and f.__scripts.OnEvent then f.__scripts.OnEvent(f, event, ...) end
    end
end

-- The files an addon's TOC lists, in order, so a file missing from the TOC
-- is caught here rather than in game.
function TocFiles(dir, name)
    local files = {}
    local toc = assert(io.open(dir .. "/" .. name .. ".toc", "r"), "no TOC for " .. name)
    for line in toc:lines() do
        line = line:gsub("\r", ""):match("^%s*(.-)%s*$")
        if line ~= "" and line:sub(1, 1) ~= "#" then
            files[#files + 1] = (line:gsub("\\", "/"))
        end
    end
    toc:close()
    return files
end

function LoadAddon(dir, name)
    local ns = {}
    for _, file in ipairs(TocFiles(dir, name)) do
        local h = assert(io.open(dir .. "/" .. file, "r")); local src = h:read("*a"); h:close()
        assert(loadstring(src, "@" .. file))(name, ns)
    end
    return ns
end
