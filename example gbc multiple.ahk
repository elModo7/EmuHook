; Uses PID instead of Window/Exe name and attaches to two instances
; Example made for Pokemon Crystal U GBC
#NoEnv
#Persistent
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

Run, ./emu/VisualBoyAdvance.exe "./emu/pokecrystal.gbc",,, PID1
PID1 := "ahk_pid " PID1
WinWaitActive, %PID1%

Run, ./emu/VisualBoyAdvance.exe "./emu/pokecrystal.gbc",,, PID2
PID2 := "ahk_pid " PID2
WinWaitActive, %PID2%

OnExit, exitLabel
return

q::gosub, getData
Esc::ExitApp

getData:
	eh := new EmuHook(PID1, "gbc")
	eh2 := new EmuHook(PID2, "gbc")
	MsgBox, % "Emulator: " eh.gameExe "`nPID: " eh.gamePID "`nProcessBase:" eh.baseProc "`nRAM: " eh.ram "`nWRAM: " eh.wram "`nSRAM: " eh.sram "`nTrainer ID: " HexToDec(eh.rmwh(eh.wram + 0x47B) eh.rmwh(eh.wram + 0x47C))
	MsgBox, % "Emulator: " eh2.gameExe "`nPID: " eh2.gamePID "`nProcessBase:" eh2.baseProc "`nRAM: " eh2.ram "`nWRAM: " eh2.wram "`nSRAM: " eh2.sram "`nTrainer ID: " HexToDec(eh2.rmwh(eh2.wram + 0x47B) eh2.rmwh(eh2.wram + 0x47C))
return

exitLabel:
	; In case the class was not instantiated
	PID1 := StrReplace(PID1, "ahk_pid ")
	PID2 := StrReplace(PID2, "ahk_pid ")
	Process, Close, % PID1
	Process, Close, % PID2
	
	eh.gamePID := StrReplace(eh.gamePID, "ahk_pid ")
	eh2.gamePID := StrReplace(eh2.gamePID, "ahk_pid ")
	Process, Close, % eh.gamePID
	Process, Close, % eh2.gamePID
ExitApp
