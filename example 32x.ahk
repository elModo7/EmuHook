; Example made for Mortal Kombat II (Europe).32x
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "32x") ; ex: "ahk_exe Fusion.exe"

output := "Emulator: " emuName 
output .= "`nTIME: " emu.rm(emu.ram + 0xAB8E)
output .= "`nTIME: " emu.rmd(0xFFAB8E) ; Dynamic Example 1
output .= "`nTIME: " emu.rmd(0xAB8E) ; Dynamic Example 2
MsgBox % output
