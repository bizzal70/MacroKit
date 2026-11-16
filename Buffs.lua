local addonName, ns = ...

-- Missing buffs: a small row of glowing icons for the self-buffs this
-- character should have up but does not, or that are about to run out.
-- Click an icon to cast that buff on yourself.
--
-- Logic:
--   * Only buffs whose spell the character has learned are asked for.
--   * Each reminder lists every buff that counts (any armor, any aspect,
--     the single or the group version), so the one you chose is respected;
--     clicking casts the first one learned from its `cast` list.
--   * A buff with little time left also shows, with the time: under 2
--     minutes for long buffs, under 30 seconds for short ones.
--   * Nothing shows while dead, mounted or on a flight.
--   * In combat the row stays as it was: the game does not let addons
--   change click-to-cast buttons in combat, and hides buff details from
--   them then. It catches up as soon as combat ends.

local ICON_SIZE = 36
local GAP = 6
local LONG_BUFF = 5 * 60          -- seconds: buffs longer than this...
local WARN_LONG, WARN_SHORT = 120, 30   -- ...warn this early, else this early

-- By class: what to look for. `any`: buff names that count. `cast`: spells
-- to cast, first learned wins. `weapon`: a weapon enchant rather than a buff.
ns.BUFFS = {
    PRIEST = {
        { any = { "Power Word: Fortitude", "Prayer of Fortitude" }, cast = { "Power Word: Fortitude" } },
        { any = { "Inner Fire" }, cast = { "Inner Fire" } },
        { any = { "Divine Spirit", "Prayer of Spirit" }, cast = { "Divine Spirit" } },
    },
    MAGE = {
        { any = { "Arcane Intellect", "Arcane Brilliance" }, cast = { "Arcane Intellect" } },
        { any = { "Molten Armor", "Mage Armor", "Ice Armor", "Frost Armor" },
          cast = { "Molten Armor", "Ice Armor", "Mage Armor", "Frost Armor" } },
    },
    WARLOCK = {
        { any = { "Fel Armor", "Demon Armor", "Demon Skin" }, cast = { "Fel Armor", "Demon Armor", "Demon Skin" } },
    },
    DRUID = {
        { any = { "Mark of the Wild", "Gift of the Wild" }, cast = { "Mark of the Wild" } },
        { any = { "Thorns" }, cast = { "Thorns" } },
        { any = { "Omen of Clarity" }, cast = { "Omen of Clarity" } },
    },
    PALADIN = {
        { any = { "Blessing of Might", "Blessing of Wisdom", "Blessing of Kings", "Blessing of Sanctuary",
                  "Greater Blessing of Might", "Greater Blessing of Wisdom", "Greater Blessing of Kings" },
          cast = { "Blessing of Might", "Blessing of Wisdom" } },
        { any = { "Devotion Aura", "Retribution Aura", "Concentration Aura", "Crusader Aura",
                  "Shadow Resistance Aura", "Frost Resistance Aura", "Fire Resistance Aura" },
          cast = { "Devotion Aura", "Retribution Aura" } },
    },
    SHAMAN = {
        { any = { "Lightning Shield", "Water Shield" }, cast = { "Lightning Shield", "Water Shield" } },
        { weapon = true, cast = { "Windfury Weapon", "Flametongue Weapon", "Frostbrand Weapon", "Rockbiter Weapon" } },
    },
    WARRIOR = {
        { any = { "Battle Shout", "Commanding Shout" }, cast = { "Battle Shout" } },
    },
    HUNTER = {
        { any = { "Aspect of the Hawk", "Aspect of the Monkey", "Aspect of the Cheetah", "Aspect of the Pack",
                  "Aspect of the Wild", "Aspect of the Viper", "Aspect of the Dragonhawk", "Aspect of the Beast" },
          cast = { "Aspect of the Hawk", "Aspect of the Monkey" } },
        { any = { "Trueshot Aura" }, cast = { "Trueshot Aura" } },
    },
}

-- The first learned spell of a list, or nil.
local function FirstLearned(list)
    for _, spell in ipairs(list or {}) do
        if ns.Learned(spell) then return spell end
    end
end

local function Usable(value)
    return value ~= nil and not (issecretvalue and issecretvalue(value))
end

-- Whether the player has any of these buffs, and the seconds left on it
-- (nil when it never runs out). Returns nil, "unknown" when the game will
-- not say (no API, or the answer is hidden), so nothing is shown wrongly.
local function FindBuff(names)
    if not (C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName) then return nil, "unknown" end
    for _, name in ipairs(names) do
        local ok, aura = pcall(C_UnitAuras.GetAuraDataBySpellName, "player", name, "HELPFUL")
        if not ok then return nil, "unknown" end
        if aura ~= nil then
            if type(aura) ~= "table" then return nil, "unknown" end
            local expires, duration = aura.expirationTime, aura.duration
            if not Usable(expires) or not Usable(duration) then return true, nil, nil end
            if expires == 0 or duration == 0 then return true, nil, nil end
            return true, expires - GetTime(), duration
        end
    end
    return false
end

-- Whether the main hand has a weapon enchant (shaman imbues), and the
-- seconds left.
local function FindWeaponEnchant()
    if type(GetWeaponEnchantInfo) ~= "function" then return nil, "unknown" end
    local ok, has, expiresMs = pcall(GetWeaponEnchantInfo)
    if not ok or not Usable(has) then return nil, "unknown" end
    if not has then return false end
    if Usable(expiresMs) and type(expiresMs) == "number" then return true, expiresMs / 1000, 30 * 60 end
    return true
end

-- Whether now is a time to remind at all.
local function Quiet()
    local function Yes(fn, ...)
        if type(fn) ~= "function" then return false end
        local ok, value = pcall(fn, ...)
        return ok and Usable(value) and value and true or false
    end
    return Yes(UnitIsDeadOrGhost, "player") or Yes(IsMounted) or Yes(UnitOnTaxi, "player")
end

-- What to show right now: a list of { spell =, left = seconds or nil }.
function ns.MissingBuffs()
    if not ns.db or ns.db.buffReminder == false or Quiet() then return {} end
    local _, class = UnitClass("player")
    local wanted = {}
    for _, buff in ipairs(ns.BUFFS[class] or {}) do
        local spell = FirstLearned(buff.cast)
        if spell then
            local has, left, duration
            if buff.weapon then
                has, left, duration = FindWeaponEnchant()
            else
                has, left, duration = FindBuff(buff.any)
            end
            if has == false then
                wanted[#wanted + 1] = { spell = spell }
            elseif has == true and left and duration then
                local warn = duration > LONG_BUFF and WARN_LONG or WARN_SHORT
                if left < warn then wanted[#wanted + 1] = { spell = spell, left = math.max(0, left) } end
            end
        end
    end
    return wanted
end

---------------------------------------------------------------------------
-- The row of icons
---------------------------------------------------------------------------

local bar
local icons = {}

-- Hiding an icon once it has been clicked, in combat too. Addon code may
-- not hide a click-to-cast button in combat, but the game's restricted
-- "secure snippets" may. The snippet runs on the release of the click,
-- which always comes after the spell is cast, whichever of press or
-- release the game casts on. A cast that failed (no mana, too soon) is
-- noticed when combat ends, and the icon comes back then.
local secureHeader
local HIDE_PRE = [[ if not down then return nil, "hide" end ]]
local HIDE_POST = [[ if message == "hide" then self:Hide() end ]]
local function HideOnClick(button)
    if not secureHeader then
        local ok, header = pcall(CreateFrame, "Frame", addonName .. "BuffSecure", UIParent, "SecureHandlerBaseTemplate")
        if not ok or not header or not header.WrapScript then return end
        secureHeader = header
    end
    pcall(secureHeader.WrapScript, secureHeader, button, "OnClick", HIDE_PRE, HIDE_POST)
end

local function SavePosition()
    local point, _, relativePoint, x, y = bar:GetPoint()
    if point then ns.db.buffPoint = { point, relativePoint, x, y } end
end

local function CreateIcon(index)
    -- A secure button, so a click can cast a spell.
    local button = CreateFrame("Button", addonName .. "Buff" .. index, bar, "SecureActionButtonTemplate")
    button:SetSize(ICON_SIZE, ICON_SIZE)
    -- Both: the game's click-to-cast code acts on the press or the release,
    -- whichever the "cast on key down" setting (ActionButtonUseKeyDown, on
    -- by default) says, and ignores the other. With "AnyUp" alone, clicks
    -- did nothing while that setting was on (0.11.0-0.11.1).
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:SetAttribute("type", "spell")
    button:SetAttribute("unit", "player")
    HideOnClick(button)

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- A pulsing gold frame, to catch the eye.
    button.glow = button:CreateTexture(nil, "OVERLAY")
    button.glow:SetPoint("TOPLEFT", -4, 4)
    button.glow:SetPoint("BOTTOMRIGHT", 4, -4)
    button.glow:SetColorTexture(1, 0.82, 0.2, 0.55)
    button.glow:SetDrawLayer("BACKGROUND")
    -- The pulse is a nicety: without animations the frame simply stays lit.
    pcall(function()
        local pulse = button.glow:CreateAnimationGroup()
        pulse:SetLooping("BOUNCE")
        local fade = pulse:CreateAnimation("Alpha")
        fade:SetFromAlpha(0.25)
        fade:SetToAlpha(1)
        fade:SetDuration(0.8)
        pulse:Play()
        button.pulse = pulse
    end)

    -- The global cooldown's sweep, so it is clear when a tap would work.
    local okCd, cd = pcall(CreateFrame, "Cooldown", nil, button, "CooldownFrameTemplate")
    if okCd and cd then
        cd:SetAllPoints()
        button.cd = cd
    end

    button.time = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    button.time:SetPoint("BOTTOM", 0, 2)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(self.spell or "?")
        GameTooltip:AddLine(self.left and "Running out: click to cast it again on yourself." or "Missing: click to cast it on yourself.", 1, 1, 1, true)
        GameTooltip:AddLine("Move this row with the Position button in /macrokit, or Shift-drag it.", 0.6, 0.6, 0.6, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function() if IsShiftKeyDown() and not InCombatLockdown() then bar:StartMoving() end end)
    button:SetScript("OnDragStop", function() bar:StopMovingOrSizing(); SavePosition() end)
    icons[index] = button
    return button
end

-- Set spots for the row, chosen by clicking through them (the Position
-- button in the window, or /macrokit buffs move): easy with a gamepad.
-- Shift-drag still places it anywhere, with a mouse.
ns.BUFF_SPOTS = {
    { label = "Above the middle", point = "CENTER", x = 0, y = 160 },
    { label = "Below the middle", point = "CENTER", x = 0, y = -160 },
    { label = "Top of the screen", point = "TOP", x = 0, y = -110 },
    { label = "Bottom, above the bars", point = "BOTTOM", x = 0, y = 220 },
    { label = "Left of the middle", point = "CENTER", x = -280, y = 0 },
    { label = "Right of the middle", point = "CENTER", x = 280, y = 0 },
}

-- Where the row is: "Where you dragged it", or the set spot's name.
function ns.BuffSpotLabel()
    if ns.db.buffPoint then return "Where you dragged it" end
    local spot = ns.BUFF_SPOTS[ns.db.buffSpot or 1] or ns.BUFF_SPOTS[1]
    return spot.label
end

local function Place()
    bar:ClearAllPoints()
    local point = ns.db.buffPoint
    if point then
        bar:SetPoint(point[1], UIParent, point[2], point[3], point[4])
    else
        local spot = ns.BUFF_SPOTS[ns.db.buffSpot or 1] or ns.BUFF_SPOTS[1]
        bar:SetPoint(spot.point, UIParent, spot.point, spot.x, spot.y)
    end
end

local function CreateBar()
    bar = CreateFrame("Frame", addonName .. "BuffBar", UIParent)
    bar:SetSize(ICON_SIZE, ICON_SIZE)
    bar:SetMovable(true)
    bar:SetClampedToScreen(true)
    -- Shown for a few seconds after moving, so the new spot can be seen
    -- even with no buff missing.
    bar.preview = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bar.preview:SetPoint("CENTER")
    bar.preview:SetText("Missing buffs show here")
    bar.preview:Hide()
    Place()
end

local previewUntil = 0

-- Moves the row to the next set spot. Not in combat (the row holds
-- click-to-cast buttons, which the game does not let addons move then).
-- Returns the new spot's name, or nil.
function ns.NextBuffSpot()
    if not ns.db then return end
    if InCombatLockdown() then
        ns.Print("The missing-buffs row cannot be moved in combat.")
        return
    end
    if ns.db.buffPoint then
        ns.db.buffPoint = nil          -- from a dragged place, start at the first spot
        ns.db.buffSpot = 1
    else
        ns.db.buffSpot = (ns.db.buffSpot or 1) % #ns.BUFF_SPOTS + 1
    end
    if not bar then CreateBar() end
    Place()
    previewUntil = GetTime() + 4
    ns.RefreshBuffs()
    if C_Timer and C_Timer.After then C_Timer.After(4.1, function() ns.RefreshBuffs() end) end
    return ns.BuffSpotLabel()
end

local function TimeText(seconds)
    if seconds >= 60 then return ("%d:%02d"):format(seconds / 60, seconds % 60) end
    return ("%ds"):format(seconds)
end

-- Brings the row up to date. Out of combat only (see above).
function ns.RefreshBuffs()
    if not ns.db or InCombatLockdown() then return end
    if not bar then CreateBar() end
    local wanted = ns.MissingBuffs()
    for index, want in ipairs(wanted) do
        local button = icons[index] or CreateIcon(index)
        button.spell, button.left = want.spell, want.left
        button:SetAttribute("spell", want.spell)
        local texture
        if C_Spell and C_Spell.GetSpellTexture then
            local ok, t = pcall(C_Spell.GetSpellTexture, want.spell)
            if ok then texture = t end
        end
        button.icon:SetTexture(texture or 134400)
        button.time:SetText(want.left and TimeText(want.left) or "")
        button:ClearAllPoints()
        button:SetPoint("LEFT", bar, "LEFT", (index - 1) * (ICON_SIZE + GAP), 0)
        button:Show()
    end
    for index = #wanted + 1, #icons do icons[index]:Hide() end
    bar:SetWidth(math.max(1, #wanted) * (ICON_SIZE + GAP) - GAP)
    local previewing = #wanted == 0 and GetTime() < previewUntil
    bar.preview:SetShown(previewing)
    if previewing then bar:SetWidth(ICON_SIZE * 5) end
    bar:SetShown(#wanted > 0 or previewing)
    if ns.UpdateGlobalCooldown then ns.UpdateGlobalCooldown() end
end

function ns.BuffBar() return bar, icons end

---------------------------------------------------------------------------
-- The global cooldown
--
-- While it runs, a tap would only bring "Spell is not ready yet", and
-- hide the icon. So during it:
--   * every icon shows the cooldown sweep (in combat too), and
--   * out of combat the icons are switched off, greyed, and switched back
--     on as it ends. In combat the game does not let addons switch
--     click-to-cast buttons off, so only the sweep shows then.
-- The icons are always switched back on when combat starts
-- (PLAYER_REGEN_DISABLED comes just before the game locks them), so they
-- can never be left off for a fight.
---------------------------------------------------------------------------

-- Each icon reads its own spell's cooldown, which includes the global
-- cooldown. (The modern game also reports the global cooldown alone, as
-- spell 61304, but Forever does not have that spell: it answers nil,
-- tested in game 2026-11-16.) A buff with a cooldown of its own stays
-- greyed until that is ready too.

-- A spell's cooldown: start and length in seconds, or nil when it is ready
-- or the game will not say.
function ns.SpellCooldown(spell)
    if not spell or not (C_Spell and C_Spell.GetSpellCooldown) then return nil end
    local ok, info = pcall(C_Spell.GetSpellCooldown, spell)
    if not ok or type(info) ~= "table" then return nil end
    local start, duration = info.startTime, info.duration
    if not Usable(start) or not Usable(duration) or type(duration) ~= "number" or duration <= 0 then return nil end
    if start + duration <= GetTime() then return nil end
    return start, duration
end

local function SetIconEnabled(button, enabled)
    if InCombatLockdown() then return end
    pcall(button.SetEnabled, button, enabled)
    button.icon:SetDesaturated(not enabled)
end

local enableTimer = false
-- In combat Forever hides cooldowns from addons (secret values): they
-- cannot be compared, so nothing can be switched off, but they can be
-- handed to the sweep as they are, which draws them. Hiding them is also
-- why the icons cannot grey out in combat.
local function SweepInCombat(button)
    if not (button.cd and button.spell and C_Spell) then return end
    if C_Spell.GetSpellCooldownDuration and button.cd.SetCooldownFromDurationObject then
        local ok, durationObject = pcall(C_Spell.GetSpellCooldownDuration, button.spell)
        if ok and durationObject ~= nil and pcall(button.cd.SetCooldownFromDurationObject, button.cd, durationObject) then
            return
        end
    end
    if C_Spell.GetSpellCooldown then
        local ok, info = pcall(C_Spell.GetSpellCooldown, button.spell)
        if ok and type(info) == "table" then
            pcall(button.cd.SetCooldown, button.cd, info.startTime, info.duration)
        end
    end
end

function ns.UpdateGlobalCooldown()
    if InCombatLockdown() then
        for _, button in ipairs(icons) do
            if button:IsShown() then SweepInCombat(button) end
        end
        return
    end
    local soonest
    for _, button in ipairs(icons) do
        local start, duration = ns.SpellCooldown(button:IsShown() and button.spell or nil)
        if button.cd then
            if start then pcall(button.cd.SetCooldown, button.cd, start, duration) else pcall(button.cd.Clear, button.cd) end
        end
        SetIconEnabled(button, start == nil)
        if start then
            local ends = start + duration
            if not soonest or ends < soonest then soonest = ends end
        end
    end
    -- Switch them back on as their cooldowns end.
    if soonest and not enableTimer and C_Timer and C_Timer.After then
        enableTimer = true
        C_Timer.After(math.max(0.05, soonest - GetTime() + 0.05), function()
            enableTimer = false
            ns.UpdateGlobalCooldown()
        end)
    end
end

local function SetIconsEnabled(enabled)
    for _, button in ipairs(icons) do SetIconEnabled(button, enabled) end
end

local gcdWatcher = CreateFrame("Frame")
pcall(gcdWatcher.RegisterEvent, gcdWatcher, "SPELL_UPDATE_COOLDOWN")
pcall(gcdWatcher.RegisterEvent, gcdWatcher, "PLAYER_REGEN_DISABLED")
gcdWatcher:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        SetIconsEnabled(true)     -- never into a fight switched off
    else
        ns.UpdateGlobalCooldown()
    end
end)

local watcher = CreateFrame("Frame")
-- A failed cast (UNIT_SPELLCAST_FAILED, or an error such as "Spell is not
-- ready yet") brings a tapped icon straight back, out of combat. In combat
-- the game does not let addons show it again, so it waits for the end.
local PLAYER_EVENTS = { UNIT_AURA = true, UNIT_INVENTORY_CHANGED = true,
    UNIT_SPELLCAST_FAILED = true, UNIT_SPELLCAST_FAILED_QUIET = true, UNIT_SPELLCAST_INTERRUPTED = true }
for _, event in ipairs({ "UNIT_AURA", "PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD", "SPELLS_CHANGED",
        "PLAYER_MOUNT_DISPLAY_CHANGED", "UNIT_INVENTORY_CHANGED", "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST",
        "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_FAILED_QUIET", "UNIT_SPELLCAST_INTERRUPTED", "UI_ERROR_MESSAGE" }) do
    pcall(watcher.RegisterEvent, watcher, event)
end
watcher:SetScript("OnEvent", function(_, event, unit)
    if PLAYER_EVENTS[event] and unit ~= "player" then return end
    ns.RefreshBuffs()
end)
-- Every few seconds as well, for buffs running out and weapon enchants
-- (which send no event when they fade).
if C_Timer and C_Timer.NewTicker then
    C_Timer.NewTicker(5, function() ns.RefreshBuffs() end)
end
