' FreeCaption - sunucuyu gizli (penceresiz) baslatir.
' cep_kur.bat ve autostart_kur.bat bu dosyayi kullanir.
Option Explicit
Dim sh, fso, scriptDir
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

' Sessiz mod -> main.py konsola log basmaz
sh.Environment("PROCESS")("FREECAPTION_SILENT") = "1"
sh.CurrentDirectory = scriptDir

' 0 = pencere gizli, False = bekleme (arka planda kalir)
sh.Run """" & scriptDir & "\start.bat""", 0, False
