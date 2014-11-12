#Singleinstance force
#include VJoyLib\VJoy_lib.ahk

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

; ============================================================================================
; CONFIG SECTION - Configure ADHD

; Authors - Edit this section to configure ADHD according to your macro.
; You should not add extra things here (except add more records to hotkey_list etc)
; Also you should generally not delete things here - set them to a different value instead

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

ADHD.config_ignore_noaction_warning()

; Stuff for the About box

ADHD.config_about({name: "Mixer", version: 0.1, author: "evilC", link: "<a href=""http://evilc.com/proj/adhd"">Homepage</a>"})
; The default application to limit hotkeys to.

; GUI size
ADHD.config_size(375,650)

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

Gui, Add, Button, x5 y40 w360 h50 center gFunctionalityToggle, ENABLE / DISABLE

;Gui, font, italic
;Gui, Add, Text, x15 y60 w300, Note: Bindings are just shown here for convenience.`nChange bindings on the Bindings Tab!
;Gui, font, norm

Gui, Add, Text, x15 y100 center, Input
Gui, Add, Text, x60 yp-5 w180 center, Current Binding`n(Bind on Bindings Tab)
Gui, Add, Text, x270 yp center, Output`nButton
Gui, Add, Text, x330 yp center, Latch`nMode

Loop 16 {
	y := 100 + (A_Index * 30)
	Gui, Add, Text, x15 y%y% w20 center, %A_Index%
	Gui, Add, Edit, x60 yp-5 w180 disabled vBinding%A_Index%
	ADHD.gui_add("DropDownList", "Output" A_Index, "x260 yp W50", ButtonString, A_Index)
	ADHD.gui_add("Checkbox", "Latch" A_Index, "x335 yp+3", "" , 0)
}
; End GUI creation section
; ============================================================================================

; ID of the virtual stick (1st virtual stick is 1)
vjoy_id := 1

; Init Vjoy library
VJoy_Init(vjoy_id)
; End vjoy setup

ADHD.finish_startup()

; Find max nunmber of buttons supported by vjoy stick
max_buttons := VJoy_GetVJDButtonNumber(vjoy_id)

return

InputPressed(input){
	global vjoy_id
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
	global vjoy_id
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
	global max_buttons
	global vjoy_id

	global latch_states
	global output_buttons

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

	; Release all buttons
	Loop %max_buttons% {
		VJoy_SetBtn(0, vjoy_id, A_Index)
	}

}

functionality_toggled_hook(){
	global ADHD

	if (ADHD.private.functionality_enabled ){
		Gui, Color, Default
	} else {
		Gui, Color, EEAA99
	}

}

; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this
