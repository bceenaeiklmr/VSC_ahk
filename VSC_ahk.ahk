; Script     VSC_ahk.ahk
; License:   MIT License
; Author:    Bence Markiel (bceenaeiklmr)
; Github:    https://github.com/bceenaeiklmr/VSC_ahk
; Date       15.03.2023
; Version    0.1.1

#SingleInstance Force
#Warn

; ################################################################################

; Visual Studio Code
#HotIf WinActive("Visual Studio Code ahk_exe Code.exe")
; scroll in projects
RButton & WheelUp::Send '{CtrlDown}{PgUp}{CtrlUp}'   ; ->
RButton & WheelDown::Send '{CtrlDown}{PgDn}{CtrlUp}' ; <-
$Rbutton::Click 'Right'
; create a backup file
^!s::VSC.Backup
; open current projects dir in file explorer
:*x::open::Run(VSC.FileDir())
; open dev dir
:*x::dev::Run("C:\dev\ahk\v2")
; open user library
:*x::lib::VSC.OpenFiles(VSC.ahk_lib)
:*:\n::"``n" ; `n 
:*:\t::"``t" ; `t
#HotIf

; ################################################################################

class VSC {

    static Backup(Dest := "") {
        FilePath := this.FilePath()
        if !Dest
            Dest := this.FileDir() "\backup"
        if !DirExist(Dest)
            DirCreate(Dest)
        Ext := SubStr(A_ScriptName, -4)
        Name := StrReplace(VSC.Project(), Ext)
        Date := FormatTime(A_Now, "ddMMyy_HHmmss") 
        FileCopy(FilePath, Dest "/" Name "_" Date Ext)
    }

    static NewInstance(Files*) {
        if !WinExist(this.Title)
            return Run(this.Path)
        A_Clipboard := this.Path
        Send("#r")
        WinWait("Run")
        Send("^v{Enter}")
        WinWait("Get Started")
        this.hWnds.Push(WinExist("A"))
        if files.Length
            this.OpenFiles(files*)
    }

    __New() {
        VSC.NewInstance() 
    }

    static title := "Visual Studio Code ahk_exe Code.exe"
    
    static path  := StrReplace(A_AppData, "\Roaming") "\Local\Programs\Microsoft VS Code\Code.exe"

    static hWnds := Array()

    static ahk_lib => StrReplace(A_AhkPath, "AutoHotkey.exe") "Lib\ahk_lib.ahk"

    static __New() {

        if (A_TitleMatchMode !== 2)
            SetTitleMatchMode(2)
        
        if WinExist(this.title)
            this.hWnds.Push(WinExist("A"))

    }

    static OpenFiles(files*) {
        CB := ClipboardAll()
        for v in files {
            if !(v ~= "\\|\/")
                v := A_ScriptDir "\" v
            v := StrReplace(v, "/", "\")
            if !FileExist(v)
                continue
            Path := StrSplit(v, "\")
            FileName := Path[Path.Length]
            A_Clipboard := StrReplace(v, FileName)
            this.FileOpen()
            WinWaitActive("Open File")
            Send(FileName        ; enter filename
              . "{F4}^a{Delete}" ; focus address bar, select all and delete
              . "^v{Enter}"      ; paste the path & enter
              . "!o")            ; open file hotkey
            WinWaitActive(FileName)
        }
        A_Clipboard := CB
    }

    static OpenFileNewInstance(files*) {
        VSC()
        this.OpenFiles(files*)
    }

    static Activate(instance := 0) {
        if !(instance > VSC.hWnds.Length)
            hWnd := VSC.hWnds[instance]
        else if !instance
            hWnd := VSC.hWnds[VSC.hWnds.Length]
        if !WinActive("ahk_id" hWnd)
            WinActivate("ahk_id" hWnd)
    }

    static FocusProject(FileName) {
        first := this.Project
        while !(this.Project ~= FileName) {
            send '{CtrlDown}{PgDn}{CtrlUp}'
            sleep 66
            if (A_index>1 && first = this.Project)  ; project limit
                return 1
        }
    }

    static Project() {
        RegExMatch(WinGetTitle(this.Title), "[a-zA-Z0-9]+(.)+?[(.)+?a-zA-Z0-9]+?\.(ah2|ahk)", &proj)
        return proj[]
    }

    static Position(x := "", y := "", w := "", h := "") {
        w := (w = "" ? 2260 : w),
            h := (h = "" ? 1340 : h),
            x := (x = "" ? (A_screenWidth - w) // 2 : x),
            y := (y = "" ? (A_screenHeight - h) // 4 : y)
        winMove x, y, w, h, this.title
        this.Activate()
    }

    static Minimize() {
        WinMinimize("ahk_id" this.title)
    }

    ; in built hotkeys
    static FileCreate() => this.HK("^N")
    static FileOpen() => this.HK("^O")
    static FileClose() => this.HK("^{F4}")
    static FileCloseAll() => this.HK("^K|^W")
    static FileSave() => this.HK("^S")
    static FileSaveAs() => this.HK("^+S")
    static FileSaveAll() => this.HK("^K|S")
    static FilePath() => this.HK("^K|P*")
    static FileOpenNext() => this.HK("^{Tab}")
    static FileOpenPrevious() => this.HK("^+{Tab}")
    static FileShowInExplorer() => this.HK("^K|R")
    static FileShowNewInstance() => this.HK("^K|O")
    static EditorReopen() => this.HK("^+T")    ; closed editor
    static EditorPreviewModeOpen() => this.HK("^K|{Enter}")
    static IndentText() => this.HK("+!F")

    static FileDir() => SubStr(StrReplace(this.FilePath(), this.Project()), 1, -1)

    static HK(keys) {
        clip := (keys ~= "\*") ? 1 : 0
        keys := strSplit(StrReplace(keys, "*"), "|")
        ; copypath have to be performed twice
        loop (clip) ? 2 : 1 {
            for k, v in keys {
                send format("{:L}", v)
                if (k !== keys.Length)
                    sleep 100
            }
        }
        return (clip) ? A_Clipboard: ""
    }

}
