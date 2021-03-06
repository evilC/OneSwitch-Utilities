﻿#Singleinstance force
;#include VJoyLib\VJoy_lib.ahk
#include <VJoy_lib>

output_states := []

ButtonString := ""
Loop 32 {
	ButtonString .= A_Index
	if (A_Index != 32){
		ButtonString .= "|"
	}
}

; Create an instance of the library
ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

; ============================================================================================
; CONFIG SECTION - Configure ADHD

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

; Stuff for the About box

ADHD.config_about({name: "OneSwitch Mix", version: 1.0.0, author: "evilC", link: "<a href=""http://oneswitch.org.uk"">Homepage</a>"})
; The default application to limit hotkeys to.

; GUI size
ADHD.config_size(375,700)

; Hook into ADHD events
; First parameter is name of event to hook into, second parameter is a function name to launch on that event
ADHD.config_event("option_changed", "option_changed_hook")
ADHD.config_event("functionality_toggled", "functionality_toggled_hook")

Loop 16 {
	ADHD.config_hotkey_add({uiname: "Input " A_Index, subroutine: "Input" A_Index})
	adhd_hk_k_%A_Index%_TT := "ChoiceMade"
}

ADHD.init()
ADHD.create_gui()

; The "Main" tab is tab 1
Gui, Tab, 1
; ============================================================================================
; GUI SECTION

; Add the GUI for vJoy selection
Gui, Add, Text, x15 y40, vJoy Stick ID
ADHD.gui_add("DropDownList", "selected_virtual_stick", "xp+70 yp-5 w50 h20 R9", "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16", "1")
Gui, Add, Text, xp+60 yp+5 w200 vadhd_virtual_stick_status, 

Gui, Add, Button, x5 y60 w360 h50 center gFunctionalityToggle, ENABLE / DISABLE

;Gui, font, italic
;Gui, Add, Text, x15 y60 w300, Note: Bindings are just shown here for convenience.`nChange bindings on the Bindings Tab!
;Gui, font, norm

Gui, Add, Text, x15 y130 center, Input
Gui, Add, Text, x60 yp-5 w180 center, Current Binding`n(Bind on Bindings Tab)
Gui, Add, Text, x270 yp center, Output`nButton
Gui, Add, Text, x330 yp center, Latch`nMode

Loop 16 {
	y := 130 + (A_Index * 30)
	Gui, Add, Text, x15 y%y% w20 center, %A_Index%
	Gui, Add, Edit, x60 yp-5 w180 disabled vBinding%A_Index%
	ADHD.gui_add("DropDownList", "Output" A_Index, "x260 yp W50", ButtonString, A_Index)
	ADHD.gui_add("Checkbox", "Latch" A_Index, "x335 yp+3", "" , 0)
}
; End GUI creation section
; ============================================================================================

ADHD.finish_startup()

; Find max nunmber of buttons supported by vjoy stick

return

InputPressed(input){
	global ADHD, vjoy_id
	global latch_states, output_buttons, output_states

	;msgbox % input " Pressed!"
	if (latch_states[input]){
		; Button is latched mode
		output_states[input] := !output_states[input]
		VJoy_SetBtn(output_states[input], vjoy_id, output_buttons[input])
	} else {
		; Straight Pass-Through mode
		VJoy_SetBtn(1, vjoy_id, output_buttons[input])
	}
}

InputReleased(input){
	global ADHD, vjoy_id
	global latch_states, output_buttons, output_states

	if (!latch_states[input]){
		; Straight Pass-Through mode
		VJoy_SetBtn(0, vjoy_id, output_buttons[input])
	}

}

FunctionalityToggle:
	ADHD.private.functionality_toggle()
	Return

; === Hotkeys
Input1:
	InputPressed(1)
	Return

Input2:
	InputPressed(2)
	Return

Input3:
	InputPressed(3)
	Return

Input4:
	InputPressed(4)
	Return

Input5:
	InputPressed(5)
	Return

Input6:
	InputPressed(6)
	Return

Input7:
	InputPressed(7)
	Return

Input8:
	InputPressed(8)
	Return

Input9:
	InputPressed(9)
	Return

Input10:
	InputPressed(10)
	Return

Input11:
	InputPressed(11)
	Return

Input12:
	InputPressed(12)
	Return

Input13:
	InputPressed(13)
	Return

Input14:
	InputPressed(14)
	Return

Input15:
	InputPressed(15)
	Return

Input16:
	InputPressed(16)
	Return

Input1Up:
	InputReleased(1)
	Return

Input2Up:
	InputReleased(2)
	Return

Input3Up:
	InputReleased(3)
	Return

Input4Up:
	InputReleased(4)
	Return

Input5Up:
	InputReleased(5)
	Return

Input6Up:
	InputReleased(6)
	Return

Input7Up:
	InputReleased(7)
	Return

Input8Up:
	InputReleased(8)
	Return

Input9Up:
	InputReleased(9)
	Return

Input10Up:
	InputReleased(10)
	Return

Input11Up:
	InputReleased(11)
	Return

Input12Up:
	InputReleased(12)
	Return

Input13Up:
	InputReleased(13)
	Return

Input14Up:
	InputReleased(14)
	Return

Input15Up:
	InputReleased(15)
	Return

Input16Up:
	InputReleased(16)
	Return

; === Hooks into ADHD stuff	

; This is called when any of the config options change. Also called once at start
option_changed_hook(){
	global ADHD
	global vjoy_id, vjoy_is_ready

	global latch_states
	global output_buttons

	; Build handy lookup array for state of latches and buttons
	latch_states := []
	output_buttons := []

	Loop 16 {
		GuiControlGet,val,,adhd_hk_hotkey_%A_Index%
		GuiControl,, Binding%A_Index%, %val%

		GuiControlGet,val,,Latch%A_Index%
		latch_states[A_Index] := val

		GuiControlGet,val,,Output%A_Index%
		output_buttons[A_Index] := val
	}

	; Release Buttons
	if (vjoy_is_ready){
		Loop % VJoy_GetVJDButtonNumber(vjoy_id) {
			VJoy_SetBtn(0, vjoy_id, A_Index)
		}
	}

	; Change joysticks
	connect_to_vjoy()

}

functionality_toggled_hook(){
	global ADHD

	if (ADHD.private.functionality_enabled ){
		Gui, Color, Default
	} else {
		Gui, Color, EEAA99
	}

}

; Connect to vJoy stick.
connect_to_vjoy(){
	;global ADHD, this.vjoy_id ; What ID we are connected to now
	global vjoy_id, vjoy_is_ready
	global selected_virtual_stick	; What ID is selected in the UI
	;global adhd_vjoy_ready ;store this global, so loops outside can see whether vjoy is ready or not.
	; Connect to virtual stick
	if (vjoy_id != selected_virtual_stick){

		if (VJoy_Ready(vjoy_id)){
			VJoy_RelinquishVJD(vjoy_id)
			VJoy_Close()
		}
		vjoy_id := selected_virtual_stick
		vjoy_status := DllCall("vJoyInterface\GetVJDStatus", "UInt", vjoy_id)
		if (vjoy_status == 2){
			GuiControl, +Cred, adhd_virtual_stick_status
			GuiControl, , adhd_virtual_stick_status, Busy - Other app controlling this device?
		}  else if (vjoy_status >= 3){
			; 3-4 not available
			GuiControl, +Cred, adhd_virtual_stick_status
			GuiControl, , adhd_virtual_stick_status, Not Available - Add more virtual sticks using the vJoy config app
		} else if (vjoy_status == 0){
			; already owned by this app - should not come here as we want to release non used sticks
			GuiControl, +Cred, adhd_virtual_stick_status
			GuiControl, , adhd_virtual_stick_status, Already Owned by this app (Should not see this!)
		}
		if (vjoy_status <= 1){
			VJoy_Init(vjoy_id)
			if (VJoy_Ready(vjoy_id)){
				; Seem to need this to allow reconnecting to sticks (ie you selected id 1 then 2 then 1 again. Else control of stick does not resume
				VJoy_AcquireVJD(vjoy_id)
				VJoy_ResetVJD(vjoy_id)
				vjoy_is_ready := 1
				GuiControl, +Cgreen, adhd_virtual_stick_status
				GuiControl, , adhd_virtual_stick_status, Connected
			} else {
				GuiControl, +Cred, adhd_virtual_stick_status
				GuiControl, , adhd_virtual_stick_status, Problem Connecting
				vjoy_is_ready := 0
			}
		} else {
			vjoy_is_ready := 0
		}
	}
}

; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this
