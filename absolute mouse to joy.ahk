#include <CvJoyInterface>
#SingleInstance force

ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

SetKeyDelay, 0, 50

ADHD.config_about({name: "Mouse To Joy", version: "1.0.0", author: "evilC", link: "<a href=""http://oneswitch.org.uk"">Homepage</a>"})
ADHD.config_size(375,200)
ADHD.config_event("option_changed", "option_changed_hook")

ADHD.config_hotkey_add({uiname: "Calibrate", subroutine: "Calibrate"})
adhd_hk_k_1_TT := "Which Button to use for Choice button 1"

ADHD.init()
ADHD.create_gui()

Gui, Tab, 1

Gui, Add, Text, xm y40, Max Mouse Move Value
ADHD.gui_add("Edit", "MaxMove", "xp+150 yp-2 w80", "", "4")

ADHD.finish_startup()

JoyPos := {x:0, y: 0}
MoveMultiplier := 100
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
	global MoveScale, OutputStick, CalibrateMode, MaxSeenMove
	static MAX_TIME := 1000000		; Only cache values for this long.
	; RawInput statics
	static DeviceSize := 2 * A_PtrSize, iSize := 0, sz := 0, offsets := {x: (20+A_PtrSize*2), y: (24+A_PtrSize*2)}, uRawInput
	
	static axes := {x: 1, y: 2}
	
	SetTimer, OnTimeout, Off
	SetTimer, OnTimeout, -20

	; Find size of rawinput data - only needs to be run the first time.
	if (!iSize){
		r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", 0, "UInt*", iSize, "UInt", 8 + (A_PtrSize * 2))
		VarSetCapacity(uRawInput, iSize)
	}
	sz := iSize	; param gets overwritten with # of bytes output, so preserve iSize
	; Get RawInput data
	r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", &uRawInput, "UInt*", sz, "UInt", 8 + (A_PtrSize * 2))

	for axis in axes {
		mv := NumGet(&uRawInput, offsets[axis], "Int")
		if (CalibrateMode){
			if (abs(mv) > MaxSeenMove){
				MaxSeenMove := abs(mv)
			}
		} else {
			ax := (mv * MoveScale) + 16384
			OutputStick.SetAxisByName(ax,axis)
		}
	}

	/*
	for axis in axes {
		mv := NumGet(&uRawInput, offsets[axis], "Int")
		this.JoyPos[axis] += ( mv * this.MoveMultiplier)
		if (this.JoyPos[axis] > 16384){
			this.JoyPos[axis] := 16384
		} else if (this.JoyPos[axis] < -16384){
			this.JoyPos[axis] := -16384
		}
		ax := this.JoyPos[axis] + 16384
		this.OutputStick.SetAxisByName(ax,axis)
	}
	*/
	
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
	global MaxMove, MoveScale
	MoveScale := (16384 / MaxMove)

}
; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this