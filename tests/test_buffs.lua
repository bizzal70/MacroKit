-- Missing buffs: a row of click-to-cast icons for self-buffs that are not
-- up (or nearly out), only for learned spells, quiet while mounted or
-- dead, and left alone in combat.
NOW = 1000
GetTime = function() return NOW end
AURAS = {}           -- buff name -> { expirationTime =, duration = }
C_UnitAuras = { GetAuraDataBySpellName = function(unit, name) return AURAS[name] end }
MOUNTED, DEAD = false, false
IsMounted = function() return MOUNTED end
UnitIsDeadOrGhost = function() return DEAD end
UnitOnTaxi = function() return false end
IsShiftKeyDown = function() return false end
C_Timer.NewTicker = function() end

local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Names()
    local list = {}
    for _, want in ipairs(ns.MissingBuffs()) do list[#list + 1] = want.spell end
    return table.concat(list, ",")
end

CLASS, SPEC = "PRIEST", nil
Learn("Power Word: Fortitude", "Inner Fire")
Fire("ADDON_LOADED", "MacroKit")
check(ns.db.buffReminder == true, "the reminder is on to begin with")

check(Names() == "Power Word: Fortitude,Inner Fire", "a priest with neither buff up is reminded of both (Divine Spirit is not learned)")
AURAS["Prayer of Fortitude"] = { expirationTime = NOW + 3000, duration = 3600 }
check(Names() == "Inner Fire", "the group Fortitude counts as Fortitude")
AURAS["Inner Fire"] = { expirationTime = NOW + 500, duration = 600 }
check(Names() == "", "with both up, nothing is shown")
AURAS["Inner Fire"].expirationTime = NOW + 90
local list = ns.MissingBuffs()
check(#list == 1 and list[1].spell == "Inner Fire" and math.floor(list[1].left) == 90, "a long buff with under 2 minutes left is shown, with the time")

-- Quiet while mounted or dead.
MOUNTED = true
check(Names() == "", "nothing while mounted")
MOUNTED, DEAD = false, true
check(Names() == "", "nothing while dead")
DEAD = false

-- The row of buttons.
AURAS["Inner Fire"] = nil
ns.RefreshBuffs()
local bar, icons = ns.BuffBar()
check(bar:IsShown() and icons[1]:IsShown() and icons[1].spell == "Inner Fire", "the row shows a button for the missing buff")
check(icons[1].__attributes and icons[1].__attributes.type == "spell" and icons[1].__attributes.spell == "Inner Fire"
    and icons[1].__attributes.unit == "player", "clicking it casts Inner Fire on yourself")
AURAS["Inner Fire"] = { expirationTime = NOW + 600, duration = 600 }
ns.RefreshBuffs()
check(not bar:IsShown(), "and the row goes away once the buff is up")

-- Combat: left alone.
AURAS["Inner Fire"] = nil
IN_COMBAT = true
ns.RefreshBuffs()
check(not bar:IsShown(), "in combat the row is not changed")
IN_COMBAT = false
Fire("PLAYER_REGEN_ENABLED")
check(bar:IsShown(), "it catches up when combat ends")

-- A hidden answer (a secret value) or no aura API: nothing shown wrongly.
local real = C_UnitAuras
C_UnitAuras = nil
check(Names() == "", "without the aura API nothing is guessed")
C_UnitAuras = real

-- Any of several buffs counts; the first learned is cast.
CLASS = "MAGE"
AURAS = {}
Learn("Arcane Intellect", "Frost Armor", "Mage Armor")
check(Names() == "Arcane Intellect,Mage Armor", "a mage without armor is offered the first learned armor in order (Mage Armor before Frost Armor)")
AURAS["Frost Armor"] = { expirationTime = NOW + 1700, duration = 1800 }
check(Names() == "Arcane Intellect", "any armor counts as wearing armor")

-- Shaman weapon imbue.
CLASS = "SHAMAN"
Learn("Rockbiter Weapon", "Lightning Shield")
ENCHANT = false
GetWeaponEnchantInfo = function() return ENCHANT, 1200000 end
check(Names() == "Lightning Shield,Rockbiter Weapon", "a shaman is reminded of the shield and the weapon imbue")
ENCHANT = true
AURAS["Lightning Shield"] = { expirationTime = NOW + 500, duration = 600 }
check(Names() == "", "and not once both are on")

-- Rogues have no self-buffs to remind of.
CLASS = "ROGUE"
check(Names() == "", "a rogue is never reminded")

-- Off and on.
CLASS = "PRIEST"
AURAS = {}
SlashCmdList.MACROKIT("buffs")
check(ns.db.buffReminder == false and Names() == "", "/macrokit buffs turns it off")
SlashCmdList.MACROKIT("buffs")
check(ns.db.buffReminder == true and Names() ~= "", "and on again")
