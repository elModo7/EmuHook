; Example made for Zelda Breath of the Wild US v208
; WiiU uses Big-Endian
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "wiiu") ; ex: "ahk_exe Cemu.exe"

output := "Emulator: " emuName 
output .= "`nHealth: " emu.rmd(0x4301D6FB, 1) ; Health
MsgBox % output

emu.wmd(8, 0x4301D6FB) ; Health set to 8
output := "Health: " emu.rmd(0x4301D6FB, 1)
MsgBox % output
return
