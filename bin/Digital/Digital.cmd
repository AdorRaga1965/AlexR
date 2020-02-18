@echo off
set ver=v5.7
title Dijital Activation Windows 10 %ver% by mephistooo2 - TNCTR.com
mode con cols=70 lines=2
color 4e

:init
setlocal DisableDelayedExpansion
set cmdInvoke=1
set winSysFolder=System32
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
echo ADMIN RIGHTS ACTIVATE...
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
if '%cmdInvoke%'=='1' goto InvokeCmd 
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
goto ExecElevation

:InvokeCmd
ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
"%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)
::===============================================================================================================
setlocal enabledelayedexpansion
setlocal EnableExtensions
pushd "%~dp0"
mode con cols=80 lines=41
color 5f
cd /d "%~dp0"
if /i "%PROCESSOR_ARCHITECTURE%"=="x86" if not defined PROCESSOR_ARCHITEW6432 set xOS=x86
for /f "tokens=2 delims==" %%a IN ('"wmic Path Win32_OperatingSystem Get Caption /format:LIST"')do (set NameOS=%%a) >nul 2>&1
for /f "tokens=2 delims==" %%a IN ('"wmic Path Win32_OperatingSystem Get CSDVersion /format:LIST"')do (set SP=%%a) >nul 2>&1
for /f "tokens=2 delims==" %%a IN ('"wmic Path Win32_OperatingSystem Get Version /format:LIST"')do (set Version=%%a) >nul 2>&1
:MAINMENU
echo ================================================================================
set ver=v5.7
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a:%%b)
echo                                                              %mydate% - %mytime%                                                           
echo  Dijital Activation Windows 10 %ver% - mephistooo2 - www.TNCTR.com 
echo.
echo   SUPPORT MICROSOFT PRUDUCTS:
echo   Windows 10 (all versions)
echo.
echo          OS NAME : %NameOS% %SP% %xOS%
reg.exe query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DigitalProductId >nul 2>&1
echo          VERSION : %Version%
echo    ARCHITECTURAL : %PROCESSOR_ARCHITECTURE%
echo          PC NAME : %computername%
echo ================================================================================
echo.
Echo.        [1] DIGITAL ACTIVATION START FOR WINDOWS 10 
Echo.
Echo.        [2] DIGITAL $OEM$ ACTIVATION FOLDER EXTRACT TO DESKTOP
Echo.
Echo.        [3] WINDOWS ^& OFFICE ACTIVATION STATUS CHECK
Echo.
Echo.        [4] DIGITAL ACTIVATION VISIT WEBSITE (TNCTR)
Echo.
Echo.        [5] EXIT 
Echo.
Echo.        [6] RETURN KMS SUITE MENU
echo.
echo ================================================================================
choice /C:123456 /N /M "YOUR CHOICE : "
if errorlevel 6 goto :KMSSuite
if errorlevel 5 goto :Exit
if errorlevel 4 goto :TNCTR
if errorlevel 3 goto :Check
if errorlevel 2 goto :OEM
if errorlevel 1 goto :HWIDActivate
::===============================================================================================================

:HWIDActivate
set slp=SoftwareLicensingProduct
set sps=SoftwareLicensingService
FOR /F "tokens=3" %%I IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" ^| findstr CurrentVersion ^| findstr REG_SZ') DO (SET winver=%%I)
for /f "tokens=2* delims= " %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v "PROCESSOR_ARCHITECTURE"') do if "%%b"=="AMD64" (set vera=x64) else (set vera=x86)
for /f "tokens=2 delims== " %%A in ('"wmic path %slp% where (Name LIKE '%%Windows%%' and PartialProductKey is not null) get LicenseStatus /format:list"') do set status=%%A
for /f "tokens=2 delims=, " %%A in ('"wmic path %slp% where (Name LIKE '%%Windows%%' and LicenseStatus='%status%') get name /value"') do set osedition=%%A

if not exist "bin" md "bin"
set "gatherosstate=bin\%vera%\gatherosstate.exe"
set "slc=bin\%vera%\slc.dll"
::===============================================================================================================
:CheckWindows
set status=0
set spp=SoftwareLicensingProduct
wmic path %spp% where (Name LIKE '%%Windows%%') get LicenseStatus 2>nul | findstr "1" >nul && set status=1
if %status%==1 goto :Licensed
if %status%==0 goto :GenerateHWIDA
::===============================================================================================================
:Licensed
     echo.
     echo Windows 10 %osedition% %vera% preactivated.
     echo.
     echo Press any key to continue...
     pause >nul
     mode con cols=80 lines=41
     goto:MainMenu
::===============================================================================================================
:GenerateHWIDA
mode con cols=97 lines=62
cd /d "%~dp0"
cls
call :Header "WINDOWS 10 DIGITAL LICENSE [Windows 10 %osedition% %vera%]"
echo:
if [%osedition%] == [Cloud] (
	set "edition=Cloud"
	set "key=V3WVW-N2PV2-CGWC3-34QGF-VMJ2C"
	set "sku=178"
	set "editionId=X21-32983"
	goto :parseAndPatch
)
if [%osedition%] == [CloudN] (
	set "edition=CloudN"
	set "key=NH9J3-68WK7-6FB93-4K3DF-DJ4F6"
	set "sku=179"
	set "editionId=X21-32987"
	goto :parseAndPatch
)
if [%osedition%] == [Core] (
	set "edition=Core"
	set "key=YTMG3-N6DKC-DKB77-7M9GH-8HVX7"
	set "sku=101"
	set "editionId=X19-98868"
	goto :parseAndPatch
)
if [%osedition%] == [CoreCountrySpecific] (
	set "edition=CoreCountrySpecific"
	set "key=N2434-X9D7W-8PF6X-8DV9T-8TYMD"
	set "sku=99"
	set "editionId=X19-99652"
	goto :parseAndPatch
)
if [%osedition%] == [CoreN] (
	set "edition=CoreN"
	set "key=4CPRK-NM3K3-X6XXQ-RXX86-WXCHW"
	set "sku=98"
	set "editionId=X19-98877"
	goto :parseAndPatch
)
if [%osedition%] == [CoreSingleLanguage] (
	set "edition=CoreSingleLanguage"
	set "key=BT79Q-G7N6G-PGBYW-4YWX6-6F4BT"
	set "sku=100"
	set "editionId=X19-99661"
	goto :parseAndPatch
)
if [%osedition%] == [Education] (
	set "edition=Education"
	set "key=YNMGQ-8RYV3-4PGQ3-C8XTP-7CFBY"
	set "sku=121"
	set "editionId=X19-98886"
	goto :parseAndPatch
)
if [%osedition%] == [EducationN] (
	set "edition=EducationN"
	set "key=84NGF-MHBT6-FXBX8-QWJK7-DRR8H"
	set "sku=122"
	set "editionId=X19-98892"
	goto :parseAndPatch
)
if [%osedition%] == [Enterprise] (
	set "edition=Enterprise"
	set "key=XGVPP-NMH47-7TTHJ-W3FW7-8HV2C"
	set "sku=4"
	set "editionId=X19-99683"
	goto :parseAndPatch
)
if [%osedition%] == [EnterpriseN] (
	set "edition=EnterpriseN"
  set "key=WGGHN-J84D6-QYCPR-T7PJ7-X766F"
	set "sku=27"
	set "editionId=X19-98746"
	goto :parseAndPatch
)
if [%osedition%] == [EnterpriseS] (
	set "edition=EnterpriseS"
	set "key=NK96Y-D9CD8-W44CQ-R8YTK-DYJWX"
	set "sku=125"
	set "editionId=X21-05035"
	goto :parseAndPatch
)
if [%osedition%] == [EnterpriseSN] (
	set "edition=EnterpriseSN"
	set "key=RW7WN-FMT44-KRGBK-G44WK-QV7YK"
	set "sku=126"
	set "editionId=X21-04921"
	goto :parseAndPatch
)
if [%osedition%] == [Professional] (
	set "edition=Professional"
	set "key=VK7JG-NPHTM-C97JM-9MPGT-3V66T"
	set "sku=48"
	set "editionId=X19-98841"
	goto :parseAndPatch
)
if [%osedition%] == [ProfessionalEducation] (
	set "edition=ProfessionalEducation"
	set "key=8PTT6-RNW4C-6V7J2-C2D3X-MHBPB"
	set "sku=164"
	set "editionId=X21-04955"
	goto :parseAndPatch
)
if [%osedition%] == [ProfessionalEducationN] (
	set "edition=ProfessionalEducationN"
	set "key=GJTYN-HDMQY-FRR76-HVGC7-QPF8P"
	set "sku=165"
	set "editionId=X21-04956"
	goto :parseAndPatch
)
if [%osedition%] == [ProfessionalN] (
	set "edition=ProfessionalN"
	set "key=2B87N-8KFHP-DKV6R-Y2C8J-PKCKT"
	set "sku=49"
	set "editionId=X19-98859"
	goto :parseAndPatch
)
if [%osedition%] == [ProfessionalWorkstation] (
	set "edition=ProfessionalWorkstation"
	set "key=DXG7C-N36C4-C4HTG-X4T3X-2YV77"
	set "sku=161"
	set "editionId=X21-43626"
	goto :parseAndPatch
)
if [%osedition%] == [ProfessionalWorkstationN] (
	set "edition=ProfessionalWorkstationN"
	set "key=WYPNQ-8C467-V2W6J-TX4WX-WT2RQ"
	set "sku=162"
	set "editionId=X21-43644"
	goto :parseAndPatch
)
if [%osedition%] == [ServerRdsh] (
	set "edition=ServerRdsh"
	set "key=NJCF7-PW8QT-3324D-688JX-2YV66"
	set "sku=175"
	set "editionId=X21-41295"
	goto :parseAndPatch
)
::===============================================================================================================
:parseAndPatch
cls
mode con cols=97 lines=15
call :Header "WINDOWS 10 DIGITAL LICENSE [Windows 10 %osedition% %vera%]"
echo Files are being prepared...
if not exist %gatherosstate% (
	call :Footer
	echo gatherosstate.exe not found. Enter ISO drive letter to copy.
	call :Footer
	set /p ogspath=Enter drive letter : ^>
	xcopy "!ogspath!:\sources\gatherosstate.exe" /s ".\bin" /Q /Y >nul 2>&1
)
set "ps=bin\
if [%osedition%] == [EnterpriseN] (
	set "ps=bin\entn.ps1"
	xcopy "!ps!" /s ".\bin" /Q /Y >nul 2>&1
	cd /d "bin"
	set "ps=entn.ps1"
	for /f "tokens=*" %%a in ('powershell -executionpolicy bypass -File !ps!') do set "key=%%a"
	if exist "!ps!" del /s /q "!ps!" >nul 2>&1
)
if [%osedition%] == [EnterpriseSN] (
	set "ps=bin\entsn.ps1"
	xcopy "!ps!" /s ".\bin" /Q /Y >nul 2>&1
	cd /d "bin"
	set "ps=entsn.ps1"
    for /f "tokens=*" %%a in ('powershell -executionpolicy bypass -File !ps!') do set "key=%%a"
	if exist "!ps!" del /s /q "!ps!" >nul 2>&1
)
call :Footer
cls
mode con cols=97 lines=48
call :Header "WINDOWS 10 DIGITAL LICENSE [Windows 10 %osedition% %vera%]"
echo Creating registry entries...
reg add "HKLM\SYSTEM\Tokens" /v "Channel" /t REG_SZ /d "Retail" /f
reg add "HKLM\SYSTEM\Tokens\Kernel" /v "Kernel-ProductInfo" /t REG_DWORD /d %sku% /f
reg add "HKLM\SYSTEM\Tokens\Kernel" /v "Security-SPP-GenuineLocalStatus" /t REG_DWORD /d 1 /f
call :Footer
echo  Default product key is installing for Windows 10 %edition% %vera%...
echo:
cscript /nologo %windir%\system32\slmgr.vbs -ipk %key%
call :Footer
echo Create GenuineTicket.XML file for Windows 10 %edition% %vera%...
start /wait "" "%gatherosstate%"
timeout /t 3 >nul 2>&1
call :Footer
echo GenuineTicket.XML file is installing for Windows 10 %edition% %vera%...
echo:
clipup -v -o -altto bin\%vera%\
call :Footer
echo Windows 10 %edition% %vera% activating...
echo:
cscript /nologo %windir%\system32\slmgr.vbs -ato
call :Footer
echo Deleting registry entries...
reg delete "HKLM\SYSTEM\Tokens" /f
call :Footer
echo Press any key to continue...
pause >nul
CLS
mode con cols=80 lines=41
goto:MainMenu
::===============================================================================================================
:Header
echo.
echo %~1
echo.
echo:
goto:eof
::===============================================================================================================
:Footer
echo:
echo.
echo:
goto:eof
::===============================================================================================================
: HWIDA_EXIT
mode con cols=80 lines=41
CLS
GOTO MAINMENU
::===============================================================================================================
:OEM
cd /d "%userprofile%\desktop\"
IF EXIST $OEM$ (
echo.
echo ===============================================
echo $OEM$ folder already exists on Desktop.
echo ===============================================
echo. 
echo Press any key to continue...
pause >nul
mode con cols=80 lines=41
GOTO MAINMENU
) ELSE (
md %userprofile%\desktop\$OEM$
cd /d "%~dp0"
XCOPY $OEM$\* %userprofile%\desktop\$OEM$\ /s /i)
echo MSGBOX "$OEM$ FOLDER EXTRACT TO DESKTOP" > %temp%\TEMPmessage.vbS
call %temp%\TEMPmessage.vbs
del %temp%\TEMPmessage.vbs /f /q
CLS
mode con cols=80 lines=41
GOTO MAINMENU
::===============================================================================================================
:Check
echo.
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  cmd /u /c echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
echo ********************************************************************************
echo ***                         Windows Activation Status                        ***
echo ********************************************************************************
wscript //nologo %systemroot%\System32\slmgr.vbs /dli | wscript //nologo %systemroot%\System32\slmgr.vbs /xpr
echo.

set verb=0
set spp=SoftwareLicensingProduct
for /f "tokens=2 delims==" %%G in ('"wmic path %spp% where (PartialProductKey is not null) get ID /value"') do (set app=%%G&call :chk)
echo.
echo Press any key to continue...
pause >nul
mode con cols=80 lines=41
CLS
GOTO MAINMENU

:chk
wmic path %spp% where ID='%app%' get Name /value | findstr /i "Windows" 1>nul && (exit /b)
if %verb%==0 (
set verb=1
echo ********************************************************************************
echo ***                         Office Activation Status                         ***
echo ********************************************************************************
)
wscript //nologo %systemroot%\system32\slmgr.vbs /dli %app% | wscript //nologo %systemroot%\System32\slmgr.vbs /xpr %app%
echo.
echo Press any key to continue...
pause >nul
mode con cols=80 lines=41
CLS
GOTO MAINMENU
::===============================================================================================================
:TNCTR
echo.
start https://www.tnctr.com/topic/450916-kms-dijital-online-aktivasyon-suite-v52/
echo Press any key to continue...
pause >nul
CLS
GOTO MAINMENU
::===============================================================================================================
:Exit
echo.
echo MSGBOX "SPECIAL THANKS : TNCTR Family - CODYQX4, abbodi1406, qewlpal, s1ave77, cynecx, qad, Mouri_Naruto (MDL)", vbInformation,"..:: mephistooo2 | TNCTR ::.."  > %temp%\TEMPmessage.vbs
call %temp%\TEMPmessage.vbs
del %temp%\TEMPmessage.vbs /f /q
ENDLOCAL
exit
::===============================================================================================================
:KMSSuite
cd..
cd..
call KMS_Suite.cmd
ENDLOCAL
exit