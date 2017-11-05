Suspend , on
GetMonitorNoOfWindow(active_ID)
{
	;Get Center point of The Window
	WinGetPos, WinXPos, WinYPos, WinWidth, WinHeight, ahk_id %active_ID%
	WinCenterXPos := WinXPos + WinWidth/2
	WinCenterYPos := WinYPos + WinHeight/2

	;Parameters of Monitors
	SysGet, MonitorCount, MonitorCount
	;MonitorNoOfWindow = 1
	Loop, %MonitorCount%
	{
		SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
		;MsgBox, Monitor:`t#%A_Index%`nName:`t%MonitorName%`nLeft:`t%MonitorLeft% (%MonitorWorkAreaLeft% work)`nTop:`t%MonitorTop% (%MonitorWorkAreaTop% work)`nRight:`t%MonitorRight% (%MonitorWorkAreaRight% work)`nBottom:`t%MonitorBottom% (%MonitorWorkAreaBottom% work)
		If (MonitorWorkAreaLeft < WinCenterXPos) and (WinCenterXPos < MonitorWorkAreaRight)
		{
			If (MonitorWorkAreaTop < WinCenterYPos)and(WinCenterYPos < MonitorWorkAreaBottom)
			{
				Return A_Index
				break
			}
		}
	}
}
SizeWin(x,y,w,h)
{
    WinGet, active_ID, ID, A
    WinRestore, ahk_id %active_ID%
    ;  WinMaximize, ahk_id %active_ID%
    winID := GetMonitorNoOfWindow(active_ID)  ;获取当前显示器ID
    SysGet, MonitorWorkArea, MonitorWorkArea, %winID%
    k := 8 * (A_ScreenDPI/96)
    TX := MonitorWorkAreaLeft + x * (MonitorWorkAreaRight - MonitorWorkAreaLeft)/100 - k
    TY := MonitorWorkAreaTop + y * (MonitorWorkAreaBottom - MonitorWorkAreaTop)/100 - K
    TW := w * (MonitorWorkAreaRight - MonitorWorkAreaLeft)/100 + 2 * k
    TH := h * (MonitorWorkAreaBottom - MonitorWorkAreaTop)/100 + 2 * k
    WinMove, ahk_id %active_ID%, , %TX%, %TY%, %TW%, %TH%
}
ReSizeWin(direction,is_add)
{
	WinGet, active_ID, ID, A
	winID := GetMonitorNoOfWindow(active_ID)  ;获取当前显示器ID
	SysGet, MonitorWorkArea, MonitorWorkArea, %winID%
	k := 8 * (A_ScreenDPI/96)
	Xadd := (MonitorWorkAreaRight - MonitorWorkAreaLeft)/20
	Yadd := (MonitorWorkAreaBottom - MonitorWorkAreaTop)/20
	WinGetPos, X, Y, W, H, ahk_id %active_ID%
	TX := X
	TY := Y
	TW := W
	TH := H
	if(direction == "t"){
		if(is_add){
			if(Y-MonitorWorkAreaTop+k>=Yadd){
				TY := Y-Yadd
				TH := H+Yadd
			}else{
				TY := MonitorWorkAreaTop-k
				TH := H+Y-MonitorWorkAreaTop+k
			}
		}else{
			if(H>=3*Yadd+2*k){
				TY := Y+Yadd
				TH := H-Yadd
			}
		}
	}else if(direction == "l"){
		if(is_add){
			if(X-MonitorWorkAreaLeft+k>=Xadd){
				TX := X-Xadd
				TW := TW+Xadd
			}else{
				TX := MonitorWorkAreaLeft-k
				TW := W+X-MonitorWorkAreaLeft+k
			}
		}else{
			if(W>=3*Xadd+2*k){
				TX := X+Xadd
				TW := W-Xadd
			}
		}
	}else if(direction == "r"){
		if(is_add){
			if(MonitorWorkAreaRight+k-X-W>=Xadd){
				TW := TW+Xadd
			}else{
				TW := MonitorWorkAreaRight+k-X
			}
		}else{
			if(W>=3*Xadd+2*k){
				TW := W-Xadd
			}
		}
	}else if(direction == "b"){
		if(is_add){
			if(MonitorWorkAreaBottom+k-Y-H>=Yadd){
				TH := H+Yadd
			}else{
				TH := MonitorWorkAreaBottom+k-Y
			}
		}else{
			if(H>=3*Yadd+2*k){
				TH := H-Yadd
			}
		}
	}

	WinMove, ahk_id %active_ID%, , %TX%, %TY%, %TW%, %TH%
}
LAlt & Numpad0::
LAlt & NumpadIns::
RAlt & \::
    Suspend
    return
*Esc::
    Suspend, on
    return

; TL
Numpad7::
NumpadHome::
q::
    SizeWin(0, 0, 50, 50)
    return
; TC
Numpad8::
NumpadUp::
w::
    SizeWin(0, 0, 100, 50)
    return
; TR
Numpad9::
NumpadPgUp::
e::
    SizeWin(50, 0, 50, 50)
    return

; CL
Numpad4::
NumpadLeft::
a::
    SizeWin(0, 0, 50, 100)
    return
; CC
Numpad5::
NumpadClear::
s::
    SizeWin(8, 8, 84, 84)
    return
; CR
Numpad6::
NumpadRight::
d::
    SizeWin(50, 0, 50, 100)
    return

; BL
Numpad1::
NumpadEnd::
z::
    SizeWin(0, 50, 50, 50)
    return
; BC
Numpad2::
NumpadDown::
x::
    SizeWin(0, 50, 100, 50)
    return
; BR
Numpad3::
NumpadPgDn::
c::
    SizeWin(50, 50, 50, 50)
    return

^Numpad1::
^NumpadEnd::
1::
    SizeWin(45, 45, 10, 10)
    return
^Numpad2::
^NumpadDown::
2::
    SizeWin(40, 40, 20, 20)
    return
^Numpad3::
^NumpadPgDn::
3::
    SizeWin(35, 35, 30, 30)
    return
^Numpad4::
^NumpadLeft::
4::
    SizeWin(30, 30, 40 ,40)
    return
^Numpad5::
^NumpadClear::
5::
    SizeWin(25, 25, 50, 50)
    return
^Numpad6::
^NumpadRight::
6::
    SizeWin(20, 20, 60, 60)
    return
^Numpad7::
^NumpadHome::
7::
    SizeWin(15, 15, 70, 70)
    return
^Numpad8::
^NumpadUp::
8::
    SizeWin(10, 10, 80, 80)
    return
^Numpad9::
^NumpadPgUp::
9::
    SizeWin(5, 5, 90, 90)
    return
^NumpadSub::
-::
    WinSet, Style, ^0xC00000, A
    return
^NumpadAdd::
=::
    WinSet, AlwaysOnTop, toggle, A
    return

w & WheelUp::
    ReSizeWin("t",True)
    return
w & WheelDown::
    ReSizeWin("t",False)
    return

a & WheelUp::
    ReSizeWin("l",True)
    return
a & WheelDown::
    ReSizeWin("l",False)
    return

d & WheelUp::
    ReSizeWin("r",True)
    return
d & WheelDown::
    ReSizeWin("r",False)
    return

x & WheelUp::
    ReSizeWin("b",True)
    return
x & WheelDown::
    ReSizeWin("b",False)
    return