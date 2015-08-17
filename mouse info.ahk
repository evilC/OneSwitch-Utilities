#SingleInstance force

LoggingEnabled := 0

Gui, Add, ListView, % "vMyListView w120 h" A_ScreenHeight,  Time|X|Y
LV_ModifyCol(1, 50)
LV_ModifyCol(2, 50)
Gui, +Resize
Gui, Show, x0

; Register mouse for WM_INPUT messages.
RIDEV_INPUTSINK := 0x00000100
DevSize := 8 + A_PtrSize
VarSetCapacity(RAWINPUTDEVICE, DevSize)
NumPut(1, RAWINPUTDEVICE, 0, "UShort")
NumPut(2, RAWINPUTDEVICE, 2, "UShort")
Flags := RIDEV_INPUTSINK
NumPut(Flags, RAWINPUTDEVICE, 4, "Uint")
NumPut(WinExist("A"), RAWINPUTDEVICE, 8, "Uint")
r := DllCall("RegisterRawInputDevices", "Ptr", &RAWINPUTDEVICE, "UInt", 1, "UInt", DevSize )
OnMessage(0x00FF, "MouseMoved")
return

; Called when the mouse moved.
; Messages tend to contain small (+/- 1) movements, and happen frequently (~20ms)
MouseMoved(wParam, lParam){
	global LoggingEnabled, StartTime
	; RawInput statics
	static DeviceSize := 2 * A_PtrSize, iSize := 0, sz := 0, offsets := {x: (20+A_PtrSize*2), y: (24+A_PtrSize*2)}, uRawInput
	
	if (!LoggingEnabled){
		return
	}
	; Find size of rawinput data - only needs to be run the first time.
	if (!iSize){
		r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", 0, "UInt*", iSize, "UInt", 8 + (A_PtrSize * 2))
		VarSetCapacity(uRawInput, iSize)
	}
	sz := iSize	; param gets overwritten with # of bytes output, so preserve iSize
	; Get RawInput data
	r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", &uRawInput, "UInt*", sz, "UInt", 8 + (A_PtrSize * 2))

	x := NumGet(&uRawInput, offsets.x, "Int")
	y := NumGet(&uRawInput, offsets.y, "Int")
	
	LV_Modify(LV_Add( ,A_TickCount - StartTime, x,y), "Vis")
}

F11::
	StartTime := A_TickCount
	LV_Delete()
	return

F12::
	StartTime := A_TickCount
	LoggingEnabled := !LoggingEnabled
	return

GuiSize:
	if (A_EventInfo = 1){  ; The window has been minimized.  No action needed.
		return
	}
	GuiControl, Move, MyListView, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 20)
	return