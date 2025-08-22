; Example made for Sonic the hedgehog 4 Episode 1 EUR: NPEB00153
; PS3 uses big-endian
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Persistent
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "ps3") ; ex: "ahk_exe rpcs3.exe"
MsgBox % "Rings: " emu.rmd(0x3AFB01AA, 2) ; 2 byte big-endian (seems like address sometimes changes)
emu.wmd(123, 0x3AFB01AA, 2)
MsgBox % "Rings: " emu.rmd(0x3AFB01AA, 2)
return