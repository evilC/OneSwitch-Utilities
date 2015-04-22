#Singleinstance force
;#include VJoyLib\VJoy_lib.ahk
#include <VJoy_lib>
; Create an instance of the library

ADHD := New ADHDLib

; Ensure running as admin
ADHD.run_as_admin()

; Store the value of the Choice Button so that if the user changes binding, we can remove the old binding
;LastChoiceButton := ""

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

ADHD.config_about({name: "OneSwitch Pulse", version: "1.1.0", author: "evilC", link: "<a href=""http://oneswitch.org.uk"">Homepage</a>"})
; The default application to limit hotkeys to.

; GUI size
ADHD.config_size(375,500)

; Hook into ADHD events
; First parameter is name of event to hook into, second parameter is a function name to launch on that event
ADHD.config_event("option_changed", "option_changed_hook")
ADHD.config_event("bind_mode_on", "bind_mode_on_hook")
ADHD.config_event("bind_mode_off", "bind_mode_off_hook")
ADHD.config_event("functionality_toggled", "functionality_toggle_hook")

ADHD.config_hotkey_add({uiname: "Choice Button 1", subroutine: "Choice1Made"})
adhd_hk_k_1_TT := "Which Button to use for Choice button 1"
ADHD.config_hotkey_add({uiname: "Choice Button 2", subroutine: "Choice2Made"})
adhd_hk_k_2_TT := "Which Button to use for Choice button 2"
ADHD.config_hotkey_add({uiname: "Choice Button 3", subroutine: "Choice3Made"})
adhd_hk_k_3_TT := "Which Button to use for Choice button 3"
ADHD.config_hotkey_add({uiname: "Choice Button 4", subroutine: "Choice4Made"})
adhd_hk_k_4_TT := "Which Button to use for Choice button 4"
ADHD.config_hotkey_add({uiname: "Choice Button 5", subroutine: "Choice5Made"})
adhd_hk_k_5_TT := "Which Button to use for Choice button 5"
ADHD.config_hotkey_add({uiname: "Choice Button 6", subroutine: "Choice6Made"})
adhd_hk_k_6_TT := "Which Button to use for Choice button 6"
ADHD.config_hotkey_add({uiname: "Choice Button 7", subroutine: "Choice7Made"})
adhd_hk_k_7_TT := "Which Button to use for Choice button 7"
ADHD.config_hotkey_add({uiname: "Choice Button 8", subroutine: "Choice8Made"})
adhd_hk_k_8_TT := "Which Button to use for Choice button 8"


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

Gui, Add, GroupBox, x5 yp+46 W365 R11 section, Output Configuration

Gui, Add, Text, x15 yp+30, Choice Button 1
ADHD.gui_add("DropDownList", "ChoiceButton1Out", "xp+100 yp-5 W50", "None||" ButtonString, "21")
ChoiceButton1Out_TT := "Which Button to send when Choice button 1 is hit"

Gui, Add, Text, xp+100 yp+5, Choice Button 2
ADHD.gui_add("DropDownList", "ChoiceButton2Out", "xp+100 yp-5 W50", "None||" ButtonString, "None")
ChoiceButton2Out_TT := "Which Button to send when Choice button 2 is hit"

Gui, Add, Text, x15 yp+30, Choice Button 3
ADHD.gui_add("DropDownList", "ChoiceButton3Out", "xp+100 yp-5 W50", "None||" ButtonString, "None")
ChoiceButton3Out_TT := "Which Button to send when Choice button 3 is hit"

Gui, Add, Text, xp+100 yp+5, Choice Button 4
ADHD.gui_add("DropDownList", "ChoiceButton4Out", "xp+100 yp-5 W50", "None||" ButtonString, "None")
ChoiceButton4Out_TT := "Which Button to send when Choice button 4 is hit"

Gui, Add, Text, x15 yp+30, Choice Button 5
ADHD.gui_add("DropDownList", "ChoiceButton5Out", "xp+100 yp-5 W50", "None||" ButtonString, "None")
ChoiceButton5Out_TT := "Which Button to send when Choice button 5 is hit"

Gui, Add, Text, xp+100 yp+5, Choice Button 6
ADHD.gui_add("DropDownList", "ChoiceButton6Out", "xp+100 yp-5 W50", "None||" ButtonString, "None")
ChoiceButton6Out_TT := "Which Button to send when Choice button 6 is hit"

Gui, Add, Text, x15 yp+30, Choice Button 7
ADHD.gui_add("DropDownList", "ChoiceButton7Out", "xp+100 yp-5 W50", "None||" ButtonString, "None")
ChoiceButton7Out_TT := "Which Button to send when Choice button 7 is hit"

Gui, Add, Text, xp+100 yp+5, Choice Button 8
ADHD.gui_add("DropDownList", "ChoiceButton8Out", "xp+100 yp-5 W50", "None||" ButtonString, "None")
ChoiceButton8Out_TT := "Which Button to send when Choice button 8 is hit"

Gui, Add, Text, x15 yp+40, Pulse Button
ADHD.gui_add("DropDownList", "PulseButton", "xp+100 yp-5 W50", ButtonString, "22")
PulseButton_TT := ""

Gui, Add, Text, x15 yp+40, Timeout (ms)
ADHD.gui_add("Edit", "TimeoutRate", "xp+100 yp-5 W50", "", "25000")

Gui, Add, Text, xp+100 yp+5, Timeout Button
ADHD.gui_add("DropDownList", "TimeoutButton", "xp+100 yp-5 W50", ButtonString, "23")
TimeoutButton_TT := ""

Gui, Add, Text, x15 yp+40, Timeout Warning
ADHD.gui_add("CheckBox", "TimeoutWarningEnabled", "xp+100 yp W50", "", 0)

Gui, Add, Text, xp+100 yp, Warning Time (ms)
ADHD.gui_add("Edit", "TimeoutWarningTime", "xp+100 yp-5 W50", "", "24000")


Gui, Add, GroupBox, x5 yp+40 W180 R2 section, Misc Config
Gui, Add, GroupBox, x190 yp W180 R2 section, Debug

Gui, Add, Text, x15 yp+30, Pulse Rate (ms)
ADHD.gui_add("Edit", "PulseRate", "xp+80 yp-5 W50", "", "1500")
PulseRate_TT := "The rate at which to pulse (in ms)"

Gui, Add, Text, x195 yp+5, Choice: 
Gui, Add, Text, xp+40 yp vChoiceState, 

Gui, Add, Text, xp+60 yp, Pulse: 
Gui, Add, Text, xp+40 yp vPulseState, 

; End GUI creation section
; ============================================================================================

ADHD.finish_startup()

OnMessage(0x4a, "Receive_WM_COPYDATA")  ; 0x4a is WM_COPYDATA

; Pass through other buttons 1:1
Loop {
	if (ButtonPassThroughStick != "none" && vjoy_is_ready){	; only manipulate buttons if this stick is connected.
		Loop %max_buttons% {
			if (A_Index != ChoiceButton1Out && A_Index != ChoiceButton2Out && A_Index != ChoiceButton3Out && A_Index != ChoiceButton4Out && A_Index != ChoiceButton5Out && A_Index != ChoiceButton6Out && A_Index != ChoiceButton7Out && A_Index != ChoiceButton8Out && A_Index != PulseButton && A_Index != TimeoutButton){
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
Choice1Made:
	ChoiceMade(1)
	return

Choice2Made:
	ChoiceMade(2)
	return

Choice3Made:
	ChoiceMade(3)
	return

Choice4Made:
	ChoiceMade(4)
	return

Choice5Made:
	ChoiceMade(5)
	return

Choice6Made:
	ChoiceMade(6)
	return

Choice7Made:
	ChoiceMade(7)
	return

Choice8Made:
	ChoiceMade(8)
	return

; Choice Button Released
Choice1MadeUp:
	ChoiceMadeUp(1)
	return

Choice2MadeUp:
	ChoiceMadeUp(2)
	return

Choice3MadeUp:
	ChoiceMadeUp(3)
	return

Choice4MadeUp:
	ChoiceMadeUp(4)
	return

Choice5MadeUp:
	ChoiceMadeUp(5)
	return

Choice6MadeUp:
	ChoiceMadeUp(6)
	return

Choice7MadeUp:
	ChoiceMadeUp(7)
	return

Choice8MadeUp:
	ChoiceMadeUp(8)
	return

ChoiceMade(num){
	global vjoy_id
	global ChoiceButton1Out, ChoiceButton2Out, ChoiceButton3Out, ChoiceButton4Out, ChoiceButton5Out, ChoiceButton6Out, ChoiceButton7Out, ChoiceButton8Out
	; Press virtual choice button
	
	if (ChoiceButton%num%Out != "None"){
		VJoy_SetBtn(1, vjoy_id, ChoiceButton%num%Out)
	}
	
	; Stop the timers while the button is held
	stop_timers()

	; Set debug output
	GuiControl,, ChoiceState, *
	return
}


ChoiceMadeUp(num){
	global vjoy_id
	global ChoiceButton1Out, ChoiceButton2Out, ChoiceButton3Out, ChoiceButton4Out, ChoiceButton5Out, ChoiceButton6Out, ChoiceButton7Out, ChoiceButton8Out

	; Release virtual button
	if (ChoiceButton%num%Out != "None"){
		VJoy_SetBtn(0, vjoy_id, ChoiceButton%num%Out)
	}
	
	; Resume the timers when the button is released.
	start_timers()
	
	; Debug output
	GuiControl,, ChoiceState, 
	return
}

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

TimeoutWarning:
	SoundBeep 1000, 100
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
	global TimeoutWarningEnabled, TimeoutWarningTime

	; Start Pulsing again
	SetTimer, Pulse, %PulseRate%
	SetTimer, Timeout, %TimeoutRate%
	if (TimeoutWarningEnabled){
		SetTimer, TimeoutWarning, %TimeoutWarningTime%
	}
}

stop_timers(){
	SetTimer, Pulse, Off
	SetTimer, Timeout, Off
	SetTimer, TimeoutWarning, Off
}

; This is called when any of the config options change. Also called once at start
option_changed_hook(){
	global ADHD
	global vjoy_id, vjoy_is_ready
	global adhd_limit_application
	;global ChoiceButtonIn
	global JoyID
	;global LastChoiceButton
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

	; Quit at this point if functionality disabled
	if (!ADHD.private.functionality_enabled){
		return
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
	option_changed_hook()
}

Receive_WM_COPYDATA(wParam, lParam){
    StringAddress := NumGet(lParam + 2*A_PtrSize)  ; Retrieves the CopyDataStruct's lpData member.
    CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
	if (CopyOfData = "TimeoutReset"){
		stop_timers()
		start_timers()
	}
    return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}

; KEEP THIS AT THE END!!
;#Include ADHDLib.ahk		; If you have the library in the same folder as your macro, use this
#Include <ADHDLib>			; If you have the library in the Lib folder (C:\Program Files\Autohotkey\Lib), use this

