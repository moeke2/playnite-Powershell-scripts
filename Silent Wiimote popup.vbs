Set WshShell = CreateObject("WScript.Shell")
Set oExec = WshShell.Exec("cmd.exe /c ""D:\Games\Playnite\_playnite_scripts\test.bat""""D:\Games\Playnite\_playnite_scripts\Wiimote popup.ps1""""")

Do
    ' Here you can place any code or just keep it looping
    WScript.Sleep 60000 ' Sleep for 60 seconds (60000 milliseconds)
Loop


