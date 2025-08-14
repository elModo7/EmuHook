; Minimal example on how to hook to one emulator and retrieve data
; Example made for Zelda Twilight Princess EUR
; GameCube uses Big-Endian
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "gc") ; ex: "ahk_exe Dolphin.exe"

output := "Emulator: " emuName 
output .= "`nRupees: " emu.rmd(0x80408164, 2) ; Rupees (Dynamic Address Space)
MsgBox % output

; Write 0x3E7 to memory (999)
emu.wmd(0x03, 0x80408164)
emu.wmd(0xE7, 0x80408165)
output := "Change Trigger to 999:`nRupees: " emu.rmd(0x80408164, 2) " -> Big-Endian" ; Display of Big-Endian param (recommended for GC)
MsgBox % output
emu.wmd(1234, 0x80408164, 2)
output .= "`n`nChange Trigger to 1234:`nRupees: " emu.rmd(0x80408164, 2)
MsgBox % output