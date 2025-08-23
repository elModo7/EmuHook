; OS Version ...: Windows 10 x64
;@Ahk2Exe-SetName EmuHook Memory Viewer
;@Ahk2Exe-SetDescription Dynamic memory viewer for Console Emulators and PC Games.
;@Ahk2Exe-SetVersion 1.0.1
;@Ahk2Exe-SetCopyright Copyright (c) 2025`, elModo7
;@Ahk2Exe-SetOrigFilename EmuHook Memory Viewer.exe
; INITIALIZE
; *******************************
#NoEnv
#SingleInstance, Off
#Persistent
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1
global version := "1.0.2"
DetectHiddenWindows, On
ListLines, Off
#Include %A_ScriptDir%\..\..\lib\EmuHook.ahk
#Include <cJSON>
#Include <Neutron>
FileEncoding, UTF-8
configLoaded := 0
global 0

; Init Neutron GUI
neutron := new NeutronWindow()
neutron.Load("Memory_viewer.html")
neutron.Gui("+LabelNeutron")

Loop %0%
{
    GivenPath := %A_Index%
    Loop %GivenPath%, 1
        configPath = %A_LoopFileLongPath%
	if (configPath != "") {
		loadConfig(configPath)
		configLoaded := 1
	}
}

; FileInstalls
FileCreateDir, % A_Temp "\VictorDevLog_MemoryViewer"
FileInstall, res/ico/info.ico, % A_Temp "\VictorDevLog_MemoryViewer\info.ico" 
FileInstall, res/ico/close3.ico, % A_Temp "\VictorDevLog_MemoryViewer\close3.ico" 

; Tray Menu
Menu, Tray, NoStandard
Menu, tray, add, % "Memory Viewer Info", showAboutScreen
Menu tray, Icon, % "Memory Viewer Info", % A_Temp "\VictorDevLog_MemoryViewer\info.ico"
Menu, Tray, Add, Exit, ExitSub
Menu tray, Icon, Exit, % A_Temp "\VictorDevLog_MemoryViewer\close3.ico"

; Parameters
if (!configLoaded) {
	Loop, %0%
	{
		param := %A_Index%
		switch
		{
			case InStr(param, "-h") || InStr(param, "-help"):
				MsgBox 0x40, Params, Allowed params:`n`nconfig=<path>
			case InStr(param, "-config="):
				configPath := StrSplit(param, "=")[2]
				loadConfig(configPath)
		}
	}
}

if (configPath == "") {
	if (FileExist("config.json"))
		loadConfig("config.json")
	else {
		MsgBox 0x10, Error, config.json file not found!`n`nIt must be placed under %A_ScriptDir%\default.json
		ExitApp
	}
}

; It expects the emulator to be running already!
memData.processName := memData.processName == "auto" ? checkRunningEmulator() : memData.processName
if(!InStr(memData.processName, "ahk_exe "))
{
    memData.processName := "ahk_exe " memData.processName
}
if (!WinExist(memData.processName)) {
    MsgBox 0x10, Process not found, % "The target process " "" memData.processName "" " is not running or was not detected properly.`n`nMake sure target process is not minimized and/or run EmuHook as admin."
    ExitApp
}

; Initialize EmuHook
emu := new EmuHook(memData.processName, memData.romType)
neutron.Show("w560 h480")

OnExit, ExitSub
OnMessage(0x404, "AHK_ICONCLICKNOTIFY") ; Detect Tray Icon Clicks
SetTimer, processData, % memData.updateInterval
return

processData() {
	global sock, emu, memData, neutron
	resBodyArray := []
	for k, addressData in memData.addresses
	{
		resBody := {}
        resBody.address := addressData.address
        resBody.bytes := addressData.bytes ? addressData.bytes : 1
		resBody.value := emu.rmd(resBody.address, resBody.bytes)
		if(addressData.options){
            if (addressData.options[resBody.value])
                resBody.value := addressData.options[resBody.value]
            else
                resBody.value := addressData.options["default"]
        }
		resBodyArray.push(resBody)
	}
	neutron.wnd.updateTableValues(JSON.Dump(resBodyArray))
}

AHK_ICONCLICKNOTIFY(wParam,lParam)
{
	if (lParam = 0x205) ; RIGHT CLK
	{
		Menu, Tray, Show
	}
	else if (lParam = 0x208) ; MIDDLE CLK
	{
		TrayTip, EmuHook Memory Viewer - VictorDevLog, % "A software by Víctor Santiago Martínez Picardo`nv" version
	}
	return 0
}

closeApp(unhandledParam := ""){
	gosub, ExitSub
}

loadConfig(path) {
    global memData, neutron
    if (path != "" && FileExist(path)) {
        FileRead, memDataJSON, % path
        memData := JSON.Load(memDataJSON)
		neutron.wnd.generateHtmlTable(memDataJSON)
    } else {
        MsgBox 0x10, Error, Config file not found!
        ExitApp
    }
}

NeutronClose:
GuiClose:
ExitSub:
ExitApp

showAboutScreen:
	showAboutScreen("EmuHook Memory Viewer v" version, "Memory tool for reading data from memory directly from the Emulated System's memory context and/or PC Games.")
return

#Include <aboutScreen>

; Neutron's FileInstall Resources
FileInstall, Memory_viewer.html, Memory_viewer.html
FileInstall, bootstrap.min.css, bootstrap.min.css
FileInstall, font-awesome.min.css, font-awesome.min.css
FileInstall, bootstrap.min.js, bootstrap.min.js
FileInstall, jquery.min.js, jquery.min.js
FileInstall, fontawesome-webfont.woff, fontawesome-webfont.woff