local addonName, ns = ...

local button = CreateFrame("Button", addonName .. "MinimapButton", Minimap)
button:SetSize(31, 31)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)
button:RegisterForDrag("LeftButton")
button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
button:Hide()

local background = button:CreateTexture(nil, "BACKGROUND")
background:SetSize(24, 24)
background:SetPoint("CENTER")
background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetSize(18, 18)
icon:SetPoint("CENTER")
icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

local border = button:CreateTexture(nil, "OVERLAY")
border:SetSize(50, 50)
border:SetPoint("TOPLEFT")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

local function Place()
    local angle = ns.db.minimapAngle
    local radius = Minimap:GetWidth() / 2 + 5
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

-- Dragging slides the button around the rim of the minimap.
local function FollowCursor(self)
    -- Stop as soon as the mouse button is up, even if the game never sent
    -- OnDragStop (it can go missing when two buttons overlap); otherwise the
    -- button would keep following the cursor and drag along with another.
    if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
        self:SetScript("OnUpdate", nil)
        return
    end
    local centerX, centerY = Minimap:GetCenter()
    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    ns.db.minimapAngle = math.atan2(cursorY / scale - centerY, cursorX / scale - centerX)
    Place()
end

button:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", FollowCursor) end)
button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
button:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
button:SetScript("OnClick", function() ns.ToggleWindow() end)
button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("MacroKit")
    GameTooltip:AddLine("Click: macros for your class and spec", 1, 1, 1)
    local new, ready = ns.Counts()
    if new > 0 then
        GameTooltip:AddLine(new .. " new macro" .. (new > 1 and "s" or "") .. " since you last looked", 1, 0.3, 0.3)
    end
    if ready > 0 then
        GameTooltip:AddLine(ready .. " ready to add", 1, 0.82, 0)
    end
    GameTooltip:AddLine("Drag: move this button", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
button:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- A red badge with a count, on the button's top-right edge, while there
-- are new macros (added by MacroKit, or ready to add) the player has not
-- looked at, or macros waiting to be added. It sits on its own frame above
-- the button, so the gold ring never covers it.
local badge = CreateFrame("Frame", addonName .. "MinimapBadge", button)
badge:SetSize(18, 18)
badge:SetPoint("CENTER", button, "TOPRIGHT", -5, -5)
badge:SetFrameLevel((button:GetFrameLevel() or 8) + 5)
local dot = badge:CreateTexture(nil, "ARTWORK")
dot:SetAllPoints()
dot:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
dot:SetVertexColor(0.85, 0.1, 0.1, 1)
local count = badge:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
count:SetPoint("CENTER", 0, 0)
count:SetTextColor(1, 1, 1)
badge:Hide()
badge.count = count
function ns.UpdateBadge()
    local _, _, total = ns.Counts()
    -- Not while the window is open: the player is looking at it already.
    if total and total > 0 and not (ns.WindowShown and ns.WindowShown()) then
        count:SetText(total > 9 and "9+" or tostring(total))
        badge:Show()
    else
        count:SetText("")
        badge:Hide()
    end
end

-- Shows or hides the button as the setting says.
function ns.UpdateMinimapButton()
    if ns.db.minimapButton then
        Place()
        button:Show()
    else
        button:Hide()
    end
end
