; iswitchw-plus - Incrementally switch between windows using substrings
; Time-stamp: <Joseph 2011-06-11 22:48:21 星期六>
; you can reach me here :<jixiuf@gmail.com>
; Test on AutoHotKey_L v1.0.97.02

; keyboardfreak's  version
;     http://www.autohotkey.com/forum/viewtopic.php?t=1040
;
; ezuk's version
;     http://www.autohotkey.com/forum/viewtopic.php?t=33353;
; and this file ,my version is hosted on github.com
;     https://github.com/jixiuf/my_autohotkey_scripts/blob/master/ahk_scripts/iswitchw-plus.ahk
;
;    about iswitchb.el
; http://cvs.savannah.gnu.org/viewvc/*checkout*/emacs/emacs/lisp/iswitchb.el
;    about "anything.el" you can find it here .
; http://www.emacswiki.org/emacs/Anything

;
; When this script is triggered via its hotkey the list of titles of
; all visible windows appears. The list can be narrowed quickly to a
; particular window by typing one or more substring of a window title.
; separated by empty space(new feature).
;
; When the list is narrowed the desired window can be selected using
; the cursor keys, Enter,and Ctrl+j. If the substring matches exactly
; onewindow that window is activated immediately (configurable, see
; the  "autoactivateifonlyone" variable).
; you can also close the selected window by Ctrl+k,and Alt+k
; the difference is Alt+k ,close the window and quit.
; Ctrl+k close the window and  keep iswitcher running .
;
; The window selection can be cancelled with Esc and Ctrl+g.
;
; The switcher window can be moved horizontally with the left/right
; arrow keys if it blocks the view of windows under it.
;
; The switcher can also be operated with the mouse, although it is
; meant to be used from the keyboard. A mouse click activates the
; currently selected window. Mouse users may want to change the
; activation key to one of the mouse keys.
;
; If enabled possible completions are offered when the same unique
; substring is found in the title of more than one window.
;
; For example, the user typed the string "co" and the list is
; narrowed to two windows: "Windows Commander" and "Command Prompt".
; In this case the "command" substring can be completed automatically,
; so the script offers this completion in square brackets which the
; user can accept with the TAB key:
;
;     co[mmand]
;
; This feature can be confusing for novice users, so it is disabled
; by default.
; 
;
; you can use UP,Ctrl+P Alt+p Shift+Tab,Alt+Shift+Tab
; to select previous item
; and use Down ,Ctrl+n Alt+n  Tab ,Alt+Tab  to select next item .
;
; Ctrl+u will clear all search string in textfield ,
; Ctrl+h ,and backspace will delete a char.
; Ctrl+backspace ,AltBackspace will delete last keyword in textfield.
; enter ,and Ctrl+j for select
; escape ,and Ctrl+g for cancel

; Ctrl+alt+k ,force kill the selected window
; Alt+k      ,kill the selected window and quit.
; Ctrl+k ,    kill the selected window and keep switcher going ,so that
;             you can select other window or kill other window.
;
; Ctrl+s ,  toggle the status of window:minimize,maximize and restore
; you can press Ctrl+s several times
;
; For the idea of this script the credit goes to the creators of the
; iswitchb package for the Emacs editor
;
; 
;
;
;----------------------------------------------------------------------
;
#SingleInstance force
;42td: display tray icon
;#NoTrayIcon
Menu Tray, Icon, %SystemRoot%\system32\shell32.dll, 99
#InstallKeybdHook
;42td avoid taskbar flashing when cycling quickly (function cycleCurrentWindowGroup)
#WinActivateForce

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
; User configuration

; set this to yes if you want to select the only matching window
; automatically
autoactivateifonlyone =  ;42td

; set this to yes if you want to enable tab completion (see above)
; it has no effect if firstlettermatch (see below) is enabled
tabcompletion =yes

; set this to yes to enable digit shortcuts when there are ten or
; less items in the list
digitshortcuts =yes

; set this to yes to enable first letter match mode where the typed
; search string must match the first letter of words in the
; window title (only alphanumeric characters are taken into account)
;
; For example, the search string "ad" matches both of these titles:
;
;  AutoHotkey - Documentation
;  Anne's Diary
;
firstlettermatch =

; set this to yes to enable activating the currently selected
; window in the background
;
activateselectioninbg =

; number of milliseconds to wait for the user become idle, before
; activating the currently selected window in the background
;
; it has no effect if activateselectioninbg is off
;
; if set to blank the current selection is activated immediately
; without delay
; activateselectioninbg  不为空的时候有效

bgactivationdelay = 600


; Close switcher window if the user activates an other window.
; It does not work well if activateselectioninbg is enabled, so
; currently they cannot be enabled together.
closeifinactivated =yes

if activateselectioninbg <>
    if closeifinactivated <>
    {
        msgbox, activateselectioninbg and closeifinactivated cannot be enabled together
        exitapp
    }

; List of subtsrings separated with pipe (|) characters (e.g. carpe|diem).
; Window titles containing any of the listed substrings are filtered out
; from the list of windows.
filterlist = asticky|blackbox

; Set this yes to update the list of windows every time the contents of the
; listbox is updated. This is usually not necessary and it is an overhead which
; slows down the update of the listbox, so this feature is disabled by default.
dynamicwindowlist =

; path to sound file played when the user types a substring which
; does not match any of the windows
;
; set this to blank if you don't want a sound
;
;42td
;nomatchsound = %windir%\Media\ding.wav
nomatchsound =

; 42td: Set an icon to be used for windows which are grouped under other windows
; (file (e.g. DLL) and index).
sameGroupIconFile = %SystemRoot%\system32\shell32.dll
;sameGroupIconNum =  50 ;blank
;sameGroupIconNum = 147 ;green up arrow
;sameGroupIconNum = 247 ;white upward triangle
;sameGroupIconNum = 264 ;blue up arrow on white
sameGroupIconNum = 268 ;white >>
;sameGroupIconNum = 294 ;dot

; 42td: Change this function to define which windows belong into the same
; group.
; Two windows are put in the same group iff this function returns the same
; value for them. Apart from that, the actual values can be chosen
; arbitrarily. This example used "W:", "P:", and "x:" prefixes (for window ID,
; PID, and process name, resp.) to avoid name clashes. (Which is not
; necessary, as window IDs seem to always be hexadecimal with "0x" prefix and
; PIDs decimal.)
windowGroupConf(windowId, title, windowClass, pid, processName) { ;42td
    return 1 == 0 ? ""
        : windowClass == "#32770" ? ("W:" . windowId)
        : windowClass == "mintty" && RegExMatch(title, "\b(bash|zsh)\b") ? "mintty_shell"
        : (windowClass == "MozillaWindowClass" || windowClass == "MozillaDialogClass") ? ("P:" . pid)
		: (processName == "java" || processName == "javaw") ? ("P:" . pid)
        : ("x:" . processName)
}

; 42td: How long cycleCurrentWindowGroup should show a tooltip of all window
; titles in group. 0 or negative to disable.
cycleTooltipDuration = 2700

if nomatchsound <>
    ifnotexist, %nomatchsound%
        msgbox, Sound file %nomatchsound% not found. No sound will be played.

;----------------------------------------------------------------------
;
; Global variables
;
;     numallwin      - the number of windows on the desktop
;     allwinarray    - array containing the titles of windows on the desktop
;                      dynamicwindowlist is disabled
;     allwinidarray  - window ids corresponding to the titles in allwinarray
;     numwin         - the number of windows in the listbox
;     idarray        - array containing window ids for the listbox items
;     orig_active_id - the window ID of the originally active window
;                      (when the switcher is activated)
;     prev_active_id - the window ID of the last window activated in the
;                      background (only if activateselectioninbg is enabled)
;     switcher_id    - the window ID of the switcher window
;     filters        - array of filters for filtering out titles
;                      from the window list
;
;----------------------------------------------------------------------

AutoTrim, off
DetectHiddenWindows, off
Gui,+LastFound +AlwaysOnTop -Caption ToolWindow   

WinSet, Transparent, 220 ;42td
Gui, Color,black,black
;42td {
;Gui,Font,s13 c7cfc00 bold
Gui,Font,s12 Ce0e0e0
Gui,Font,,Verdana
Gui,Font,,DejaVu Sans
;} 42td
;;Gui, Add, ListView, vindex gListViewClick x-2 y-2 w800 h530 AltSubmit -VScroll
Gui, Add, Text,     x10  y10 w800 h30, Search`:
Gui, Add, Edit,     x90 y5 w500 h30,
Gui, Add, ListView, x0 y40 w800 h510 -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 gListViewClick, index|title|proc

if filterlist <>
{
    loop, parse, filterlist, |
    {
        filters%a_index% = %A_LoopField%
    }
}

listSeparator := "`f" ;42td

;----------------------------------------------------------------------
;
;
<^>!CapsLock::CapsLock ;42td: AltGr+CapsLock for CapsLock toggle

;+CapsLock:: cycleCurrentWindowGroup() ;42td
^SC028:: cycleCurrentWindowGroup(false) ;42td
^SC02B:: cycleCurrentWindowGroup(true) ;42td

;42td: CapsLock as main hotkey
!Tab::
search =
numallwin = 0
GuiControl,, Edit1
GoSub, RefreshWindowList

WinGet, orig_active_id, ID, A
prev_active_id = %orig_active_id%

Gui, Show, Center h550 w800, Window Switcher

; If we determine the ID of the switcher window here then
; why doesn't it appear in the window list when the script is
; run the first time? (Note that RefreshWindowList has already
; been called above).
; Answer: Because when this code runs first the switcher window
; does not exist yet when RefreshWindowList is called.
OutputDebug % "switcher_id == " . switcher_id
WinGet, switcher_id, ID, A
OutputDebug % "switcher_id == " . switcher_id
WinSet, AlwaysOnTop, On, ahk_id %switcher_id%

;Transform, ctrlN, Chr, 

Loop
{
    OutputDebug % "=== input loop ===" ;42td
    if closeifinactivated <>
        settimer, CloseIfInactive, 200

    ;42td
    ;patrick: ErrorLevel is an end key if it is one, otherwise "Max"
    ; HotKey,CapsLock,Off
    ; Input, input, L1, {enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right}{LControl}npsgukjh{LAlt}{LShift}{CapsLock}^{PrintScreen}
    Input, input, L1 M, {enter}{esc}{backspace}{up}{down}{left}{right}{pgup}{pgdn}{tab}{PrintScreen}{LAlt}
    ;GetKeyState state, ALT
    OutputDebug % "ErrorLevel = " . ErrorLevel
    ; HotKey,CapsLock,On

    if closeifinactivated <>
        settimer, CloseIfInactive, off

	;42td
	; if ErrorLevel = EndKey:^
	; {
	; 	SelectNextInGroup()
	; 	continue
        ; }


    ;;enter for select
    if ErrorLevel = EndKey:Enter
    {
        ActivateWindow(0)
        break
    }

    ;excape for cancel 
    if ErrorLevel = EndKey:escape
    {
        GoSub, CancelSwitch
        break
    }

     ;;delete last char 
     if ErrorLevel = EndKey:backspace
     {
             if (GetKeyState("LControl", "P")=1||GetKeyState("LAlt","P")=1){
                     GoSub, DeleteSearchWord
                     continue
             } else{
                     GoSub, DeleteSearchChar
        continue
       }
    }

    if ErrorLevel = EndKey:up
    {
        SelectPrevious()
        continue
    }

    if ErrorLevel = EndKey:down
    {
       SelectNext()
       continue
    }

    if ErrorLevel = EndKey:left
    {
        direction = -1
        GoSuB MoveSwitcher
        continue
    }

    if ErrorLevel = EndKey:right
    {
        direction = 1
        GoSuB MoveSwitcher
        continue
    }

    if ErrorLevel = EndKey:tab
        if completion =
        {
          if (GetKeyState("LShift", "P")!=1){ ;42td: swapped (without shift = previous)
                SelectPrevious()
          }else{
                SelectNext()
          }
            continue
        }else
            input = %completion%

    ;;42td: Pass through PrintScreen
    if ErrorLevel = EndKey:PrintScreen
    {
            Send,{PrintScreen}
            continue
    }

    ;;control+g for cancel too
    if input = %CtrlG%
    {
            GoSub, CancelSwitch
            break
    }

    if input = %CtrlN%
    {
            SelectNext()
            continue
    }
    if input = %CtrlP%
    {
            SelectPrevious()
            continue
    }

    ;    if (GetKeyState("LAlt", "P")=1 and input = k)
    if ErrorLevel = EndKey:LAlt
    {
            Input, i, L1
            if i = k
            {
                    GoSub, DeleteAllSearchChar
            }
            continue
    }


    ; if ErrorLevel = EndKey:pgup
    ; {
    ;     Send, {pgup}
    ;     GoSuB ActivateWindowInBackgroundIfEnabled
    ;     continue
    ; }

    ; if ErrorLevel = EndKey:pgdn
    ; {
    ;     Send, {pgdn}
    ;     GoSuB ActivateWindowInBackgroundIfEnabled
    ;     continue
    ; }

    ;;toggle the status of selected window
    ;;WinMaximize-> WinMinimize->WinRestore-> 
  ; if ErrorLevel = EndKey:s
  ;   {
  ;      if (GetKeyState("LControl", "P")=1){
  ;         oldCloseifinactivated =closeifinactivated
  ;         closeifinactivated=
  ;         settimer, CloseIfInactive, off
  ;         GoSub, toggleWinStatus
  ;         WinActivate ,ahk_id %switcher_id%
  ;         GuiControl,, Edit1,%search%
  ;         SendInput {end}
  ;         sleep 10
  ;         closeifinactivated = oldCloseifinactivated
  ;         continue
  ;      }else{
  ;           input=s
  ;      }

  ;   }

    ;; TODO modify later to have emacs style
    ;; SEE ctrl+u
    ;;Ctrl+alt+k ,force kill the selected window
    ;;Alt+k      ,kill the selected window and quit.
    ;;Ctrl+k ,    kill the selected window and keep switcher running ,so that
    ;;            you can select other window or kill other window.
  ; if ErrorLevel = EndKey:k
  ;   {
  ;      if (GetKeyState("LControl", "P")=1  and GetKeyState("LAlt", "P")=1){
  ;         GoSub, ForceKillSelectedWindow 
  ;         GoSub, CancelSwitch       ;; quit 
  ;         break
       
  ;      }else if (GetKeyState("LControl", "P")=1){
  ;            GoSub, KillSelectedWindow
  ;            tmpRefresh=yes ;force refresh window list 
  ;      }else if (GetKeyState("LAlt", "P")=1){
  ;         GoSub  KillSelectedWindow ;;kill the select window
  ;         GoSub, CancelSwitch       ;; quit 
  ;         break
  ;      }else{
  ;        input=k
  ;      }

  ; }

    ; Ctrl+u clear "search" string ,just like bash
    ; if ErrorLevel = EndKey:u
    ; {
    ;   if (GetKeyState("LControl", "P")=1){
    ;           GoSub, DeleteAllSearchChar
    ;           continue
    ;    }else{
    ;         input=u
    ;     }
    ; }


    ; FIXME: probably other error level cases
    ; should be handled here (interruption?)

    ; invoke digit shortcuts if applicable
    if digitshortcuts <>
;42td: display index (for first ten) also if there are more than 10 windows
;        if numwin <= 10
            if input in 1,2,3,4,5,6,7,8,9,0
            {
                if input = 0
                    input = 10

                if numwin < %input%
                {
                    if nomatchsound <>
                        SoundPlay, %nomatchsound%
                    continue
                }

                 LV_Modify(input, "Select") ;;select line number <input>
                 LV_Modify(input, "Focus") ;; focus line number <input>
;;                GuiControl, choose, ListView1, %input%
                ActivateWindow(0)
                break
            }

    ; process typed character

    search = %search%%input%
    GuiControl,, Edit1, %search%
    GuiControl,Focus,Edit1 ;; focus Edit1 ,
    Send {End} ;;move cursor right ,make it after the new inputed char 
    GoSub, RefreshWindowList
}

Gosub, CleanExit

return

;----------------------------------------------------------------------
;
; Refresh the list of windows according to the search criteria
;
; Sets: numwin  - see the documentation of global variables
;       idarray - see the documentation of global variables
;
RefreshWindowList:
    ; refresh the list of windows if necessary

    OutputDebug % "=== RefreshWindowList ===" ;42td
    if ( dynamicwindowlist = "yes" or numallwin = 0 or tmpRefresh="yes" )
    {
        tmpRefresh=no ;; reset to no 
        numallwin = 0
        windowGroups := windowGroups() ;42td

        WinGet, id, list, , , Program Manager
        Loop, Parse, windowGroups, `f
        {
            windowGroup := A_LoopField ;42td
            OutputDebug % "-- init loop for group " . windowGroup . " --"
            Loop, %id%
            {
                StringTrimRight, this_id, id%a_index%, 0
                WinGetTitle, title, ahk_id %this_id%
                if (windowGroup(this_id, title) != windowGroup) ;42td
                    continue
                OutputDebug % "- window " . winDescr(this_id)

				;42td: moved filtering to function
				if (excludeWindow(this_id, title)) 
					continue

                ; replace pipe (|) characters in the window title,
                ; because Gui Add uses it for separating listbox items
                StringReplace, title, title, |, -, all

                numallwin += 1
                allwinarray%numallwin% = %title%
                allwinidarray%numallwin% = %this_id%
				allWinGroupArray%numallwin% := windowGroup
				OutputDebug % "allwin.." . numallwin . " == " . this_id . " / " . title . " / " . windowGroup
            }
        }
    }

    ; filter the window list according to the search criteria
    winlist =
    numwin = 0
    Loop, %numallwin%
    {
        StringTrimRight, title, allwinarray%a_index%, 0
        StringTrimRight, this_id, allwinidarray%a_index%, 0

        ; don't add the windows not matching the search string
        ; if there is a search string
        if search <>
            if firstlettermatch =
            {
                matched=yes
                procName:=getProcessname(this_id)
                
                titleAndProcName=%title%%procName%
                Loop,parse,search ,%A_Space%,%A_Space%%A_TAB%
                {
                    if titleAndProcName not contains %A_LoopField%,
                    {
                        matched=no
                        break
                    }
                }
                if matched=no
                {
                    continue
                }
            }
            else
            {
                stringlen, search_len, search

                index = 1
                match =

                loop, parse, title, %A_Space%
                {                   
                    stringleft, first_letter, A_LoopField, 1

                    ; only words beginning with an alphanumeric
                    ; character are taken into account
                    if first_letter not in 1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
                        continue

                    stringmid, search_char, search, %index%, 1

                    if first_letter <> %search_char%
                        break

                    index += 1

                    ; no more search characters
                    if index > %search_len%
                    {
                        match = yes
                        break
                    }
                }

                if match =
                    continue    ; no match
            }
        ; end if search <> ""

		if (visibleWindow(this_id)) {
			numwin += 1
			winarray%numwin% = %title%
			OutputDebug % "winarray" . numwin . " == " . title
			idarray%numwin%= %this_id%
			winGroupArray%numwin% := allWinGroupArray%a_index%
			OutputDebug % "winGroupArray" . numwin . " := allWinGroupArray" . a_index . " == " . winGroupArray%numwin%
		}
    }    ; window loop

    ; sort the list alphabetically
    ;;I don't like sort it alphabetically 
    ;;Sort, winlist, D|


    ImageListID1 := IL_Create(numwin,1,1)
    ; Attach the ImageLists to the ListView so that it can later display the icons:
    LV_SetImageList(ImageListID1, 1)
    LV_Delete()
    empty=0
    iconIdArray:=Object()
    iconTitleArray:=Object()
    iconIdNum=0
    OutputDebug % "-- GUI loop --"

	;42td: the row number to select initially (as long as input filter is empty);
	;always the 2nd window in Z-order (which may or may not be row 2).
	;Examples (1a and 1b in same group):
	;Z-order 1a, 2a, 3a -> display order 1a, 2a, 3a; select 2a at row 2
	;Z-order 1a, 2a, 1b -> display order 1a, 1b, 2a; select 2a at row 3
	;Z-order 1a, 1b, 2a -> display order 1a, 1b, 2a; select 1b at row 2
	selectedRowNum := 0

    loop,%numwin%,
    {
        title := winarray%a_index%
        wid := idarray%a_index%
        OutputDebug % "- window " . winDescr(wid)

		if (wid == windowId2) { ;42td
			selectedRowNum := a_index
		}

        Use_Large_Icons_Current =1
        IconNumber := ""
        if(normalWindow(wid)) { ;42td: moved condition to function
			prevIndex := a_index - 1
			skipIcon := a_index > 1 && (winGroupArray%prevIndex% == winGroupArray%a_index%)
            if (skipIcon) { ;42td
                iconTitleArray.Insert(title)
                iconIdArray.Insert(wid)
                IconNumber := IL_Add(ImageListID1, sameGroupIconFile, sameGroupIconNum)
                iconIdNum++
            } else {
            ; WM_GETICON values -    ICON_SMALL =0,   ICON_BIG =1,   ICON_SMALL2 =2
            If Use_Large_Icons_Current =1
            {
                SendMessage, 0x7F, 1, 0,, ahk_id %wid%
                h_icon := ErrorLevel
                OutputDebug % "SendMessage 7F, 1 => h_icon = " . h_icon ;42td
            }
            If ( ! h_icon )
            {
                SendMessage, 0x7F, 2, 0,, ahk_id %wid%
                OutputDebug % "SendMessage 7F, 2 => h_icon = " . h_icon ;42td
                h_icon := ErrorLevel
                If ( ! h_icon )
                {
                    SendMessage, 0x7F, 0, 0,, ahk_id %wid%
                    OutputDebug % "SendMessage 7F, 0 => h_icon = " . h_icon ;42td
                    h_icon := ErrorLevel
                    If ( ! h_icon )
                    {
                        If Use_Large_Icons_Current =1
                            h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 ) ; GCL_HICON is -14
                        OutputDebug % "GetClassLong .., -14 => h_icon = " . h_icon ;42td
                        If ( ! h_icon )
                        {
                            h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 ) ; GCL_HICONSM is -34
                            OutputDebug % "GetClassLong .., -34 => h_icon = " . h_icon ;42td
                            If ( ! h_icon )
                                h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
                            OutputDebug % "GetClassLong .., 32512 => h_icon = " . h_icon ;42td
                        }
                    }
                }
            }
            if (h_icon) {
                iconIdArray.Insert(wid)
                iconTitleArray.Insert(winarray%a_index%)
                iconIdNum+=1
                ; Add the HICON directly to the small-icon and large-icon lists.
                ; Below uses +1 to convert the returned index from zero-based to one-based:
                IconNumber := DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, h_icon) + 1
            }
            }
        } else {
            OutputDebug % "no icon for " . title ;42td
            WinGetClass, Win_Class, ahk_id %wid%
            If Win_Class = #32770 ; fix for displaying control panel related windows (dialog class) that aren't on taskbar
            {
                iconTitleArray.Insert(winarray%a_index%)
                iconIdArray.Insert(wid)
                iconIdNum+=1
;42td                IconNumber := IL_Add(ImageListID1, "C:\WINDOWS\system32\shell32.dll" , 217) ; generic control panel icon
                IconNumber := IL_Add(ImageListID1, "%SystemRoot%\system32\shell32.dll" , 217)
            }
        }
        if (IconNumber != "") { ;42td moved LV_Add from two branches above
            ;42td: display index only for first ten rows
            displayIndex := a_index-empty < 10 ? a_index-empty : a_index-empty == 10 ? 0 : " "
            LV_Add("Icon" . IconNumber, displayIndex, title, getProcessName(wid)) ; spaces added for layout
        } else {
           empty +=1
        }
    } ; window loop

    numwin:=iconIdNum
    for i ,ele in iconIdArray{
        idarray%i%:=ele
        winarray%i%:=iconTitleArray[i]
    }

    ; if the pattern didn't match any window
    if numwin = 0
        ; if the search string is empty then we can't do much
        if search =
        {
            Gui, cancel
            Gosub, CleanExit
        }
        ; delete the last character
        else
        {
            if nomatchsound <>
                SoundPlay, %nomatchsound%

            GoSub, DeleteSearchChar
            return
        }
    if (search != "") ;42td: select 2nd group only initially, not after filtering
    {
        LV_Modify(1, "Select") ;;select the first row
        LV_Modify(1, "Focus") ;; focus the first row
    } else {
        LV_Modify(selectedRowNum, "Select") ;;select the row where the 2nd group starts
        LV_Modify(selectedRowNum, "Focus") ;; focus the 2nd row
    }
    ;;LV_ModifyCol()  ; Auto-size each column to fit its contents.
    LV_ModifyCol(1,48)
    LV_ModifyCol(2,602) ;42td
    LV_ModifyCol(3,150) ;42td
    if numwin = 1
        if autoactivateifonlyone <>
        {
            ActivateWindow(500)
            Gosub, CleanExit
        }
    GoSub ActivateWindowInBackgroundIfEnabled

    completion =

    if tabcompletion =
        return

    ; completion is not implemented for first letter match mode
    if firstlettermatch <>
        return

    ; determine possible completion if there is
    ; a search string and there are more than one
    ; window in the list

    if search =
        return
   
    if numwin = 1
        return
    loop
    {
        nextchar =
        loop, %numwin%
        {
            stringtrimleft, title, winarray%a_index%, 0
            if nextchar =
            {
                substr = %search%%completion%
                stringlen, substr_len, substr
                stringgetpos, pos, title, %substr%

                if pos = -1
                    break

                pos += %substr_len%

                ; if the substring matches the end of the
                ; string then no more characters can be completed
                stringlen, title_len, title
                if pos >= %title_len%
                {
                    pos = -1
                    break
                }

                ; stringmid has different position semantics
                ; than stringgetpos. strange...
                pos += 1
                stringmid, nextchar, title, %pos%, 1
                substr = %substr%%nextchar%
            }
            else
            {
                stringgetpos, pos, title, %substr%
                if pos = -1
                    break
            }
        }

        if pos = -1
            break
        else
            completion = %completion%%nextchar%
    }

    if completion <>
    {
        GuiControl,Focus,Edit1 ;; focus Edit1 ,
        GuiControl,, Edit1, %search%[%completion%]
        StringLen ,searchStrLen,search
        ;; Send {Right}
        Send {Home} ;;
        Send {Right %searchStrLen%} ;;move right ,
        ToolTip,You can press <Tab> now `,if you set tabcompletion =yes ,0,-30
        SetTimer, RemoveToolTip, 3000
    }
return

;----------------------------------------------------------------------
;
; Delete last search char and update the window list
;
DeleteSearchChar:
if search =
{
    GuiControl,, Edit1, 
    return
}
StringTrimRight, search, search, 1
GuiControl,, Edit1, %search%
GuiControl,Focus,Edit1 ;; focus Edit1 ,
Send {End} ;;move cursor end 

GoSub, RefreshWindowList
return
;------------------------------------------------------------------
DeleteSearchWord: ;;delete last word of search string ,search string
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
}else{
  search=
  GuiControl,,Edit1,
}
  GuiControl,Focus,Edit1 ;; focus Edit1 ,
  Send {End}
  GoSub, RefreshWindowList
return
;---------------------------------------------------------------------
DeleteAllSearchChar:

GuiControl,, Edit1, 
if search =
    return
search=    
GoSub, RefreshWindowList
return
;----------------------------------------------------------------------
;42td: Checks whether a window type is relevant for the list.
;This does not include filtering by config or input, only whether it is a normal window which can be focused.
;(Moved from condition in GUI loop whether it's a control panel window) || normalWindow(wid)
visibleWindow(wid) {
	WinGetClass, c, ahk_id %wid%
	r := c == "#32770" || normalWindow(wid)
	OutputDebug % "visibleWindow(" . wid . ") == " . r
	return r
}
;----------------------------------------------------------------------
normalWindow(wid) { ;42td: Moved from condition in GUI loop whether it's a window for which the icon lookup works
	WS_EX_APPWINDOW = 0x40000
	WS_EX_TOOLWINDOW = 0x80
	GW_OWNER = 4
	WinGet, es, ExStyle, ahk_id %wid%
	r := ( es & WS_EX_APPWINDOW ) || ( ! DllCall( "GetWindow", "uint", wid, "uint", GW_OWNER ) && ! ( es & WS_EX_TOOLWINDOW ) )
	OutputDebug % "normalWindow(" . wid . ") == " . r
	return r
}
;----------------------------------------------------------------------
excludeWindow(winId, title) {
	result := excludeWindowImpl(winId, title)
	OutputDebug % "excludeWindow(" . winId . ", " . title . ") == " . result
	return result
}

excludeWindowImpl(winId, title) {
	global
;	OutputDebug % "in excludeWindowImpl: switcher_id == " . switcher_id . ", filterlist == " . filterlist . ", filters1 == " . filters1

	; FIXME: windows with empty titles?
	if title =
		return true

	; don't add the switcher window
	if switcher_id = %winId%
		return true


	; don't add titles which match any of the filters
	if filterlist <>
	{
		loop
		{
			stringtrimright, filter, filters%a_index%, 0
;			OutputDebug % "filter == """ . filter . """"
			if filter =
				return false
			else
				ifinstring, title, %filter%
				{
				   return true
				}
		}
	}
	return false
}
;----------------------------------------------------------------------
;
; Activate selected window
;
ActivateWindow(delay) {
Sleep %delay% ;42td: pause to avoid accidental input to selected window
Gui, submit
rowNum:= LV_GetNext(0)
stringtrimleft, window_id, idarray%rowNum%, 0
  IL_Destroy(ImageListID1) ; destroy gui, listview and associated icon imagelist.
  LV_Delete()
WinActivate, ahk_id %window_id%
}

;-------------------------------------------
;Kill the window you selected
KillSelectedWindow:
Gui, submit,NoHide 
rowNum:= LV_GetNext(0)
stringtrimleft, window_id, idarray%rowNum%, 0
WinClose, ahk_id %window_id%
return

;-------------------------------------------
; force kill the window you selected 
ForceKillSelectedWindow:
Gui, submit,NoHide 
rowNum:= LV_GetNext(0)
stringtrimleft, window_id, idarray%rowNum%, 0
WinGet, pid, PId, ahk_id %window_id%
Process ,Close, %pid%
send {escape}
return

;----------------------------------------------------------------------
;
; Activate selected window in the background
;
ActivateWindowInBackground:
  index:=LV_GetNext(0)
  stringtrimleft, window_id, idarray%index%, 0
   
   if prev_active_id <> %window_id%
   {
       WinActivate, ahk_id %window_id%
       WinActivate, ahk_id %switcher_id%
       prev_active_id = %window_id%
   }
return

;----------------------------------------------------------------------
;
; Activate selected window in the background if the option is enabled.
; If an activation delay is set then a timer is started instead of
; activating the window immediately.
;
ActivateWindowInBackgroundIfEnabled:

if activateselectioninbg =
    return

; Don't do it just after the switcher is activated. It is confusing
; if active window is changed immediately.
WinGet, id, ID, ahk_id %switcher_id%
if id =
    return

if bgactivationdelay =
    GoSub ActivateWindowInBackground
else
    settimer, BgActivationTimer, %bgactivationdelay%

return

;----------------------------------------------------------------------
;
; Check if the user is idle and if so activate the currently selected
; window in the background
;
BgActivationTimer:

settimer, BgActivationTimer, off

GoSub ActivateWindowInBackground

return

;----------------------------------------------------------------------
;
; Stop background window activation timer if necessary and exit
;
CleanExit:

settimer, BgActivationTimer, off

exit

;----------------------------------------------------------------------
;
; Cancel keyboard input if GUI is closed.
;
GuiClose:

send, {esc}

return

;----------------------------------------------------------------------
;
; Handle mouse click events on the list box
;
ListViewClick:
if (A_GuiControlEvent = "Normal"
    and !GetKeyState("Down", "P") and !GetKeyState("Up", "P"))

;;    ActivateWindow(0)
send ,{enter}
;;    GoSub, BgActivationTimer
return

;----------------------------------------------------------------------
;
; Move switcher window horizontally
;
; Input: direction - 1 for right, -1 for left
;
MoveSwitcher:

direction *= 100
WinGetPos, x, y, width, , ahk_id %switcher_id%
x += %direction%

if x < 0
    x = 0
else
{
   SysGet screensize, MonitorWorkArea
   screensizeRight -= %width%
   if x > %screensizeRight%
      x = %screensizeRight%
}

prevdelay = %A_WinDelay%
SetWinDelay, -1
WinMove, ahk_id %switcher_id%, , %x%, %y%
SetWinDelay, %prevdelay%

return

;----------------------------------------------------------------------
;
; Close the switcher window if the user activated an other window
;
CloseIfInactive:

ifwinnotactive, ahk_id %switcher_id%
    send, {esc}

return
;----------------------------------------------------------------------
RemoveToolTip:
  SetTimer, RemoveToolTip, Off
  ToolTip
return
;----------------------------------------------------------------------
;42td: SelectNext and SelectPrevious joined into one function;
;move by one group instead of by one row
MoveSelectionByGroup(direction, sameGroup) {
	global
	local rowNum := LV_GetNext(0)
	local startGroup := winGroupArray%rowNum%
	OutputDebug % "MoveSelectionByGroup(" . direction . ") started at " . rowNum . " / " . startGroup

	Loop {
		rowNum := mod1(rowNum + direction, numwin)
		local group := winGroupArray%rowNum%
		OutputDebug % "rowNum == " . rowNum . ", group == """ . group . """"
		local currSameGroup := (group == startGroup)
		if (currSameGroup == sameGroup) {
			break
		}
	}

	LV_Modify(rowNum, "Select") ;;select next line
	LV_Modify(rowNum, "Focus") ;; focus next line

	GoSuB ActivateWindowInBackgroundIfEnabled
}
SelectNext() {
	MoveSelectionByGroup(1, false)
}
SelectPrevious() {
	MoveSelectionByGroup(-1, false)
	MoveSelectionByGroup(1, true)
}
SelectNextInGroup() {
	MoveSelectionByGroup(1, true)
}
;-------------------------------------------------------------------------
;42td: "1-based modulo"
mod1(dividend, divisor) {
	return mod(dividend - 1, divisor) + 1
}
;-------------------------------------------------------------------------
CancelSwitch:
        Gui, cancel

        ; restore the originally active window if
        ; activateselectioninbg is enabled
        if activateselectioninbg <>
            WinActivate, ahk_id %orig_active_id%
return
;---------------------------------------------------------------------------
getProcessname(wid){
       ; show process name if enabled
           WinGet, procname, ProcessName, ahk_id %wid%
           stringgetpos, pos, procname, .
           if ErrorLevel <> 1
           {
               stringleft, procname, procname, %pos%
           }
    ;;       stringupper, procname, procname
    return procname
}
;----------------------------------------------------------------------------
toggleWinStatus:
    rowNum:= LV_GetNext(0)
    stringtrimleft, window_id, idarray%rowNum%, 0
       WinGet,wstatus,MinMax,ahk_id %window_id%
      if (wstatus=1){ ;;maximized ,
         WinRestore ,ahk_id %window_id% 
      }else if (wstatus=-1){ ;;minimized 
         WinMaximize , ahk_id %window_id% 
      }else{
         WinMinimize , ahk_id %window_id% 
      }
return 
;----------------------------------------------------------------------------
listContains(byref list, elem, sep = "`f") { ;42td
    return InStr(sep . list . sep, sep . elem . sep, true) > 0
}
;----------------------------------------------------------------------------
listAdd(byref list, byref elem, duplicates = true, sep = "`f") { ;42td
    if (duplicates || !listContains(list, elem, sep)) {
        if (list != "") {
            list .= sep
        }
        list .= elem
        return true
    } else {
       return false
    }
}
;----------------------------------------------------------------------------
windowGroup(windowId, title = "", windowClass = "", pid = "", processName = "") { ;42td
    if (title == "")
        WinGetTitle, title, ahk_id %windowId%
    if (windowClass == "")
        WinGetClass windowClass, ahk_id %windowId%
    if (pid == "")
        WinGet, pid, PID, ahk_id %windowId%
    if (processName == "")
        processName := getProcessname(windowId)
    r := windowGroupConf(windowId, title, windowClass, pid, processName)
    OutputDebug % "windowGroupConf(..) == """ . r . """ for params (" . windowId . ", """ . title . """, """ . windowClass . """, " . pid . ", """ . processName . """)"
    return r
}
;----------------------------------------------------------------------------
; The -> windowGroup()s of all existing windows in Z-order (topmost Z-order of
; each group counts).
windowGroups() { ; 42td
	OutputDebug % "=== windowGroups() ==="
;	global currentWindowGroup := ""
	global windowId2 := "" ;ID of 2nd visible window in Z-order
	WinGet, winIds, list, , , Program Manager
	windowGroups := ""
	Loop, %winIds% {
		winId := winIds%A_Index%
		if (visibleWindow(winId)) {
			WinGetTitle, title, ahk_id %winId%
			if (!excludeWindow(winId, title)) {
				g := windowGroup(winId)
;				if (currentWindowGroup == "") {
;					currentWindowGroup := g
;				}
				listAdd(windowGroups, g, false)

				if (windowId2 == "") { ;at 1st visible window
					windowId2 := "-"
				} else if (windowId2 == "-") { ;at 2nd visible window
					windowId2 := winId
					OutputDebug % "windowId2 == " . windowId2
				}
			}
		}
	}
	OutputDebug % "windowGroups() == """ . windowGroups . """"
	return windowGroups
}
;----------------------------------------------------------------------------
; Focuses the next window of the active window's group (as defined by function
; windowGroup).
; 
; Example: Current window Z-order: A12BC3D456
; (window A active; windows B, C, D in same group as A; windows 1 to 6 not in
; same group)
; 
; Discarded strategies (involving Z-order):
; - Simply focusing B (=> BA12C3D456; next invocation => AB12C3D456); this
;   does not cycle, just toggles between two.
; - WinActivateBottom style (DA12BC3456; then CDA12B3456) is a little
;   counter-intuitive.
; - Desired resulting Z-order:     B12C3DA456
;   (ABCD cycled to BCDA; others unaffected; A as early as possible (i.e.
;   directly after D, so it stays before desktop gadgets, for example)
;   Disadvantage: A can be hidden by related and unrelated windows.
;   Implementation: Send A, 4, 5, 6 to bottom Z-order, then focus B.
; - Desired resulting Z-order:     BCDA123456
;   (ABCD cycled to BCDA; placed before others to maximize the chance that A
;   stays visible.
;   Disadvantage: A can still be hidden by related windows.
;   Implementation: Send A, 1, ..., 6 to bottom Z-order, then focus B.
;
; Chosen strategie (instead of Z-order):
; Windows should have a fixed straightforward order. Threrefore, use process
; start time (plus window ID for the case where windows belong to the same
; process).
cycleCurrentWindowGroup(forward = true, beyondActiveOnly = true) { ;42td
	global listSeparator
	global cycleTooltipDuration
    OutputDebug % "=== cycleCurrentWindowGroup(" . forward . ", " . beyondActiveOnly . ") ==="
	WinGet, activeWinId, ID, A
    activeGroup := windowGroup(activeWinId)
	activeStartTime := windowStartTime(activeWinId) . "_" . activeWinId
	nextStartTime := ""
	nextWinId := ""
	tooltipText := ""

    WinGet, winIds, list, , , Program Manager
    Loop, %winIds% {
        winId := winIds%A_Index%
        OutputDebug % "winIds[" . A_Index . "] == " . winDescr(winId)
        if (activeGroup == windowGroup(winId) && visibleWindow(winId)) {
			startTime := windowStartTime(winId) . "_" . winId
			if (cycleTooltipDuration > 0) {
				WinGetTitle, title, ahk_id %winId%
				title := RegExReplace(title, "\s+$", "")
				tooltipText .= "`n" . startTime . "`t" . title
			}
			if (winId == activeWinId)
				continue
			if ((!beyondActiveOnly) || ((startTime > activeStartTime) == forward)) {
				if (nextStartTime == "" || ((startTime < nextStartTime) == forward)) {
					; first or startTime < nextStartTime, i.e. startTime is new best (minimum) (for forward)
					nextStartTime := startTime
					nextWinId := winId
				}
			}
        }
    }
	if (nextWinId != "") {
		WinActivate, ahk_id %nextWinId%
		if (cycleTooltipDuration > 0) {
			OutputDebug % "tooltipText = """ . tooltipText . """"
			showCycleWGTooltip(tooltipText, nextWinId)
		}
	} else if (beyondActiveOnly) { ;overflow to first (forward == true) or last (forward == false) window in group
		cycleCurrentWindowGroup(forward, false)
	}
}

;----------------------------------------------------------------------------
showCycleWGTooltip(tooltipText, highlightWinId) { ;42td
	global cycleTooltipDuration
	Sort, tooltipText
	tooltipText := RegExReplace(tooltipText, "\n[^\n\t]*" . highlightWinId . "\t", "`n> ")
	OutputDebug % "tooltipText [2] = """ . tooltipText . """"
	tooltipText := RegExReplace(tooltipText, "\n[^\n\t]*\t", "`n:   ")
	OutputDebug % "tooltipText [3] = """ . tooltipText . """"
	tooltipText := SubStr(tooltipText, 2)	;remove leading linefeed
	WinGetPos, , , windowWidth, , A
	ToolTip, %tooltipText%, 0, 0, 7	;show briefly to determine size
	WinGetPos,,,tooltipWidth,,ahk_class tooltips_class32
	ToolTip,,,,7	;hide immediately
	x := tooltipWidth > windowWidth ? 0 : (windowWidth - tooltipWidth)
	ToolTip, %tooltipText%, x, 0, 7
	SetTimer, RemoveCycleWGTooltip, %cycleTooltipDuration%
}
RemoveCycleWGTooltip:
	SetTimer, RemoveCycleWGTooltip, Off
	ToolTip,,,,7
	return
;----------------------------------------------------------------------------
winSetZOrderBottom(winId) { ;42td
    OutputDebug % "Sending !Esc to " . winDescr(winId)
;    ControlSend,,!{Esc},ahk_id %winId%
;    WinActivate, ahk_id %winId%
;    Send !{Esc}
    WinSet, Bottom,, ahk_id %winId%
    outputDebugWindowZOrder()
}
;----------------------------------------------------------------------------
outputDebugWindowZOrder() { ;42td
    WinGet, winIds, list, , , Program Manager
    winIdsStr := ""
    Loop, %winIds% {
        listAdd(winIdsStr, winIds%A_Index%, true, " ")
    }
    OutputDebug % "window order: " . winIdsStr
}
;----------------------------------------------------------------------------
winDescr(winId) { ;42td
    WinGetTitle, t, ahk_id %winId%
    return winId . "`t[" . getProcessname(winId) . " / """ . t . """]"
}
;----------------------------------------------------------------------------
;42td
;http://www.autohotkey.com/board/topic/88406-windows-task-info-is-start-time-available-for-ahk-script/#entry560785
windowStartTime(winId) {
	global
	if (!windowStartTime%winId%) {
		WinGet, pid, PID, ahk_id %winId%
		query := "Select * from Win32_Process Where processID = " . pid
		for result in ComObjGet("winmgmts:").ExecQuery(query) {	
			OutputDebug % "Win32_Process result: " . result . ", " . result.processID . ", " . result.creationDate
			windowStartTime%winId% := result.creationDate
			break
		}
	}
	OutputDebug % "windowStartTime(" . winDescr(winId) . ") == " . windowStartTime%winId%
	return windowStartTime%winId%
}