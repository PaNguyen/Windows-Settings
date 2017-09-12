F4::
WinGet, Window, List
tList:=[]
Loop %Window%
{
        Id:=Window%A_Index%
        WinGetTitle, TVar , % "ahk_id " Id
        Window%A_Index%:=TVar ;use this if you want an array
        tList.=TVar "`n" ;use this if you just want the list
}
; MsgBox %tList%
InputBox, choice, Open Windows, %tList%
MsgBox %choice%
return

