#NoEnv
#SingleInstance Force
SetBatchLines, -1
#Include <EmuHook>
#Include <gb_c_headers> ; Only used here for showcase since I am lazy to support all emulators for this feature atm

; Only VisualBoyAdvance supported and has to be running already!
emu := new EmuHook("ahk_exe VisualBoyAdvance.exe", "gbc")
romBase := emu.rm(emu.baseProc + 0x1C924C, 4) ; 0x1D93A4 too

output := "Emulator: " emu.gameExe 

; Title:
headers.title := ""
Loop, 16
{
	headers.title .= Chr(emu.rm(romBase + 0x133 + A_Index))
}

; Manufacturer code:
headers.manufacturerCode := ""
Loop, 4
{
	headers.manufacturerCode .= Chr(emu.rm(romBase + 0x13E + A_Index))
}

output .= "`nTitle: " headers.title
output .= "`nManufacturer Code: " headers.manufacturerCode
output .= "`nSGB: " headers.sgb[emu.rm(romBase + 0x146)]
output .= "`nMBC: " headers.mbc[emu.rm(romBase + 0x147)]
output .= "`nROM Size: " headers.romSize[emu.rm(romBase + 0x148)]
output .= "`nRAM Size: " headers.ramSize[emu.rm(romBase + 0x149)]
output .= "`nDestination: " headers.destination[emu.rm(romBase + 0x14A)]
output .= "`nLicensee: " headers.licensee[emu.rm(romBase + 0x14B)]
if (headers.licensee[emu.rm(romBase + 0x14B)] == "New licensee code")
{
	output .= "`nNew Licensee code: " headers.newLicensee[""Chr(emu.rm(romBase + 0x144))Chr(emu.rm(romBase + 0x145))""]
}
output .= "`nVersion: " headers.version[emu.rm(romBase + 0x14C)]
MsgBox % output



