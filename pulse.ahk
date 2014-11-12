#Singleinstance force
;#include VJoyLib\VJoy_lib.ahk
#include <VJoy_lib>
; Create an instance of the library

ADHD := New ADHDLib

; Store the value of the Choice Button so that if the user changes binding, we can remove the old binding
LastChoiceButton := ""

ButtonString := ""
Loop 32 {
	ButtonString .= A_Index
	if (A_Index != 32){
		ButtonString .= "|"
	}
}


; ============================================================================================
; CONFIG SECTION - Configure ADHD

; Authors - Edit this section to configure ADHD according to your macro.
; You should not add extra things here (except add more records to hotkey_list etc)
; Also you should generally not delete things here - set them to a different value instead

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

; Stuff for the About box

ADHD.config_about({name: "OneSwitch Pulse", version: 1.0, author: "evilC", link: "<a href=""http://oneswitch.org.uk"">Homepage</a>"})
; The default application to limit hotkeys to.

; GUI size
ADHD.config_size(375,250)

; We need no actions, so disable warning
ADHD.config_ignore_noaction_warning()

; Hook into ADHD events
; First parameter is name of event to hook into, second parameter is a function name to launch on that event
ADHD.config_event("option_changed", "option_changed_hook")
ADHD.config_event("bind_mode_on", "bind_mode_on_hook")
ADHD.config_event("bind_mode_off", "bind_mode_off_hook")

ADHD.config_hotkey_add({uiname: "Choice Button", subroutine: "ChoiceMade"})
adhd_hk_k_1_TT := "ChoiceMade"


ADHD.init()
ADHD.create_gui()

; The "Main" tab is tab 1
Gui, Tab, 1
; ============================================================================================
; GUI SECTION

Gui, Add, GroupBox, x5 yp+30 W365 R4 section, Output Configuration

Gui, Add, Text, x15 yp+30, Choice Button
ADHD.gui_add("DropDownList", "ChoiceButtonOut", "xp+80 yp-5 W50", ButtonString, "1")
ChoiceButtonOut_TT := ""

Gui, Add, Text, xp+100 yp+5, Pulse Button
ADHD.gui_add("DropDownList", "PulseButton", "xp+80 yp-5 W50", ButtonString, "2")
PulseButton_TT := ""

Gui, Add, Text, x15 yp+40, Timeout (ms)
ADHD.gui_add("Edit", "TimeoutRate", "xp+80 yp-5 W50", "", "3000")
;TimeoutRate_TT := ""

Gui, Add, Text, xp+100 yp+5, Timeout Button
ADHD.gui_add("DropDownList", "TimeoutButton", "xp+80 yp-5 W50", ButtonString, "3")
TimeoutButton_TT := ""

Gui, Add, GroupBox, x5 yp+40 W180 R2 section, Misc Config
Gui, Add, GroupBox, x190 yp W180 R2 section, Debug

Gui, Add, Text, x15 yp+30, Pulse Rate (ms)
ADHD.gui_add("Edit", "PulseRate", "xp+80 yp-5 W50", "", "1000")
PulseRate_TT := "The rate at which to pulse (in ms)"

Gui, Add, Text, x195 yp+5, Choice: 
Gui, Add, Text, xp+40 yp vChoiceState, 

Gui, Add, Text, xp+60 yp, Pulse: 
Gui, Add, Text, xp+40 yp vPulseState, 

; End GUI creation section
; ============================================================================================

; Load vJoy DLL
;LoadPackagedLibrary()
;VJoy_LoadLibrary()

; ID of the virtual stick (1st virtual stick is 1)
vjoy_id := 1

; Init Vjoy library
VJoy_Init(vjoy_id)
; End vjoy setup

ADHD.finish_startup()

; Find max nunmber of buttons supported by vjoy stick
max_buttons := VJoy_GetVJDButtonNumber(vjoy_id)

; Pass through other buttons 1:1
Loop {
	Loop %max_buttons% {
		if (A_Index != ChoiceButtonOut && A_Index != PulseButton && A_Index != TimeoutButton){
			if (getkeystate(JoyPrefix A_Index)){
				VJoy_SetBtn(1, vjoy_id, A_Index)
			} else {
				VJoy_SetBtn(0, vjoy_id, A_Index)
			}
		}
	}
	Sleep 10
}

return

; === Hotkeys

; Choice Button pressed
ChoiceMade:
	; Press virtual choice button
	VJoy_SetBtn(1, vjoy_id, ChoiceButtonOut)
	
	; Stop the pulse
	SetTimer, Pulse, Off
	
	; Reset the Timeout
	SetTimer, Timeout, %TimeoutRate%

	; Set debug output
	GuiControl,, ChoiceState, *
	return

; Choice Button Released
ChoiceMadeUp:
	; Release virtual button
	VJoy_SetBtn(0, vjoy_id, ChoiceButtonOut)

	; Resume the pulse
	SetTimer, Pulse, %PulseRate%

	; Debug output
	GuiControl,, ChoiceState, 
	return

; === Timers

; Do a pulse
Pulse:
	; Press the virtual pulse button
	VJoy_SetBtn(1, vjoy_id, PulseButton)

	; debug output
	GuiControl,, PulseState, *

	; Wait for a bit so the press has a chance to register
	Sleep 50

	; Release the virtual pulse button
	VJoy_SetBtn(0, vjoy_id, PulseButton)

	; Debug output
	GuiControl,, PulseState, 
	return

; This handles what happens when TimeOut is hit
Timeout:
	; Press the virtual timeout button
	VJoy_SetBtn(1, vjoy_id, TimeoutButton)
	
	; Wait for a bit so the press has a chance to register
	Sleep 50

	; Release the virtual timeout button
	VJoy_SetBtn(0, vjoy_id, TimeoutButton)
	
	return

; === Hooks into ADHD stuff	

; Bind Mode was enabled. Stop pulsing so the virtual stick does not get bound as an input accidentally
bind_mode_on_hook(){
	SetTimer, Pulse, Off
	SetTimer, Timeout, Off
}

bind_mode_off_hook(){
	global PulseRate
	global TimeoutRate

	; Start Pulsing again
	SetTimer, Pulse, %PulseRate%
	SetTimer, Timeout, %TimeoutRate%
}

; This is called when any of the config options change. Also called once at start
option_changed_hook(){
	global ADHD
	global adhd_limit_application
	;global ChoiceButtonIn
	global JoyID
	global LastChoiceButton
	global PulseRate
	global TimeoutRate
	global JoyPrefix
	global vjoy_id
	global max_buttons

	; Stop Pulsing
	SetTimer, Pulse, Off
	SetTimer, Timeout, Off
	
	; Release all buttons
	Loop %max_buttons% {
		VJoy_SetBtn(0, vjoy_id, A_Index)
	}

	; Start Pulsing again - possibly with new values
	SetTimer, Pulse, %PulseRate%
	SetTimer, Timeout, %TimeoutRate%

}

; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this

