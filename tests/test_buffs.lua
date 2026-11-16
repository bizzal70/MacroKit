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
check(table.concat(icons[1].__clicks or {}, ",") == "AnyUp,AnyDown", "the button takes both press and release, as the game's cast-on-key-down setting needs")
check(icons[1].__attributes and icons[1].__attributes.type == "spell" and icons[1].__attributes.spell == "Inner Fire"
    and icons[1].__attributes.unit == "player", "clicking it casts Inner Fire on yourself")
AURAS["Inner Fire"] = { expirationTime = NOW + 600, duration = 600 }
ns.RefreshBuffs()
check(not bar:IsShown(), "and the row goes away once the buff is up")

-- Clicking an icon hides it, in combat too, through a secure snippet run
-- on the release of the click (here run the way the game would).
local function SecureClick(button, down)
    local wrap = button.__wrap
    local pre = assert(loadstring("local self, button, down = ... " .. wrap.pre))
    local _, message = pre(button, "LeftButton", down)
    if message ~= nil then
        assert(loadstring("local self, button, down, message = ... " .. wrap.post))(button, "LeftButton", down, message)
    end
end
AURAS["Inner Fire"] = nil
ns.RefreshBuffs()
check(icons[1].__wrap and icons[1].__wrap.script == "OnClick", "each icon carries a secure snippet on its click")
IN_COMBAT = true
SecureClick(icons[1], true)
check(icons[1]:IsShown(), "pressing does not hide it yet (the spell may cast on the release)")
SecureClick(icons[1], false)
check(not icons[1]:IsShown(), "releasing hides it, even in combat")
IN_COMBAT = false
Fire("PLAYER_REGEN_ENABLED")
check(icons[1]:IsShown(), "if the buff still did not go up, the icon comes back after combat")
-- Out of combat, a failed cast brings it straight back.
SecureClick(icons[1], true); SecureClick(icons[1], false)
check(not icons[1]:IsShown(), "tapped out of combat, it hides")
Fire("UI_ERROR_MESSAGE", 51, "Spell is not ready yet")
check(icons[1]:IsShown(), "and \"Spell is not ready yet\" brings it straight back")
SecureClick(icons[1], true); SecureClick(icons[1], false)
Fire("UNIT_SPELLCAST_FAILED", "player")
check(icons[1]:IsShown(), "as does any failed cast")
SecureClick(icons[1], true); SecureClick(icons[1], false)
Fire("UNIT_SPELLCAST_FAILED", "target")
check(not icons[1]:IsShown(), "another unit's failed cast does not")
-- The global cooldown: out of combat the icons are switched off (greyed)
-- while it runs, so a tap cannot hide them uselessly; the sweep shows.
GCD = nil
C_Spell.GetSpellCooldown = function(id)
    -- Like Forever: no spell 61304; the global cooldown shows on each spell.
    if id == 61304 then return nil end
    if GCD then return { startTime = GCD.start, duration = GCD.duration } end
    return { startTime = 0, duration = 0 }
end
ns.RefreshBuffs()
GCD = { start = NOW, duration = 1.5 }
Fire("SPELL_UPDATE_COOLDOWN")
check(icons[1].__enabled == false and icons[1].icon.__desaturated == true, "during the global cooldown the icon is switched off and greyed")
check(icons[1].cd and icons[1].cd.__cooldown and icons[1].cd.__cooldown[2] == 1.5, "and shows the cooldown sweep")
NOW = NOW + 2
RunAfters()
check(icons[1].__enabled == true and icons[1].icon.__desaturated == false, "as it ends the icon is switched back on")
-- Combat starting during it: switched back on first, never left off for a fight.
GCD = { start = NOW, duration = 1.5 }
Fire("SPELL_UPDATE_COOLDOWN")
check(icons[1].__enabled == false, "off again during the next global cooldown")
Fire("PLAYER_REGEN_DISABLED")
check(icons[1].__enabled == true, "combat starting switches it back on, so it is never off for a whole fight")
IN_COMBAT = true
-- In combat the game hides the numbers (secret values): they cannot be
-- compared, only handed to the sweep, which draws them.
local SECRET_START, SECRET_LENGTH = {}, {}
local realIsSecret = issecretvalue
issecretvalue = function(v) return v == SECRET_START or v == SECRET_LENGTH end
local realGetCooldown = C_Spell.GetSpellCooldown
C_Spell.GetSpellCooldown = function() return { startTime = SECRET_START, duration = SECRET_LENGTH } end
icons[1].cd.__cooldown = nil
Fire("SPELL_UPDATE_COOLDOWN")
check(icons[1].__enabled == true, "in combat it stays clickable (the game does not allow switching it off)")
check(icons[1].cd.__cooldown and icons[1].cd.__cooldown[1] == SECRET_START and icons[1].cd.__cooldown[2] == SECRET_LENGTH,
    "and the hidden cooldown is handed straight to the sweep, which draws it")
-- Where the game offers a duration object for the sweep, that is used.
local DURATION = {}
C_Spell.GetSpellCooldownDuration = function() return DURATION end
icons[1].cd.SetCooldownFromDurationObject = function(self, d) self.__durationObject = d end
Fire("SPELL_UPDATE_COOLDOWN")
check(icons[1].cd.__durationObject == DURATION, "or its duration object, where the game has one")
C_Spell.GetSpellCooldownDuration = nil
C_Spell.GetSpellCooldown = realGetCooldown
issecretvalue = realIsSecret
IN_COMBAT = false
GCD = nil
NOW = NOW + 2
RunAfters()
Fire("SPELL_UPDATE_COOLDOWN")

AURAS["Inner Fire"] = { expirationTime = NOW + 600, duration = 600 }
ns.RefreshBuffs()

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

-- Moving the row through set spots (the gamepad-friendly way).
CLASS = "PRIEST"
AURAS = {}
check(ns.BuffSpotLabel() == "Above the middle", "the row starts above the middle of the screen")
local bar = ns.BuffBar()
check(ns.NextBuffSpot() == "Below the middle" and bar.__point and bar.__point[5] == -160, "Position moves it to the next spot")
for _ = 1, 4 do ns.NextBuffSpot() end
check(ns.BuffSpotLabel() == "Right of the middle", "through every spot")
check(ns.NextBuffSpot() == "Above the middle", "and round to the first again")
-- With nothing missing, the row still shows for a moment so its new spot can be seen.
AURAS["Power Word: Fortitude"] = { expirationTime = 0, duration = 0 }
AURAS["Inner Fire"] = { expirationTime = 0, duration = 0 }
ns.NextBuffSpot()
check(bar:IsShown() and bar.preview:IsShown(), "after moving, the row shows where it is even with nothing missing")
NOW = NOW + 5
ns.RefreshBuffs()
check(not bar:IsShown(), "and hides again a few seconds later")
-- A place dragged with the mouse, then Position: back to the set spots.
ns.db.buffPoint = { "TOPLEFT", "TOPLEFT", 50, -50 }
check(ns.BuffSpotLabel() == "Where you dragged it", "a dragged place is named as such")
check(ns.NextBuffSpot() == "Above the middle", "and Position goes back to the first set spot")
SlashCmdList.MACROKIT("buffs move")
check(ns.BuffSpotLabel() == "Below the middle", "/macrokit buffs move steps too")
SlashCmdList.MACROKIT("buffs reset")
check(ns.BuffSpotLabel() == "Above the middle", "/macrokit buffs reset goes back to the first spot")
IN_COMBAT = true
check(ns.NextBuffSpot() == nil and ns.BuffSpotLabel() == "Above the middle", "it cannot be moved in combat")
IN_COMBAT = false
AURAS = {}

-- Off and on.
CLASS = "PRIEST"
AURAS = {}
SlashCmdList.MACROKIT("buffs")
check(ns.db.buffReminder == false and Names() == "", "/macrokit buffs turns it off")
SlashCmdList.MACROKIT("buffs")
check(ns.db.buffReminder == true and Names() ~= "", "and on again")
