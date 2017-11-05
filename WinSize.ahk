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
    Suspend , on
}
ReSizeWin(direction)
{
    GetKeyState, Cdown, Control, P
    if Cdown = D
    {
        WinGet, active_ID, ID, A
        winID := GetMonitorNoOfWindow(active_ID)  ;获取当前显示器ID
        SysGet, MonitorWorkArea, MonitorWorkArea, %winID%
        k := 7 * (A_ScreenDPI/96)
        Xadd := (MonitorWorkAreaRight - MonitorWorkAreaLeft)/20
        Yadd := (MonitorWorkAreaBottom - MonitorWorkAreaTop)/20
        WinGetPos, X, Y, W, H, ahk_id %active_ID%
        if(direction == "l")
        {
            if(X >= MonitorWorkAreaLeft + Xadd){
                TX := X - Xadd
                TW := W + Xadd
            }
            else if(X <= MonitorWorkAreaLeft + (k+1) && X >= MonitorWorkAreaLeft - (k+1))
            {
                TX := MonitorWorkAreaLeft - k
                TW := W + X - TX - Xadd
            }
            else
            {
                TX := MonitorWorkAreaLeft - k
                TW := W + X - TX
            }
        }
        else if(direction == "r")
        {
            if(MonitorWorkAreaRight - X - W + 2*(k+1) >= Xadd){
                TW := W + Xadd
            }
            else if(X + W <= MonitorWorkAreaRight + 2*(k+1) && X + W >= MonitorWorkAreaRight - (k+1))
            {
                TX := X + Xadd
                TW := MonitorWorkAreaRight - TX + 2*k
            }
            else
            {
                TW := MonitorWorkAreaRight - X + 2*k
            }
        }
        else if(direction == "u")
        {
            if(Y >= MonitorWorkAreaTop + Yadd){
                TY := Y - Yadd
                TH := H + Yadd
            }
            else if(Y <= MonitorWorkAreaTop + (k+1) && Y >= MonitorWorkAreaTop - (k+1))
            {
                TY := MonitorWorkAreaTop - k
                TH := H + Y - TY - Yadd
            }
            else
            {
                TY := MonitorWorkAreaTop - k
                TH := H + Y - TY
            }
        }
        else if(direction == "d")
        {
            if(MonitorWorkAreaBottom - Y - H + 2*(k+1) >= Yadd){
                TH := H + Yadd
            }
            else if(Y + H <= MonitorWorkAreaBottom + 2*(k+1) && Y + H >= MonitorWorkAreaBottom - (k+1))
            {
                TY := Y + Yadd
                TH := MonitorWorkAreaBottom - TY + 2*k
            }
            else
            {
                TH := MonitorWorkAreaBottom - Y + 2*k
            }
        }
        WinMove, ahk_id %active_ID%, , %TX%, %TY%, %TW%, %TH%
    }
}
Alt & LWin::
    Suspend
    ;  Mode := 0
    return
Esc::
    Suspend, on
    return

; TL
q::
    SizeWin(0, 0, 50, 50)
    return
; TC
w::
    SizeWin(0, 0, 100, 50)
    return
; TR
e::
    SizeWin(50, 0, 50, 50)
    return

; CL
a::
    SizeWin(0, 0, 50, 100)
    return
; CC
s::
    SizeWin(8, 8, 84, 84)
    return
; CR
d::
    SizeWin(50, 0, 50, 100)
    return

; BL
z::
    SizeWin(0, 50, 50, 50)
    return
; BC
x::
    SizeWin(0, 50, 100, 50)
    return
; BR
c::
    SizeWin(50, 50, 50, 50)
    return

1::
    SizeWin(45, 45, 10, 10)
    return
2::
    SizeWin(40, 40, 20, 20)
    return
3::
    SizeWin(35, 35, 30, 30)
    return
4::
    SizeWin(30, 30, 40 ,40)
    return
5::
    SizeWin(25, 25, 50, 50)
    return
6::
    SizeWin(20, 20, 60, 60)
    return
7::
    SizeWin(15, 15, 70, 70)
    return
8::
    SizeWin(10, 10, 80, 80)
    return
9::
    SizeWin(5, 5, 90, 90)
    return
0::
    SizeWin(0, 0, 100, 100)
    WinMaximize, A
    Suspend , on
    return
-::
    WinMinimize, A
    Suspend , on
    return
t::
    WinSet, Style, ^0xC00000, A
    Suspend , on
    return
p::
    WinSet, AlwaysOnTop, toggle, A
    Suspend , on
    return
u::
    ReSizeWin("u")
    return
j::
    ReSizeWin("d")
    return
h::
    ReSizeWin("l")
    return
k::
    ReSizeWin("r")
    return
*Control UP::
    Suspend, on
    return