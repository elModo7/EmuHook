; Example made for Borderline (Japan, Europe).sg and Galaga (Taiwan).sg
; RAM starts at 0xCXXX so 0xC346 would be 0x346 here
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "sg-1000") ; ex: "ahk_exe Fusion.exe"

output := "Emulator: " emuName 
output .= "`n`n*******************`n`nBorderline:`nLives: " emu.rm(emu.ram + 0xDE) "`nFuel: " emu.rm(emu.ram + 0xDF)
output .= "`n`n*******************`n`nGalaga:`nLives: " emu.rmd(0x346) ; Dyncamic Example
MsgBox % output
