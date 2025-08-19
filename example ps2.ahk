; Example made for Haunting Ground (USA).iso
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Persistent
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "ps2") ; ex: "ahk_exe pcsx2-qt.exe"
SetTimer, checkBeingChased, 500
return

Numpad1::emu.wm(0, emu.ram + 0x17F5058, 4) ; Set far camera position by punk7890
Numpad2::emu.wmd(1, 0x217F5058, 4) ; Set close camera position by punk7890
Numpad3::emu.wmd(1, 0x2180F684, 4) ; Save Anywhere (has to be triggered while pressing select button) by HewieBelli
Numpad4:: 
	; Unlock All Menu and Special Options by punk7890
	emu.wmd(0xFFFFFFFF, 0x20487A2C, 4)
	emu.wmd(0xFFFFFFFF, 0x20487A24, 4)
return

checkBeingChased:
	ToolTip % emu.rmd(0x20A861E8, 4) ? "You are being chased" : "You are safe"
return