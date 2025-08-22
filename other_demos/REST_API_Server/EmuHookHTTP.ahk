; *** IMPORTANT ***
; AHKHTTP is known for having memory leaks and other bugs so I am deprecating this script.
; Always resort to Java version of EmuHook if you need an HTTP REST API.
; Use the TCP/WebSocket version whenever possible for third-party integrations.

; Allows doing HTTP Queries to read/write memory just like the Java port
; AHK is notorious for dropping connections after a while, so this is mostly a test script
; Examples:
/*
cmd > EmuHookHTTP.exe -port=8080 -config=defaultAddresses.json
http://localhost:8000/setEmulator?name=VisualBoyAdvance.exe&romType=gbc
http://localhost:8000/rm?address=0x8D9&ram=wram
http://localhost:8000/wm?address=0x8D9&value=15&ram=wram
http://localhost:8000/readDefault
*/
#Persistent
#SingleInstance, force
SetBatchLines, -1
serverVersion := "1.0.0"
servePort := 8000
global emu := {}
global defaultAddresses := []
emu.version := "(Uninitialized)"

Loop, %0%
{
	param := %A_Index%
	switch
	{
		case InStr(param, "-port="):
			servePort := StrSplit(param, "=")[2]
		case InStr(param, "-config="):
			defaultAddressesPath := StrSplit(param, "=")[2]
            loadDefaultAddresses(defaultAddressesPath)
	}
}

paths := {}
paths["/version"] := Func("apiShowVersion")
paths["/setEmulator"] := Func("apiSetEmulator")
paths["/setEmulatorAuto"] := Func("apiSetEmulatorAuto")
paths["/rm"] := Func("apiReadMemory")
paths["/rmwh"] := Func("apiReadMemoryWithoutHex")
paths["/wm"] := Func("apiWriteMemory")
paths["/readDefault"] := Func("apiReadDefault")
paths["404"] := Func("notFound")

server := new HttpServer()
server.SetPaths(paths)
server.Serve(servePort)
return

apiShowVersion(ByRef req, ByRef res) {
    global emu, serverVersion
    res.SetBodyText("EmuHook Server v" serverVersion "`nEmuHook Engine v" emu.version)
    res.status := 200
}

apiSetEmulator(ByRef req, ByRef res){
    global emu, emuName
    emuName := req.queries["name"]
    romType := req.queries["romType"]
    
    if(emuName && romType) {
        emuName := "ahk_exe " emuName
        emu := new EmuHook(emuName, romType)
        res.SetBodyText("Hooked to " emuName)
        res.status := 200
    } else {
        res.SetBodyText("Param 'name' or 'romType' not informed, use /setEmulator?name=mGBA.exe&romType=gba")
        res.status := 500
    }    
}

apiSetEmulatorAuto(ByRef req, ByRef res){
    global emu, emuName
    emuName := checkRunningEmulator()
    emu := new EmuHook(emuName)
    
    res.SetBodyText("Auto-Hooked to " emuName)
    res.status := 200
}

apiReadMemory(ByRef req, ByRef res){
    global emu
    resBody := {}
    resBody.address := req.queries["address"]
    resBody.ram := req.queries["ram"] ? req.queries["ram"] : "ram"
    resBody.bytes := req.queries["bytes"] ? req.queries["bytes"] : 1
    resBody.endian := req.queries["endian"] ? req.queries["endian"] : "l"
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

    res.SetBodyText(JSON.Dump(resBody))
    res.status := 200
}

apiReadMemoryWithoutHex(ByRef req, ByRef res){
    global emu
    resBody := {}
    resBody.address := req.queries["address"]
    resBody.ram := req.queries["ram"] ? req.queries["ram"] : "ram"
    resBody.bytes := req.queries["bytes"] ? req.queries["bytes"] : 1
    resBody.endian := req.queries["endian"] ? req.queries["endian"] : "l"
    resBody.completeAddress := ""
    
    switch resBody.ram
    {
        case "ram": resBody.completeAddress := resBody.address + emu.ram
        case "wram": resBody.completeAddress := resBody.address + emu.wram
        case "sram": resBody.completeAddress := resBody.address + emu.sram
        default: resBody.completeAddress := resBody.address + emu.ram
    }
    
    value := emu.rmwh(resBody.completeAddress, resBody.bytes, resBody.endian)
    resBody.value := value ; Needed in a new line

    res.SetBodyText(JSON.Dump(resBody))
    res.status := 200
}

apiWriteMemory(ByRef req, ByRef res){
    global emu
    resBody := {}
    resBody.address := req.queries["address"]
    resBody.ram := req.queries["ram"] ? req.queries["ram"] : "ram"
    resBody.bytes := req.queries["bytes"] ? req.queries["bytes"] : 1
    resBody.endian := req.queries["endian"] ? req.queries["endian"] : "l"
    resBody.value := req.queries["value"]
    resBody.completeAddress := ""
    
    if (resBody.value != "") {
        switch resBody.ram
        {
            case "ram": resBody.completeAddress := resBody.address + emu.ram
            case "wram": resBody.completeAddress := resBody.address + emu.wram
            case "sram": resBody.completeAddress := resBody.address + emu.sram
            default: resBody.completeAddress := resBody.address + emu.ram
        }
        
        emu.wm(resBody.value, resBody.completeAddress, resBody.bytes, resBody.endian)

        res.SetBodyText("Value written successfully")
        res.status := 200
    } else {
        res.SetBodyText("Value parameter missing")
        res.status := 500
    }
}

apiReadDefault(ByRef req, ByRef res){
    global emu, defaultAddresses
    resBodyArray := []
    
    for k, defaultAddress in defaultAddresses
    {
        resBody := {}
        resBody.address := defaultAddress.address
        resBody.ram := defaultAddress.ram
        resBody.bytes := defaultAddress.bytes
        resBody.endian := defaultAddress.endian
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

    res.SetBodyText(JSON.Dump(resBodyArray))
    res.status := 200
}

notFound(ByRef req, ByRef res) {
    res.SetBodyText("EmuHook: page not found")
}

loadDefaultAddresses(path) {
    global defaultAddresses
    if (path != "" && FileExist(path)) {
        FileRead, defaultAddressesJSON, % path, UTF-8
        defaultAddresses := JSON.Load(defaultAddressesJSON)
    } else {
        MsgBox 0x10, Error, Default addresses file not found!
        ExitApp
    }
}

#Include <AHKhttp>
#Include <AHKsock>
#Include <cJSON>
#Include %A_ScriptDir%\..\..\lib\EmuHook.ahk
