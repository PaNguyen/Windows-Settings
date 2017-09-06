#SingleInstance force
;#NoTrayIcon
#NoEnv
SendMode Input

Capslock::Ctrl
Ctrl::Capslock

; Capslock = Escape key, unless its used with another key, where it acts as Ctrl.
; Capslock::
;     Send {LControl Down}
;     KeyWait, CapsLock
;     Send {LControl Up}
;     if ( A_PriorKey = "CapsLock" )
;     {
;         ;Send {Esc}
;         state := GetKeyState("Capslock", "T") ? "Off" : "On"
;         SetCapsLockState, %state%
;     }
; return
; ; Escape key toggles capslock
; Escape::
;     ;state := GetKeyState("Capslock", "T") ? "Off" : "On"
;     ;SetCapsLockState, %state%
; return