#NoEnv
;;#NoTrayIcon
#SingleInstance Ignore
;;agent version
VERSION = V55
RUNSTATUS=0
;;
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1
CoordMode, Pixel, Screen
DN = %A_ScriptDir%\ENV
if( not FileExist(DN)){
    FileCreateDir , DN
}
INIFILE=%DN%\KrsysMiner.ini
LOGFILE=%DN%\result.txt
CFGFILE=%DN%\config.bat
README=%DN%\readme.text

if( NOT FileExist(INIFILE) ){
    f:=FileOpen(INIFILE,"w")
    f.Close()
}
;;Clear Log File
f:=FileOpen(LOGFILE,"w")
f.Close()



;;
opt := GetAddressList()
;; UI design
Gui, New, hwndhGui AlwaysOnTop MinSize
Gui, Add, Text,, KrSys Miner UI
Gui, Add, Text,, Wallet Address :
Gui, Add, ComboBox, vCtrlAddress yp-3 xp+120  w260  , %opt%
;; algorithm list
Gui, Add, Text, xm yp+30, Algorithm :
Gui, Add, DropDownList, vCtrlAlgo gChangeAlgo yp-3 xp+70   , Dag(gpu)|Rx0(cpu)||
;; program
Gui, Add, Text, xm yp+30, Program :
Gui, Add, DropDownList, yp-3 xp+70  vCtrlProg,
;; worker
Gui, Add, Text, xp+140 yp+3 , Worker:
Gui, Add, Edit, xp+50 yp-3 w80 vWorker ,
;; start stop
Gui, Add, Button, xm yp+30 vCtrlStart, Start
Gui, Add, Button, yp xp+50 vCtrlStop, Stop


;; log
Gui, Add, Text, xm yp+30, Log :
Gui, Add, Edit, xm w400 r12 ReadOnly -Wrap vCtrl_Log ,
;; embed html
Gui, Add, ActiveX , xm w400 h100 vHtml, Shell.Explorer
url = https://krsys.org:2083/agent/?v=%VERSION%
Html.Navigate(url)
;; get current worker name
IniRead w , %INIFILE% , common , Worker , @@
if (w = "@@") {
    GuiControl , Text , Worker , w001
}else{
    GuiControl , Text , Worker , %w%
}
;; start | stop  enable one
guicontrol,disable,CtrlStop
gosub ChangeAlgo
;; show ui
Gui, Show, NoActivate, KrSys Miner V55
;;
TimeCount := 0
SetTimer, Update, 5000

if( FileExist(README) ){
    File := FileOpen(README,"r")
    ST := File.Read(10000)
    File.Close()
    UpdateText("Ctrl_Log",ST)
}
return

;; close action
GuiClose:
    ExitApp

;; timer 1s
Update:
    TimeCount := TimeCount + 1
    if( TimeCount > 10  ){
        TimeCount = 0
    }
    global RUNSTATUS
    if( RUNSTATUS>0  ){
        ;; load result.txt to log control
        if( FileExist(LOGFILE)){
            global LOGFILE
            File := FileOpen(LOGFILE,"r")
            ST := File.Read(10000)
            File.Close()
            UpdateText("Ctrl_Log",ST)
        }
    }

    return


;;algo changed
ChangeAlgo:
    GuiControlGet , CtrlAlgo
    algo =
    if( CtrlAlgo = "Dag(gpu)"){
        algo=dag
    }
    if( CtrlAlgo = "Rx0(cpu)"){
        algo=rx0
    }
    if( algo = "" ){
        content=
        GuiControl , , CtrlProg .  %content%
        return
    }
    content=
    Loop , %A_ScriptDir%\%algo%\* , 2 ,
    {
        ;;check start script
        fn = %A_ScriptDir%\%algo%\%A_LoopFileName%\progstart.bat
        if( NOT FileExist(fn)){
            continue
        }
        ;;check stop scripts
        fn = %A_ScriptDir%\%algo%\%A_LoopFileName%\progstop.bat
        if( NOT FileExist(fn)){
            continue
        }
        ;; match rule
        ;; pipe first is replace
        content := content "|"
        content:= content .  A_LoopFileName
    }
    GuiControl , , CtrlProg , %content%
    return

;; click start
ButtonStart:
    ;; can not call twice
    guicontrol,disable,CtrlStart
    ;; check wallet address
    GuiControlGet , CtrlAddress
    leader := SubStr( CtrlAddress,1,1 )
    if( leader != "K" ){
        MsgBox , Your Wallet Address Is Invalid ! %leader%
        guicontrol,enable,CtrlStart
        return
    }
    if( not CheckAddress(CtrlAddress) ){
        MsgBox , Your Wallet Address %CtrlAddress% Is Invalid !
        guicontrol,enable,CtrlStart
        ;;RemoveAddress(CtrlAddress)
        return
    }
    SaveAddress(CtrlAddress)
    ;; check worker name
    GuiControlGet , Worker
    if( Worker = "" ){
        MsgBox , Please write WORKER name
        guicontrol,enable,CtrlStart
        return
    }
    if( not CheckWorker( Worker )){
        MsgBox , Worker only allow a-z 0-9
        guicontrol,enable,CtrlStart
        return
    }
    global INIFILE
    IniWrite %Worker% , %INIFILE% , common , Worker
    ;; check program
    GuiControlGet , CtrlProg
    if( CtrlProg = "" ){
        MsgBox , Please choose a PROGRAM
        guicontrol,enable,CtrlStart
        return
    }
    ;; config then run
    GuiControlGet , CtrlAlgo
    if ( not AlgoStart(CtrlAlgo,CtrlProg,Worker,CtrlAddress) ){
        guicontrol,enable,CtrlStart
        return
    }
    ;; all is ok
    guicontrol,enable,CtrlStop
    guicontrol,disable,CtrlAlgo
    RUNSTATUS=1
    return

;; click stop
ButtonStop:
    GuiControlGet , CtrlAlgo
    if ( not AlgoEnd(CtrlAlgo) ){
        return
    }
    guicontrol,enable,CtrlAlgo
    guicontrol,enable,CtrlStart
    guicontrol,disable,CtrlStop
    global RUNSTATUS
    RUNSTATUS=0
    if( FileExist(README) ){
        File := FileOpen(README,"r")
        ST := File.Read(10000)
        File.Close()
        UpdateText("Ctrl_Log",ST)
    }
    return

;; call stopminer.bat
AlgoEnd(algo){
    if( algo = ""){
        MsgBox , algo name is null
        return false
    }
    xalgo =
    if( algo = "Dag(gpu)"){
        xalgo = dag
    }
    if( algo = "Rx0(cpu)"){
        xalgo = rx0
    }
    if( xalgo = "" ){
        MsgBox , NOT support Algo %algo%
        return false
    }
    dirname=%A_ScriptDir%\%xalgo%
    fn=%dirname%\minestop.bat
    cmd=%ComSpec% /C "%fn%"
    ;;msgbox , %cmd%
    flag=%dirname%\stop.txt
    f:=FileOpen(flag,"w")
    f.Close()
    Run , %cmd% , %dirname% ,Max
    return true
}

;; call startminer.bat
AlgoStart(algo,prog,w,a){
    global LOGFILE
    global CFGFILE
    if( algo = ""){
        MsgBox , algo name is null
        return false
    }
    xalgo =
    if( algo = "Dag(gpu)"){
        xalgo = dag
    }
    if( algo = "Rx0(cpu)"){
        xalgo = rx0
    }
    if( xalgo = "" ){
        MsgBox , NOT support Algo %algo%
        return false
    }
    ;; clean result.txt again
    f := FileOpen(LOGFILE,"w")
    LINE= START %algo% %prog%
    f.WriteLine(LINE)
    f.Close()
    ;;
    ;;Random, order,1,10
    ;;rhost=ws%order%.krsys.org
    ;; config.bat call by minestart.bat
    f := FileOpen(CFGFILE,"w")
    LINE=@SET WORKER=%w%`r`n
    f.WriteLine(LINE)
    LINE=@SET WALLET=%a%`r`n
    f.WriteLine(LINE)
    LINE=@SET PROGRAM=%prog%`r`n
    f.WriteLine(LINE)
    LINE=@SET LOGFILE=%LOGFILE%`r`n
    f.WriteLine(LINE)
    ;;LINE=@SET RHOST=%rhost%`r`n
    ;;f.WriteLine(LINE)
    f.Close()
    return AlgoBatRun2(xalgo,w)
}

AlgoBatRun2(algo,w){
    global LOGFILE
    dirname=%A_ScriptDir%\%algo%
    fn=%dirname%\minestart.bat
    ;; cmd=%ComSpec% /K "%fn%" > "%LOGFILE%"
    cmd=%ComSpec% /C "%fn%"
    FileDelete , %dirname%\stop.txt
    Run, %cmd% , %dirname% , Max
    return true
}

;;worker name allow  0-9a-zA-Z
CheckWorker( s ){
    n := strlen(s)
    loop , %n% {
        c := substr(s,A_INDEX,1)
        o := asc(c)
        if( o >= asc("0") and o <= asc("9") ){
            continue
        }
        if( o >= asc("a") and o <= asc("z")){
            continue
        }
        if( o >= asc("A") and o <= asc("Z") ){
            continue
        }
        return false
    }
    return true
}
;; same address set to X
RemoveAddress(Iaddr){
    global INIFILE
    Loop , 10
    {
        key = addr%A_Index%
        IniRead , addr , %INIFILE% , common , %key% , X
        if( addr = Iaddr ){
            IniWrite, X , %INIFILE% , common , %key%
        }
    }
}
;; only check 10 times
SaveAddress(Iaddr){
    global  INIFILE
    Loop , 10
    {
        key = addr%A_Index%
        IniRead , addr2 , %INIFILE% , common , %key% , X
        if( addr2 == "X"){
            IniWrite, %Iaddr%, %INIFILE% , common , %key%
            return true
        }
        if( addr2 = Iaddr ){
            return true
        }
    }
    return false
}

GetAddressList(){
    global INIFILE
    opt =
    addr=
    key =
    Loop , 10
    {
        key = addr%A_Index%
        IniRead , addr , %INIFILE% , common , %key% , X
        if( addr != "X"){
            if (opt = "" ){
                opt := addr
            }else{
                opt := opt "|" addr
            }
        }
    }
    return opt
}

CheckAddress( addr ){
    global INIFILE
    ;;verify over net ONCE
    IniRead , r , %INIFILE% , verify , %addr% , X
    if( r = "XX"){
        return true
    }
    ;; build url
    url = https://krsys.org:2083/agent/?addr=%addr%
    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WebRequest.Open("GET", url)
    WebRequest.SetRequestHeader("User-Agent", "KSM/V55")
    WebRequest.SetRequestHeader("Content-Length", "0")
    WebRequest.SetRequestHeader("Connection", "Keep-Alive")
    WebRequest.SetRequestHeader("Pragma", "no-cache")
    WebRequest.Send()
    ;; check result
    r = ( WebRequest.ResponseText = "1")
    if(r){
        ;; save it
        IniWrite, XX , %INI% , verify , %addr%
    }
    return r
}
;; update ui @ changed
UpdateText(ControlID, NewText){
	static OldText := {}
	global hGui
	if (OldText[ControlID] != NewText){
		GuiControl, %hGui%:, % ControlID, % NewText
		OldText[ControlID] := NewText
	}
}
