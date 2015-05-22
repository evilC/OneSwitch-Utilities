#include <CvJoyInterface>
#SingleInstance force

mj := new MouseToJoy()

OutputDebug, DBGVIEWCLEAR
return

class MouseToJoy {
	JoyPos := {x:0, y: 0}
	MoveMultiplier := 100
	
	; Called on startup.
	__New(){
		static RIDEV_INPUTSINK := 0x00000100
		
		this.vJoyInterface := new CvJoyInterface()
		
		; Was vJoy installed and the DLL Loaded?
		if (!this.vJoyInterface.vJoyEnabled()){
			; Show log of what happened
			Msgbox % this.vJoyInterface.LoadLibraryLog
			ExitApp
		}
		
		this.OutputStick := this.vJoyInterface.Devices[1]
		
		Gui, Add, Edit, xm ym w80 hwndhEdit, 4
		this.hEdit := hEdit
		fn := this.OptionChanged.Bind(this)
		
		GuiControl +g, % this.hEdit, % fn
		
		; Create GUI (GUI needed to receive messages)
		Gui, Show, w100 h100
		
		; Register mouse for WM_INPUT messages.
		DevSize := 8 + A_PtrSize
		VarSetCapacity(RAWINPUTDEVICE, DevSize)
		NumPut(1, RAWINPUTDEVICE, 0, "UShort")
		NumPut(2, RAWINPUTDEVICE, 2, "UShort")
		Flags := RIDEV_INPUTSINK
		NumPut(Flags, RAWINPUTDEVICE, 4, "Uint")
		NumPut(WinExist("A"), RAWINPUTDEVICE, 8, "Uint")
		r := DllCall("RegisterRawInputDevices", "Ptr", &RAWINPUTDEVICE, "UInt", 1, "UInt", DevSize )
		fn := this.MouseMoved.Bind(this)
		OnMessage(0x00FF, fn)
		
		; Timeout function setup
		fn := this.OnTimeout.Bind(this)
		this.TimeoutFn := fn
		
		; set values dependent on options
		this.OptionChanged()
		
	}
	
	OptionChanged(){
		/*
		GuiControlGet, MoveMultiplier,, % this.hEdit
		this.MoveMultiplier := MoveMultiplier
		*/
		
		GuiControlGet, MaxMove,, % this.hEdit
		this.MaxMove := MaxMove
		this.MoveScale := (16384 / MaxMove)
	}
	
	; Called when the mouse moved.
	; Messages tend to contain small (+/- 1) movements, and happen frequently (~20ms)
	MouseMoved(wParam, lParam, code){
		static MAX_TIME := 1000000		; Only cache values for this long.
		; RawInput statics
		static DeviceSize := 2 * A_PtrSize, iSize := 0, sz := 0, offsets := {x: (20+A_PtrSize*2), y: (24+A_PtrSize*2)}, uRawInput
		
		static axes := {x: 1, y: 2}
		
		fn := this.TimeoutFn
		SetTimer, % fn, Off
		SetTimer, % fn, -20

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
			ax := (mv * this.MoveScale) + 16384
			this.OutputStick.SetAxisByName(ax,axis)
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
		; return stick to center
		this.OutputStick.SetAxisByName(16384,"x")
		this.OutputStick.SetAxisByName(16384,"y")
	}
}

GuiClose:
ExitApp