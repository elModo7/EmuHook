; Minimal example on how to hook to one pc game and retrieve data
; Example made for gatobros.exe
; PC version of EmuHook is preliminar, it works, but I normally do dedicated scripts without the EmuHook library
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the game to be running already!
emu := new EmuHook("ahk_exe gatobros.exe", "pc")

output := "Game: " emu.gameExe 
output .= "`nLives: " emu.rm(emu.ram + 0x1A1290) ; On PC -> emu.baseProc == emu.ram
output .= "`nLives: " emu.rmd(0x1A1290)
MsgBox % output
