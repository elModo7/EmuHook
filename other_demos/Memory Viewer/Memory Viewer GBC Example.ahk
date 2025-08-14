#NoEnv
#SingleInstance, Force
SetBatchlines -1
#Persistent
DetectHiddenWindows, On
ListLines, Off
#Include %A_ScriptDir%\..\..\lib\EmuHook.ahk
#Include <cJSON>
FileEncoding, UTF-8

Loop, %0%
{
	param := %A_Index%
	switch
	{
		case InStr(param, "-config="):
			configPath := StrSplit(param, "=")[2]
            loadConfig(configPath)
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
emu := new EmuHook(memData.processName, memData.romType)

Gui, Add, ListView, h230 w300 gmemListView +LV0x4000 +LV0x10000, Name|Address|Bytes|Value| ; Double Buffered ListView

ImageListID := IL_Create(1)
LV_SetImageList(ImageListID)
IL_Add(ImageListID, "shell32.dll", 13) 

SetFormat, integer, d

for addressKey, address in memData.addresses
{
    LV_Add("Icon1", addressKey, address.address, address.bytes, "")
}

LV_ModifyCol()
LV_ModifyCol(2, "Integer AutoHdr")
LV_ModifyCol(3, "Integer AutoHdr")
LV_ModifyCol(4, "Integer AutoHdr")
Gui, Show, h250 w320
SetFormat, integer, d
SetTimer, iterateTable, % memData.updateInterval
return

iterateTable:
    Loop % LV_GetCount()
    {
        LV_GetText(rowName, A_Index, 1)
        LV_GetText(rowAddress, A_Index, 2)
        if(memData.addresses[rowName].options){
            memoryValue := emu.rmd(rowAddress)
            if (memData.addresses[rowName].options[memoryValue])
                LV_Modify(A_Index,,,,,memData.addresses[rowName].options[memoryValue])
            else
                LV_Modify(A_Index,,,,,memData.addresses[rowName].options["default"])
        }else{
            LV_Modify(A_Index,,,,,emu.rmd(rowAddress))
        }
    }
return

memListView:
if (A_GuiEvent = "DoubleClick")
{
    LV_GetText(rowName, A_EventInfo, 1)
    LV_GetText(rowAddress, A_EventInfo, 2)
    ToolTip % "You double-clicked row number " A_EventInfo ".`nText: " rowName "`nAddress: " rowAddress "`nValue: " emu.rmd(rowAddress)
    Sleep, 1000
    ToolTip
}
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

GuiEscape:
GuiClose:
ExitApp