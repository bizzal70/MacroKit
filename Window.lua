local addonName, ns = ...

-- The MacroKit window: the macros for the character being played, by class
-- and spec, each with its state. Ready macros can be added one at a time
-- or all at once; macros already in the list can be dragged (or clicked up)
-- straight onto the action bars. Drawn from plain colours and the game's
-- own icons, so it ships no image files.

local ACCENT_R, ACCENT_G, ACCENT_B = 0.85, 0.63, 0.40
local WIDTH = 440
local HEADER_HEIGHT = 38
local PADDING = 14
local ROW_HEIGHT = 36
local LIST_TOP = HEADER_HEIGHT + 40     -- below the title and the class line
local FOOTER_HEIGHT = 74
local QUESTION_MARK = 134400

local window, classLine, emptyText, addAllButton, removeButton, autoBox
local rows = {}

local function Fill(frame, r, g, b, a)
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetColorTexture(r, g, b, a)
    return texture
end

local function Outline(frame, alpha)
    local function Edge(point1, point2, isVertical)
        local edge = frame:CreateTexture(nil, "BORDER")
        edge:SetColorTexture(ACCENT_R, ACCENT_G, ACCENT_B, alpha)
        edge:SetPoint(point1)
        edge:SetPoint(point2)
        if isVertical then edge:SetWidth(1) else edge:SetHeight(1) end
    end
    Edge("TOPLEFT", "TOPRIGHT", false)
    Edge("BOTTOMLEFT", "BOTTOMRIGHT", false)
    Edge("TOPLEFT", "BOTTOMLEFT", true)
    Edge("TOPRIGHT", "BOTTOMRIGHT", true)
end

local function Label(parent, font, justify)
    local label = parent:CreateFontString(nil, "OVERLAY", font)
    label:SetJustifyH(justify or "LEFT")
    label:SetWordWrap(false)
    return label
end

-- A small framed button. SetActive greys it out when it cannot be used.
local function TextButton(parent, width, text, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width, 22)
    Fill(button, 1, 1, 1, 0.07)
    Outline(button, 0.35)
    local hover = button:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints()
    hover:SetColorTexture(1, 1, 1, 0.12)
    local label = Label(button, "GameFontHighlightSmall", "CENTER")
    label:SetPoint("CENTER")
    label:SetText(text)
    button:SetScript("OnClick", function(self)
        if self.active ~= false then onClick(self) end
    end)
    function button.SetActive(self, active)
        self.active = active
        if active then label:SetTextColor(1, 1, 1) else label:SetTextColor(0.45, 0.45, 0.45) end
    end
    button.label = label
    return button
end

local function ClassColour(class)
    local colour = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    if colour then return colour.r, colour.g, colour.b end
    return 1, 0.82, 0
end

local function Icon(macro)
    local spell = macro.spells and macro.spells[1]
    if spell and C_Spell and C_Spell.GetSpellTexture then
        local ok, icon = pcall(C_Spell.GetSpellTexture, spell)
        if ok and icon then return icon end
    end
    return QUESTION_MARK
end

-- Puts a macro on the cursor, ready to drop onto an action bar.
local function PickUp(macro)
    if not ns.Exists(macro.name) then return end
    pcall(PickupMacro, macro.name)
end

local function ShowTooltip(row)
    local macro = row.macro
    if not macro then return end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(macro.name)
    if macro.desc then GameTooltip:AddLine(macro.desc, 1, 1, 1, true) end
    GameTooltip:AddLine(" ")
    for line in (macro.body .. "\n"):gmatch("(.-)\n") do
        GameTooltip:AddLine(line, 0.6, 0.8, 1)
    end
    GameTooltip:AddLine(" ")
    local status, missing = ns.Status(macro)
    if status == "have" then
        GameTooltip:AddLine("Drag onto your action bars, or click to pick it up.", 0.25, 1, 0.25, true)
    elseif status == "ready" then
        GameTooltip:AddLine("Click Add to put it in your macros.", 1, 0.82, 0, true)
    else
        GameTooltip:AddLine("Learn " .. missing .. " to use this macro.", 0.6, 0.6, 0.6, true)
    end
    GameTooltip:Show()
end

local function CreateRow(index)
    local row = CreateFrame("Button", nil, window)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", PADDING, -(LIST_TOP + (index - 1) * ROW_HEIGHT))
    row:SetPoint("TOPRIGHT", -PADDING, -(LIST_TOP + (index - 1) * ROW_HEIGHT))
    local hover = row:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints()
    hover:SetColorTexture(1, 1, 1, 0.06)
    if index % 2 == 0 then Fill(row, 1, 1, 1, 0.025) end

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(28, 28)
    row.icon:SetPoint("LEFT", 2, 0)
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.name = Label(row, "GameFontHighlight")
    row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -1)
    row.desc = Label(row, "GameFontDisableSmall")
    row.desc:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 1)
    row.desc:SetWidth(WIDTH - PADDING * 2 - 40 - 150)
    row.status = Label(row, "GameFontHighlightSmall", "RIGHT")
    row.status:SetPoint("RIGHT", -70, 0)
    row.add = TextButton(row, 56, "Add", function() ns.AddOne(row.macro) end)
    row.add:SetPoint("RIGHT", -4, 0)

    row:RegisterForDrag("LeftButton")
    row:SetScript("OnDragStart", function() PickUp(row.macro) end)
    row:SetScript("OnClick", function() PickUp(row.macro) end)
    row:SetScript("OnEnter", ShowTooltip)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    rows[index] = row
    return row
end

local function Refresh()
    local list, class = ns.Wanted()
    local className, specName = ns.ClassAndSpecNames()
    local r, g, b = ClassColour(class)
    classLine:SetText((className or "Your class") .. (specName and ("  -  " .. specName) or ""))
    classLine:SetTextColor(r, g, b)

    local inCombat = InCombatLockdown()
    local count, ready = 0, 0
    for index, macro in ipairs(list or {}) do
        count = index
        local row = rows[index] or CreateRow(index)
        row.macro = macro
        row.icon:SetTexture(Icon(macro))
        row.name:SetText(macro.name)
        row.desc:SetText(macro.desc or "")
        local status, missing = ns.Status(macro)
        if status == "have" then
            row.status:SetText("|cff40ff40In your macros|r")
            row.icon:SetDesaturated(false)
            row.add:Hide()
        elseif status == "ready" then
            ready = ready + 1
            row.status:SetText("|cffffd100Ready|r")
            row.icon:SetDesaturated(false)
            row.add:Show()
            row.add:SetActive(not inCombat)
        else
            row.status:SetText("|cff808080Needs " .. missing .. "|r")
            row.icon:SetDesaturated(true)
            row.add:Hide()
        end
        row:Show()
    end
    for index = count + 1, #rows do rows[index]:Hide() end

    if not list then
        emptyText:SetText(("There are no macros for %s yet. MacroKit has Paladin macros so far."):format(className or "your class"))
        emptyText:Show()
    else
        emptyText:Hide()
    end
    local listHeight = list and (count * ROW_HEIGHT) or 40
    window:SetHeight(LIST_TOP + listHeight + FOOTER_HEIGHT)

    addAllButton.label:SetText(ready > 0 and ("Add all missing (" .. ready .. ")") or "Add all missing")
    addAllButton:SetActive(ready > 0 and not inCombat)
    removeButton:SetActive(next(ns.char.made) ~= nil and not inCombat)
    autoBox.tick:SetShown(ns.char.auto and true or false)
end

local function CreateWindow()
    window = CreateFrame("Frame", addonName .. "Window", UIParent)
    window:SetWidth(WIDTH)
    window:SetPoint("CENTER")
    window:SetFrameStrata("HIGH")
    window:SetToplevel(true)
    window:EnableMouse(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:Hide()
    Fill(window, 0.05, 0.05, 0.06, 0.97)
    Outline(window, 0.55)
    -- Lets Escape close the window.
    tinsert(UISpecialFrames, addonName .. "Window")

    local header = CreateFrame("Frame", nil, window)
    header:SetPoint("TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", -1, -1)
    header:SetHeight(HEADER_HEIGHT)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() window:StartMoving() end)
    header:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
    Fill(header, 0.16, 0.12, 0.08, 1)
    local title = Label(header, "GameFontNormalLarge")
    title:SetPoint("LEFT", PADDING, 0)
    title:SetText("MacroKit")
    title:SetTextColor(1, 0.9, 0.75)

    local close = CreateFrame("Button", nil, header)
    close:SetSize(HEADER_HEIGHT, HEADER_HEIGHT)
    close:SetPoint("RIGHT")
    local closeHover = close:CreateTexture(nil, "HIGHLIGHT")
    closeHover:SetAllPoints()
    closeHover:SetColorTexture(0.9, 0.2, 0.2, 0.45)
    -- The cross is two drawn strokes, so it needs no font glyph or texture.
    for _, direction in ipairs({ 1, -1 }) do
        local stroke = close:CreateLine(nil, "ARTWORK")
        stroke:SetThickness(2)
        stroke:SetColorTexture(0.9, 0.9, 0.9, 1)
        stroke:SetStartPoint("CENTER", close, -6, 6 * direction)
        stroke:SetEndPoint("CENTER", close, 6, -6 * direction)
    end
    close:SetScript("OnClick", function() window:Hide() end)

    -- The class and spec, in the class's colour.
    classLine = Label(window, "GameFontNormal")
    classLine:SetPoint("TOPLEFT", PADDING, -(HEADER_HEIGHT + 12))
    local hint = Label(window, "GameFontDisableSmall", "RIGHT")
    hint:SetPoint("TOPRIGHT", -PADDING, -(HEADER_HEIGHT + 14))
    hint:SetText("Drag a macro onto your bars")

    emptyText = Label(window, "GameFontHighlight")
    emptyText:SetPoint("TOPLEFT", PADDING, -(LIST_TOP + 10))
    emptyText:SetWidth(WIDTH - PADDING * 2)
    emptyText:SetWordWrap(true)

    -- Footer: add everything, take back what MacroKit added, and the
    -- automatic adding switch.
    addAllButton = TextButton(window, 170, "Add all missing", function() ns.Install(false) end)
    addAllButton:SetPoint("BOTTOMLEFT", PADDING, 40)
    removeButton = TextButton(window, 200, "Remove MacroKit's macros", function() ns.Remove() end)
    removeButton:SetPoint("BOTTOMRIGHT", -PADDING, 40)

    autoBox = CreateFrame("Button", nil, window)
    autoBox:SetSize(WIDTH - PADDING * 2, 20)
    autoBox:SetPoint("BOTTOMLEFT", PADDING, 12)
    local box = CreateFrame("Frame", nil, autoBox)
    box:SetSize(14, 14)
    box:SetPoint("LEFT", 2, 0)
    Fill(box, 0, 0, 0, 0.5)
    Outline(box, 0.7)
    autoBox.tick = box:CreateTexture(nil, "ARTWORK")
    autoBox.tick:SetPoint("TOPLEFT", 3, -3)
    autoBox.tick:SetPoint("BOTTOMRIGHT", -3, 3)
    autoBox.tick:SetColorTexture(ACCENT_R, ACCENT_G, ACCENT_B, 1)
    local autoLabel = Label(autoBox, "GameFontHighlightSmall")
    autoLabel:SetPoint("LEFT", box, "RIGHT", 8, 0)
    autoLabel:SetText("Add a spec's macros by itself the first time I play it")
    autoBox:SetScript("OnClick", function()
        SlashCmdList.MACROKIT(ns.char.auto and "auto off" or "auto on")
    end)
end

function ns.ToggleWindow()
    if not ns.char then return end
    if not window then CreateWindow() end
    if window:IsShown() then
        window:Hide()
    else
        Refresh()
        window:Show()
    end
end

-- Called whenever macros, spells, spec or combat change.
function ns.RefreshWindow()
    if window and window:IsShown() then
        Refresh()
    end
end
