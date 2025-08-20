; Example made for God Of War Ghost Of Sparta EUR
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "psp") ; ex: "ahk_exe PPSSPPWindows64.exe"
MsgBox % "Red Orbs: " emu.rmd(0x9E06AF0, 2)
emu.wmd(12345, 0x9E06AF0, 2)
MsgBox % "Red Orbs: " emu.rmd(0x9E06AF0, 2)
return