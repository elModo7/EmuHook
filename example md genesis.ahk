; Example made for Sonic The Hedgehog (USA, Europe).md
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "md") ; ex: "ahk_exe Fusion.exe"

output := "Emulator: " emuName 
output .= "`nLives: " emu.rm(emu.ram + 0xFE12)
output .= "`nLives: " emu.rmd(0xFFFE12) ; Dynamic Example 1
output .= "`nLives: " emu.rmd(0xFE12) ; Dynamic Example 2
MsgBox % output
