; Example made for Super Mario 3D Land EUR
; This demo is kinda sad, since inner addresses are pointers, so this is the only demo so far (0.6.7) that will not work without tweaking
; I also don't have a 3ds and have no interest in playing it for now
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "3ds")

output := "Emulator: " emuName 
output .= "`nCoins: " emu.rmd(0xF9680E8, 1) "`nSecondary Pwr: " emu.rmd(0xF9680F0, 1)
MsgBox % output
emu.wmd(99, 0xF9680E8)
MsgBox % "Coins: " emu.rmd(0xF9680E8, 1)