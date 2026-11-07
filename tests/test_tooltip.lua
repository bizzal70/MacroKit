-- Action button tooltips: MacroKit explains its own macros under the
-- spell's tooltip, and leaves everything else alone.
local ns = LoadAddon(ADDON_DIR, "MacroKit")
local function check(cond, what) if not cond then error("CHECK FAILED: " .. what, 2) end; io.write("pass  ", what, "\n") end
local function Tip() return table.concat(TOOLTIP, " | ") end

SPEC = nil
Learn("Holy Light", "Holy Strike")
CreateMacro("Mine", 1, "/say mine", true)
Fire("ADDON_LOADED", "MacroKit")
Fire("PLAYER_ENTERING_WORLD")
RunAfters()
check(GetMacroIndexByName("Heal") > 0 and ns.char.made.Heal, "MacroKit has added its Heal macro")

ACTIONS[1] = { kind = "macro", id = GetMacroIndexByName("Heal"), text = "Heal" }
ACTIONS[2] = { kind = "spell", id = 635 }
ACTIONS[3] = { kind = "macro", id = GetMacroIndexByName("Mine"), text = "Mine" }

GameTooltip:SetAction(1)
check(Tip():find("spell tooltip for slot 1", 1, true), "the game's own tooltip for the spell is kept")
check(Tip():find("MacroKit: Heal", 1, true) and Tip():find("Casts Holy Light on the friend under your mouse", 1, true),
    "and MacroKit adds what its macro does underneath: " .. Tip())

GameTooltip:SetAction(2)
check(not Tip():find("MacroKit", 1, true), "a plain spell on a button gets nothing added")
GameTooltip:SetAction(3)
check(not Tip():find("MacroKit", 1, true), "nor does a macro the player made")

-- A macro of the player's own that happens to share a name with one of MacroKit's.
ns.char.made.Heal = nil
GameTooltip:SetAction(1)
check(not Tip():find("MacroKit", 1, true), "a macro MacroKit did not add is not explained, even with a matching name")
ns.char.made.Heal = true

-- The name read from the macro itself when the button gives no text.
ACTIONS[1].text = nil
GameTooltip:SetAction(1)
check(Tip():find("MacroKit: Heal", 1, true), "the macro is found by its index when the button gives no name")

-- Switching it off and on.
SlashCmdList.MACROKIT("tooltips")
GameTooltip:SetAction(1)
check(not ns.db.actionTooltips and not Tip():find("MacroKit", 1, true), "/macrokit tooltips turns the explanations off")
SlashCmdList.MACROKIT("tooltips")
GameTooltip:SetAction(1)
check(Tip():find("MacroKit: Heal", 1, true), "and back on")

-- The game misbehaving raises no error.
GetActionInfo = function() error("something this client does differently") end
check(pcall(GameTooltip.SetAction, GameTooltip, 1), "a surprise from the game raises no error")
