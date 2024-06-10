#Requires AutoHotkey v2.0
#include surge-sniper-v1.ahk

surgeSniperUI := Gui(,"Surge Sniper",)
; Majority of GUI code/skeleton from A Basement's Deep Pool Macro with changes by nibbiebrownie
UiSetup() {
    local guiWidth := 400
    local guiHeight := 440
    global detectionbox
    surgeSniperUI.Opt("+Caption -SysMenu +AlwaysOnTop")
    Tabs := surgeSniperUI.AddTab3("", ["Main","Basic Settings","Positioning","DetectionBoxPos"])
    surgeSniperUI.SetFont("s15 q5 w800", "Constantia")
    surgeSniperUI.Add("Text", "cblue x" ((guiWidth/2)-110) " y45", "⌖ Surge Sniper Macro ⌖")
    surgeSniperUI.SetFont("s15 q5 w800 underline italic", "Constantia")
    surgeSniperUI.Add("Text", "Cblack x160 y100", "The Goal")
    surgeSniperUI.SetFont("s11 q5 w500 norm", "Arial")
    surgeSniperUI.Add("Text", "Cblack x" ((guiWidth/2)-109) " y75", "By nibbiebrownie and A Basement")
    surgeSniperUI.SetFont("s11 q5 w500", "Arial")
    surgeSniperUI.Add("Text", "Cblack x90 y300", "F3 - Start | F6 - Pause | F8 - Stop")
    surgeSniperUI.Add("Picture","y140 x140 w125 h125", A_ScriptDir "\Images\key.png")

    ; Almost certainly a better way to center the button but I'm tired and alignment sucks
    surgeSniperUI.Add("Button","x" ((guiWidth/2)-53) " y320","Enable Macro").OnEvent("Click", EnableMacro)

    Tabs.UseTab(2)
    surgeSniperUI.SetFont("s15 q5 w800", "Constantia")
    surgeSniperUI.Add("Text", "", "Basic Settings")
    surgeSniperUI.SetFont("s9 q5 w500", "Arial")

    surgeSniperUI.Add("Text", "Section", "AutoReconnect:")
    surgeSniperUI.Add("Checkbox", "VAutoReconnect ys x350 Checked" AutoReconnect)

    ; Hidden because I do not plan to implement this
    ; It was supposed to be a way to return to the mainframe every time a surge ends
    ; But the downtime between surges is only 1 minute, the 1 min of gains of mainframe vs somewhere else isn't worth my time to make this
    surgeSniperUI.Add("Text", "hidden Section xs", "returnToMainframe:")
    surgeSniperUI.Add("Checkbox", "hidden VreturnToMainframe ys x350 Checked" returnToMainframe)


    Tabs.UseTab(3)
    surgeSniperUI.SetFont("s15 q5 w800", "Constantia")
    surgeSniperUI.Add("Text", "Section", "Positioning")
    surgeSniperUI.Add("Text"," ys+5 x270 c0x000000","X")
    surgeSniperUI.Add("Text"," ys+5 x340 c0x000000","Y")
    surgeSniperUI.SetFont("s9 q5 w500", "Arial")
    for Name, PositionArray in PositionTable {
        GuiPos1(Name, PositionArray)
    }


    Tabs.UseTab(4)
    surgeSniperUI.SetFont("s15 q5 w800", "Constantia")
    surgeSniperUI.Add("Text", "Section", "Detection Box Settings")
    surgeSniperUI.Add("Text"," ys+5 x270 c0x000000","X")
    surgeSniperUI.Add("Text"," ys+5 x340 c0x000000","Y")
    surgeSniperUI.SetFont("s9 q5 w500", "Arial")

    surgeSniperUI.Add("Text", "Section xs yp+30", "DetectionBox")
    surgeSniperUI.Add("Button", "w25 h25 x220 ys", "?").OnEvent("Click", boxHelp)
    surgeSniperUI.Add("Button", "w130 h25 x250 ys", "Set Box").OnEvent("Click", setOCRBox)

    surgeSniperUI.Add("Text", "Section xs yp+30", "")
    surgeSniperUI.Add("Text", "x252 yp+4", "X:")
    surgeSniperUI.Add("Edit", "vBoxX disabled w40 x270 ys vBoxX", detectionBox[1])
    surgeSniperUI.Add("Text", "x320 yp+4", "Y:")
    surgeSniperUI.Add("Edit", "vBoxY disabled w40 x338 ys vBoxY", detectionBox[2])

    surgeSniperUI.Add("Text", "Section xs yp+30", "")
    surgeSniperUI.Add("Text", "x252 yp+4", "W:")
    surgeSniperUI.Add("Edit", "vBoxW disabled w40 x270 ys vBoxW", detectionBox[3])
    surgeSniperUI.Add("Text", "x320 yp+4 ", "H:")
    surgeSniperUI.Add("Edit", "vBoxH disabled w40 x338 ys vBoxH", detectionBox[4])

    surgeSniperUI.Add("Text", "Section xs yp+30", "")
    surgeSniperUI.Add("Button", "w130 h25 x250 ys", "Show Box").OnEvent("Click", showOCRBox)

    surgeSniperUI.Show()

}

boxHelp(*) {
    MsgBox("Clicking Set Box will activate box mode. Box mode allows you to set the hacker surge detection box. This box should cover the entire announcement message.`n`nYour current box coords are shown below the set box button.`n`nIn my experience, a large box has been best for text recognition, avoid making it barely fit the message. Click show box with the default box for an example`n`nW = Width, H = Height","Box Help",0x40000)
}



GuiPos1(Name, PositionArray) {
    surgeSniperUI.Add("Text","Section xs yp+30", Name)
    surgeSniperUI.Add("Button", "w25 h25 x220 ys", "S").OnEvent("Click", ButtonClicked)
    Ud1 := surgeSniperUI.Add("Edit","ys w60 x250",)
    surgeSniperUI.AddUpDown("v" Name "XPos Range1-4000", PositionArray[1])

    ud2 := surgeSniperUI.Add("Edit","ys w60 x320",)
    surgeSniperUI.AddUpDown("v" Name "YPos Range1-4000", PositionArray[2])

    ButtonClicked(*) {
        global CurrentPositionLabel := [UD1, UD2]
    }
}

; By A Basement
^LButton::{
    try {
        OutputDebug(Type(CurrentPositionLabel))
        if Type(CurrentPositionLabel) = "Array" {
            MouseGetPos(&u,&u2)
            CurrentPositionLabel[1].Text := u
            CurrentPositionLabel[2].Text := u2
            global CurrentPositionLabel := ""
        }
    }
}



EnableMacro(*) {
    if(setBox) {
        MsgBox("Box Mode Active! Please set your detection box in positioning settings, then click the Set Box button to disable box mode","Box Mode Active!",0x40000)
    } else {
        UpdateValues(surgeSniperUI.Submit())
        SaveValues()
        global Settings_Setup := true
    }
    
}

SaveValues() {
    IniWrite(returnToMainframe, SettingsIni, "ToggleSettings", "ReturnToMainframe")
    IniWrite(AutoReconnect, SettingsIni, "ToggleSettings", "AutoReconnect")
  
    for PosName, PosArray in PositionTable {
      IniWrite(PosArray[1] "|" PosArray[2], SettingsIni, "PositionTable", PosName)
    }

    IniWrite(detectionBox[1] "|" detectionBox[2] "|" detectionBox[3] "|" detectionBox[4], SettingsIni, "DetectionSettings", "detectionBoxCoords")
}

UpdateValues(NV) {
global returnToMainframe := NV.returnToMainframe
global AutoReconnect := NV.AutoReconnect

FixedNV := ObjToMap(NV)

for PositionName, ___A in PositionTable {
    PositionTable[PositionName] := [FixedNV[PositionName "XPos"], FixedNV[PositionName "YPos"]]
}

}

ObjToMap(Obj, Depth:=5, IndentLevel:="")
{
	if Type(Obj) = "Object"
		Obj := Obj.OwnProps()
    if Type(Obj) = "String" {
      Obj := [Obj]
    }
	for k,v in Obj
	{
		List.= IndentLevel k
		if (IsObject(v) && Depth>1)
			List.="`n" ObjToMap(v, Depth-1, IndentLevel . "    ")
		Else
			List.=":" v
		List.="/\"
	}
	
  NewMap := Map()
  SplitArray := StrSplit(List, "/\")
  for __ArrayNum, SplitText in SplitArray {
    ValueSplit := StrSplit(SplitText, ":")
    
    if InStr(SplitText, ":") {
      NewMap[ValueSplit[1]] := ValueSplit[2]
      OutputDebug('`n' ValueSplit[1] " : " ValueSplit[2])
    }
  }

  return NewMap
}

LoadValues() {
    global returnToMainframe := IniRead(SettingsIni, "ToggleSettings", "returnToMainframe")
    global AutoReconnect := IniRead(SettingsIni, "ToggleSettings", "AutoReconnect")
    global detectionBox

    for PosName, __A in PositionTable {
        SplitStr := StrSplit(IniRead(SettingsIni, "PositionTable", PosName), "|")
        PositionTable[PosName] := [SplitStr[1],SplitStr[2]]
      }
    
        SplitStr := StrSplit(IniRead(SettingsIni, "DetectionSettings", "detectionBoxCoords"), "|")
        detectionBox[1] := SplitStr[1]
        detectionBox[2] := SplitStr[2]
        detectionBox[3] := SplitStr[3]
        detectionBox[4] := SplitStr[4]
    


}

; Found on this thread https://www.autohotkey.com/boards/viewtopic.php?style=19&t=116406&start=20
SelectScreenRegion(Key, Color := "Red", Transparent:= 80)
{
	CoordMode("Mouse", "Screen")
	MouseGetPos(&sX, &sY)
	ssrGui := Gui("+AlwaysOnTop -caption +Border +ToolWindow +LastFound -DPIScale")
	WinSetTransparent(Transparent)
	ssrGui.BackColor := Color
	Loop 
	{
		Sleep 10
		MouseGetPos(&eX, &eY)
		W := Abs(sX - eX), H := Abs(sY - eY)
		X := Min(sX, eX), Y := Min(sY, eY)
		ssrGui.Show("x" X " y" Y " w" W " h" H)
	} Until !GetKeyState(Key, "p")
	ssrGui.Destroy()
	Return { X: X, Y: Y, W: W, H: H, X2: X + W, Y2: Y + H }
}