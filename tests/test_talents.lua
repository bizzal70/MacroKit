-- Following the character's talents: points in each tree, a respec, a
-- reset, and a switch between dual-spec talent sets.
local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Has(name) return GetMacroIndexByName(name) > 0 end
local function Said(from) return table.concat(PRINTED, " | ", from + 1) end

-- The game's talents, the later layout: id, name, description, icon, points.
TABS = { { "Holy", 0 }, { "Protection", 0 }, { "Retribution", 0 } }
GROUP, GROUPS = 1, 2
GetNumTalentTabs = function() return #TABS end
GetTalentTabInfo = function(tab) return 100 + tab, TABS[tab][1], "desc", "icon", TABS[tab][2] end
GetActiveTalentGroup = function() return GROUP end
GetNumTalentGroups = function() return GROUPS end
local function Spend(holy, prot, ret) TABS[1][2], TABS[2][2], TABS[3][2] = holy, prot, ret end
-- Talent spells come and go with the points, as in the game.
local function Unlearn(...) for _, name in ipairs({ ... }) do KNOWN[SPELL_IDS[name]] = nil end end

SPEC = nil
Learn("Holy Strike", "Holy Light", "Seal of Righteousness", "Seal of the Crusader", "Judgement",
    "Seal of Fury", "Righteous Fury")
Fire("ADDON_LOADED", "MacroKit")
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(select(2, ns.ClassAndSpec()) == nil, "with no points spent there is no spec")

-- Spending points: the tree with the most points is the spec.
Spend(0, 0, 5)
Learn("Seal of Command", "Repentance")
local before = #PRINTED
Fire("CHARACTER_POINTS_CHANGED")
RunAfters()
local _, spec, how = ns.ClassAndSpec()
check(spec == 70 and how == "talent points", "five points in Retribution make the character Retribution, read from the talent points")
check(Said(before):find("Your talents show you are Retribution", 1, true), "and it says so: " .. Said(before))
check(Has("Command") and Has("Repent") and not Has("Tank Up"), "Retribution's macros are added")

-- A respec into Protection.
Spend(0, 11, 0)
Unlearn("Seal of Command", "Repentance")
before = #PRINTED
Fire("PLAYER_TALENT_UPDATE")
RunAfters()
check(select(2, ns.ClassAndSpec()) == 66, "after a respec into Protection, the spec follows")
check(Said(before):find("Talents changed: you are now Protection (was Retribution)", 1, true), "and it says so: " .. Said(before))
check(Has("Tank Up") and Has("Taunt"), "Protection's macros are added")
check(Has("Command") and Has("Repent"), "Retribution's are not deleted by themselves")
check(Said(before):find("2 macros from your old spec no longer fit: Command, Repent", 1, true), "but are pointed out: " .. Said(before))
local stale = ns.StaleMacros()
check(#stale == 2 and stale[1] == "Command" and stale[2] == "Repent", "MacroKit knows which of its macros belong to the old spec")

-- The window shows them with a Clear button.
SlashCmdList.MACROKIT("")
check(MacroKitStaleBar.__shown, "the window shows a notice about the old spec's macros")
local clear
for _, f in ipairs(Frames()) do
    if rawget(f, "label") and f.label.__text == "Clear them" then clear = f end
end
IN_COMBAT = true
Fire("PLAYER_REGEN_DISABLED")
clear.__scripts.OnClick(clear)
check(Has("Command") and clear.active == false, "in combat the Clear button is greyed out and does nothing")
IN_COMBAT = false
Fire("PLAYER_REGEN_ENABLED")
RunAfters()
clear.__scripts.OnClick(clear)
check(not Has("Command") and not Has("Repent") and Has("Tank Up") and Has("Holy Strike"), "Clear deletes only the old spec's macros")
check(not MacroKitStaleBar.__shown, "and the notice goes")
SlashCmdList.MACROKIT("")

-- Switching to the second talent set (dual spec) that is Holy.
GROUP = 2
Spend(21, 0, 0)
Learn("Holy Shock")
before = #PRINTED
Fire("ACTIVE_TALENT_GROUP_CHANGED", 2, 1)
RunAfters()
check(select(2, ns.ClassAndSpec()) == 65 and Has("Holy Shock"), "switching talent sets to a Holy one switches to Holy and adds its macros")
check(Said(before):find("Talents changed: you are now Holy (was Protection)", 1, true), "and says so: " .. Said(before))
before = #PRINTED
SlashCmdList.MACROKIT("clear")
check(not Has("Tank Up") and Said(before):find("Cleared 2 macros from your old spec", 1, true), "/macrokit clear clears the old spec's macros: " .. Said(before))

-- A talent reset.
Spend(0, 0, 0)
Unlearn("Holy Shock")
before = #PRINTED
Fire("CONFIRM_TALENT_WIPE")
Fire("CHARACTER_POINTS_CHANGED")
RunAfters()
check(select(2, ns.ClassAndSpec()) == nil, "after a reset there is no spec")
check(Said(before):find("Your talents were reset", 1, true), "and it says so: " .. Said(before))
check(Said(before):find("from your old spec no longer fit: Holy Shock", 1, true), "pointing out the Holy macros: " .. Said(before))

-- Logging in on another day: no messages about what was already known.
Spend(0, 0, 9)
ns.char.lastSpec = 70
before = #PRINTED
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(not Said(before):find("Talents changed", 1, true), "logging in does not announce a spec that has not changed")

-- /macrokit talents reports what the game says.
before = #PRINTED
SlashCmdList.MACROKIT("talents")
local said = Said(before)
check(said:find("Talent points: Holy 0, Protection 0, Retribution 9", 1, true) and said:find("Active talent set: 2 of 2", 1, true)
    and said:find("Spec: Retribution (from talent points)", 1, true), "/macrokit talents shows the points, the talent set and the spec: " .. said)

-- Forever's own way: the trait system, as its talent frame reads it. The
-- groups come back in an order that does not match MacroKit's, so the
-- tree's name decides.
GetNumTalentTabs, GetTalentTabInfo = nil, nil
GROUPS_SPENT = { [11] = 0, [12] = 14, [13] = 3 }
C_ClassTalents = { GetActiveConfigID = function() return 900 end }
C_Traits = {
    GetConfigInfo = function(id) assert(id == 900); return { treeIDs = { 77 } } end,
    GetGroupDisplayInfoByTreeID = function(tree)
        assert(tree == 77)
        return { { groupID = 13, displayName = "Retribution" }, { groupID = 11, displayName = "Holy" }, { groupID = 12, displayName = "Protection" } }
    end,
    GetGroupCurrencyInfo = function(config, ids)
        local out = {}
        for _, id in ipairs(ids) do out[#out + 1] = { traitNodeGroupID = id, currencyInfos = { { spent = GROUPS_SPENT[id] } } } end
        return out
    end,
}
local _, specT, howT = ns.ClassAndSpec()
check(specT == 66 and howT == "talent points", "Forever's trait groups are read, and matched to trees by name: 14 points in Protection")
before = #PRINTED
SlashCmdList.MACROKIT("talents")
check(Said(before):find("Talent points: Retribution 3, Holy 0, Protection 14", 1, true), "/macrokit talents shows the trees as the game names them: " .. Said(before))
C_ClassTalents.GetActiveConfigID = function() error("not ready yet") end
local okT, _, _, howFail = pcall(ns.ClassAndSpec)
check(okT and howFail ~= "talent points", "a failing trait call raises no error and is not taken as a reading")
C_ClassTalents, C_Traits = nil, nil

-- The early layout: name, icon, points.
GetNumTalentTabs = function() return #TABS end
GetTalentTabInfo = function(tab) return TABS[tab][1], "icon", TABS[tab][2] end
Spend(3, 0, 0)
check(select(2, ns.ClassAndSpec()) == 65, "the early talent layout is read too")

-- A client without the talent functions falls back to talent spells.
GetNumTalentTabs, GetTalentTabInfo = nil, nil
Learn("Holy Shock")
local _, spec2, how2 = ns.ClassAndSpec()
check(spec2 == 65 and how2 == "talent spell", "without talent points, a known talent spell decides (Holy Shock: Holy)")
before = #PRINTED
SlashCmdList.MACROKIT("talents")
check(Said(before):find("does not report talent points", 1, true), "and /macrokit talents says the points cannot be read")
