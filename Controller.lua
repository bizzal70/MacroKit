local addonName, ns = ...

-- The controller pack: macros for things a gamepad makes awkward in World
-- of Warcraft: Forever, gathered from what controller players asked for
-- (heal yourself without targeting, use a quest item from the bags, save
-- and wear a set of gear, leave a group, say hello or thanks without a
-- keyboard). Put one on the gamepad's action bar and it is one button.
--
-- The pack is never added by itself: it waits in the window's Controller
-- tab, which only shows once a controller is used (or
-- /macrokit controller, which works either way). Macros every character can share go in
-- the account-wide General macros (120 slots), so they cost none of a
-- character's 18. Only the heal, whose spell is the class's, is a
-- character macro.
--
-- A macro here may also have:
--   general  true: an account-wide General macro
--   icon     the icon to show (the question mark with #showtooltip if none)
--   needs    a function returning what is missing on this client, or nil
--   Body     a function giving the body now (the quest item macro)

local QUEST_ITEM = "Quest Item"

-- Whether a controller is in use: a controller button or stick has been
-- used since logging in (GAME_PAD_ACTIVE_CHANGED). Being connected is not
-- enough: the author's PC reports two controllers with none in use. Once
-- used, it stays true for the session. Without C_GamePad, yes.
ns.controllerUsed = false
function ns.ControllerInUse()
    if not C_GamePad then return true end
    return ns.controllerUsed
end

local GEAR_SET = "MacroKit"

-- The heal each class can cast on itself, from level 1. A priest learns
-- Heal later: the first line casts it once known, else Lesser Heal goes off.
local HEALS = {
    PALADIN = { spell = "Holy Light", body = "#showtooltip Holy Light\n/cast [@player] Holy Light" },
    PRIEST = { spell = "Lesser Heal", body = "#showtooltip\n/cast [@player] Heal\n/cast [@player] Lesser Heal" },
    DRUID = { spell = "Healing Touch", body = "#showtooltip Healing Touch\n/cast [@player] Healing Touch" },
    SHAMAN = { spell = "Healing Wave", body = "#showtooltip Healing Wave\n/cast [@player] Healing Wave" },
}

local function NoGearSets()
    if not (C_EquipmentSet and C_EquipmentSet.CreateEquipmentSet and C_EquipmentSet.SaveEquipmentSet
            and C_EquipmentSet.GetEquipmentSetID) then
        return "gear sets in this game"
    end
end

local function NoLeaveParty()
    if not (C_PartyInfo and C_PartyInfo.LeaveParty) then return "a way to leave from a macro" end
end

-- The quest item to use: one that starts a quest, else a quest item with a
-- use. Returns its item ID, or nil.
function ns.QuestItemID()
    if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo
            and C_Container.GetContainerItemQuestInfo) then
        return nil
    end
    local usable
    for bag = 0, 4 do
        local okSlots, slots = pcall(C_Container.GetContainerNumSlots, bag)
        for slot = 1, (okSlots and type(slots) == "number") and slots or 0 do
            local okInfo, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
            local okQuest, quest = pcall(C_Container.GetContainerItemQuestInfo, bag, slot)
            if okInfo and type(info) == "table" and info.itemID and okQuest and type(quest) == "table" then
                if quest.questID and not quest.isActive then
                    return info.itemID                       -- starts a quest: the best choice
                end
                if not usable and quest.isQuestItem and C_Item and C_Item.GetItemSpell then
                    local okSpell, spell = pcall(C_Item.GetItemSpell, info.itemID)
                    if okSpell and spell then usable = info.itemID end
                end
            end
        end
    end
    return usable
end

local function QuestItemBody()
    local id = ns.QuestItemID()
    if id then
        return ("#showtooltip item:%d\n/use item:%d"):format(id, id)
    end
    return "/run print(\"MacroKit: no quest item to use in your bags.\")"
end

local function M(fields) return fields end

-- Macros that use an item or spell show it with #showtooltip; the others
-- (emotes, gear, leaving) keep their own icon, so they have none.

-- The pack for this character's class, in the order the window lists it.
function ns.ControllerList()
    local _, class = UnitClass("player")
    local list = {}
    local heal = HEALS[class]
    if heal then
        list[#list + 1] = M{ name = "Heal Me", desc = heal.spell .. " on yourself, whatever you have targeted",
            how = "Heals you, without changing your target and without aiming at your own frame: one button for a "
                .. "controller. It always heals you, even with a friend targeted.",
            spells = { heal.spell }, body = heal.body }
    end
    list[#list + 1] = M{ name = QUEST_ITEM, general = true, icon = "INV_Misc_Note_06",
        desc = "Uses the quest item in your bags",
        how = "Uses the item in your bags that starts a quest, or else a quest item you can use. MacroKit keeps the "
            .. "macro pointing at the right item as your bags change (outside combat), so it stays one button.",
        Body = QuestItemBody, body = QuestItemBody() }
    list[#list + 1] = M{ name = "Save Gear", general = true, icon = "INV_Chest_Chain",
        desc = "Saves what you are wearing as a gear set",
        how = "Saves everything you are wearing as the gear set \"" .. GEAR_SET .. "\", replacing what was saved "
            .. "before. Wear Gear puts it back on.",
        needs = NoGearSets,
        body = "/run local s=C_EquipmentSet local i=s.GetEquipmentSetID(\"" .. GEAR_SET .. "\") "
            .. "if i then s.SaveEquipmentSet(i) else s.CreateEquipmentSet(\"" .. GEAR_SET .. "\") end "
            .. "print(\"MacroKit: gear saved.\")" }
    list[#list + 1] = M{ name = "Wear Gear", general = true, icon = "INV_Shoulder_02",
        desc = "Puts your saved gear set back on",
        how = "Equips the gear set Save Gear saved, every piece at once. Not in combat: the game does not allow it.",
        needs = NoGearSets,
        body = "/equipset " .. GEAR_SET }
    list[#list + 1] = M{ name = "Leave Group", general = true, icon = "Ability_Rogue_Sprint",
        desc = "Leaves your party or raid",
        how = "Leaves the party or raid you are in, with no menu to find.",
        needs = NoLeaveParty,
        body = "/run C_PartyInfo.LeaveParty()" }
    list[#list + 1] = M{ name = "Hello", general = true, icon = "INV_Misc_Toy_10",
        desc = "Waves at your target", how = "Waves (the /wave emote), at your target if you have one.",
        body = "/wave" }
    list[#list + 1] = M{ name = "Thanks", general = true, icon = "INV_Misc_Gift_01",
        desc = "Thanks your target", how = "Thanks your target (the /thank emote), for a buff or a hand in a fight.",
        body = "/thank" }
    list[#list + 1] = M{ name = "Follow Me", general = true, icon = "Ability_Tracking",
        desc = "Asks others to follow you", how = "Waves others on to follow you (the /followme emote).",
        body = "/followme" }
    list[#list + 1] = M{ name = "Need Help", general = true, icon = "Spell_Holy_SealOfProtection",
        desc = "Calls for help", how = "Calls out for help (the /helpme emote).",
        body = "/helpme" }
    return list
end

-- Keeps the Quest Item macro on the right item. Only touches it if
-- MacroKit made it, and never in combat (the game does not allow it).
function ns.UpdateQuestItemMacro()
    if InCombatLockdown() or not ns.db or not ns.db.generalMade[QUEST_ITEM] then return end
    local ok, index = pcall(GetMacroIndexByName, QUEST_ITEM)
    if not ok or type(index) ~= "number" or index == 0 then return end
    local body = QuestItemBody()
    local okInfo, _, _, current = pcall(GetMacroInfo, index)
    if okInfo and current == body then return end
    pcall(EditMacro, index, nil, nil, body)
end

-- Adds the whole pack, or what is missing of it.
function ns.InstallController()
    if InCombatLockdown() then
        ns.Print("Macros cannot be added in combat.")
        return
    end
    local added, waiting = {}, {}
    for _, macro in ipairs(ns.ControllerList()) do
        local status, missing = ns.Status(macro)
        if status == "ready" then
            if ns.AddOne(macro, true) then added[#added + 1] = macro.name end
        elseif status == "needs" then
            waiting[#waiting + 1] = macro.name .. " (" .. missing .. ")"
        end
    end
    if #added > 0 then
        ns.Print("Added the controller pack: " .. table.concat(added, ", ") .. ". Put them on your gamepad's bars from /macrokit or /macro.")
    else
        ns.Print("You already have every controller macro this character can use.")
    end
    if #waiting > 0 then
        ns.Print("Not added: " .. table.concat(waiting, ", ") .. ".")
    end
    ns.RefreshWindow()
end

local watcher = CreateFrame("Frame")
for _, event in ipairs({ "BAG_UPDATE_DELAYED", "QUEST_ACCEPTED", "QUEST_REMOVED", "PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD" }) do
    pcall(watcher.RegisterEvent, watcher, event)
end
watcher:SetScript("OnEvent", function() ns.UpdateQuestItemMacro() end)

-- The first controller button or stick used: the window shows its tab.
local padWatcher = CreateFrame("Frame")
pcall(padWatcher.RegisterEvent, padWatcher, "GAME_PAD_ACTIVE_CHANGED")
padWatcher:SetScript("OnEvent", function(_, _, isActive)
    if not isActive or ns.controllerUsed then return end
    ns.controllerUsed = true
    if ns.RefreshWindow then ns.RefreshWindow() end
end)
