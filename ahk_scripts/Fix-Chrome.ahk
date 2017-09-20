#IfWinActive, ahk_exe chrome.exe

^n::
SendInput {Ctrl Up}{Down}{Ctrl Down}
return

^p::
SendInput {Ctrl Up}{Up}{Ctrl Down}
return
