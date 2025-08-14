#NoEnv
#Persistent
#SingleInstance Force
SetBatchLines, -1
serverVersion := "1.0.0"
servePort := 8000
global globalConfig := {}
global emu := {}

Loop, %0%
{
	param := %A_Index%
	switch
	{
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

emuName := "ahk_exe " globalConfig.processName
emu := new EmuHook(emuName, globalConfig.romType)

Server := new SocketTCP()
Server.OnAccept := Func("OnAccept")
Server.Bind(["0.0.0.0", servePort])
Server.Listen()
return

OnAccept(Server)
{
	global globalConfig, sock
	sock := Server.Accept()
	SetTimer, sendData, % globalConfig.updateInterval
}

sendData() {
	global sock, emu, globalConfig
	resBodyArray := []
	for k, addressData in globalConfig.addresses
	{
		resBody := {}
        resBody.address := addressData.address
        resBody.ram := addressData.ram
        resBody.bytes := addressData.bytes
        resBody.endian := addressData.endian
        resBody.completeAddress := ""
        
        switch resBody.ram
        {
            case "ram": resBody.completeAddress := resBody.address + emu.ram
            case "wram": resBody.completeAddress := resBody.address + emu.wram
            case "sram": resBody.completeAddress := resBody.address + emu.sram
            default: resBody.completeAddress := resBody.address + emu.ram
        }
        
        value := emu.rm(resBody.completeAddress, resBody.bytes, resBody.endian)
        resBody.value := value ; Needed in a new line
        resBodyArray.push(resBody)
	}
	sock.SendText(JSON.Dump(resBodyArray))
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
