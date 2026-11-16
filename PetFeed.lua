local addonName, ns = ...

-- The hunter's Pet macro also feeds the pet when it is not happy.
--
-- A macro cannot see the pet's happiness, so MacroKit rewrites the Pet
-- macro (outside combat, and only the one it added, as it added it):
--   happy (or no pet, or no food):  Call Pet / Revive Pet / Mend Pet
--   not happy, with food:           Call Pet / Revive Pet / Feed Pet, then
--                                   the food; Shift still casts Mend Pet
--
-- Which foods a pet eats is not something addons can read, so the best
-- food in the bags is tried, and one the pet refuses ("Your pet doesn't
-- like that food", or too low a level) is remembered for that pet and
-- skipped from then on.

local PET_MACRO = "Pet"
ns.PET_NORMAL = "#showtooltip\n/cast [nopet] Call Pet; [@pet,dead] Revive Pet; Mend Pet"
local FEED_FIRST = "#showtooltip\n/cast [nopet] Call Pet; [@pet,dead] Revive Pet; [mod:shift] Mend Pet; Feed Pet\n/use [pet,nodead,nomod:shift] item:"

function ns.PetFeedBody(itemID)
    return FEED_FIRST .. itemID
end

-- The game's own wording for the two refusals, with English to fall back on.
local function Refusals()
    return {
        [_G.SPELL_FAILED_WRONG_PET_FOOD or "Your pet doesn't like that food"] = true,
        [_G.SPELL_FAILED_FOOD_LOWLEVEL or "That food's level is not high enough for your pet"] = true,
    }
end

local function Clean(body)
    return ((body or ""):gsub("\r", ""):gsub("%s+$", ""))
end

-- Whether a Pet macro body is one MacroKit wrote (so it may be changed).
local function Ours(body)
    body = Clean(body)
    return body == ns.PET_NORMAL or (body:sub(1, #FEED_FIRST) == FEED_FIRST and body:sub(#FEED_FIRST + 1):match("^%d+$") ~= nil)
end

local function PetName()
    local ok, name = pcall(UnitName, "pet")
    if ok and type(name) == "string" and not (issecretvalue and issecretvalue(name)) then return name end
end

-- Foods this pet has refused, by item ID.
local function Refused()
    local name = PetName()
    if not name or not ns.char then return {} end
    ns.char.petRefused = ns.char.petRefused or {}
    ns.char.petRefused[name] = ns.char.petRefused[name] or {}
    return ns.char.petRefused[name]
end

-- The pet's happiness: 1 unhappy, 2 content, 3 happy. Nil if there is no
-- pet out, or this game has no pet happiness.
function ns.PetHappiness()
    if type(GetPetHappiness) ~= "function" then return nil end
    local ok, happiness = pcall(GetPetHappiness)
    if ok and type(happiness) == "number" and not (issecretvalue and issecretvalue(happiness)) then return happiness end
end

-- The best food in the bags this pet has not refused: the highest item
-- level, as better food pleases a pet more. Food is what casts "Food" when
-- used (not conjured mage food, which casts "Refreshment" and pets refuse).
function ns.PetFood()
    if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo
            and C_Item and C_Item.GetItemSpell) then
        return nil
    end
    local refused = Refused()
    local best, bestLevel
    for bag = 0, 4 do
        local okSlots, slots = pcall(C_Container.GetContainerNumSlots, bag)
        for slot = 1, (okSlots and type(slots) == "number") and slots or 0 do
            local okInfo, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
            local id = okInfo and type(info) == "table" and info.itemID
            if id and not refused[id] then
                local okSpell, spell = pcall(C_Item.GetItemSpell, id)
                if okSpell and spell == "Food" then
                    local level = 0
                    if C_Item.GetItemInfo then
                        local okItem, _, _, _, itemLevel = pcall(C_Item.GetItemInfo, id)
                        if okItem then level = tonumber(itemLevel) or 0 end
                    end
                    if not bestLevel or level > bestLevel then best, bestLevel = id, level end
                end
            end
        end
    end
    return best
end

-- What the Pet macro should say right now.
function ns.WantedPetBody()
    local happiness = ns.PetHappiness()
    if happiness and happiness < 3 and ns.Knows("Feed Pet") then
        local food = ns.PetFood()
        if food then return ns.PetFeedBody(food), food end
    end
    return ns.PET_NORMAL
end

local feedingWith      -- the food the macro last said to feed, to blame on a refusal
local saidNoFood       -- so "no food" is said once until things change

-- Rewrites the Pet macro if it should change. Only for hunters, only the
-- macro MacroKit added, only while it is still as MacroKit wrote it, and
-- never in combat. Returns the body it set, if any.
function ns.UpdatePetMacro()
    if InCombatLockdown() or not ns.char or not ns.char.made[PET_MACRO] or type(EditMacro) ~= "function" then return end
    local _, class = UnitClass("player")
    if class ~= "HUNTER" then return end
    local okIndex, index = pcall(GetMacroIndexByName, PET_MACRO)
    if not okIndex or type(index) ~= "number" or index == 0 then return end
    local okInfo, _, _, current = pcall(GetMacroInfo, index)
    if not okInfo or not Ours(current) then return end
    local body, food = ns.WantedPetBody()
    feedingWith = food
    local happiness = ns.PetHappiness()
    if happiness and happiness < 3 and not food and ns.Knows("Feed Pet") then
        if not saidNoFood then
            saidNoFood = true
            ns.Print("Your pet is not happy, and there is no food in your bags it will eat. The Pet macro feeds it once there is.")
        end
    else
        saidNoFood = false
    end
    if Clean(current) == Clean(body) then return end
    if pcall(EditMacro, index, nil, nil, body) then return body end
end

-- A refusal: remember that food for this pet and try the next one.
function ns.PetFoodRefused(message)
    if not feedingWith or type(message) ~= "string" or not Refusals()[message] then return end
    Refused()[feedingWith] = true
    ns.Print("Your pet will not eat that food, so the Pet macro will try another.")
    feedingWith = nil
    ns.UpdatePetMacro()
end

local watcher = CreateFrame("Frame")
for _, event in ipairs({ "UNIT_HAPPINESS", "UNIT_PET", "PET_UI_UPDATE", "UNIT_POWER_UPDATE", "BAG_UPDATE_DELAYED",
        "PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD", "UI_ERROR_MESSAGE" }) do
    pcall(watcher.RegisterEvent, watcher, event)
end
watcher:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "UI_ERROR_MESSAGE" then
        ns.PetFoodRefused(arg2)
    elseif event == "UNIT_POWER_UPDATE" and arg1 ~= "pet" then
        return
    else
        ns.UpdatePetMacro()
    end
end)
