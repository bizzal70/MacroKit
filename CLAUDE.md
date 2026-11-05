# MacroKit

Adds ready-made class and spec macros to the character's macro list. One addon, one repository: `bizzal70/MacroKit`.

## Workflow

- **No local `.git`.** GitHub holds all history. Publish with `tools\Publish.ps1 -Message "..."`, which uses a throwaway temp clone and runs the tests first.
- **Layout:** the addon's own files (`MacroKit.toc`, `Data.lua`, `Core.lua`) sit at the top of the project, because that is what the release packager expects. `tests/`, `tools/`, `media/` and `.github/` are left out of the released zip by `.pkgmeta`.
- **Testing in game:** `tools\Link-Addon.ps1` junctions this folder into the client's `Interface\AddOns` as `MacroKit`. Edits are live after `/reload`; a new file or a TOC change needs a full client restart.
- **Client install:** `C:\Program Files (x86)\World of Warcraft\_forever_\` (`Wow.exe`, product `wowf`), the live client.
- **Tests:** `python tests/run.py` runs every `tests/test_*.lua` in real Lua 5.1 (the `lupa` pip package) against a fake WoW API in `tests/wow_stub.lua`. They prove the addon's own logic only.
- **Releases:** a tag starting with `v` runs `.github/workflows/release.yml` (BigWigs packager). The CurseForge token secret may be saved as `CF_API_KEY` or `CF_KEY`; the workflow accepts either.

## How it works

- `Data.lua` holds the macros by class file name (`PALADIN`) and specialization ID (Holy 65, Protection 66, Retribution 70). Each has a name (16 characters at most), the spells it needs, and a body (255 characters at most). The tests enforce all three.
- On `PLAYER_ENTERING_WORLD` and the player's `PLAYER_SPECIALIZATION_CHANGED` it waits 3 seconds, then adds the spec's macros once per spec (`MacroKitCharDB.done`). `/macrokit` adds missing ones at any time.
- Macros are created per character (`CreateMacro(name, 134400, body, true)`), never under a name already in use, only when every listed spell is known (`C_Spell.GetSpellInfo` by name, then `IsPlayerSpell`), and never past `MAX_CHARACTER_MACROS` (18 if the global is missing). In combat it defers to `PLAYER_REGEN_ENABLED`.
- `MacroKitCharDB.made` records which macros it added; `/macrokit remove` deletes only those.
- If `GetSpecialization` gives nothing, every spec's macros are offered and the spell check filters them.
- Not yet seen in game (built 2026-11-05). Unverified: whether Forever's Paladin spell names match Retail, whether `C_Spell.GetSpellInfo` resolves names for unlearned spells, and whether icon 134400 shows the dynamic question mark. `/macrokit list` shows which spell each held-back macro is waiting on; ask the user for it.

## Client facts


Everything below, unless marked verified, comes from community sources during the beta (Warcraft Wiki, GitHub ports, fan guides), not from Blizzard docs. Builds change. Verify in game before relying on any of it.

- Local client was 1.60.1.70338 on 2026-10-11 (beta, `WowB.exe`); the live client is 1.60.1.70707 (2026-10-30, `_forever_\Wow.exe`). The TOC interface number for live is not yet confirmed; check `select(4, GetBuildInfo())` in game.
- TOC: `## Interface: 16001` (verified in game on build 70338).
- TOC flavor suffix is `_Forever.toc` or `_Camelot.toc`. The TOC `[Game]` variable expands to `Camelot`. Game type for `AllowLoadGameType` is `forever` / `camelot`.
- The client is Retail-based: Midnight 12.x API and UI architecture, not the Classic API. Port from Retail code.
- `WOW_PROJECT_ID` is `18` on build 70338 (verified in game 2026-10-11, along with interface 16001, by a starter addon since removed). Community guides written against earlier builds say it is 1 (`WOW_PROJECT_MAINLINE`); that is out of date, so Retail code gated on `WOW_PROJECT_ID == WOW_PROJECT_MAINLINE` will not run here. The name of the constant for 18 is not yet known. Prefer testing for the specific API you need over branching on either number.
- Lua 5.1: no `goto`, no `//`, no bitwise operators (use `bit.band` etc.), no `require`. The TOC is the module loader. Start files with `local addonName, ns = ...`.
- Removed globals: `GetItemInfo`, `GetSpellInfo`, `UnitAura`/`UnitBuff`/`UnitDebuff`, `GetTalentInfo`, `GetNumTalentTabs`, `CombatLogGetCurrentEventInfo`, `InterfaceOptionsFrame_OpenToCategory`. Use `C_Item`, `C_Spell`, `C_UnitAuras`, `C_Traits`, and the `Settings` API.
- `C_Spell.GetSpellInfo` returns a table. Item and spell data can be nil until cached.
- Registering an event that does not exist throws and aborts the file. Wrap speculative `RegisterEvent` calls in `pcall`.
- Secret values (Midnight combat restrictions) are active. In combat, `UnitHealth`, aura data, and some names and booleans can be secret: arithmetic, comparison, and printing fail. Guard with `issecretvalue`, and pass values straight to widgets (`StatusBar:SetValue`, `Cooldown:SetCooldownFromDurationObject`) instead of doing Lua math. Combat-log parsing is not available.
- Check `InCombatLockdown()` before touching protected frames and defer to `PLAYER_REGEN_ENABLED`.
- SavedVariables: initialise in `ADDON_LOADED`. Early beta builds reportedly wrote them but did not read them back; on build 70338 they are read back (confirmed in game 2026-10-11).
