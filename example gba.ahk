; Minimal example on how to hook to one emulator and retrieve data
; Example made for Wario Land 4 GBA
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "gba")

output := "Emulator: " emuName 
output .= "`nWario HP: " emu.rm(emu.ram + 0x1910)
output .= "`nWario HP: " emu.rmd(0x3001910) ; Example dynamic mode (auto WRAM, SRAM, RAM, IWRAM)
MsgBox % output
