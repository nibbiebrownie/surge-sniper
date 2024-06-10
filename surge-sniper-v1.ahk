#Requires AutoHotkey v2.0
#include UWBOCRLib.ahk
#include routes.ahk
#include areaDict.ahk
#include ssGui.ahk
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SetMouseDelay -1

areasDict := getAreaDict()
global SettingsIni := "ssSettings.ini"
global AutoReconnect := true
global returnToMainframe := false
global Settings_Setup := false
global setBox := false
global showBox := false
global CurrentPostionLabel := "1"
global lastKnownSurgeArea := "Mainframe" ; Default to mainframe cause its the best


; XY Coordinates of all click locations

global PositionTable := Map()

PositionTable["TpButton"] := [959, 346]
PositionTable["TpButtonRedPartBR"] := [174,396]
PositionTable["TpButtonRedPartTL"] := [160,389]
PositionTable["TpSearch"] := [1253,253]
PositionTable["MiniX"] := [1470, 257]
PositionTable["MiniXBR"] := [1483, 272]
PositionTable["MiniXTL"] := [1455, 243]
PositionTable["StupidCatBR"] := [903, 515]
PositionTable["StupidCatTL"] := [1001, 606]
PositionTable["DisconnectedBackgroundLeftSide"] := [764,543]
PositionTable["ReconnectButton"] := [1057,618]
PositionTable["DisconnectedBackgroundRightSide"] := [1156,538]
global detectionBox := [538,662,838,138]

try {
    LoadValues()
}

UiSetup()

; By A Basement
StupidCatCheck() {
  MiniX := PositionTable["MiniX"]
  MiniXBR := PositionTable["MiniXBR"]
  MiniXTL := PositionTable["MiniXTL"]

  if not PixelSearch(&u,&u, MiniXTL[1], MiniXTL[2], MiniXBR[1], MiniXBR[2], 0xFF0B4E, 5) {
    OutputDebug("`n StupidCat has NOT Been found X VER")
    return false
  }

  if PixelSearch(&u,&u, PositionTable["StupidCatTL"][1], PositionTable["StupidCatTL"][2], PositionTable["StupidCatBR"][1], PositionTable["StupidCatBR"][2], 0x95AACD, 10) {
    OutputDebug("`n StupidCat has Been found")
    return true
  }
  OutputDebug("`n StupidCat has NOT Been found")
  return false
}

; FindMedian code by A Basement
FindMedian(TheArray) {
    XNum := 0
    YNum := 0

    for _ArrayNum, PositionArray in TheArray {
        XNum += PositionArray[1]
        YNum += PositionArray[2]
    } 

    XNum /= TheArray.Length
    YNum /= TheArray.Length
    return [XNum, YNum]
}


/*
    Ideas for better movement
    1. menu to let people change their own movement
    2. use on screen coords and OCR. ex. TP to area, search for the area surge double key text. Find its x/y coords. 
*/
teleportToArea(areaIdentifier) {

    ; Code from A Basement's DeepPoolFishingMacro
    Mean := FindMedian([PositionTable["TpButtonRedPartBR"], PositionTable["TpButtonRedPartTL"]])
    SendEvent "{Click, " Mean[1] ", " Mean[2] ", 1}"
    Sleep(1000)
    SendEvent "{Click, " PositionTable["TpSearch"][1] ", " PositionTable["TpSearch"][2] ", 1 }"
    Sleep(50)
    SendText areaIdentifier
    Sleep(200)
    SendEvent "{Click, " PositionTable["TpButton"][1] ", " PositionTable["TpButton"][2] ", 1}"
    Sleep(5000)
    return
}

positionPlayerInZone(areaIdentifier) {
    if(!StupidCatCheck()) {
        routeNum := "area_" areasDict.Get(areaIdentifier)
        %routeNum%()
        global lastKnownSurgeArea := areaIdentifier
    } else {
        SendEvent "{F Down}{F Up}"
        Sleep(600)
        SendEvent "{F Down}{F Up}"
        Sleep(600)
        SendEvent "{F Down}{F Up}"
    }
    
    return
    
}

; code by A Basement
checkDisconnect() {
    if PixelSearch(&A,&A, (PositionTable["DisconnectedBackgroundLeftSide"][1]-5),(PositionTable["DisconnectedBackgroundLeftSide"][2]-5),(PositionTable["DisconnectedBackgroundLeftSide"][1]+5),(PositionTable["DisconnectedBackgroundLeftSide"][2]+5), 0x393B3D, 2) {
        if PixelSearch(&A, &A, (PositionTable["ReconnectButton"][1]-10),(PositionTable["ReconnectButton"][2]-10),(PositionTable["ReconnectButton"][1]+10),(PositionTable["ReconnectButton"][2]+10), 0xFFFFFF, 0) {
            if PixelSearch(&A,&A, (PositionTable["DisconnectedBackgroundRightSide"][1]-5),(PositionTable["DisconnectedBackgroundRightSide"][2]-5),(PositionTable["DisconnectedBackgroundRightSide"][1]+5),(PositionTable["DisconnectedBackgroundRightSide"][2]+5), 0x393B3D, 2) {
                OutputDebug("Reconnecting!")
                return true
            }
        }
    }
    return false
}

reconnectAndReturnToLastSurge() {
    ; Two clicks for redundancy, A Basement's probably does it better but I don't understand the break_time thing and want to see if this works
    Loop {
        SendEvent "{Click, " PositionTable["ReconnectButton"][1] ", " PositionTable["ReconnectButton"][2] ", 1}"
        Sleep(100)
    } Until(PixelSearch(&A, &A, PositionTable["TpButtonRedPartTL"][1],PositionTable["TpButtonRedPartTL"][2],PositionTable["TpButtonRedPartBR"][1],PositionTable["TpButtonRedPartBR"][2], 0xEC0D3A, 15))
        Sleep(1000)
        teleportToArea(lastKnownSurgeArea)
        positionPlayerInZone(lastKnownSurgeArea)
    
}

/* used for testing
f5:: {
areaIdentifier := "Mainframe"
teleportToArea(areaIdentifier)
positionPlayerInZone(areaIdentifier)
} 
*/


f8:: {
    ExitApp
    return
}


f6:: {
    Pause -1
    return
}

f3:: {
    ; Constantly watching announcement area for keywords
    loop {

        if(AutoReconnect) {
            if(checkDisconnect()) {
                reconnectAndReturnToLastSurge() 
            } 
        }
        local areaIdentifier := "Mainframe" ; This is default cause best zone 
        Result := OCR.FromRect(detectionBox[1],detectionBox[2],detectionBox[3],detectionBox[4],,5)

        if(RegExMatch(Result.Text, "i)Boosted|Boost|Boo|sted|sted H")) {
            if RegExMatch(Result.Text, "i)Mai|Main|Fra|Frame|ame!|ame") {
                areaIdentifier := "Mainframe"
            } else if RegExMatch(Result.Text, "i)Lab!|Lab|ab!|La|b!"){
                areaIdentifier := "Lab"
            } else if RegExMatch(Result.Text, "i)Cave!|Cave|Cav|Ca|ave!|ave") {
                areaIdentifier := "Cave"
            } else if RegExMatch(Result.Text, "i)Fortress|Fortr|Fort|ress|tress|Fortress!|tress!|ortress") {
                areaIdentifier := "Fortress"
            } else if RegExMatch(Result.Text, "i)Matrix|Matr|rix|rix!|ix!|ix") {
                areaIdentifier := "Matrix"
            } else {
                Continue
            }
                teleportToArea(areaIdentifier)
                positionPlayerInZone(areaIdentifier)
        }
    }
}

; Left Control and Left Alt
<^<!LButton:: {
    if(setBox) {
        Area := SelectScreenRegion("LButton")
        global detectionBox := [Area.X,Area.Y, Area.W, Area.H]
        surgeSniperUI["BoxX"].Value := Area.X
        surgeSniperUI["BoxY"].Value := Area.Y
        surgeSniperUI["BoxW"].Value := Area.W
        surgeSniperUI["BoxH"].Value := Area.H
        
    }

}

setOCRBox(*) {
    global setBox := !setBox
    if(setBox) {
        MsgBox("Set box mode active!`n`nHold Left Control + Left Alt + Left Click and drag to set the box.`n`nClick the setbox button again to disable box mode", "Box Mode Active", 0x40000)
    } else {
        MsgBox("Set box mode disabled.", "Box Mode Disabled", 0x40000)
    }
    return

}

showOCRBox(*) {
    ; global showBox := !showBox I couldn't get this to toggle properly, so I gave up and made it just show the box on a timer
    ssrGui := Gui("+AlwaysOnTop -caption +Border +ToolWindow +LastFound -DPIScale")
    WinSetTransparent(80)
    ssrGui.BackColor := "Red"
    ssrGui.Show("x" detectionBox[1] " y" detectionBox[2] " w" detectionBox[3] " h" detectionBox[4])
    Sleep(5000)
    ssrGui.Hide() 
    
    return
    
}





