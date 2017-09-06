F1::
SysGet, Mon1, Monitor, 1
horz := Mon1Left + (Mon1Right - Mon1Left)/2
vert := Mon1Top + (Mon1Bottom - Mon1Top)/2
CoordMode, Mouse, Screen
MouseMove, horz, vert
return

F2::
SysGet, Mon, Monitor, 2
horz := MonLeft + (MonRight - MonLeft)/2
vert := MonTop + (MonBottom - MonTop)/2
CoordMode, Mouse, Screen
MouseMove, horz, vert
return 

F3::
SysGet, Mon, Monitor, 3
horz := MonLeft + (MonRight - MonLeft)/2
vert := MonTop + (MonBottom - MonTop)/2
CoordMode, Mouse, Screen
MouseMove, horz, vert
return