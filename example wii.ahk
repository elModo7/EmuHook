; Minimal example on how to hook to one emulator and retrieve data
; Example made for Wii Play US WBFS -> RHAE01.wbfs (first shooting minigame)
; Wii uses Big-Endian
; Note: if you search using Dolphin Memory Engine, you have to substract: 0x8E000000 in order to get direct address
; Example: 0x91E40FC2 - 0x8E000000 = 0x3E40FC2 (automatic from 0.5.7+)
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "wii") ; ex: "ahk_exe Dolphin.exe"

output := "Emulator: " emuName 
output .= "`nScore: " emu.rmd(0x91E40FC2, 2) ; Points
MsgBox % output

; Write 999 to memory
emu.wmd(999, 0x91E40FC2, 2)
output := "Change Trigger to 999:`nPoints: " emu.rmd(0x91E40FC2, 2)
MsgBox % output
