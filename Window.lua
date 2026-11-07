local addonName, ns = ...

-- The MacroKit window. At the top, the character's class and a Spec menu
-- (Every spec, or one specialization, to look at its macros). Under that,
-- two tabs: "Ready to use" (macros whose spells are known: in the macro
-- list, or ready to add) and "Not learned yet" (macros waiting on a spell).
-- Ready macros can be added one at a time or all at once; macros already in
-- the list can be dragged, or clicked up, straight onto the action bars.
-- Drawn from plain colours and the game's own icons, so it ships no images.

local ACCENT_R, ACCENT_G, ACCENT_B = 0.85, 0.63, 0.40
local WIDTH = 440
local HEADER_HEIGHT = 38
local PADDING = 14
local ROW_HEIGHT = 36
local TAB_TOP = HEADER_HEIGHT + 40      -- the tabs sit under the class line
local TAB_HEIGHT = 26
local LIST_TOP = TAB_TOP + TAB_HEIGHT + 8
local FOOTER_HEIGHT = 74
local HOW_HEIGHT = 84                    -- the How it works panel under the list
local HOW_HINT = "Hover over a macro to see how it works."
local MENU_ROW = 22
local QUESTION_MARK = 134400

local window, classLine, specButton, menu, emptyText, specNote, addAllButton, removeButton, autoBox
local howPanel, howTitle, howText
local tabs = {}
local rows = {}
local menuRows = {}

-- What the window is showing. The spec comes from ns.ActiveSpec(), or from
-- ns.char.view when a spec has been picked in the menu (kept per
-- character). tab: "ready" or "later".
local tab = "ready"

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
    if not macro or not ns.Exists(macro.name) then return end
    pcall(PickupMacro, macro.name)
end

-- The How it works panel shows the macro the mouse is over.
local function ShowHow(macro)
    if macro and macro.how then
        howTitle:SetText("How " .. macro.name .. " works")
        howText:SetText(macro.how)
    else
        howTitle:SetText("How it works")
        howText:SetText(HOW_HINT)
    end
end

local function ShowTooltip(row)
    local macro = row.macro
    if not macro then return end
    ShowHow(macro)
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(macro.name)
    if macro.how then
        GameTooltip:AddLine(macro.how, 1, 1, 1, true)
    elseif macro.desc then
        GameTooltip:AddLine(macro.desc, 1, 1, 1, true)
    end
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
    row.desc:SetWidth(WIDTH - PADDING * 2 - 40 - 70)
    -- The status sits on the name's line, at the right, so it never runs
    -- into the description below.
    row.status = Label(row, "GameFontHighlightSmall", "RIGHT")
    row.status:SetPoint("TOPRIGHT", -70, -4)
    row.name:SetPoint("RIGHT", row.status, "LEFT", -8, 0)
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

---------------------------------------------------------------------------
-- The Spec menu: a button that opens a short list of choices.
---------------------------------------------------------------------------

local function CloseMenu()
    if menu then menu:Hide() end
end

local function OpenMenu()
    local choices, own = ns.SpecChoices()
    if not choices then return end
    local current = ns.char.view or ns.ActiveSpec() or own
    for index, choice in ipairs(choices) do
        local option = menuRows[index]
        if not option then
            option = CreateFrame("Button", nil, menu)
            option:SetHeight(MENU_ROW)
            option:SetPoint("TOPLEFT", 1, -1 - (index - 1) * MENU_ROW)
            option:SetPoint("TOPRIGHT", -1, -1 - (index - 1) * MENU_ROW)
            local hover = option:CreateTexture(nil, "HIGHLIGHT")
            hover:SetAllPoints()
            hover:SetColorTexture(1, 1, 1, 0.12)
            option.mark = option:CreateTexture(nil, "ARTWORK")
            option.mark:SetSize(4, MENU_ROW - 8)
            option.mark:SetPoint("LEFT", 4, 0)
            option.mark:SetColorTexture(ACCENT_R, ACCENT_G, ACCENT_B, 1)
            option.label = Label(option, "GameFontHighlightSmall")
            option.label:SetPoint("LEFT", 14, 0)
            option:SetScript("OnClick", function(self)
                ns.char.view = self.key
                CloseMenu()
                ns.RefreshWindow()
                -- Picking a spec can make its macros addable.
                ns.ScheduleCheck()
            end)
            menuRows[index] = option
        end
        option.key = choice.key
        option.label:SetText(choice.label)
        option.mark:SetShown(choice.key == current)
        option:Show()
    end
    for index = #choices + 1, #menuRows do menuRows[index]:Hide() end
    menu:SetHeight(#choices * MENU_ROW + 2)
    menu:Show()
end

---------------------------------------------------------------------------
-- Drawing
---------------------------------------------------------------------------

local function SetTab(button, selected)
    button.selected = selected
    button.underline:SetShown(selected)
    if selected then
        button.label:SetTextColor(1, 0.9, 0.75)
    else
        button.label:SetTextColor(0.6, 0.6, 0.6)
    end
end

local function Refresh()
    local _, spec = ns.ClassAndSpec()
    local list, class, shown = ns.WindowList(ns.char.view or ns.ActiveSpec())
    local className = ns.ClassAndSpecNames()
    local r, g, b = ClassColour(class)
    classLine:SetText(className or "Your class")
    classLine:SetTextColor(r, g, b)

    -- The Spec menu's button shows what is being looked at.
    local hasSpecs = ns.SpecChoices() ~= nil
    if list and hasSpecs then
        local label = shown == "shared" and "Every spec" or ns.SpecName(class, shown)
        specButton.label:SetText("Spec: " .. label .. "  v")
        specButton:Show()
    else
        specButton:Hide()
        CloseMenu()
    end

    -- Sort the macros into the two tabs.
    local ready, later = {}, {}
    for _, macro in ipairs(list or {}) do
        if ns.Status(macro) == "needs" then later[#later + 1] = macro else ready[#ready + 1] = macro end
    end
    tabs.ready.label:SetText("Ready to use (" .. #ready .. ")")
    tabs.later.label:SetText("Not learned yet (" .. #later .. ")")
    SetTab(tabs.ready, tab == "ready")
    SetTab(tabs.later, tab == "later")
    for _, button in pairs(tabs) do button:SetShown(list ~= nil) end

    local inCombat = InCombatLockdown()
    local shownList = tab == "ready" and ready or later
    local count, addable = 0, 0
    for index, macro in ipairs(shownList) do
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
            row.status:SetText("|cffffd100Ready to add|r")
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
    for _, macro in ipairs(ready) do
        if ns.Status(macro) == "ready" then addable = addable + 1 end
    end

    -- What to say when there is nothing to list.
    local message
    if not list then
        message = ("There are no macros for %s yet. MacroKit has Paladin macros so far."):format(className or "your class")
    elseif count == 0 and tab == "ready" then
        message = "Nothing ready yet: the spells these macros need are not learned. See Not learned yet (" .. #later .. ")."
    elseif count == 0 then
        message = "You know every spell these macros need."
    end
    emptyText:SetText(message or "")
    emptyText:SetShown(message ~= nil)

    -- Before a spec is chosen, a word on where its macros will come from.
    local noteHeight = 0
    if list and hasSpecs and spec == nil and shown == "shared" then
        specNote:SetText("Your spec shows once you learn a talent spell. Until then, pick yours in the Spec menu.")
        specNote:ClearAllPoints()
        specNote:SetPoint("TOPLEFT", PADDING, -(LIST_TOP + math.max(count, message and 1 or 0) * ROW_HEIGHT + 6))
        specNote:Show()
        noteHeight = 26
    else
        specNote:Hide()
    end

    local listHeight = math.max(count, 1) * ROW_HEIGHT + noteHeight
    if not list then listHeight = 40 end
    -- How it works sits between the list and the buttons, while there are
    -- macros to explain.
    local howHeight = 0
    if list and count > 0 then
        howPanel:ClearAllPoints()
        howPanel:SetPoint("TOPLEFT", PADDING, -(LIST_TOP + listHeight + 6))
        howPanel:SetPoint("TOPRIGHT", -PADDING, -(LIST_TOP + listHeight + 6))
        howPanel:Show()
        howHeight = HOW_HEIGHT + 6
    else
        howPanel:Hide()
    end
    window:SetHeight(LIST_TOP + listHeight + howHeight + FOOTER_HEIGHT)

    addAllButton.label:SetText(addable > 0 and ("Add all missing (" .. addable .. ")") or "Add all missing")
    addAllButton:SetActive(addable > 0 and not inCombat)
    removeButton:SetActive(next(ns.char.made) ~= nil and not inCombat)
    autoBox.tick:SetShown(ns.char.auto and true or false)
end

local function CreateTab(key, x, width)
    local button = CreateFrame("Button", nil, window)
    button:SetSize(width, TAB_HEIGHT)
    button:SetPoint("TOPLEFT", x, -TAB_TOP)
    Fill(button, 1, 1, 1, 0.04)
    local hover = button:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints()
    hover:SetColorTexture(1, 1, 1, 0.08)
    button.label = Label(button, "GameFontNormal", "CENTER")
    button.label:SetPoint("CENTER")
    button.underline = button:CreateTexture(nil, "ARTWORK")
    button.underline:SetPoint("BOTTOMLEFT")
    button.underline:SetPoint("BOTTOMRIGHT")
    button.underline:SetHeight(2)
    button.underline:SetColorTexture(ACCENT_R, ACCENT_G, ACCENT_B, 1)
    button:SetScript("OnClick", function()
        tab = key
        CloseMenu()
        Refresh()
    end)
    tabs[key] = button
    return button
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
    window:SetScript("OnHide", CloseMenu)
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

    -- The class, in its colour, and the Spec menu beside it.
    classLine = Label(window, "GameFontNormalLarge")
    classLine:SetPoint("TOPLEFT", PADDING, -(HEADER_HEIGHT + 12))
    specButton = TextButton(window, 200, "Spec", function()
        if menu:IsShown() then CloseMenu() else OpenMenu() end
    end)
    specButton:SetPoint("TOPRIGHT", -PADDING, -(HEADER_HEIGHT + 8))
    menu = CreateFrame("Frame", addonName .. "SpecMenu", window)
    menu:SetWidth(200)
    menu:SetPoint("TOPRIGHT", specButton, "BOTTOMRIGHT", 0, -2)
    menu:SetFrameStrata("DIALOG")
    menu:EnableMouse(true)
    Fill(menu, 0.08, 0.08, 0.1, 0.98)
    Outline(menu, 0.6)
    menu:Hide()

    -- The two tabs, side by side across the window.
    local tabWidth = (WIDTH - PADDING * 2 - 6) / 2
    CreateTab("ready", PADDING, tabWidth)
    CreateTab("later", PADDING + tabWidth + 6, tabWidth)

    emptyText = Label(window, "GameFontHighlight")
    emptyText:SetPoint("TOPLEFT", PADDING, -(LIST_TOP + 10))
    emptyText:SetWidth(WIDTH - PADDING * 2)
    emptyText:SetWordWrap(true)

    specNote = Label(window, "GameFontDisableSmall")
    specNote:SetWidth(WIDTH - PADDING * 2)
    specNote:SetWordWrap(true)

    -- How it works: a framed panel whose text follows the hovered macro.
    howPanel = CreateFrame("Frame", addonName .. "HowPanel", window)
    howPanel:SetHeight(HOW_HEIGHT)
    Fill(howPanel, 1, 1, 1, 0.04)
    Outline(howPanel, 0.3)
    howTitle = Label(howPanel, "GameFontNormal")
    howTitle:SetPoint("TOPLEFT", 10, -8)
    howText = Label(howPanel, "GameFontHighlightSmall")
    howText:SetPoint("TOPLEFT", howTitle, "BOTTOMLEFT", 0, -5)
    howText:SetWidth(WIDTH - PADDING * 2 - 20)
    howText:SetWordWrap(true)
    howText:SetJustifyV("TOP")
    ShowHow(nil)

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
    autoLabel:SetText("Add new macros by themselves as I learn their spells")
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
    if ns.UpdateBadge then ns.UpdateBadge() end
    if window and window:IsShown() then
        Refresh()
    end
end
