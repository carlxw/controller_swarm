#Include XInput.ahk
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force ; Ensures only one instance of the script is running at a time.
; DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr") ; Allows MouseMove to be consistent across non-primary monitors
CoordMode, Mouse, Screen ; Sets the CoordMode for MouseMove
CoordMode, Pixel, Screen ; Sets the CoordMode for Pixel
; #NoTrayIcon ; Hides the AHK tray icon when running
#UseHook
#InstallMouseHook

global THUMB_TRIGGER_ANALOG_TOLERANCE = 10
global STICK_ANALOG_TOLERANCE = 5000
global MOUSE_MOVE_DELTA = 3

; Increase the following value to make the mouse cursor move faster: (Default 0.30)
global CONTMULTIPLIER = 0.5

; Decrease the following value to require less stick displacement-from-center
; to start moving the mouse.  However, you may need to calibrate your stick
; -- ensuring it's properly centered -- to avoid cursor drift. A perfectly tight
; and centered stick could use a value of 1: (Default 3)
global CONTTHRESHOLD = 3

ProcessButton(isControllerKeyDown, key) {
    if (!isControllerKeyDown && GetKeyState(key)) {
        Send, {%key% UP}
    }

    if (isControllerKeyDown && !GetKeyState(key)) {
        Send, {%key% DOWN}
    }

    return
}

XInput_Init("xinput1_2.dll")

Loop {
    ; if (!WinActive("League of Laegends (TM) Client")) {
    ;     sleep, 1000
    ;     Continue
    ; }
    if (state := Xinput_GetState(0)) {
        a_button := state.wButtons & (1 << 12)
        b_button := state.wButtons & (1 << 13)
        x_button := state.wButtons & (1 << 14)
        y_button := state.wButtons & (1 << 15)

        up_button := state.wButtons & (1 << 0)
        down_button := state.wButtons & (1 << 1)
        left_button := state.wButtons & (1 << 2)
        right_button := state.wButtons & (1 << 3)

        start_button := state.wButtons & (1 << 4)
        back_button := state.wButtons & (1 << 5)

        left_thumb_button := state.bLeftTrigger > THUMB_TRIGGER_ANALOG_TOLERANCE
        right_thumb_button := state.bRightTrigger > THUMB_TRIGGER_ANALOG_TOLERANCE

        left_shoulder_button := state.wButtons & (1 << 8)
        right_shoulder_button := state.wButtons & (1 << 9)

        left_thumb_stick_x := state.sThumbLX
        left_thumb_stick_y := state.sThumbLY
        right_thumb_stick_x := state.sThumbRX
        right_thumb_stick_y := state.sThumbRY

        ; =================================================

        ProcessButton(a_button || right_shoulder_button, "LButton")
        ProcessButton(b_button || left_shoulder_button, "RButton")
        ProcessButton(y_button, "c")

        ; =================================================

        ProcessButton(left_thumb_button, "e")
        ProcessButton(right_thumb_button, "r")

        ; =================================================

        ProcessButton(start_button || back_button, "Esc")

        ; =================================================

        ProcessButton(up_button    || left_thumb_stick_y >  STICK_ANALOG_TOLERANCE, "w")
        ProcessButton(down_button  || left_thumb_stick_y < -STICK_ANALOG_TOLERANCE, "s")
        ProcessButton(left_button  || left_thumb_stick_x < -STICK_ANALOG_TOLERANCE, "a")
        ProcessButton(right_button || left_thumb_stick_x >  STICK_ANALOG_TOLERANCE, "d")

        ; =================================================

        if (Abs(right_thumb_stick_x) > STICK_ANALOG_TOLERANCE || Abs(left_thumb_stick_x) > STICK_ANALOG_TOLERANCE || Abs(right_thumb_stick_y) > STICK_ANALOG_TOLERANCE || Abs(left_thumb_stick_y) > STICK_ANALOG_TOLERANCE) {
            if (right_thumb_stick_x > STICK_ANALOG_TOLERANCE) {
                DeltaX := right_thumb_stick_x / 780 
            }
            else if (right_thumb_stick_x < -STICK_ANALOG_TOLERANCE) {
                DeltaX := right_thumb_stick_x / 780 
            }
            else{
                DeltaX := 0
            }

            if (right_thumb_stick_y > STICK_ANALOG_TOLERANCE) {
                DeltaY := right_thumb_stick_y / 780 
            }
            else if (right_thumb_stick_y < -STICK_ANALOG_TOLERANCE) {
                DeltaY := right_thumb_stick_y / 780 
            }
            else {
                DeltaY := 0
            }

            x := DeltaX * CONTMULTIPLIER
            y := DeltaY * CONTMULTIPLIER * -1
            ; OutputDebug, %x%, %y% | %right_thumb_stick_x%, %right_thumb_stick_y%
            ; SetMouseDelay, -1 ; Makes movement smoother.
	        ; MouseMove, DeltaX * CONTMULTIPLIER, DeltaY * CONTMULTIPLIER * -1, 0, R
            DllCall("mouse_event", "UInt", 0x01, "Int", x, "Int", y, "UInt", 0, "UInt", 0)
        }
        Sleep, 5
    }
}

F12::Reload
F11::ExitApp