#include <CvJoyInterface>
#SingleInstance force

ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

SetKeyDelay, 0, 50

ADHD.config_about({name: "Mouse To Joy", version: "1.0.1", author: "evilC", link: "<a href=""http://oneswitch.org.uk"">Homepage</a>"})
ADHD.config_size(375,250)
ADHD.config_event("option_changed", "option_changed_hook")

ADHD.config_hotkey_add({uiname: "Calibrate", subroutine: "Calibrate"})
adhd_hk_k_1_TT := "Calibrates Relative Mode"

ADHD.init()
ADHD.create_gui()

Gui, Tab, 1

Gui, Add, GroupBox, x5 y35 w250 R3, Absolute Mode
Gui, Add, Text, xm y60, Max Mouse Move Value
ADHD.gui_add("Edit", "MaxMove", "xp+150 yp-2 w60", "", "4")
Gui, Add, Text, xm yp+30, Center Timeout (ms)
ADHD.gui_add("Edit", "CenterTimeout", "xp+150 yp-2 w60", "", "20")
Gui, Add, GroupBox, x5 yp+40 w250 R2, Relative Mode
Gui, Add, Text, xm yp+20, Move Scale
ADHD.gui_add("Edit", "RelMoveScale", "xp+150 yp-2 w60", "", "100")
ADHD.gui_add("Radio", "AbsMode", "x280 y70 w80 Checked", "Absolute", "")
ADHD.gui_add("Radio", "RelMode", "x280 y150 w80 ", "Relative", "")

ADHD.finish_startup()

JoyPos := {x:0, y: 0}
CalibrateMode := 0

RIDEV_INPUTSINK := 0x00000100

vJoyInterface := new CvJoyInterface()

; Was vJoy installed and the DLL Loaded?
if (!vJoyInterface.vJoyEnabled()){
; Show log of what happened
	Msgbox % vJoyInterface.LoadLibraryLog
	ExitApp
}

OutputStick := vJoyInterface.Devices[1]

; Register mouse for WM_INPUT messages.
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
MouseMoved(wParam, lParam, code){
	global CalibrateMode, MaxSeenMove
	global AbsMode, RelMode
	global RelMoveScale, AbsMoveScale, OutputStick
	global JoyPos
	global CenterTimeout
	static MAX_TIME := 1000000		; Only cache values for this long.
	; RawInput statics
	static DeviceSize := 2 * A_PtrSize, iSize := 0, sz := 0, offsets := {x: (20+A_PtrSize*2), y: (24+A_PtrSize*2)}, uRawInput
	
	static axes := {x: 1, y: 2}
	
	; Find size of rawinput data - only needs to be run the first time.
	if (!iSize){
		r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", 0, "UInt*", iSize, "UInt", 8 + (A_PtrSize * 2))
		VarSetCapacity(uRawInput, iSize)
	}
	sz := iSize	; param gets overwritten with # of bytes output, so preserve iSize
	; Get RawInput data
	r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", &uRawInput, "UInt*", sz, "UInt", 8 + (A_PtrSize * 2))

	if (CalibrateMode){
		; Calibrate Mode
		for axis in axes {
			mv := NumGet(&uRawInput, offsets[axis], "Int")
			if (abs(mv) > MaxSeenMove){
				MaxSeenMove := abs(mv)
			}
		}
	} else if (AbsMode){
		; Absolute Mode
		SetTimer, OnTimeout, Off
		SetTimer, OnTimeout, % "-" CenterTimeout
		
		for axis in axes {
			mv := NumGet(&uRawInput, offsets[axis], "Int")
			ax := (mv * AbsMoveScale) + 16384
			OutputStick.SetAxisByName(ax,axis)
		}
	} else {
		; Relative Mode
		SetTimer, OnTimeout, Off
		
		for axis in axes {
			mv := NumGet(&uRawInput, offsets[axis], "Int")
			JoyPos[axis] += ( mv * RelMoveScale)
			if (JoyPos[axis] > 16384){
				JoyPos[axis] := 16384
			} else if (JoyPos[axis] < -16384){
				JoyPos[axis] := -16384
			}
			ax := JoyPos[axis] + 16384
			OutputStick.SetAxisByName(ax,axis)
		}
	}
}

OnTimeout(){
	global OutputStick
	; return stick to center
	OutputStick.SetAxisByName(16384,"x")
	OutputStick.SetAxisByName(16384,"y")
}

Calibrate:
	if (CalibrateMode){
		GuiControl,,MaxMove, % MaxSeenMove
	} else {
		MaxSeenMove := 0
	}
	CalibrateMode := !CalibrateMode
	if (CalibrateMode){
		SoundBeep, 1000, 250
	} else {
		SoundBeep, 500, 250
	}
	return
	
option_changed_hook(){
	global MaxMove, AbsMoveScale
	AbsMoveScale := (16384 / MaxMove)
}
; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this