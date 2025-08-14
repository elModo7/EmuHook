; Resident Evil Archives (REmake) DoorSkip
; 0x8033E198 (it is a pointer though)
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "wii") ; ex: "ahk_exe Dolphin.exe"

Loop
{
	emu.wmd(2, 0x8033E198)
	Sleep, 10
}
