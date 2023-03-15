# VSC_ahk

VSC_ahk is a simple AutoHotkey v2 script to make shortcuts in Visual Studio Code.

I needed automatic backups of the ahk files I work on, so I created a simple ahk script.

--

Holding the right `mouse button` and `scrolling with the mouse wheel` you can scroll through the tabs in VSC.

`Ctrl` + `Alt` + `s` creates a backup file of the active project.

The `:open` hotstring opens the current project's directory in file explorer.

The `:dev` hotstring opens your dev dir.

The `:lib` hotstring opens the user library.

Typing `\n` results in a newline character and `\t` a tab.

You can open multiple files with `VSC.OpenFiles(files*)` and even in a new instance of VSC using `OpenFileNewInstance(files*)`.
