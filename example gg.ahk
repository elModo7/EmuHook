; Example made for Sonic The Hedgehog (World) (Rev 1).gg
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "gg") ; ex: "ahk_exe Fusion.exe"

output := "Emulator: " emuName 
output .= "`nLives: " emu.rm(emu.ram + 0x1240)
output .= "`nLives: " emu.rmd(0xD240) ; Dynamic Example
MsgBox % output
