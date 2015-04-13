#Singleinstance force
;#include VJoyLib\VJoy_lib.ahk
#include <VJoy_lib>
; Create an instance of the library

ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

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

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

; Stuff for the About box

ADHD.config_about({name: "OneSwitch Pulse", version: "1.0.2", author: "evilC", link: "<a href=""http://oneswitch.org.uk"">Homepage</a>"})
; The default application to limit hotkeys to.

; GUI size
ADHD.config_size(375,340)

; Hook into ADHD events
; First parameter is name of event to hook into, second parameter is a function name to launch on that event
ADHD.config_event("option_changed", "option_changed_hook")
ADHD.config_event("bind_mode_on", "bind_mode_on_hook")
ADHD.config_event("bind_mode_off", "bind_mode_off_hook")
ADHD.config_event("functionality_toggled", "functionality_toggle_hook")

ADHD.config_hotkey_add({uiname: "Choice Button", subroutine: "ChoiceMade"})
adhd_hk_k_1_TT := "ChoiceMade"


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

Gui, Add, GroupBox, x5 yp+30 W365 R2 section, Input Configuration
Gui, Add, Text, x15 yp+30, Pass through unused buttons from stick ID
ADHD.gui_add("DropDownList", "ButtonPassThroughStick", "xp+220 yp-5 W50", "None|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16", "None")

Gui, Add, GroupBox, x5 yp+46 W365 R4 section, Output Configuration

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

ADHD.finish_startup()

; Pass through other buttons 1:1
Loop {
	if (ButtonPassThroughStick != "none" && vjoy_is_ready){	; only manipulate buttons if this stick is connected.
		Loop %max_buttons% {
			if (A_Index != ChoiceButtonOut && A_Index != PulseButton && A_Index != TimeoutButton){
				if (getkeystate(ButtonPassThroughStick "Joy" A_Index)){
					VJoy_SetBtn(1, vjoy_id, A_Index)
				} else {
					VJoy_SetBtn(0, vjoy_id, A_Index)
				}
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
	stop_timers()
	
	; Press the virtual timeout button
	VJoy_SetBtn(1, vjoy_id, TimeoutButton)
	
	; Wait for a bit so the press has a chance to register
	Sleep 50

	; Release the virtual timeout button
	VJoy_SetBtn(0, vjoy_id, TimeoutButton)
	
	start_timers()
	
	return

; === Hooks into ADHD stuff	

; Bind Mode was enabled. Stop pulsing so the virtual stick does not get bound as an input accidentally
bind_mode_on_hook(){
	stop_timers()
}

bind_mode_off_hook(){
	start_timers()
}

start_timers(){
	global PulseRate
	global TimeoutRate

	; Start Pulsing again
	SetTimer, Pulse, %PulseRate%
	SetTimer, Timeout, %TimeoutRate%
}

stop_timers(){
	SetTimer, Pulse, Off
	SetTimer, Timeout, Off
}

; This is called when any of the config options change. Also called once at start
option_changed_hook(){
	global ADHD
	global vjoy_id, vjoy_is_ready
	global adhd_limit_application
	;global ChoiceButtonIn
	global JoyID
	global LastChoiceButton
	global PulseRate
	global TimeoutRate
	global JoyPrefix
	global max_buttons

	; Stop Pulsing
	stop_timers()

	; Release Buttons
	if (vjoy_is_ready){
		Loop % VJoy_GetVJDButtonNumber(vjoy_id) {
			VJoy_SetBtn(0, vjoy_id, A_Index)
		}
	}

	connect_to_vjoy()

	if (vjoy_is_ready){
		max_buttons := VJoy_GetVJDButtonNumber(vjoy_id)
	} else {
		max_buttons := 0
	}

	; Start Pulsing again - possibly with new values
	start_timers()
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

functionality_toggle_hook(){
	global ADHD
	if (ADHD.private.functionality_enabled){
		start_timers()
	} else {
		stop_timers()
	}
}

; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this

