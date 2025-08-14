; Minimal example on how to hook to one emulator and retrieve data
; Example made for Pokemon Crystal U GBC
#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>

; It expects the emulator to be running already!
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "gbc") ; ex: "ahk_exe mGBA.exe"

;~ emu.wmd(0x30, 0xD47B) emu.wmd(0x39, 0xD47C) ; Dynamic Write, set player ID to 12345

output := "Emulator: " emuName 
output .= "`nTrainer ID: " HexToDec(emu.rmwh(emu.wram + 0x47B) emu.rmwh(emu.wram + 0x47C)) "`nMusic: " emu.rm(emu.ram + 0x101) 
output .= "`nTrainer ID: " HexToDec(emu.rmwhd(0xD47B) emu.rmwhd(0xD47C)) "`nMusic: " emu.rmd(0xC101)  ; Example dynamic mode (auto WRAM, SRAM, RAM, IWRAM)
MsgBox % output
