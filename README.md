# EmuHook — a unified memory-hooking library for emulators

> **Version:** 0.5.8  
> **Language:** AutoHotkey (v1, 32/64-bit)  
> **Language:** Java 18  
> **Core idea:** Hook an emulator’s process once, resolve the emulated console’s base RAM addresses, and expose a single, consistent API for reading/writing real-time game memory across many systems.

----------

## TL;DR

EmuHook lets you:

-   **Attach once** to an emulator (by EXE or PID) and keep a **persistent handle** for fast memory I/O.
    
-   **Auto-resolve base addresses** (WRAM, IRAM, SRAM…) per system/emulator.
    
-   **Read/write** memory in **little- or big-endian** (e.g., GC/Wii on Dolphin).
    
-   **Follow multi-level pointer chains**.
    
-   Use a **common address model** for your overlays, race/crowd-control plugins, real-time event dispatchers, data miners, and debugging tools.
    

Supported emulators (as of 0.5.8): **mGBA, VisualBoyAdvance, VBA-H, VBA-rr, BGB, Gambatte Speedrun, GSE, BizHawk (EmuHawk), DuckStation (PSX), melonDS (NDS), FCEUX (NES), SNES9x (SNES), Dolphin (GC/Wii)**. Some require **AHK64**.

----------

## Why I built it

Emulator memory tooling is traditionally **per-emulator and per-system**. That fractures tooling for overlays, routing, races, or Twitch integrations. EmuHook normalizes those differences behind a single AHK class, TCP sockets, WebSockets or HTTP REST API (Java), so your higher-level code (events, UI, networking) doesn’t care which emulator or system you’re using.

----------

## Feature highlights

-   **One class to hook them all:** `EmuHook` manages PID discovery, base module resolution, and a **long-lived process handle**.
    
-   **Per-emulator base address resolution:** Internals know where each emulator keeps the emulated RAM (pointer chains or offsets).
    
-   **Dynamic address-space detection** (`detectAddressSpace`): Pass a console address like `0x02000000` (GBA WRAM) and EmuHook maps it to the real process address automatically.
    
-   **Endianness toggle** (`setEndian`): Global big/little endian handling; **Dolphin** is auto-set to **big-endian**.
    
-   **Address conversion for GC/Wii** (`addrCnv`): Transparently converts `0x80000000..` style addresses to process addresses (including Wii’s dual block `0x8E000000` segment).
    
-   **Pointer helpers:** `rmp/rmpd` (read-multi-pointer), `wmp/wmpd` (write-multi-pointer), with final-byte-size support.
    
-   **Hex helpers:** `rmwh/rmwhd` return 0-padded hex strings for UI/debug output.
    
-   **Multi-instance** support via PID: pass `"ahk_pid 1234"` to target a specific emulator window.
    

----------

## Quick start

```ahk
#Include %A_ScriptDir%\EmuHook.ahk

; Attach to mGBA (GBA)
emu := new EmuHook("ahk_exe mGBA.exe", "gba")

; Read a GBA WRAM address directly by console address
; GBA WRAM: 0x02000000..0x02FFFFFF  (EmuHook maps this for you)
hp := emu.rmd(0x02037D00, 2, "wram")   ; read 2 bytes
ToolTip, HP := %hp%

; Write a byte (e.g., set flag)
emu.wmd(1, 0x0203A120, 1, "wram")

; Clean up when done
emu.Destroy()
ExitApp

```

Attach by **PID** instead:

```ahk
emu := new EmuHook("ahk_pid 12345", "gba")

```

Or auto-detect one running emulator:

```ahk
exe := checkRunningEmulator()          ; returns e.g. "ahk_exe mGBA.exe", "" or "multiple"
emu := new EmuHook(exe, "gba")

```

> **Tip:** Some emulators—**BizHawk, DuckStation, Dolphin, melonDS**—require **AutoHotkeyU64** due to 64-bit pointers.

----------

## API (practical)

### Constructor

```ahk
emu := new EmuHook("ahk_exe mGBA.exe", "gba")
emu := new EmuHook("ahk_pid 1234", "gbc")

```

-   `romType` recognized in code paths: **gbc, gb, gba, nds/ds, nes, snes/sfc, gc, wii, pc** (exact checks vary per emulator branch).
    
-   On construct:
    
    -   Resolves **PID** and **window handle**.
        
    -   Opens a **persistent process handle** (`OpenProcess`).
        
    -   Resolves `ram`, and when relevant, `wram/sram`.
        
    -   For **GC/Wii**, flips global endian to **big** and enables address conversion.
        

### Basic I/O

```ahk
; Raw read/write (process address) – use when you already know the resolved process address
val := emu.rm(addr, bytes := 1)
emu.wm(value, addr, bytes := 1)

; Auto address-space detected versions
val := emu.rmd(consoleAddr, bytes := 1, ramBlock := "ram|wram|sram")
emu.wmd(value, consoleAddr, bytes := 1, ramBlock := "ram|wram|sram")

; Hex helpers (0-padded)
hex := emu.rmwh(addr, bytes := 1)                 ; raw
hex := emu.rmwhd(consoleAddr, bytes := 1, "wram") ; detected

```

### Pointer chains

```ahk
; Read through pointers:  base -> +o1 -> +o2 ... -> value
val := emu.rmp(base, [o1, o2, ...], byt := 4, finalByt := "")

; Auto-detected address space
val := emu.rmpd(consoleAddr, [o1, o2, ...], byt := 4, finalByt := "")

; Write via pointer chains
emu.wmp(value, base, [o1, o2, ...], byt := 4, finalByt := "")
emu.wmpd(value, consoleAddr, [o1, o2, ...], byt := 4, finalByt := "")

```

### Endianness & cleanup

```ahk
emu.setEndian("l") ; little (default)
emu.setEndian("b") ; big (auto-set for GC/Wii)

emu.Destroy()      ; closes handle
; or automatic via __Delete

```

----------

## Address-space detection (what happens behind the scenes)

`detectAddressSpace(targetAddr, ramBlock := "ram")` transforms a **console** address into the **real process** address based on the system:

-   **GBC**
    
    -   `0xA000..0xBFFF` → **SRAM**
        
    -   `0xC000..0xCFFF` → **RAM**
        
    -   `0xD000..0xEFFF` → **WRAM**
        
-   **GBA**
    
    -   `0x02000000..0x02FFFFFF` → **WRAM**
        
    -   `0x03000000..0x03FFFFFF` → **IRAM** (exposed as `ram`)
        
-   **Other systems**  
    If you specify `ramBlock` (`"ram" | "wram" | "sram"`) and that base exists, EmuHook just **adds** it and you’re done. This greatly shortens overlay code.
    

For **Dolphin (GC/Wii)**, `addrCnv()` auto-converts the `0x80000000` (and Wii’s `0x8E000000`) spaces to process addresses.

----------

## Emulator notes (how base pointers are found)

> The class has per-emulator logic in `getEmulatorRAM() / getEmulatorWorkRAM() / getEmulatorSRAM()`.

-   **mGBA** — Resolves via a module-relative pointer chain (e.g., `base + 0x275CFC4` → `0x18/0x30 → 0x3C → 0x4 → (0x14 or 0x14C/0x18)` depending on GBA/GBC).
    
-   **VisualBoyAdvance (VBA)** — Uses static module offsets differing for **GBA vs GBC**.
    
-   **VBA-H** — GBC supported (WRAM + offset for RAM view), GBA intentionally blocked with a clear error.
    
-   **VBA-rr (svn480)** — GBC supported via WRAM-relative offset.
    
-   **BGB** — GBC supported (GBA appropriately blocked).
    
-   **Gambatte Speedrun / GSE** — Resolves WRAM (e.g., `+0xD000` region) via pointer chain tuned for speedrun builds.
    
-   **BizHawk (EmuHawk)** — 64-bit. Uses an external helper `ThreadstackFinder64.exe` to locate a valid stack/anchor and resolve the emulated RAM region reliably. GBA is explicitly marked unsupported in this code path.
    
-   **DuckStation (PSX)** — 64-bit pointer work (requires AHK64).
    
-   **melonDS (NDS)** — Validates `romType` (nds/ds) and resolves ARM9 RAM; 64-bit.
    
-   **FCEUX (NES)**, **SNES9x (SNES/SFC)** — Simple module + offset or short chain.
    
-   **Dolphin (GC/Wii)** — Reads an 8-byte pointer from `base + 0x1298AE0` (Dolphin 2506a), then sets **big-endian** and enables address conversion for the `0x80000000` space (Wii support includes the second memory window at `0x8E000000`).
    

> Each mapping is **emulator-build specific**. If a build updates, these offsets can shift.

----------

## Real examples you can paste

### 1) Overlay snippet (polling + event)

```ahk
#NoEnv
#SingleInstance force
#Include %A_ScriptDir%\EmuHook.ahk

emu := new EmuHook("ahk_exe mGBA.exe", "gba")

Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Font, s12, Consolas
Gui, Add, Text, vT w200, Waiting…
Gui, Show, x10 y10 NoActivate, EmuOverlay

lastCoins := -1

SetTimer, Tick, 50
return

Tick:
{
    ; Example: read 16-bit at 0x0203A4B0 (WRAM) – replace with your game’s address
    coins := emu.rmd(0x0203A4B0, 2, "wram")

    if (coins != lastCoins) {
        GuiControl,, T, Coins: %coins%
        SoundBeep, 1000, 50
        lastCoins := coins
    }
}
return

Esc::  ; exit
emu.Destroy()
ExitApp

```

### 2) Following a pointer chain

```ahk
; Follow base + [0x18, 0x30, 0x4] then read a 4-byte value at the final address
val := emu.rmp(emu.baseProc + 0x275CFC4, [0x18, 0x30, 0x4], 4)

; Same idea but from a console address and auto-detected space
val := emu.rmpd(0x02000000, [0x1C, 0x8], 4, 2) ; e.g., final 2-byte value

```

### 3) Dolphin (GC/Wii) big-endian write

```ahk
emu := new EmuHook("ahk_exe Dolphin.exe", "gc")
; For Dolphin, endian is auto "b" and 0x8000_0000 space is auto converted.
emu.wmd(0x0032, 0x8034A0B2, 2, "ram") ; write big-endian halfword

```

----------

## Performance & design choices

-   **OpenProcess once, reuse**: handle stays open until `Destroy`/script exit → lower overhead for high-frequency reads.
    
-   **No repeated PID lookups**: resolved once in `__New`.
    
-   **Endian handling** centralized**: write path builds a byte array for big-endian writes; reads recompose integers properly.
    
-   **Auto-mapping**: `detectAddressSpace` reduces boilerplate and mismatches when you switch emulators.
    

----------

## Robustness, pitfalls & recommendations (code review)

> This section reflects a deeper read of the current `EmuHook.ahk` file you shared.

1.  **Pointer-size consistency**
    
    -   `rm()` uses `"Ptr", MADDRESS` in `ReadProcessMemory` ✅
        
    -   `wm()` currently passes the address as `"UInt", MADDRESS`. On x64 this can truncate.  
        **Recommendation:** Use `"Ptr", MADDRESS` in **both** RPM and WPM calls.
        
2.  **Minimal process rights**
    
    -   `OpenProcess` uses `2035711` (**PROCESS_ALL_ACCESS**). It works but is heavy-handed and may fail with stricter policies.
        
    -   **Recommendation:** Use the minimal rights set: `PROCESS_VM_READ | PROCESS_VM_WRITE | PROCESS_VM_OPERATION | PROCESS_QUERY_INFORMATION` (+ `SYNCHRONIZE` if needed). Define named constants for readability.
        
3.  **Return-value checks**
    
    -   `ReadProcessMemory/WriteProcessMemory` return a success flag; current code doesn’t check it.
        
    -   **Recommendation:** Capture the return and (optionally) `DllCall("GetLastError")` for diagnostics. Emit a friendly error or retry if the emulator is in transition.
        
4.  **Global state changes**
    
    -   `SetFormat, Integer, hex/D` is global and can affect callers.
        
    -   **Recommendation:** Prefer `Format()` / local formatting helpers to avoid global side effects.
        
5.  **BizHawk helper**
    
    -   The path expects `lib\ThreadstackFinder64.exe` at runtime and captures its output in a temp file.
        
    -   **Recommendation:** Validate existence, handle empty output robustly, and document the requirement prominently.
        
6.  **SRAM coverage**
    
    -   `getEmulatorSRAM()` currently implements a **VBA+GBC** path; other emulators’ SRAM logic is TODO.
        
    -   **Recommendation:** Either complete or clearly state SRAM availability per emulator in docs (see the table below).
        
7.  **Multiple instances UX**
    
    -   `checkRunningEmulator()` returns `"multiple"` when more than one emulator matches.
        
    -   **Recommendation:** When that happens, surface the PIDs via `WinGet List` to help the user choose, or accept a **window title substring** to disambiguate.
        
8.  **Type semantics**
    
    -   Helpers read **unsigned integers**; some games use **signed** or **floats**.
        
    -   **Recommendation:** Add typed readers: `rm8s/rm16s/rm32s`, `rmf32/rmf64` and their write counterparts.
        
9.  **Safety**
    
    -   A gentle reminder in docs: **Do not use on online games** / anti-cheat protected titles. Prefer attaching with user privileges (no admin) unless required.
        
10.  **Unit tests & CI**
    
    -   Provide a tiny harness (start emulator with a known ROM & state, read a constant) to sanity-check each mapping on new releases.
        

----------

## Supported emulators & systems (observed in code)

Emulator EXE

Systems

AHK64?

Notes

`mGBA.exe`

GBA, GBC

No

Pointer chain to RAM/WRAM.

`VisualBoyAdvance.exe`

GBA, GBC

No

Static offsets differ per system.

`VisualBoyAdvance_H.exe`

GBC

No

RAM via WRAM+offset; GBA blocked.

`VBA-rr-svn480.exe`

GBC

No

GBA blocked; WRAM-relative fixup.

`bgb64.exe`

GBC

Yes

GBA blocked.

`gambatte_speedrun.exe` / `GSE.exe`

GBC

Mixed

Speedrun builds; WRAM at `+0xD000` via chain.

`EmuHawk.exe` (BizHawk)

GB/GBC/etc.

**Yes**

Uses `ThreadstackFinder64.exe`; GBA blocked in code.

`duckstation-qt-x64-ReleaseLTCG.exe`

PSX

**Yes**

64-bit pointers.

`melonDS.exe`

NDS/DS

**Yes**

Validates romType; ARM9 RAM.

`fceux.exe`

NES

No

Simple mapping.

`snes9x.exe`

SNES/SFC

No

Simple mapping (WRAM at $7E:0000).

`Dolphin.exe`

GC/Wii

**Yes**

Big-endian; address conversion for `0x8000_0000` / `0x8E00_0000`.

> **Note:** Exact offsets & pointer chains are tied to specific emulator builds and may change.

----------

## Building overlays & Twitch plugins on top of EmuHook

-   **Overlay UI:** Use AHK GUIs or offload to a browser source via local WebSocket/HTTP (e.g., AHK ↔ Node/WS). Poll memory at 30–60 Hz; debounce UI updates.
    
-   **Event system:** Wrap reads in a tiny dispatcher:
    

```ahk
class EventBus {
    __New(){ this.prev := {} }
    onChange(key, val) {
        if (this.prev[key] != val) {
            this.prev[key] := val
            return true
        }
        return false
    }
}

bus := new EventBus()

SetTimer, Tick, 33
Tick:
hp := emu.rmd(0x02037D00, 2, "wram")
if (bus.onChange("hp", hp)) {
    ; fire overlay update, play sound, send to chat, etc.
}
return

```

-   **Races/crowd control:** Expose a simple command bus (e.g., read chat → translate into `wmd()` writes). Always **validate ranges** before writing.
    

----------

## Changelog (from code comments)

-   **0.5.8** — PC game hooking (not just emulators)
    
-   **0.5.7** — Major GC/Wii upgrades; inner pointers usable with unconverted addresses
    
-   **0.5.5** — Endianness is global and auto-set for GC/Wii
    
-   **0.5.4** — Dynamic address-space fallback shortens commands
    
-   **0.5.1** — GC/Wii support for Dolphin 2506a + endian toggle
    
-   **0.5.0** — Keep handles open until destroyed (perf boost)
    
-   **0.4.x** — DuckStation (PSX), melonDS (NDS), GSE (Gambatte), FCEUX (NES), SNES9x (SNES), pointer-chain helpers, BizHawk fixups
    
-   **0.3.x** — BizHawk, Gambatte, VBA variants; multi-instance; SRAM tracking
    

----------

## Extending EmuHook (how to add a new emulator/system)

1.  **Find the RAM base** in your emulator:
    
    -   Use CE/IDA or the emulator’s symbols. Often there’s a global like `g_ram` reachable via a stable module offset + pointer chain.
        
2.  **Add mapping** to:
    
    -   `getEmulatorRAM()` — main RAM base.
        
    -   `getEmulatorWorkRAM()` and/or `getEmulatorSRAM()` if applicable.
        
3.  **Define address spaces** in `detectAddressSpace()` (ranges for WRAM/SRAM/IRAM).
    
4.  **Handle endian/addr space quirks**:
    
    -   If big-endian (e.g., PPC), call `this.setEndian("b")`.
        
    -   If virtual ranges (e.g., `0x8000_0000`), implement `addrCnv()` logic.
        
5.  **Guardrails**:
    
    -   Validate `romType` and emit clear errors if unsupported.
        
    -   Keep all pointer sizes `"Ptr"` to be x86/x64-safe.
        

----------

## Troubleshooting

-   **Nothing reads / 0 values:** Wrong `romType`, emulator build changed, or attaching to the wrong process. Try PID attach.
    
-   **64-bit access errors:** Ensure **AutoHotkeyU64** for BizHawk, DuckStation, Dolphin, melonDS.
    
-   **Writes have no effect:** Game state may be mirrored/cached. Try writing to the canonical region (WRAM vs IRAM) or follow the live pointer chain (`rmp`).
    
-   **SRAM reads look wrong:** Not all emulators’ SRAM mapping is implemented yet; use WRAM where possible or add a mapping.
    

----------

## Security & ethics

-   For **single-player/offline** use only. Don’t attach to protected/online titles.
    
-   Distribute overlays/plugins, not ROMs or copyrighted assets.
    
-   Respect emulator licenses.
    

----------

## Roadmap (suggested)

-   Finish **SRAM mappings** across all emulators.
    
-   Add **typed readers/writers** (signed, floats).
    
-   Introduce **bulk reads** (batch RPM) to reduce overhead for overlays.
    
-   Improve **multi-instance selection** (list PIDs and window titles).
    
-   Add **automated self-tests** per emulator build (CI matrix).
    
-   Migrate to **AHK v2** variant (or dual-target with a thin shim).
    

----------

## Final notes

EmuHook’s power lies in its **consistency**: once you target an address for one emulator, you can usually switch emulators without changing your overlay logic. It’s a solid foundation for **interactive, real-time** tooling—speedrunning races, Twitch crowd-control, data mining, or just deep game debugging.

If you want, I can produce a **ready-to-ship demo overlay** (AHK GUI + a few memory events) or scaffold a **Node/OBS** bridge that consumes EmuHook reads and renders a modern overlay.
