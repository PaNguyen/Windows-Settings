#IfWinActive ahk_exe switcheroo.exe

^n::
SendInput {Ctrl Up}{Down}{Ctrl Down}
return

^p::
SendInput {Ctrl Up}{Up}{Ctrl Down}
return

