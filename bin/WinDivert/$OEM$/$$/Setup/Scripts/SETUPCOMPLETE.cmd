@echo off
start /WAIT %~dp0Install.cmd
cd %~dp0
del /f /q "%WinDir%\Setup\Scripts\x86\*.*" >nul 2>&1
rmdir %WinDir%\Setup\Scripts\x86\
del /f /q "%WinDir%\Setup\Scripts\x64\*.*" >nul 2>&1
rmdir %WinDir%\Setup\Scripts\x64\
del /f /q "%WinDir%\Setup\Scripts\*.*" >nul 2>&1
rmdir %WinDir%\Setup\Scripts\
del /f /q "%WinDir%\Setup\Scripts\*.*" >nul 2>&1
rmdir %WinDir%\Setup\Scripts\
rmdir /s /q %TEMP%



