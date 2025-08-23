version := "0.2.3"
#NoEnv
#SingleInstance, Off
SetBatchlines -1
#Persistent
DetectHiddenWindows, On
ListLines, Off
#Include %A_ScriptDir%\..\..\lib\EmuHook.ahk
#Include <cJSON>
FileEncoding, UTF-8
configLoaded := 0
global 0

Loop % %0%
{
    GivenPath := %A_Index%
    Loop %GivenPath%, 1
        configPath = %A_LoopFileLongPath%
    if (configPath != "") {
		loadConfig(configPath)
		configLoaded := 1
	}
}

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
		MsgBox 0x10, Error, config.json file not found!
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
emu := new EmuHook(memData.processName, memData.romType)

Gui, Add, ListView, h230 w400 gmemListView +LV0x4000 +LV0x10000, Name|Address|Bytes|Value| ; Double Buffered ListView

ImageListID := IL_Create(1)
LV_SetImageList(ImageListID)
IL_Add(ImageListID, "shell32.dll", 13) 

SetFormat, integer, d

for addressKey, address in memData.addresses
{
    LV_Add("Icon1", addressKey, address.address, address.bytes ? address.bytes : 1, "")
}

LV_ModifyCol()
LV_ModifyCol(2, "Integer AutoHdr")
LV_ModifyCol(3, "Integer AutoHdr")
LV_ModifyCol(4, "Integer AutoHdr")
Gui, Show, h250 w420, EmuHook Mem Viewer %version%
SetFormat, integer, d
SetTimer, iterateTable, % memData.updateInterval
return

iterateTable:
    Loop % LV_GetCount()
    {
        LV_GetText(rowName, A_Index, 1)
        LV_GetText(rowAddress, A_Index, 2)
        LV_GetText(rowBytes, A_Index, 3)
        
        memoryValue := emu.rmd(rowAddress, rowBytes*1) ; wtf ahk, make sure it's an int?
        if(memData.addresses[rowName].options){
            if (memData.addresses[rowName].options[memoryValue])
                LV_Modify(A_Index,,,,,memData.addresses[rowName].options[memoryValue])
            else
                LV_Modify(A_Index,,,,,memData.addresses[rowName].options["default"])
        }else{
            LV_Modify(A_Index,,,,,memoryValue)
        }
    }
return

memListView:
if (A_GuiEvent = "DoubleClick")
{
    LV_GetText(rowName, A_EventInfo, 1)
    LV_GetText(rowAddress, A_EventInfo, 2)
    LV_GetText(rowBytes, A_EventInfo, 3)
    rowValue := emu.rmd(rowAddress, rowBytes)
    gosub, showRamEditGui
}
return

q::MsgBox % emu.rmd(rowAddress, rowBytes)

showRamEditGui:
    SetTimer, iterateTable, Off
    Gui ramEdit:Add, Text, x16 y16 w49 h23 +0x200 , Name:
    Gui ramEdit:Add, Text, x16 y48 w49 h23 +0x200, Address:
    Gui ramEdit:Add, Text, x16 y80 w49 h23 +0x200, Size:
    Gui ramEdit:Add, Text, x16 y112 w49 h23 +0x200, Value:
    Gui ramEdit:Add, Text, x72 y16 w121 h23 +0x200 +Center, % rowName
    Gui ramEdit:Add, Text, x72 y48 w121 h23 +0x200 +Center, % rowAddress
    Gui ramEdit:Add, Text, x72 y80 w121 h23 +0x200 +Center, % rowBytes == 1 ? "1 byte" : (rowBytes " bytes")
    Gui ramEdit:Add, Edit, x72 y112 w120 h21 +Center vrowValue, % rowValue
    Gui ramEdit:Add, Button, x112 y144 w80 h23 gsetRamValue, Set value
    Gui ramEdit:Show, w201 h175, SET
    Hotkey, Enter, setRamValue, On
    Hotkey, NumpadEnter, setRamValue, On
return

loadConfig(path) {
    global memData
    if (path != "" && FileExist(path)) {
        FileRead, memDataJSON, % path
        memData := JSON.Load(memDataJSON)
    } else {
        MsgBox 0x10, Error, Config file not found!
        ExitApp
    }
}

setRamValue:
    GuiControlGet, rowValue, ramEdit:, rowValue
    emu.wmd(rowValue, rowAddress, rowBytes)
    gosub, closeRamEdit
return

ramEditGuiEscape:
ramEditGuiClose:
    gosub, closeRamEdit
return

closeRamEdit:
    Gui, ramEdit:Destroy
    Hotkey, Enter, setRamValue, Off
    Hotkey, NumpadEnter, setRamValue, Off
    SetTimer, iterateTable, % memData.updateInterval
return

GuiEscape:
GuiClose:
ExitApp