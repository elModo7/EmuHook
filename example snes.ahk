; Minimal example on how to hook to one emulator and retrieve data
; Example made for Super Mario World E SNES
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "snes")

output := "Emulator: " emuName 
output .= "`nLives: " emu.rmd(0xDBE)
MsgBox % output
