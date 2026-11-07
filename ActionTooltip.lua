local addonName, ns = ...

-- When the mouse is over an action button holding a macro MacroKit added,
-- its tooltip gets MacroKit's explanation of what the macro does under the
-- spell's own tooltip (which the game shows because the macros use
-- #showtooltip). Macros the player made, even with the same name, are left
-- alone: only names MacroKit has recorded as its own are explained.

local ACCENT_R, ACCENT_G, ACCENT_B = 0.85, 0.63, 0.40

-- The macro of this name in the character's class data, if any.
function ns.FindMacro(name)
    local _, class = UnitClass("player")
    local set = ns.SETS[class]
    if not set or type(name) ~= "string" then return nil end
    for _, macro in ipairs(set.shared or {}) do
        if macro.name == name then return macro end
    end
    for _, list in pairs(set.specs or {}) do
        for _, macro in ipairs(list) do
            if macro.name == name then return macro end
        end
    end
end

local function Usable(value)
    return value ~= nil and not (issecretvalue and issecretvalue(value))
end

-- The name of the macro in an action slot, or nil if it holds something else.
local function MacroInSlot(slot)
    local ok, kind, id = pcall(GetActionInfo, slot)
    if not ok or not Usable(kind) or kind ~= "macro" then return nil end
    local okText, text = pcall(GetActionText, slot)
    if okText and Usable(text) and type(text) == "string" and text ~= "" then return text end
    if Usable(id) and type(GetMacroInfo) == "function" then
        local okInfo, name = pcall(GetMacroInfo, id)
        if okInfo and Usable(name) then return name end
    end
end

local function AddExplanation(tooltip, slot)
    if not ns.db or ns.db.actionTooltips == false or not ns.char then return end
    local name = MacroInSlot(slot)
    if not name or not ns.char.made[name] then return end
    local macro = ns.FindMacro(name)
    if not macro then return end
    tooltip:AddLine(" ")
    tooltip:AddLine("MacroKit: " .. macro.name, ACCENT_R, ACCENT_G, ACCENT_B)
    tooltip:AddLine(macro.how or macro.desc, 1, 1, 1, true)
    tooltip:Show()
end

-- Action buttons show their tooltip with GameTooltip:SetAction(slot).
if GameTooltip and type(GameTooltip.SetAction) == "function" then
    hooksecurefunc(GameTooltip, "SetAction", function(tooltip, slot)
        pcall(AddExplanation, tooltip, slot)
    end)
end
