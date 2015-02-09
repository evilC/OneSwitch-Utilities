#SingleInstance force
#noenv

#include <CvJoyInterface>
global vJoyInterface := new CvJoyInterface()
; Was vJoy installed and the DLL Loaded?
if (!vJoyInterface.vJoyEnabled()){
	; Show log of what happened
	Msgbox % vJoyInterface.LoadLibraryLog
	ExitApp
}

UCR := new CUCR()

return

Esc::
GuiClose:
	ExitApp
	return

GuiSize:
	WinGetPos, X, Y, Width, Height, % "ahk_id " hMainGui
	Gui, % hChildCanvas ":Show", % "x100 y5 w" Width - 135 " h" Height - 60
	return

class CUCR extends CBase {
	Plugins := []
	Flags := {}
	__New(){
		global hChildCanvas, hMainGui, vJoyInterface
		Gui, New, HwndhMainGui +Resize
		this.hwnd := hMainGui
		Gui, % this.GuiCmd("Add"), Edit, xm ym w85 h300, Other GUI stuff would go here
		Gui, % this.GuiCmd("Show"), w520, UCR Pulse Demo
		this.ChildCanvas := new this.CPluginCanvas(this)
		this.ChildCanvas.AddPlugin("Choice")
		this.ChildCanvas.AddPlugin("Pulse")
		this.ChildCanvas.AddPlugin("Timeout")
		hChildCanvas := this.ChildCanvas.hwnd
	}
	
	SetFlag(flag, value){
		this.Flags[flag] := value
	}
	
	GetFlag(flag){
		if (!ObjHasKey(this.Flags,flag)){
			return 0
		} else {
			return this.Flags[flag]
		}
	}
	
	class CPluginCanvas extends CBase {
		BottomY := 0
		__New(root){
			this._root := root
			Gui, new, % "HwndhChildCanvas +Resize -Border +Parent" this._root.hwnd
			this.hwnd := hChildCanvas
			Gui, % this.GuiCmd("Show"), x100 y5 w400 h285
		}
		
		AddPlugin(Type := 0){
			if (!Type){
				Type := "CPlugin"
			}
			this._root.Plugins.Insert(new %type%(this._root))
		}
	}
	
}

class CBase {
	GuiCmd(cmd){
		return this.hwnd ":" cmd
	}
	
}

class CPlugin extends CBase {
	Name := "Un-named"
	__New(root){
		this._root := root
		Gui, new, % "HwndhPluginHwnd -Border +Parent" this._root.ChildCanvas.hwnd
		this.hwnd := hPluginHwnd
		Gui, % this.GuiCmd("Add"), Text, x0 y0, % this.Name
		this.CreateGUI()
		this.Init()
	}
	
	CreateGUI(){
		this.ShowGui(50)
	}
	
	ShowGui(Height){
		Gui, % this.GuiCmd("Show"), % "x0 y" this._root.ChildCanvas.BottomY " w380 h" Height
		this._root.ChildCanvas.BottomY += (Height + 10)
	}
	
	Init(){
		
	}

	; Set a timer running to call Pulse() every <val> milliseconds
	; Defaults to 1 second
	; I would not expect you to write functions like this, I would do that.
	SetTimer(val := -1){
		if (val = -1){
			; default time
			val := this.TimerLength
		}
		if (this.Timer != 0){
			fn := this.Timer
			SetTimer, %fn%, Off
		}
		fn := Bind(this.TimerTriggered, this)
		; Store link to timer so we can stop it later
		this.Timer := fn
		; Start Pulse Timer
		SetTimer, % fn, % val
	}

}

; bind by Lexikos
; Requires test build of AHK? Will soon become part of AHK
; See http://ahkscript.org/boards/viewtopic.php?f=24&t=5802
bind(fn, args*) {  ; bind v1.2
    try bound := fn.bind(args*)  ; Func.Bind() not yet implemented.
    return bound ? bound : new BoundFunc(fn, args*)
}

class BoundFunc {
    __New(fn, args*) {
        this.fn := IsObject(fn) ? fn : Func(fn)
        this.args := args
    }
    __Call(callee, args*) {
        if (callee = "" || callee = "call" || IsObject(callee)) {  ; IsObject allows use as a method.
            fn := this.fn, args.Insert(1, this.args*)
            return %fn%(args*)
        }
    }
}

; =============================== BARRIE'S WORLD ===================================================================================================
; Stuff below here is an example of the code you would write to add plugins to UCR
; I heavily commented Pulse, to give you an idea of what is going on.
; The FIRST function in each plugin class is what interests you. Most of the other stuff will be simplified greatly.

; Controls the logic for PULSING
class Pulse extends CPlugin {
	; Name your plugin here
	Name := "Pulse"
	TimerLength := 1000		; Pulse Rate
	Timer := 0 ; ignore - internal use
	
	; The timer for Pulse() fired
	; This is the main "meat" of the plugin that you will be concerned with
	TimerTriggered(){
		; Press pulse button
		this.Stick.SetBtn(1, this.PulseButton)
		; Wait a bit
		Sleep 100
		; Release Pulse button
		this.Stick.SetBtn(0, this.PulseButton)
	}
	
	; Use this to define a custom GUI for the plugin
	CreateGUI(){
		; this GUI creation stuff would be simplified.
		Gui, % this.GuiCmd("Add"), Text, xm y20 h20 Section, Output: Pulse button
		Gui, % this.GuiCmd("Add"), DDL, x150 ys-5 h20 w50 R5 hwndhDDL, 1||2|3
		; Again, more complicated stuff that will be simplified
		this.hDDLPulse := hDDL
		fn := bind(this.OptionChanged, this)
		GuiControl +g, % hDDL, % fn
		this.ShowGui(50)
	}
	
	; Called once when the plugin starts
	Init(){
		; Set a flag called "PulseHandle" that points to this class...
		; ...so other plugins that are coded to look for the "PulseHandle" flag can communicate with Pulse
		this._root.SetFlag("PulseHandle", this)
		; hard-wire to vJoy ID 1 for now
		this.Stick := vJoyInterface.Devices[1]
		; Config variables for initial state of GUI Controls
		this.OptionChanged()
		; Set the timer going
		this.SetTimer()
	}
	
	; One of the settings chaged.
	; You would not need to write this code in the final version
	OptionChanged(){
		GuiControlGet, val,, % this.hDDLPulse
		; make sure old pulse button is released
		this.Stick.SetBtn(0, this.PulseButton)
		; Set new button
		this.PulseButton := val
	}
}

; Controls the logic for the CHOICE BUTTON
class Choice extends CPlugin {
	Name := "Choice"
	ChoiceInputStick := 0
	ChoiceInputButton := 0
	ChoiceOutputButton := 0
	
	; The user pressed the Choice button
	DownEvent(){
		; Stop Pulse Timer
		Pulse := this._root.GetFlag("PulseHandle") 		; Find a handle to the Pulse plugin
		if (Pulse != 0){
			Pulse.SetTimer("off")
		}

		; Stop Timeout Timer
		Timeout := this._root.GetFlag("TimeoutHandle")
		if (Timeout != 0){
			Timeout.SetTimer("off")
		}

		; Set flag so other plugins know when the last choice was made
		this._root.SetFlag("LastChoice", A_TickCount)
		
		; Press the Choice button
		this.Stick.SetBtn(1, this.ChoiceOutputButton)
		Sleep 100
		this.Stick.SetBtn(0, this.ChoiceOutputButton)
		
		; Start the Pulse timer
		if (Pulse != 0){
			Pulse.SetTimer()
		}
		
		; Start the Timeout timer
		if (Timeout != 0){
			Timeout.SetTimer()
		}
	}
	
	CreateGUI(){
		; Inputs
		Gui, % this.GuiCmd("Add"), Text, xm y20 h20 Section, Input: Choice Stick ID
		Gui, % this.GuiCmd("Add"), DDL, x150 ys-5 h20 w50 R5 hwndhStickDDL, 1|2|3||4|5
		this.hDDLChoiceInputStick := hStickDDL
		fn := bind(this.OptionChanged, this)
		GuiControl +g, % hStickDDL, % fn
		
		Gui, % this.GuiCmd("Add"), Text, xm y50 h20 Section, Input: Choice Button
		Gui, % this.GuiCmd("Add"), DDL, x150 ys-5 h20 w50 R5 hwndhButtonDDL, 1||2|3|4|5|6|7|8|9|10
		this.hDDLChoiceInputButton := hButtonDDL
		fn := bind(this.OptionChanged, this)
		GuiControl +g, % hButtonDDL, % fn
		
		; Outputs
		Gui, % this.GuiCmd("Add"), Text, xm y85 h20 Section, Output: Choice Button
		Gui, % this.GuiCmd("Add"), DDL, x150 ys-5 h20 w50 R5 hwndhButtonDDL, 1|2||3|4|5|6|7|8|9|10
		this.hDDLChoiceOutputButton := hButtonDDL
		fn := bind(this.OptionChanged, this)
		GuiControl +g, % hButtonDDL, % fn
		
		this.ShowGui(120)
	}
	
	Init(){
		this.Stick := vJoyInterface.Devices[1]
		this.OptionChanged()
	}
	
	OptionChanged(){
		GuiControlGet, Stick,, % this.hDDLChoiceInputStick
		GuiControlGet, Button,, % this.hDDLChoiceInputButton
		
		if (this.ChoiceInputStick || this.ChoiceInputButton){
			; Previous setting - remove
			hotkey, % this.ChoiceInputStick "Joy" this.ChoiceInputButton, % fn, Off
		}
		this.ChoiceInputStick := Stick
		this.ChoiceInputButton := Button
		fn := bind(this.DownEvent, this)
		hotkey, % this.ChoiceInputStick "Joy" this.ChoiceInputButton, % fn, On
		
		GuiControlGet, Button,, % this.hDDLChoiceOutputButton
		this.ChoiceOutputButton := Button
	}
}

; Controls the logic for the TIMEOUT system
class Timeout extends CPlugin {
	Name := "Timeout"
	TimerLength := 3000		; The length of the timer
	Timer := 0	; ignore - internal use
	
	; The Timeout timer hit it's limit
	TimerTriggered(){
		Pulse := this._root.GetFlag("PulseHandle")
		if (Pulse != 0){
			; Stop the timeout timer
			this.SetTimer("off")
			; Stop the pulse timer
			Pulse.SetTimer("off")
			; Press Timeout button
			this.Stick.SetBtn(1, this.TimeoutButton)
			; Wait a bit
			Sleep 100
			; Release Pulse button
			this.Stick.SetBtn(0, this.TimeoutButton)
			
			; Retstart the pulse timer
			Pulse.SetTimer()
			
			; Restart the Timeout Timer
			this.SetTimer()
		}
	}
	
	CreateGUI(){
		Gui, % this.GuiCmd("Add"), Text, xm y20 h20 Section, Output: Timeout button
		Gui, % this.GuiCmd("Add"), DDL, x150 ys-5 h20 w50 R5 hwndhDDL, 1|2|3||4|5|6|7|8|9|10
		this.hDDLTimeout := hDDL
		fn := bind(this.OptionChanged, this)
		GuiControl +g, % hDDL, % fn
		this.ShowGui(50)
	}
	
	Init(){
		this.Stick := vJoyInterface.Devices[1]
		this._root.SetFlag("TimeoutHandle", this)
		this.OptionChanged()
		this.SetTimer()
	}
	
	OptionChanged(){
		GuiControlGet, val,, % this.hDDLTimeout
		this.TimeoutButton := val		
	}
}
