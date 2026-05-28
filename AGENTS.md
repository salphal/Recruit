# HanHua (喊话助手) — Agent Guide

Compact WoW addon: single-file chat helper for YELL + custom channel broadcasting, with optional MeetingHorn integration. Author: 苍穹之霜.

## Repository

```
HanHua.toc       # Manifest — Interface/Title/Version, saved var HHdb
HanHua.lua       # ~530 lines — all logic, no XML, no libraries
Bindings.xml     # Keybinding: FASONG → HH.Send()
release.txt      # Changelog (Chinese). Keep updated.
```

No package manager, no build, no linter, no tests, one git commit. Testing = `/reload` in-game.

## Architecture `HanHua.lua`

**Entry—`ADDON_LOADED` → `HanHuaUI()`.** Builds all frames in Lua. No XML, no load-on-demand.

**Two globals:**
- `HH` — API namespace (`HH.Send()`, `HH.UpdateChannel()`, `HH.UpdateHistoryList()`, font objects, button refs)
- `HHdb` — saved variable (persists `channels`, `history`, `point`, `edit`, `v110` flag)

**Frame tree:**
```
HH.MainFrame (UIParent, movable)
├── HH.button.main     — ★ star toggle + Shift+drag move
├── HH.button.send     — 发送 send button (20s cooldown, OnUpdate countdown)
└── HH.Frame2          — togglable panel (state saved in HHdb.Frame2)
    ├── HH.button.channel[]  — CheckButtons (YELL + custom channels)
    ├── HH.FrameEdit (BackdropTemplate mixin) → HH.edit (168 byte max, multiline)
    └── HH.FrameHistory → HH.historyButtons[] (left=use, right=delete)
```

**Event wiring:**
- `PLAYER_LOGIN` → restore frame position from `HHdb.point`
- `PLAYER_ENTERING_WORLD` / `CHANNEL_UI_UPDATE` → `C_Timer.After(0.5, HH.UpdateChannel)`
- `MODIFIER_STATE_CHANGED` → refresh GameTooltip when Alt toggles
- `hooksecurefunc("ChatConfig_UpdateCheckboxes", ...)` → re-sync channels
- `hooksecurefunc("QuestLogTitleButton_OnClick", ...)` → Shift+click quest inserts name into editbox

**Compat shims** (lines 4–6):
```lua
GetAddOnMetadata  → GetAddOnMetadata or C_AddOns.GetAddOnMetadata
IsAddOnLoaded     → IsAddOnLoaded or C_AddOns.IsAddOnLoaded
LoadAddOn         → LoadAddOn or C_AddOns.LoadAddOn
```

**MeetingHorn integration** — soft coupling. If MeetingHorn loaded, `HH.Send()` writes the message to `LibStub("AceAddon-3.0"):GetAddon("MeetingHorn").MainPanel.Manage.Creator.Comment:SetText(text)`. Only re-publishes activity on text change (guarded by `lastText`). MeetingHorn must load *before* HanHua for the optional feature to work.

**Fonts** — three custom fonts created at init: `HH.FontGreen1`, `HH.FontDisabled`, `HH.FontHilight` — all use `STANDARD_TEXT_FONT`, size 12, `"OUTLINE"`.

## Conventions & gotchas

1. **Interface range** — TOC lists multiple version numbers (Classic → Retail). Update when using new APIs.
2. **Saved variable migration** — `HHdb.v110` one-time flag pattern. Add similar flags for new shapes.
3. **Cooldown** — `HH.SendColdTime = 20`. Button shows numeric countdown via `OnUpdate`; disabled during cooldown.
4. **Max bytes** — `maxBytes = 168` (increased from 128 in v1.1.2). Real-time remaining char display. Newlines stripped in `OnTextChanged`.
5. **History** — `HH.MAX_HISTORY = 15`. Deduplicated at load and on insert. Right-click deletes.
6. **Style** — 2-space indent, lowercase locals, uppercase globals. No formatter/linter config.
7. **Chinese UI** — all user-facing strings in Chinese. System messages via `SendSystemMessage`, not `DEFAULT_CHAT_FRAME`.
8. **Globals** — `HH`, `HHdb`, `BINDING_HEADER_HANHUA`, `BINDING_NAME_FASONG` are intentionally global (addon convention).
9. **Channel filter** — `GetChannelList()` filtered to exclude "MeetingHorn" and "BiaoGeYY" channels.

## Commands

- `/fasong` → `HH.Send()`
- Keybinding: Setting → "HanHua喊话助手" → "发送喊话" (key name `FASONG`)
