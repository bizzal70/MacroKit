-- The controller pack: offered in the window's Controller tab, never added
-- by itself; account-wide macros except the class heal; the Quest Item
-- macro follows the bags.

-- What this test adds to the fake game: bags, gear sets, leaving a party,
-- and editing a macro.
BAGS = {}            -- [bag][slot] = { itemID =, questID =, isActive =, isQuestItem =, use = }
C_Container = {
    GetContainerNumSlots = function(bag) return bag <= 4 and 16 or 0 end,
    GetContainerItemInfo = function(bag, slot) local i = BAGS[bag] and BAGS[bag][slot]; return i and { itemID = i.itemID } end,
    GetContainerItemQuestInfo = function(bag, slot)
        local i = BAGS[bag] and BAGS[bag][slot]
        return { isQuestItem = i and i.isQuestItem or false, questID = i and i.questID, isActive = i and i.isActive or false }
    end,
}
ITEM_SPELLS = {}
C_Item = { GetItemSpell = function(id) return ITEM_SPELLS[id] end }
C_EquipmentSet = { CreateEquipmentSet = function() end, SaveEquipmentSet = function() end, GetEquipmentSetID = function() end }
C_PartyInfo = { LeaveParty = function() end }
EditMacro = function(index, name, icon, body)
    assert(not IN_COMBAT, "EditMacro in combat")
    MACROS[index].body = body
end
local function Body(name) return MACROS[GetMacroIndexByName(name)].body end

local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Has(name) return GetMacroIndexByName(name) > 0 end

SPEC = nil
Learn("Holy Light", "Holy Strike")
Fire("ADDON_LOADED", "MacroKit")
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(Has("Heal") and not Has("Heal Me") and not Has("Hello"), "the pack is not added by itself, only the class macros are")

-- What is in it.
local names = {}
for _, macro in ipairs(ns.ControllerList()) do
    names[#names + 1] = macro.name
    check(#macro.name <= ns.MAX_NAME, macro.name .. " fits the game's name limit")
    local body = macro.Body and macro.Body() or macro.body
    check(#body <= ns.MAX_BODY, macro.name .. " fits the game's macro size")
end
check(table.concat(names, ",") == "Heal Me,Quest Item,Save Gear,Wear Gear,Leave Group,Hello,Thanks,Follow Me,Need Help",
    "a paladin's pack: " .. table.concat(names, ","))
CLASS = "WARRIOR"
check(ns.ControllerList()[1].name == "Quest Item", "a class with no heal gets the pack without Heal Me")
CLASS = "PALADIN"

-- Adding it.
local _, charBefore = GetNumMacros()
SlashCmdList.MACROKIT("controller")
for _, name in ipairs(names) do check(Has(name), name .. " is added by /macrokit controller") end
local account, character = GetNumMacros()
check(character == charBefore + 1, "only Heal Me takes a character macro slot")
check(account == 8, "the other eight are account-wide General macros")
check(Body("Heal Me"):find("/cast [@player] Holy Light", 1, true), "Heal Me heals yourself with the paladin's heal")
check(ns.db.generalMade.Hello and ns.char.made["Heal Me"], "MacroKit remembers which ones it added")
SlashCmdList.MACROKIT("controller")
check(GetNumMacros() == 8, "asking again adds nothing twice")

-- The quest item macro follows the bags.
check(Body("Quest Item"):find("no quest item", 1, true), "with no quest item it says so when pressed")
BAGS[1] = { [3] = { itemID = 5000, isQuestItem = true } }
ITEM_SPELLS[5000] = "Use: dig"
Fire("BAG_UPDATE_DELAYED")
check(Body("Quest Item") == "#showtooltip item:5000\n/use item:5000", "a quest item with a use goes in when it reaches the bags")
BAGS[2] = { [1] = { itemID = 6000, questID = 77, isActive = false } }
Fire("BAG_UPDATE_DELAYED")
check(Body("Quest Item"):find("item:6000", 1, true), "an item that starts a quest comes first")
IN_COMBAT = true
BAGS[2] = nil
Fire("BAG_UPDATE_DELAYED")
check(Body("Quest Item"):find("item:6000", 1, true), "in combat the macro is left alone")
IN_COMBAT = false
Fire("PLAYER_REGEN_ENABLED")
check(Body("Quest Item"):find("item:5000", 1, true), "and brought up to date when combat ends")
-- One the player wrote themself is never touched.
ns.db.generalMade["Quest Item"] = nil
BAGS[1] = nil
Fire("BAG_UPDATE_DELAYED")
check(Body("Quest Item"):find("item:5000", 1, true), "a Quest Item macro MacroKit did not make is left alone")
ns.db.generalMade["Quest Item"] = true

-- A client without gear sets or leaving from a macro.
DeleteMacro(GetMacroIndexByName("Save Gear")); ns.db.generalMade["Save Gear"] = nil
C_EquipmentSet = nil
local saveGear
for _, macro in ipairs(ns.ControllerList()) do if macro.name == "Save Gear" then saveGear = macro end end
local status, missing = ns.Status(saveGear)
check(status == "needs" and missing == "gear sets in this game", "without gear sets, Save Gear waits and says why")
SlashCmdList.MACROKIT("controller")
check(not Has("Save Gear"), "and is not added")

-- The window's Controller tab.
SlashCmdList.MACROKIT("")
local tabButton
for _, f in ipairs(Frames()) do
    if rawget(f, "label") and f.label.__text and f.label.__text:find("^Controller") then tabButton = f end
end
check(tabButton and tabButton.label.__text == "Controller (9)", "the window has a Controller tab with the pack's count")
tabButton.__scripts.OnClick(tabButton)
local shown = {}
for _, f in ipairs(Frames()) do
    if rawget(f, "macro") and rawget(f, "status") and f.__shown then shown[#shown + 1] = f.macro.name end
end
check(#shown == 9, "it lists the whole pack: " .. table.concat(shown, ","))

-- Without a controller connected, the tab goes away.
local function TabShown() return tabButton.__shown end
DEVICES = {}
C_GamePad = { GetAllDeviceIDs = function() return DEVICES end }
Fire("GAME_PAD_DISCONNECTED")
check(not TabShown(), "with no controller connected there is no Controller tab")
local readyTab
for _, f in ipairs(Frames()) do
    if rawget(f, "label") and f.label.__text and f.label.__text:find("^Ready to use") then readyTab = f end
end
check(readyTab.underline.__shown, "and the window goes back to Ready to use")
DEVICES = { 1 }
Fire("GAME_PAD_CONNECTED", 1)
check(TabShown(), "connecting a controller brings the tab back")
C_GamePad = nil

-- Action button tooltips explain the pack's macros too.
ACTIONS[1] = { kind = "macro", id = GetMacroIndexByName("Thanks"), text = "Thanks" }
GameTooltip:SetAction(1)
check(table.concat(TOOLTIP, " | "):find("MacroKit: Thanks", 1, true), "an action button with a pack macro explains it")

-- Remove takes the pack away with the rest.
SlashCmdList.MACROKIT("remove")
check(not Has("Hello") and not Has("Heal Me") and next(ns.db.generalMade) == nil, "/macrokit remove deletes the pack's macros too")
