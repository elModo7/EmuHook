; Example made for Super Mario 64 U
; N64 uses Big-Endian
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "n64") ; ex: "ahk_exe Project64.exe"

output := "Emulator: " emuName 
output .= "`nHealth: " emu.rmd(0x33B21D, 1) ; Health
output .= "`nLives: " emu.rmd(0x33B21E, 1) ; Lives
MsgBox % output

emu.wmd(8, 0x33B21D) ; Health set to 8
emu.wmd(99, 0x33B21E) ; Lives set to 99
output := "Health: " emu.rmd(0x33B21D, 1)
output .= "`nLives: " emu.rmd(0x33B21E, 1)
MsgBox % output
return