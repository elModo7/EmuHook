; Minimal example on how to hook to one emulator and retrieve data
; Example made for Resident Evil 1.5 PSX
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Persistent
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "psx") ; ex: "ahk_exe mGBA.exe"
SetTimer, timedMemRead, 500 ; Recommended not to start reading right away
return

timedMemRead:
	SetTimer, timedMemRead, Off
	MsgBox, % "Emulator: " emuName "`nHP: " emu.rm(emu.ram + 0xACAEE) "`nHP: " emu.rmd(0xACAEE) ; Main Character's HP
	ExitApp
return
