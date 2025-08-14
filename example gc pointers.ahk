; This is for the Japanese Version of Eternal Darkness
#SingleInstance Force
#NoEnv
SetBatchLines -1
#Include <EmuHook>
emuName := checkRunningEmulator()
emu := new EmuHook(emuName, "gc")

Gui +hWndhMainWnd +E0x02000000 +E0x00080000
Gui Color, 0x400080
Gui Font, s14 Bold c0xFFFFFF, Bai Jamjuree SemiBold
Gui Add, Text, vtxtHP x16 y8 w111 h23 +0x200 +Right, HP:
Gui Add, Text, vtxtMagic x16 y40 w111 h23 +0x200 +Right, Magic:
Gui Add, Text, vtxtSanity x16 y72 w111 h23 +0x200 +Right, Sanity:
Gui Add, Text, vtxtStamina x16 y104 w111 h23 +0x200 +Right, Stamina:
Gui Add, Progress, vhp hWndhPrg x136 y8 w120 h20 -Smooth +C0xFF0000, 33
Gui Add, Progress, vmagic x136 y40 w120 h20 -Smooth +C0x0095BF, 33
Gui Add, Progress, vsanity hWndhPrg3 x136 y72 w120 h20 -Smooth +C0x80FF80, 33
Gui Add, Progress, vstamina hWndhPrg4 x136 y104 w120 h20 -Smooth +C0xCCCC00, 33

Gui Show, w264 h135, ED Tracker (JP)
SetTimer, updateGUI, 100
Return

updateGUI:
    hp := emu.rmpd(0x806101D4, [0x24, 0x30], 4, 2)
    GuiControl,, hp, % hp
    GuiControl,, txtHP, % "HP (" hp "):"

    magic := emu.rmpd(0x806101D4, [0x28, 0x8C, 0xE4], 4, 2)
    GuiControl,, magic, % magic
    GuiControl,, txtMagic, % "Magic (" magic "):"

    sanity := emu.rmpd(0x806101D4, [0x28, 0x8C, 0xE2], 4, 2)
    GuiControl,, sanity, % sanity
    GuiControl,, txtSanity, % "Sanity (" sanity "):"

    stamina := emu.rmpd(0x806101D4, [0x28, 0x8C, 0xE6], 4, 2)
    GuiControl,, stamina, % stamina / 100
    GuiControl,, txtStamina, % "Stam. (" Round(stamina / 100) "):"
    
    ;~ emu.wmpd(100, 0x806101D4, [0x24, 0x30], 4, 2) ; This sets health to 100 always
    ;~ ToolTip, % "hp:" hp "`nmagic:" magic "`nsanity:" sanity "`nstamina:" stamina
return

GuiEscape:
GuiClose:
    ExitApp