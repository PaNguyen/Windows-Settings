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



RefreshWindowList(searchLocal)
{
OutputDebug, %searchLocal%
        ; refresh the list of windows if necessary
        ; if ( dynamicwindowlist = "yes" or numallwin = 0 or tmpRefresh="yes" )
        ; {
                tmpRefresh=no ;; reset to no 
                numallwin = 0

                WinGet, id, list, , , Program Manager

                Loop, %id%
                {
                        StringTrimRight, this_id, id%a_index%, 0
                        WinGetTitle, title, ahk_id %this_id%

                        ; FIXME: windows with empty titles?
                        if title =
                                continue

                        ; don't add the switcher window
                        if switcher_id = %this_id%
                                continue


                        ; don't add titles which match any of the filters
                        if filterlist <>
                        {
                                filtered =
                                loop
                                {
                                        stringtrimright, filter, filters%a_index%, 0
                                        if filter =
                                        {
                                                break
                                        }
                                        else
                                        {
                                                ifinstring, title, %filter%
                                                {
                                                        filtered = yes
                                                        break
                                                }
                                        }
                                }

                                if filtered = yes
                                        continue
                        }

                        ; replace pipe (|) characters in the window title,
                        ; because Gui Add uses it for separating listbox items
                        StringReplace, title, title, |, -, all

                        numallwin += 1
                        allwinarray%numallwin% = %title%
                        allwinidarray%numallwin% = %this_id%
                }
        ; }
OutputDebug, %numallwin%

        ; filter the window list according to the search criteria
        winlist =
        numwin = 0
        Loop, %numallwin%
        {
                StringTrimRight, title, allwinarray%a_index%, 0
                StringTrimRight, this_id, allwinidarray%a_index%, 0

                ; don't add the windows not matching the search string
                ; if there is a search string
                if searchLocal <>
                {
                        if firstlettermatch =
                        {
                                matched=yes
                                procName:=getProcessname(this_id)

                                titleAndProcName=%title%%procName%
                                ;OutputDebug, search2=%search%
                                Loop,parse,searchLocal ,%A_Space%,%A_Space%%A_TAB%
                                {
                                        ;OutputDebug, search3=%search%
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
                                stringlen, search_len, searchLocal
                                ;OutputDebug, search4=%search%

                                index = 1
                                match =

                                loop, parse, title, %A_Space%
                                {                   
                                stringleft, first_letter, A_LoopField, 1

                                ; only words beginning with an alphanumeric
                                ; character are taken into account
                                if first_letter not in 1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
                                        continue

                                stringmid, search_char, searchLocal, %index%, 1
                                ;OutputDebug, search5=%search%


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
                }
                numwin += 1
                winarray%numwin% = %title%
                idarray%numwin%= %this_id%
        }
        OutputDebug, %numwin%
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
        loop,%numwin%,
        {
OutputDebug, % "In loop"
                ele:=winarray%a_index%
                wid := idarray%a_index%
                WinGet, es, ExStyle, ahk_id %wid%
                Use_Large_Icons_Current =1
                ; if( ( ! DllCall( "GetWindow", "uint", wid, "uint", GW_OWNER ) and  ! ( es & WS_EX_TOOLWINDOW ) )
                        ; or ( es & WS_EX_APPWINDOW ) )
                ; {
                        ; WM_GETICON values -    ICON_SMALL =0,   ICON_BIG =1,   ICON_SMALL2 =2
                        If Use_Large_Icons_Current =1
                        {
                                SendMessage, 0x7F, 1, 0,, ahk_id %wid%
                                h_icon := ErrorLevel
                        }
                        If ( ! h_icon )
                        {
                                SendMessage, 0x7F, 2, 0,, ahk_id %wid%
                                h_icon := ErrorLevel
                                If ( ! h_icon )
                                {
                                        SendMessage, 0x7F, 0, 0,, ahk_id %wid%
                                        h_icon := ErrorLevel
                                        If ( ! h_icon )
                                        {
                                                If Use_Large_Icons_Current =1
                                                        h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 ) ; GCL_HICON is -14
                                                If ( ! h_icon )
                                                {
                                                        h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 ) ; GCL_HICONSM is -34
                                                        If ( ! h_icon )
                                                                h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
                                                }
                                        }
                                }
                        }
                        if (h_icon)
                        {
OutputDebug, here
                                iconIdArray.Insert(wid)
                                iconTitleArray.Insert(winarray%a_index%)
                                iconIdNum+=1
                                ; Add the HICON directly to the small-icon and large-icon lists.
                                ; Below uses +1 to convert the returned index from zero-based to one-based:
                                IconNumber := DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, h_icon) + 1
                                LV_Add("Icon" . IconNumber, a_index-empty,ele, getProcessName(wid)) ; spaces added for layout
                                }else{
OutputDebug, empty
                                empty +=1
                        }
                ; }
                ; else
                ; {
                ;         WinGetClass, Win_Class, ahk_id %wid%
                ;         If Win_Class = #32770 ; fix for displaying control panel related windows (dialog class) that aren't on taskbar
                ;         {
                ;                 iconTitleArray.Insert(winarray%a_index%)
                ;                 iconIdArray.Insert(wid)
                ;                 iconIdNum+=1
                ;                 IconNumber := IL_Add(ImageListID1, "C:\WINDOWS\system32\shell32.dll" , 217) ; generic control panel icon
                ;                 LV_Add("Icon" . IconNumber,a_index-empty ,ele,getProcessName(wid))
                ;         }else
                ;         {
                ;                 empty +=1
                ;         }
                ; }
        }

        numwin:=iconIdNum
        for i ,ele in iconIdArray{
                idarray%i%:=ele
                winarray%i%:=iconTitleArray[i]
        }

        if numwin >1
        {
                LV_Modify(2, "Select") ;;select the first row
                LV_Modify(2, "Focus") ;; focus the first row
                }else{
                        LV_Modify(1, "Select") ;;select the secnd row
                        LV_Modify(1, "Focus") ;; focus the second row
                }
                ;;LV_ModifyCol()  ; Auto-size each column to fit its contents.
                LV_ModifyCol(1,48)
                LV_ModifyCol(2,652)
                LV_ModifyCol(3,100)
                if numwin = 1
                        if autoactivateifonlyone <>
                {
                        GoSub, ActivateWindow
                        Gosub, CleanExit
                }
                return
}

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
ActivateWindow:
        Gui, submit
        rowNum:= LV_GetNext(0)
        stringtrimleft, window_id, idarray%rowNum%, 0
        IL_Destroy(ImageListID1) ; destroy gui, listview and associated icon imagelist.
        LV_Delete()
        WinActivate, ahk_id %window_id%

        return
CleanExit:

        ; settimer, BgActivationTimer, off
        exit


F6::
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
RefreshWindowList("")
return

ListViewClick:
        if (A_GuiControlEvent = "Normal"
                and !GetKeyState("Down", "P") and !GetKeyState("Up", "P"))
        {
                ;;    GoSub, ActivateWindow
                send ,{enter}
                ;;    GoSub, BgActivationTimer
        }
        return
    