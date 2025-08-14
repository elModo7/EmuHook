; Minimal example on how to hook to one emulator and retrieve data
; Example made for Metroid Prime Hunters EUR NDS
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "nds")

output := "Emulator: " emuName 
output .= "`nPlayer 1 HP: " emu.rmd(0x20db08e, 2)
MsgBox % output
