#NoEnv
#Persistent
#SingleInstance Force
SetBatchLines, -1
serverVersion := "1.0.3"
servePort := 8000
global globalConfig := {}
global emu := {}

Loop, %0%
{
	param := %A_Index%
	switch
	{
		case InStr(param, "-h") || InStr(param, "-help"):
			MsgBox 0x40, Params, Allowed params:`n`n-port=<port>`n-config=<path>
		case InStr(param, "-port="):
			servePort := StrSplit(param, "=")[2]
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

#Include <Socket>
#Include <cJSON>
#Include %A_ScriptDir%\..\..\lib\EmuHook.ahk

; It expects the emulator to be running already!
globalConfig.processName := globalConfig.processName == "auto" ? checkRunningEmulator() : globalConfig.processName
if(!InStr(globalConfig.processName, "ahk_exe "))
{
    globalConfig.processName := "ahk_exe " globalConfig.processName
}
if (!WinExist(globalConfig.processName)) {
    MsgBox 0x10, Process not found, The target process is not running or was not detected properly.`n`nMake sure target process is not minimized and/or run EmuHook as admin.
    ExitApp
}
emu := new EmuHook(globalConfig.processName, globalConfig.romType)

Server := new SocketTCP()
Server.OnAccept := Func("OnAccept")
Server.Bind(["0.0.0.0", servePort])
Server.Listen()
return

OnAccept(Server)
{
	global globalConfig, sock
	sock := Server.Accept()
	SetTimer, processData, % globalConfig.updateInterval
}

processData() {
	global sock, emu, globalConfig
	resBodyArray := []
	for k, addressData in globalConfig.addresses
	{
		resBody := {}
        resBody.address := addressData.address
        resBody.bytes := addressData.bytes ? addressData.bytes : 1
		
		if (addressData.write) {
			emu.wmd(addressData.value, resBody.address, resBody.bytes)
		} else {
			resBody.value := emu.rmd(resBody.address, resBody.bytes)
			resBodyArray.push(resBody)
		}
	}
	try
		sock.SendText(JSON.Dump(resBodyArray))
	catch
		SetTimer, processData, Off ; Client most surely disconnected
}

loadConfig(path) {
    global globalConfig
    if (path != "" && FileExist(path)) {
        FileRead, globalConfigJSON, % path, UTF-8
        globalConfig := JSON.Load(globalConfigJSON)
    } else {
        MsgBox 0x10, Error, Config file %path% not found!
        ExitApp
    }
}
