#SingleInstance force
; #NoTrayIcon
#InstallKeybdHook

Transform, CtrlA, Chr, 1
Transform, CtrlB, Chr, 2
Transform, CtrlC, Chr, 3
Transform, CtrlD, Chr, 4
Transform, CtrlE, Chr, 5
Transform, CtrlF, Chr, 6
Transform, CtrlG, Chr, 7
Transform, CtrlH, Chr, 8
Transform, CtrlI, Chr, 9
Transform, CtrlJ, Chr, 10
Transform, CtrlK, Chr, 11
Transform, CtrlL, Chr, 12
Transform, CtrlM, Chr, 13
Transform, CtrlN, Chr, 14
Transform, CtrlO, Chr, 15
Transform, CtrlP, Chr, 16
Transform, CtrlQ, Chr, 17
Transform, CtrlR, Chr, 18
Transform, CtrlS, Chr, 19
Transform, CtrlT, Chr, 20
Transform, CtrlU, Chr, 21
Transform, CtrlV, Chr, 22
Transform, CtrlW, Chr, 23
Transform, CtrlX, Chr, 24
Transform, CtrlY, Chr, 25
Transform, CtrlZ, Chr, 26


Process Priority,,High
SetBatchLines, -1
SetKeyDelay  -1

AutoTrim, off
DetectHiddenWindows, off
Gui,+LastFound +AlwaysOnTop -Caption ToolWindow

WinSet, Transparent, 230
Gui, Color,black,black
Gui,Font,s13 c7cfc00 bold
;;Gui, Add, ListView, vindex gListViewClick x-2 y-2 w800 h530 AltSubmit -VScroll
Gui, Add, Text,     x10  y10 w800 h30, Search`:
Gui, Add, Edit,     x90 y5 w500 h30,
Gui, Add, ListView, x0 y40 w800 h510 -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 gListViewClick, index|title|proc
WS_EX_APPWINDOW = 0x40000
WS_EX_TOOLWINDOW = 0x80
GW_OWNER = 4



F4::
WinGet, orig_active_id, ID, A
prev_active_id = %orig_active_id%

Gui, Show, Center h550 w800, Window Switcher

; If we determine the ID of the switcher window here then
; why doesn't it appear in the window list when the script is
; run the first time? (Note that RefreshWindowList has already
; been called above).
; Answer: Because when this code runs first the switcher window
; does not exist yet when RefreshWindowList is called.
WinGet, switcher_id, ID, A
WinSet, AlwaysOnTop, On, ahk_id %switcher_id%

Loop
{
        Input, input, L1 M, {enter}{esc}{backspace}{tab}{up}{down}

        ;;enter for select
        if ErrorLevel = EndKey:enter
        {
                GoSub, ActivateWindow
                break
        }

        ;excape for cancel 
        if ErrorLevel = EndKey:escape
        {
                GoSub, CancelSwitch
                break
        }

        ; ;;control+g for cancel too
        if input = %CtrlG%
        {
                GoSub, CancelSwitch
                break
        }

        ;;delete last char 
        if ErrorLevel = EndKey:backspace
        {
                if (GetKeyState("LControl", "P")=1||GetKeyState("LAlt","P")=1)
                {
                        GoSub, DeleteSearchWord
                        continue
                }else
                {
                        GoSub, DeleteSearchChar
                        continue
                }

        }

        if ErrorLevel = EndKey:tab
        {
                GoSub, ActivateWindow
                break
        }


        ; pass these keys to the selector window

        if ErrorLevel = EndKey:up
        {
                GoSuB SelectPrevious
                continue
        }

        if ErrorLevel = EndKey:down
        {
                GoSuB SelectNext
                continue
        }
        if ErrorLevel = EndKey:LControl
        {
                continue
        }

        if input = %CtrlN%
        {
                GoSub SelectNext
                continue
        }

        if input = %CtrlP%
        {
                GoSub SelectPrevious
                continue
        }


        ; process typed character

        search = %search%%input%
        ;OutputDebug, search=%search%
        GuiControl,, Edit1, %search%
        GuiControl,Focus,Edit1 ;; focus Edit1 ,
        Send {End} ;;move cursor right ,make it after the new inputed char 
        ; GoSub, RefreshWindowList
        OutputDebug, there
}

ActivateWindow:
        Gui, submit
        rowNum:= LV_GetNext(0)
        stringtrimleft, window_id, idarray%rowNum%, 0
        IL_Destroy(ImageListID1) ; destroy gui, listview and associated icon imagelist.
        LV_Delete()
        WinActivate, ahk_id %window_id%

        return

CancelSwitch:
        Gui, cancel

        ; restore the originally active window if
        ; activateselectioninbg is enabled
        if activateselectioninbg <>
            WinActivate, ahk_id %orig_active_id%
return

DeleteSearchWord:
;;delete last word of search string ,search string
;; can be Separated by empty space  
        GuiControl,, Edit1, 
        if search =
        {
                GuiControl,, Edit1,
                return
        }
        FoundPos := RegExMatch(search, "(.*) +.*", SubPat)
        if FoundPos>0
        {
                search:=SubPat1
                GuiControl,,Edit1,%search%
        }else
        {
                search=
                GuiControl,,Edit1,
        }
        GuiControl,Focus,Edit1 ;; focus Edit1 ,
        Send {End}
        ; GoSub, RefreshWindowList
        return

DeleteSearchChar:
        if search =
        {
                GuiControl,, Edit1, 
                return
        }
        ;OutputDebug, search9=%search%
        StringTrimRight, search, search, 1
        ;OutputDebug, search8=%search%
        GuiControl,, Edit1, %search%
        GuiControl,Focus,Edit1 ;; focus Edit1 ,
        Send {End} ;;move cursor end 

        ; GoSub, RefreshWindowList
        return

SelectNext:
       rowNum:= LV_GetNext(0)
       if(rowNum<numwin){
          LV_Modify(rowNum+1, "Select") ;;select next line
          LV_Modify(rowNum+1, "Focus") ;; focus next line
       }else{
          LV_Modify(1, "Select") ;;select the first row
          LV_Modify(1, "Focus") ;; focus the first row
       }

        ; GoSuB ActivateWindowInBackgroundIfEnabled
        return
;------------------------------------------------------------------------
SelectPrevious:
              rowNum:= LV_GetNext(0)
              if(rowNum<2){
                 LV_Modify(numwin, "Select") ;;select last line
                 LV_Modify(numwin, "Focus") ;; focus last line
              }else{
                 LV_Modify(rowNum-1, "Select") ;;select previous line
                 LV_Modify(rowNum-1, "Focus") ;; focus previous line
              }
              ; GoSuB ActivateWindowInBackgroundIfEnabled
              return

ListViewClick:
if (A_GuiControlEvent = "Normal"
    and !GetKeyState("Down", "P") and !GetKeyState("Up", "P"))

;;    GoSub, ActivateWindow
send ,{enter}
;;    GoSub, BgActivationTimer
return
    