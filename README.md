

# EmuHook — a unified memory-hooking library for emulators and PC games

> **Version:** 0.5.8  
> **Language:** AutoHotkey (v1, 32/64-bit)  
> **Language:** Java 18  
> **Core idea:** Hook an emulator’s process once, resolve the emulated console’s base RAM addresses, and expose a single, consistent API for reading/writing real-time game memory across many systems.

[⭐ Examples Here!](#some-image-demos)
----------

## Index

1. [TL;DR](#tldr)
2. [Why I built it](#why-i-built-it)
3. [Feature highlights](#feature-highlights)
4. [Quick start](#quick-start)
5. [API (practical)](#api-practical)
   - [Constructor](#constructor)
   - [Basic I/O](#basic-io)
   - [Pointer chains](#pointer-chains)
   - [Endianness & cleanup](#endianness--cleanup)
6. [Address-space detection](#address-space-detection-what-happens-behind-the-scenes)
7. [Emulator notes](#emulator-notes-how-base-pointers-are-found)
8. [Real examples](#real-examples-you-can-paste)
9. [Performance & design choices](#performance--design-choices)
10. [Robustness, pitfalls & recommendations](#robustness-pitfalls--recommendations-code-review)
11. [Building overlays & Twitch plugins](#building-overlays--twitch-plugins-on-top-of-emuhook)
12. [Changelog](#changelog)
13. [Extending EmuHook](#extending-emuhook-how-to-add-a-new-emulatorsystem)
14. [Troubleshooting](#troubleshooting)
15. [Supplementary Examples & Variants](#supplementary-examples--variants)
    - [Memory Viewer (GBC Example)](#1-memory-viewer-gbc-example)
    - [EmuHookHTTP](#2-emuhookhttp)
    - [Server.ahk](#3-serverahk)
16. [Roadmap](#roadmap)
17. [Final notes](#final-notes)
18. [Demo images and Videos](#some-image-demos)

----------

## TL;DR

EmuHook lets you:

-   **Attach once** to an emulator (by EXE or PID) and keep a **persistent handle** for fast memory I/O.
    
-   **Auto-resolve base addresses** (WRAM, IRAM, SRAM…) per system/emulator.
    
-   **Read/write** memory in **little- or big-endian** (e.g., GC/Wii on Dolphin).
    
-   **Follow multi-level pointer chains**.
    
-   Use a **common address model** for your overlays, race/crowd-control plugins, real-time event dispatchers, data miners, and debugging tools.
    

**Supported emulators (as of 0.5.8):** 

 - mGBA (GB/GBC/GBA)
 - VisualBoyAdvance-Link (GB/GBC/GBA)
 - VBA-H (GB/GBC/GBA)
 - VBA-rr (GB/GBC/GBA)
 - BGB (GB/GBC)
 - Gambatte Speedrun (GB/GBC)
 - GSE (Game Boy Speedrun Emulator) (GB/GBC)
 - BizHawk (EmuHawk) (GB/GBC/GBA)
 - DuckStation (PSX)
 - MelonDS (NDS)
 - FCEUX (NES)
 - SNES9x (SNES)
 - Dolphin (GC/Wii)

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

```autohotkey
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

```autohotkey
emu := new EmuHook("ahk_pid 12345", "gba")

```

Or auto-detect one running emulator:

```autohotkey
exe := checkRunningEmulator()          ; returns e.g. "ahk_exe mGBA.exe", "" or "multiple"
emu := new EmuHook(exe, "gba")

```

> **Tip:** Some emulators—**BizHawk, DuckStation, Dolphin, melonDS**—require **AutoHotkeyU64** due to 64-bit pointers.

----------

## API (practical)

### Constructor

```autohotkey
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

```autohotkey
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

```autohotkey
; Read through pointers:  base -> +o1 -> +o2 ... -> value
val := emu.rmp(base, [o1, o2, ...], byt := 4, finalByt := "")

; Auto-detected address space
val := emu.rmpd(consoleAddr, [o1, o2, ...], byt := 4, finalByt := "")

; Write via pointer chains
emu.wmp(value, base, [o1, o2, ...], byt := 4, finalByt := "")
emu.wmpd(value, consoleAddr, [o1, o2, ...], byt := 4, finalByt := "")

```

### Endianness & cleanup

```autohotkey
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

-   **mGBA** — Resolves via a module-relative pointer chain depending on GBA/GBC).
    
-   **VisualBoyAdvance (VBA)** — Uses static module offsets differing for **GBA vs GBC**.
    
-   **VBA-H** — GBC supported (WRAM + offset for RAM view), GBA intentionally blocked with a clear error.
    
-   **VBA-rr (svn480)** — GBC supported via WRAM-relative offset.
    
-   **BGB** — GBC supported (GBA appropriately blocked).
    
-   **Gambatte Speedrun / GSE** — Resolves WRAM (e.g., `+0xD000` region) via pointer chain tuned for speedrun builds.
    
-   **BizHawk (EmuHawk)** — 64-bit. Uses an external helper `ThreadstackFinder` to locate a valid stack/anchor and resolve the emulated RAM region reliably. GBA is explicitly marked unsupported in this code path.
    
-   **DuckStation (PSX)** — 64-bit pointer work (requires AHK64).
    
-   **melonDS (NDS)** — Validates `romType` (nds/ds) and resolves ARM9 RAM; 64-bit.
    
-   **FCEUX (NES)**, **SNES9x (SNES/SFC)** — Simple module + offset or short chain.
    
-   **Dolphin (GC/Wii)** — Reads an 8-byte pointer from (Dolphin 2506a), then sets **big-endian** and enables address conversion for the `0x80000000` space (Wii support includes the second memory window at `0x8E000000`).
    

> Each mapping is **emulator-build specific**. If a build updates, these offsets can shift.

----------

## Real examples you can paste

### 1) Overlay snippet (polling + event)

```autohotkey
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

```autohotkey
; Follow base + [0x28, 0x30, 0x43] then read a 4-byte value at the final address
val := emu.rmp(emu.baseProc + 0x275CFC4, [0x28, 0x30, 0x43], 4)

; Same idea but from a console address and auto-detected space
val := emu.rmpd(0x02000000, [0x1C, 0x8], 4, 2) ; e.g., final 2-byte value

```

### 3) Dolphin (GC/Wii) big-endian write

```autohotkey
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

## Building overlays & Twitch plugins on top of EmuHook

-   **Overlay UI:** Use AHK GUIs or offload to a browser source via local WebSocket/HTTP (e.g., AHK ↔ Node/WS). Poll memory at 30–60 Hz; debounce UI updates.
    
-   **Event system:** Wrap reads in a tiny dispatcher:
    

```autohotkey
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

## Changelog

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
    

---

## Supplementary Examples & Variants

These examples are built on the EmuHook core library described above, demonstrating practical applications and integrations.

---

### 1. Memory Viewer (GBC Example)

**Purpose:**  
A standalone **real-time memory viewer** for Game Boy Color titles, using EmuHook’s address-space detection to read live game data.

**Key points:**
- Targets GBC emulators supported by EmuHook (`mGBA`, `VBA`, etc.).
- Uses `rmd()` to fetch memory in **console address space**.
- Displays values in a scrolling or fixed window for debugging/hacking.
- Auto-refresh loop for live updates.

**Snippet:**
```autohotkey
emu := new EmuHook("ahk_exe mGBA.exe", "gbc")
Loop {
    val := emu.rmd(0xC000, 1, "ram") ; read from WRAM
    ToolTip, Value @ C000: % Format("0x{:02X}", val)
    Sleep 100
}

```

**Usage:**  
Great for **reverse-engineering** games, finding health/score addresses, or monitoring event triggers.

----------

### 2. EmuHookHTTP

**Purpose:**  
Extends EmuHook into a **local HTTP API**, allowing overlays, scripts, or remote services to query/write emulator memory without running AHK on the same machine.

**Key points:**

-   Wraps EmuHook calls inside a lightweight HTTP server.
    
-   Responds with JSON for memory reads, accepts POST for writes.
    
-   Can be polled by OBS browser sources, Node.js servers, or even Twitch bots.
    
-   Supports **multiple endpoints** like `/read?addr=...` and `/write`.
    

**Snippet:**

```autohotkey
; Example GET request:  /read?addr=0x02037D00&bytes=2&block=wram
emu := new EmuHook("ahk_exe mGBA.exe", "gba")
val := emu.rmd(addr, bytes, block)
SendResponse("{""value"": " val "}")

```

**Usage:**  
Ideal for **cross-language integrations** (e.g., JS overlays), race coordinators, or crowd-control tools.

----------

### 3. EmuHookServer.ahk

**Purpose:**  
A **centralized service** that runs EmuHook and exposes its capabilities over the network, acting as a hub for multiple tools to interact with the emulator simultaneously.

**Key points:**

-   Built on `Socket.ahk` providing:
    
    -   TCP/WebSocket handling
        
    -   Config parameter (addresses, update interval...)
        
    -   Persistent memory watchers
        
-   Acts as a bridge between local emulator memory and multiple remote subscribers.
    

**Snippet:**

```autohotkey
#Include EmuHookHTTP.ahk
server := new EmuHookServer("gba", 8080)
server.start()

```

**Usage:**  
Perfect for **multi-user setups** (e.g., a Twitch channel with both an overlay and a chat bot reading/writing memory in real time).

----------

**Note:**  
All these scripts depend on the EmuHook core library for actual memory access. Their value lies in **wrapping and extending** it for specific use-cases: visual debugging, HTTP-based overlays, or networked integrations.

----------

## Roadmap

-   Finish **SRAM mappings** across all emulators.
    
-   Add **typed readers/writers** (signed, floats).
    
-   Migrate to **AHK v2**.
    

----------

## Final notes

EmuHook’s power lies in its **consistency**: once you target an address for one emulator, you can usually switch emulators without changing your overlay logic. It’s a solid foundation for **interactive, real-time** tooling—speedrunning races, Twitch crowd-control, data mining, or just deep game debugging.

----------

## Some Image Demos

***[Game Boy Color]*** Pokemon Crystal - Multiplayer Proof of Concept
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/pokecrystal_multiplayer.png?raw=true)
> Tracks player positions and ***shares them between concurrent emulators*** so that you can see other players on your game.
> 
> I made a long video explaining and testing this here.
> 
> [***A small demo video can be found here***      ![](https://i.ytimg.com/vi/CU6lkQsZhMY/hqdefault.jpg?sqp=-oaymwEnCPYBEIoBSFryq4qpAxkIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB&rs=AOn4CLAu3t0CMYSFXpYEl-sz8OcnVY71tA)](https://www.youtube.com/watch?v=CU6lkQsZhMY)
> 
> [***And here I have another demo video no its usage***](https://youtu.be/fGthSATYbsU?si=XqFgtgnCzVnLQYpW)
---

***[Super Nintendo]*** Super Mario World - Web Tracker **(Java branch of EmuHook)**
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/smw.png?raw=true)
> Tracks player data and displays it in a transparent web panel that you can add to OBS.
> 
> This example runs on the Java branch of EmuHook and has ***JavaScript routines*** that periodically calls each endpoint for collecting and displaying data.
> 
> [***I have a small demo video here***](https://youtu.be/BcFzQ5KaX1s)
---

***[Game Boy Color]*** Kirby's Dream Land 2 - OBS Overlay + **Godot**
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/kirbydl2.png?raw=true)
> This overlay is made in the **Godot game engine**, EmuHook exposes a ***TCP socket / WebSockets endpoint*** and then Godot receives data periodically for updating the UI.
> 
> [***I have a small demo video here***](https://youtu.be/Q8ny1_93EDs)
---

***[GameCube]*** Eternal Darkness: Sanity's Requiem - SRT
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/ed.png?raw=true)
> Tracks player data and shows a simple UI. This is what got me into ***inner pointers + big-endian*** settings being added to EmuHook!
> 
> I have a small demo video here:
> 
> [***Small demo video here: Eternal Darkness - Real-Time Tracker***](https://youtu.be/u-wg41RRoXI)
---

***[Game Boy Advance]*** Wario Land 4 - Multiplayer & Touch Controls
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/wl4_multiplayer.png?raw=true)
> Tracks player positions and shares them between concurrent emulators so that you can see other players on the ***Real-Time map, similar to Super Mario 64 DS.***
> 
> [***I have a small demo video here***](https://youtu.be/ZMIaK6Ex5Ls)
---

***[Game Boy Advance]*** Pokemon Fire Red - Spinda Pattern Generator (Real-Time)
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/pokefirered.png?raw=true)
> A **web connected to an EmuHook backend via WebSockets** allow you to draw a Spinda and will force the next encounter to ***find the desired Spinda that you just drew.***
> 
> [***I have a small demo video here***](https://youtu.be/TZWtNENz6po)
> 
> [***I have a full explanation + live programming session here (long)***](https://youtu.be/ysw6vOrmmxI)
---

***[Game Boy Color]*** Pokemon Crystal - Data Mining & Automation Framework
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/pokecrystal.png?raw=true)
> **Where do I start?**
> 
> There is a ***Trainer Card Tracker*** that tracks player data, such as casino coins, badges, play time, player id, name, money, current map name, current bgm name, repel steps...
> 
> There is a ***Real-Time map*** that will change depending on the area you are in.
> 
> There is an ***enemy team tracker + enemy pokemon stats viewer*** with all sorts of info.
> 
> There is a ***player team tracker + active pokemon stats viewer.***
> 
> There is a little ***Cheat Menu for debugging*** and quick testing.
> 
> There is a ***Daycare Viewer*** with info on compatibility, steps, egg management, shinyness...
> 
> There is a ***Real-Time Pokedex viewer*** showing what you have seen, not seend and captured.
> 
> There is a ***Pokemon Announcer system*** made in **Godot** that gives alerts on certain events.
> 
> And lastly an ***Active Pokemon's possible movepool*** so you don't have to search a guide on what your Pokemon will learn next.
>   
>  
> **I have a few demo videos on this one:**
> 
> [***Pokemon Announcer System Demo***](https://youtu.be/n8Hv0ydb9OU)
> 
> [***Pokemon Crystal Tools for Data Mining***](https://youtu.be/wny_OoMoA9w)
> 
> [***Live Capture Alerts Demo***](https://youtu.be/f1iQT9MvXLQ)
> 
> [***Daycare Shiny Egg Breeding Demo***](https://youtu.be/irIogYmYmmY)
---

***[Nintendo DS]*** Metroid Prime Hunters - Player Health & Points Tracker
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/mph.png?raw=true)
> A tracker made for online matches because ***the netcode in MPH is not really good***, this way you can ***predict lag*** seeing when you actually hit a player.
> 
> Actually this only works for bot matches because health data is not shared in online matches, but it doesn't stop anyone from creating a middleware server for upgraded clients that do share this data using EmuHook (I am too lazy to do that right now but it should be a rather simple task, commissions are open here I guess hehe).
> 
> [***I have a small demo video here***](https://youtu.be/f7FraMlZ-gA)
---

***[Game Boy Color]*** Pokemon Crystal - HTTP REST API Pokemon Home/Bank
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/pokemon_home.png?raw=true)
> I ***don't like to depend on third party services*** like the actual Pokemon Home, so I made my own.
> 
> I **can store my pokemons on the cloud, trade them back to the game and so on**.
> 
> There is a **full video** explaining each and every step I did for making this project here:
> 
> [***I made an Unofficial Pokemon Home Cloud Storage without Nintendo***](https://www.youtube.com/watch?v=2ntk2z2zldg)
> 
> [***Second video demo explaining the usage a bit more here***](https://youtu.be/fGthSATYbsU?si=MsgduMuX_t5iSGyi)
---

***[PC & PSX]*** Resident Evil 1 (1996) - Real Time Map, Health Overlay & AutoSplitter
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/re1.png?raw=true)
> This is a set of tools I have made for RE1, it features a Real-Time map, just like the DS version, a health hud and an autosplitter.
> 
> [***I have a demo video here***](https://youtu.be/R-Xl2rBG3Bc)

***[Game Boy Advance]*** Wario Land 4 - Speedrun Tracker
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/wl4.png?raw=true)
> It tracks A LOT of data, it also calculates the completion percentage for 100% speedruns.
> 
> [***A demo video can be found here***](https://youtu.be/t7dcZh4QINw)
> 
> [***Another demo video can be found here***](https://youtu.be/jLcLBPUUhfs)

***[Game Boy Color]*** Pokemon Pinball - Adding Rumble Feature to unsupported emulators
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/pokepinball.png?raw=true)
> This example reads constantly the status of the rumble and then through the XInput.dll library it makes your controller vibrate, no matter if the emulator supports vibration or not.
> 
> [***I have a small demo video here***](https://youtu.be/8nBiUiWHXtU)

***[PC & PSX]*** Resident Evil 1 (1996) - Entity Radar, IGT, Inventory Viewer
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/re1_2.png?raw=true)
> This overlay has a custom, *from scratch* ***IGT tracker, inventory tracker, autosplitter, entity radar and a health hud.***
> 
> [***I have a small demo video here***](https://youtu.be/cI4cBudCgV4)

***[Game Boy Advance]*** Wario Land 4 - Web Tracker
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/wl4_web_tracker.png?raw=true)
> This is one of my first ***Java branch testing*** that expose a ***REST API*** and via ***timed calls*** it does ***HTTP queries*** to the backend for gathering game info.
> 
> [***I have a small demo video here***](https://youtu.be/a_KyjHa1NiI)

***[PSX]*** Parasite Eve 2 - SRT (Commission)
![alt text](https://github.com/elModo7/EmuHook/blob/main/example_images/PE.png?raw=true)
> This is pretty much the one that started it all when dealing with emulators.
> I was commissioned to do this for practicing the Parasite Eve II speedrun, it tracks current enemy HP.
> 
> [***I have a small demo video here***](https://youtu.be/M9eB8EqtNaU)

***[PC]*** Resident Evil 1 (1996) - Twitch Crowd Control
![re1_crowd_control.png](https://github.com/elModo7/EmuHook/blob/main/example_images/re1_crowd_control.png?raw=true)
> This scripts hooks onto ***Twitch chat*** via IRC and then ***translates commands into in-game actions***, like playing with your inventory, health, enemies, status effects and so on.
> 
> There are ***programmable cooldowns and multi language support***.
> 
> [***I have a small demo video here***](https://youtu.be/T4YSzTgq_FU)
---
I also made some ***achievement systems*** using EmuHook similar to **Retro Achievements** like in [***this demo***](https://youtu.be/IK_mhlc3ncU).

---
> *Some parts of this article have been auto-generated with AI because of lack of free time, however I have revised that the information given here meets the current version specification.*
