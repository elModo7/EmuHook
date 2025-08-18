; Example made for Sonic The Hedgehog (USA, Europe).sms
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "sms") ; ex: "ahk_exe Fusion.exe"

output := "Emulator: " emuName 
output .= "`nLives: " emu.rm(emu.ram + 0x1246)
output .= "`nLives: " emu.rmd(0xD246) ; Dynamic Example
MsgBox % output
