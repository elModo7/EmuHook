; Minimal example on how to hook to one emulator and retrieve data
; Example made for Super Mario Bros E NES
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "nes")

output := "Emulator: " emuName 
output .= "`nLives: " emu.rmd(0x75A)
MsgBox % output
