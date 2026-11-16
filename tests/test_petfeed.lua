-- The hunter's Pet macro feeds the pet while it is not happy.
EditMacro = function(index, name, icon, body)
    assert(not IN_COMBAT, "EditMacro in combat")
    MACROS[index].body = body
end
-- Bags and food: [bag][slot] = { itemID = }; ITEM_SPELLS: itemID -> use spell.
BAGS = {}
ITEM_SPELLS, ITEM_LEVELS = {}, {}
C_Container = {
    GetContainerNumSlots = function(bag) return bag <= 4 and 16 or 0 end,
    GetContainerItemInfo = function(bag, slot) local i = BAGS[bag] and BAGS[bag][slot]; return i and { itemID = i.itemID } end,
}
C_Item = {
    GetItemSpell = function(id) return ITEM_SPELLS[id] end,
    GetItemInfo = function(id) local l = ITEM_LEVELS[id]; if l then return "item", "link", 1, l end end,
}
HAPPINESS = 3
PET = "Bear"
GetPetHappiness = function() if PET then return HAPPINESS, 0, 0 end end
local realUnitName = UnitName
UnitName = function(unit) if unit == "pet" then return PET end; return realUnitName and realUnitName(unit) end

local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Body() return MACROS[GetMacroIndexByName("Pet")].body end

CLASS, SPEC = "HUNTER", nil
Learn("Call Pet", "Feed Pet", "Mend Pet")
CreateMacro("Pet", 1, ns.PET_NORMAL, true)
Fire("ADDON_LOADED", "MacroKit")
ns.char.made.Pet = true
check(ns.PET_NORMAL:find("Mend Pet", 1, true), "the Pet macro starts as call, revive or mend")

-- A happy pet: nothing changes.
Fire("UNIT_HAPPINESS", "pet")
check(Body() == ns.PET_NORMAL, "a happy pet keeps the usual macro")

-- Not happy, with food in the bags: the macro feeds it.
BAGS[0] = { [1] = { itemID = 117 }, [2] = { itemID = 4539 }, [3] = { itemID = 5349 } }   -- jerky, apple, conjured bread
ITEM_SPELLS[117], ITEM_SPELLS[4539], ITEM_SPELLS[5349] = "Food", "Food", "Refreshment"
ITEM_LEVELS[117], ITEM_LEVELS[4539], ITEM_LEVELS[5349] = 5, 25, 30
HAPPINESS = 2
Fire("UNIT_HAPPINESS", "pet")
check(Body() == ns.PetFeedBody(4539), "a content pet is fed the best food (not conjured food, which pets refuse)")
check(Body():find("[mod:shift] Mend Pet; Feed Pet", 1, true) and Body():find("/use [pet,nodead,nomod:shift] item:4539", 1, true),
    "Feed Pet, then the food; Shift still mends")
check(#Body() <= ns.MAX_BODY, "the feeding macro fits the game's macro size")

-- The pet refuses it: remembered, and the next food is tried.
Fire("UI_ERROR_MESSAGE", 0, "Your pet doesn't like that food")
check(Body() == ns.PetFeedBody(117), "a refused food is skipped and the next one tried")
check(ns.char.petRefused.Bear[4539], "and remembered for this pet")
Fire("UI_ERROR_MESSAGE", 0, "Something else went wrong")
check(Body() == ns.PetFeedBody(117), "other errors are not taken as a refusal")

-- Happy again: back to normal.
HAPPINESS = 3
Fire("UNIT_HAPPINESS", "pet")
check(Body() == ns.PET_NORMAL, "a happy pet gets the usual macro back")

-- Unhappy with nothing it eats: the usual macro, and one line in chat.
local said = #PRINTED
HAPPINESS = 1
BAGS[0] = { [3] = { itemID = 5349 } }
Fire("BAG_UPDATE_DELAYED")
check(Body() == ns.PET_NORMAL, "with no food it will eat, the macro stays as it is")
check(table.concat(PRINTED, " | ", said + 1):find("no food in your bags it will eat", 1, true), "and it says so once")
Fire("BAG_UPDATE_DELAYED")
check(#PRINTED == said + 1, "only once")

-- Never in combat.
BAGS[0] = { [1] = { itemID = 117 } }
IN_COMBAT = true
Fire("BAG_UPDATE_DELAYED")
check(Body() == ns.PET_NORMAL, "nothing changes in combat")
IN_COMBAT = false
Fire("PLAYER_REGEN_ENABLED")
check(Body() == ns.PetFeedBody(117), "and it catches up when combat ends")

-- A Pet macro the player changed is left alone.
MACROS[GetMacroIndexByName("Pet")].body = "/cast Mend Pet\n/say mine"
HAPPINESS = 3
Fire("UNIT_HAPPINESS", "pet")
check(Body() == "/cast Mend Pet\n/say mine", "a Pet macro the player changed is never rewritten")

-- Not a hunter, or no pet happiness in the game: nothing happens.
MACROS[GetMacroIndexByName("Pet")].body = ns.PET_NORMAL
HAPPINESS = 1
CLASS = "WARRIOR"
Fire("UNIT_HAPPINESS", "pet")
check(Body() == ns.PET_NORMAL, "only hunters' Pet macros are touched")
CLASS = "HUNTER"
GetPetHappiness = nil
Fire("UNIT_HAPPINESS", "pet")
check(Body() == ns.PET_NORMAL, "a game without pet happiness leaves the macro alone")
