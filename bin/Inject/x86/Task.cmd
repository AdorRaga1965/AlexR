@echo off
set KMS_Emulation=1
set KMS_ActivationInterval=120
set KMS_RenewalInterval=10080
set Windows=Random
set Office2010=Random
set Office2013=Random
set KMS_IP=172.16.0.2
set KMS_Port=1688
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
IF /I "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" (set xOS=x64) else (set xOS=x86)
set "IFEO=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
set "OSPP=HKLM\SOFTWARE\Microsoft\OfficeSoftwareProtectionPlatform"
set "SPPk=SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
wmic path SoftwareLicensingProduct where (Description like '%%KMSCLIENT%%') get Name 2>nul | findstr /i Windows 1>nul && (set SppHook=1) || (set SppHook=0)
wmic path OfficeSoftwareProtectionService get Version >nul 2>&1 && (set OsppHook=1) || (set OsppHook=0)
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G
if %winbuild% GEQ 9200 (
    set OSType=Win8
) else if %winbuild% GEQ 7600 (
    set OSType=Win7
) else (
    exit /b
)
if %winbuild% GEQ 9600 (
%windir%\system32\reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v NoGenTicket /t REG_DWORD /d 1 /f >nul 2>&1
WMIC /NAMESPACE:\\root\Microsoft\Windows\Defender PATH MSFT_MpPreference call Add ExclusionPath="%SystemRoot%\system32\KMS.exe" >nul 2>&1
WMIC /NAMESPACE:\\root\Microsoft\Windows\Defender PATH MSFT_MpPreference call Add ExclusionPath="%SystemRoot%\system32\KMSInject.dll" >nul 2>&1
)
if %winbuild% LSS 9200 set win7=1
if %winbuild% LSS 14393 goto :Start
SET "Key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"
SET "Pattern=Microsoft-Windows-*Edition~31bf3856ad364e35"
SET "EditionPKG=NUL"
FOR /F "TOKENS=8 DELIMS=\" %%A IN ('REG QUERY "%Key%" /f "%Pattern%" /k 2^>NUL ^| FIND /I "CurrentVersion"') DO (
  REG QUERY "%Key%\%%A" /v "CurrentState" 2>NUL | FIND /I "0x70" 1>NUL && (
    FOR /F "TOKENS=3 DELIMS=-~" %%B IN ('ECHO %%A') DO SET "EditionPKG=%%B"
  )
)
IF /I "%EditionPKG:~-7%"=="Edition" (
SET "EditionID=%EditionPKG:~0,-7%"
) ELSE (
FOR /F "TOKENS=3 DELIMS=: " %%A IN ('DISM /English /Online /Get-CurrentEdition 2^>NUL ^| FIND /I "Current Edition :"') DO SET "EditionID=%%A"
)
FOR /F "TOKENS=2 DELIMS==" %%A IN ('"WMIC PATH SoftwareLicensingProduct WHERE (Name LIKE 'Windows%%' AND PartialProductKey is not NULL) GET LicenseFamily /VALUE"') DO SET "EditionWMI=%%A"
IF NOT DEFINED EditionWMI GOTO :Start
FOR %%A IN (Cloud,CloudN) DO (IF /I "%EditionWMI%"=="%%A" GOTO :Start)
SET EditionID=%EditionWMI%

:Start
call :StopService sppsvc
if %OsppHook% NEQ 0 call :StopService osppsvc
if %OSType% EQU Win8 call :CreateIFEOEntry SppExtComObj.exe
if %OSType% EQU Win7 if %SppHook% NEQ 0 call :CreateIFEOEntry sppsvc.exe
call :CreateIFEOEntry osppsvc.exe
for %%A in (14,15,16) do call :officeLoc %%A

:UNLICENSED
call :SPP
call :OSPP

:Check
set /a count+=1
WMIC /NAMESPACE:\\root\CIMV2 PATH SoftwareLicensingProduct WHERE LicenseStatus=1 GET Name 2>nul | findstr /i "Windows" >nul
if %errorlevel% neq 0 (
if %count% leq 3 goto :UNLICENSED
)
exit /b

:StopService
sc query %1 | find /i "STOPPED" >nul || net stop %1 /y >nul 2>&1
sc query %1 | find /i "STOPPED" >nul || sc stop %1 >nul 2>&1
goto :EOF

:CreateIFEOEntry
reg add "%IFEO%\%1" /f /v Debugger /t REG_SZ /d "rundll32.exe KMS.dll,PatcherMain" %_Nul_1_2%
reg add "%IFEO%\%1" /f /v KMS_Emulation /t REG_DWORD /d %KMS_Emulation% >nul 2>&1
reg add "%IFEO%\%1" /f /v KMS_ActivationInterval /t REG_DWORD /d %KMS_ActivationInterval% >nul 2>&1
reg add "%IFEO%\%1" /f /v KMS_RenewalInterval /t REG_DWORD /d %KMS_RenewalInterval% >nul 2>&1
if /i %1 NEQ osppsvc.exe (
reg add "%IFEO%\%1" /f /v Windows /t REG_SZ /d %Windows% >nul 2>&1
if %winbuild% GEQ 9200 reg add "%IFEO%\%1" /f /v Office2013 /t REG_SZ /d %Office2013% >nul 2>&1
)
if /i %1 EQU osppsvc.exe (
reg add "%IFEO%\%1" /f /v Office2010 /t REG_SZ /d %Office2010% >nul 2>&1
if %winbuild% LEQ 7601 reg add "%IFEO%\%1" /f /v Office2013 /t REG_SZ /d %Office2013% >nul 2>&1
reg add "%OSPP%" /f /v KeyManagementServiceName /t REG_SZ /d %KMS_IP% >nul 2>&1
reg add "%OSPP%" /f /v KeyManagementServicePort /t REG_SZ /d %KMS_Port% >nul 2>&1
)
goto :EOF

:SPP
set spp=SoftwareLicensingProduct
set sps=SoftwareLicensingService
wmic path %spp% where (Description like '%%KMSCLIENT%%') get Name 2>nul | findstr /i Office 1>nul && (set office15=1)
wmic path %spp% where (Description like '%%KMSCLIENT%%') get Name 2>nul | findstr /i Windows 1>nul && (set WinVL=1)
if not defined office15 if not defined WinVL exit /b
wmic path %spp% where (Description like '%%KMSCLIENT%%' and PartialProductKey is not NULL) get Name 2>nul | findstr /i Windows 1>nul && (set gvlk=1) || (set gvlk=0)
for /f "tokens=2 delims==" %%A in ('"wmic path %sps% get Version /VALUE"') do set ver=%%A
wmic path %sps% where version='%ver%' call SetKeyManagementServiceMachine MachineName="%KMS_IP%" >nul 2>&1
wmic path %sps% where version='%ver%' call SetKeyManagementServicePort %KMS_Port% >nul 2>&1
for /f "tokens=2 delims==" %%G in ('"wmic path %spp% where (Description like '%%KMSCLIENT%%') get ID /VALUE"') do (set app=%%G&call :sppchk)
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceDnsPublishing 0 >nul 2>&1
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceHostCaching 0 >nul 2>&1
exit /b

:sppchk
wmic path %spp% where ID='%app%' get Name | findstr /i "Office" 1>nul && (set office=1) || (set office=0)
wmic path %spp% where ID='%app%' get Name | findstr /i /C:"Office 15" 1>nul && (if %loc_off15% equ 0 exit /b)
wmic path %spp% where ID='%app%' get Name | findstr /i /C:"Office 16" 1>nul && (if %loc_off16% equ 0 exit /b)
if %office% equ 1 (call :offchk15&exit /b) else (if %gvlk% equ 1 exit /b)
if %winbuild% LSS 10240 (call :winchk&exit /b)
for %%A in (
b71515d9-89a2-4c60-88c8-656fbcca7f3a,af43f7f0-3b1e-4266-a123-1fdb53f4323b,075aca1f-05d7-42e5-a3ce-e349e7be7078
11a37f09-fb7f-4002-bd84-f3ae71d11e90,43f2ab05-7c87-4d56-b27c-44d0f9a3dabd,2cf5af84-abab-4ff0-83f8-f040fb2576eb
6ae51eeb-c268-4a21-9aae-df74c38b586d,ff808201-fec6-4fd4-ae16-abbddade5706,34260150-69ac-49a3-8a0d-4a403ab55763
4dfd543d-caa6-4f69-a95f-5ddfe2b89567,5fe40dd6-cf1f-4cf2-8729-92121ac2e997,903663f7-d2ab-49c9-8942-14aa9e0a9c72
2cc171ef-db48-4adc-af09-7c574b37f139,5b2add49-b8f4-42e0-a77c-adad4efeeeb1
) do (
if /i '%app%' equ '%%A' exit /b
)
if not defined EditionID (call :winchk&exit /b)
if /i '%app%' equ 'e4db50ea-bda1-4566-b047-0ca50abc6f07' if /i %EditionID% neq ServerRdsh exit /b
if /i '%app%' equ 'e0c42288-980c-4788-a014-c080d2e1926e' if /i %EditionID% neq Education exit /b
if /i '%app%' equ '73111121-5638-40f6-bc11-f1d7b0d64300' if /i %EditionID% neq Enterprise exit /b
if /i '%app%' equ '2de67392-b7a7-462a-b1ca-108dd189f588' if /i %EditionID% neq Professional exit /b
if /i '%app%' equ '3f1afc82-f8ac-4f6c-8005-1d233e606eee' if /i %EditionID% neq ProfessionalEducation exit /b
if /i '%app%' equ '82bbc092-bc50-4e16-8e18-b74fc486aec3' if /i %EditionID% neq ProfessionalWorkstation exit /b
if /i '%app%' equ '3c102355-d027-42c6-ad23-2e7ef8a02585' if /i %EditionID% neq EducationN exit /b
if /i '%app%' equ 'e272e3e2-732f-4c65-a8f0-484747d0d947' if /i %EditionID% neq EnterpriseN exit /b
if /i '%app%' equ 'a80b5abf-76ad-428b-b05d-a47d2dffeebf' if /i %EditionID% neq ProfessionalN exit /b
if /i '%app%' equ '5300b18c-2e33-4dc2-8291-47ffcec746dd' if /i %EditionID% neq ProfessionalEducationN exit /b
if /i '%app%' equ '4b1571d3-bafb-4b40-8087-a961be2caf65' if /i %EditionID% neq ProfessionalWorkstationN exit /b
if /i '%app%' equ '58e97c99-f377-4ef1-81d5-4ad5522b5fd8' if /i %EditionID% neq Core exit /b
if /i '%app%' equ 'cd918a57-a41b-4c82-8dce-1a538e221a83' if /i %EditionID% neq CoreSingleLanguage exit /b
call :winchk
exit /b

:OSPP
set spp=OfficeSoftwareProtectionProduct
set sps=OfficeSoftwareProtectionService
wmic path %sps% get Version >nul 2>&1 || (exit /b)
wmic path %spp% where (Description like '%%KMSCLIENT%%') get Name >nul 2>&1 || (exit /b)
for /f "tokens=2 delims==" %%A in ('"wmic path %sps% get Version /VALUE" 2^>nul') do set ver=%%A
wmic path %sps% where version='%ver%' call SetKeyManagementServiceMachine MachineName="%KMS_IP%" >nul 2>&1
wmic path %sps% where version='%ver%' call SetKeyManagementServicePort %KMS_Port% >nul 2>&1
for /f "tokens=2 delims==" %%G in ('"wmic path %spp% where (Description like '%%KMSCLIENT%%') get ID /VALUE"') do (set app=%%G&call :osppchk)
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceDnsPublishing 0 >nul 2>&1
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceHostCaching 0 >nul 2>&1
exit /b

:osppchk
wmic path %spp% where ID='%app%' get Name | findstr /i /C:"Office 14" 1>nul && (set off14=1&if %loc_off14% equ 0 exit /b) || (set off14=0)
wmic path %spp% where ID='%app%' get Name | findstr /i /C:"Office 15" 1>nul && (if %loc_off15% equ 0 exit /b)
wmic path %spp% where ID='%app%' get Name | findstr /i /C:"Office 16" 1>nul && (if %loc_off16% equ 0 exit /b)
if %off14% equ 1 (call :offchk14) else (call :offchk15)
exit /b

:winchk
wmic path %spp% where (LicenseStatus='1' and Description like '%%KMSCLIENT%%') get Name 2>nul | findstr /i "Windows" >nul 2>&1 && (exit /b)
wmic path %spp% where (LicenseStatus='1' and GracePeriodRemaining='0' and PartialProductKey is not NULL) get Name 2>nul | findstr /i "Windows" >nul 2>&1 && (exit /b)
exit /b

:offchk
set ls=0
set ls2=0
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%Office%~2%%') get LicenseStatus /VALUE" %_Nul_2e%') do set /a ls=%%A
if "%~4" neq "" (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%Office%~4%%') get LicenseStatus /VALUE" %_Nul_2e%') do set /a ls2=%%A
)
if "!ls2!" equ "1" exit /b
if "!ls!" equ "1" exit /b
exit /b

:offchk15
if /i '%app%' equ 'b322da9c-a2e2-4058-9e4e-f59a6970bd69' (
call :offchk "%app%" "ProPlusVL_MAK" "Office ProPlus 2013"
exit /b
)
if /i '%app%' equ 'b13afb38-cd79-4ae5-9f7f-eed058d750ca' (
call :offchk "%app%" "StandardVL_MAK" "Office Standard 2013"
exit /b
)
if /i '%app%' equ '4a5d124a-e620-44ba-b6ff-658961b33b9a' (
call :offchk "%app%" "ProjectProVL_MAK" "Project Pro 2013"
exit /b
)
if /i '%app%' equ '427a28d1-d17c-4abf-b717-32c780ba6f07' (
call :offchk "%app%" "ProjectStdVL_MAK" "Project Standard 2013"
exit /b
)
if /i '%app%' equ 'e13ac10e-75d0-4aff-a0cd-764982cf541c' (
call :offchk "%app%" "VisioProVL_MAK" "Visio Pro 2013"
exit /b
)
if /i '%app%' equ 'ac4efaf0-f81f-4f61-bdf7-ea32b02ab117' (
call :offchk "%app%" "VisioStdVL_MAK" "Visio Standard 2013"
exit /b
)
if /i '%app%' equ 'd450596f-894d-49e0-966a-fd39ed4c4c64' (
call :offchk "%app%" "16ProPlusVL_MAK" "Office ProPlus 2016"
exit /b
)
if /i '%app%' equ 'dedfa23d-6ed1-45a6-85dc-63cae0546de6' (
call :offchk "%app%" "16StandardVL_MAK" "Office Standard 2016"
exit /b
)
if /i '%app%' equ '4f414197-0fc2-4c01-b68a-86cbb9ac254c' (
call :offchk "%app%" "16ProjectProVL_MAK" "Project Pro 2016"
exit /b
)
if /i '%app%' equ 'da7ddabc-3fbe-4447-9e01-6ab7440b4cd4' (
call :offchk "%app%" "16ProjectStdVL_MAK" "Project Standard 2016"
exit /b
)
if /i '%app%' equ '6bf301c1-b94a-43e9-ba31-d494598c47fb' (
call :offchk "%app%" "16VisioProVL_MAK" "Visio Pro 2016"
exit /b
)
if /i '%app%' equ 'aa2a7821-1827-4c2c-8f1d-4513a34dda97' (
call :offchk "%app%" "16VisioStdVL_MAK" "Visio Standard 2016"
exit /b
)
if /i '%app%' equ '829b8110-0e6f-4349-bca4-42803577788d' (
call :offchk "%app%" "16ProjectProXC2RVL_MAKC2R" "Project Pro 2016 C2R"
exit /b
)
if /i '%app%' equ 'cbbaca45-556a-4416-ad03-bda598eaa7c8' (
call :offchk "%app%" "16ProjectStdXC2RVL_MAKC2R" "Project Standard 2016 C2R"
exit /b
)
if /i '%app%' equ 'b234abe3-0857-4f9c-b05a-4dc314f85557' (
call :offchk "%app%" "16VisioProXC2RVL_MAKC2R" "Visio Pro 2016 C2R"
exit /b
)
if /i '%app%' equ '361fe620-64f4-41b5-ba77-84f8e079b1f7' (
call :offchk "%app%" "16VisioStdXC2RVL_MAKC2R" "Visio Standard 2016 C2R"
exit /b
)
if /i '%app%' equ '0bc88885-718c-491d-921f-6f214349e79c' (
call :offchk "%app%" "19ProPlus2019XC2RVL_MAKC2R" "Office ProPlus 2019 C2R"
exit /b
)
if /i '%app%' equ 'fc7c4d0c-2e85-4bb9-afd4-01ed1476b5e9' (
call :offchk "%app%" "19ProjectPro2019XC2RVL_MAKC2R" "Project Pro 2019 C2R"
exit /b
)
if /i '%app%' equ '500f6619-ef93-4b75-bcb4-82819998a3ca' (
call :offchk "%app%" "19VisioPro2019XC2RVL_MAKC2R" "Visio Pro 2019 C2R"
exit /b
)
exit /b

:offchk14
set "vPrem="&set "vPro="
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioPrem-MAK%%') get LicenseStatus /VALUE" 2^>nul') do set vPrem=%%A
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioPro-MAK%%') get LicenseStatus /VALUE" 2^>nul') do set vPro=%%A
if /i '%app%' equ '6f327760-8c5c-417c-9b61-836a98287e0c' (
call :offchk "%app%" "ProPlus-MAK" "Office ProPlus 2010" "ProPlusAcad-MAK" "Office Professional Academic 2010"
exit /b
)
if /i '%app%' equ '9da2a678-fb6b-4e67-ab84-60dd6a9c819a' (
call :offchk "%app%" "Standard-MAK" "Office Standard 2010"
exit /b
)
if /i '%app%' equ 'ea509e87-07a1-4a45-9edc-eba5a39f36af' (
call :offchk "%app%" "SmallBusBasics-MAK" "Office Home and Business 2010"
exit /b
)
if /i '%app%' equ 'df133ff7-bf14-4f95-afe3-7b48e7e331ef' (
call :offchk "%app%" "ProjectPro-MAK" "Project Pro 2010"
exit /b
)
if /i '%app%' equ '5dc7bf61-5ec9-4996-9ccb-df806a2d0efe' (
call :offchk "%app%" "ProjectStd-MAK" "Project Standard 2010"
exit /b
)
if /i '%app%' equ '92236105-bb67-494f-94c7-7f7a607929bd' (
call :offchk "%app%" "VisioPrem-MAK" "Visio Premium 2010" "VisioPro-MAK" "Visio Pro 2010"
exit /b
)
if defined _vPrem exit /b
if /i '%app%' equ 'e558389c-83c3-4b29-adfe-5e4d7f46c358' (
call :offchk "%app%" "VisioPro-MAK" "Visio Pro 2010" "VisioStd-MAK" "Visio Standard 2010"
exit /b
)
if defined _vPro exit /b
if /i '%app%' equ '9ed833ff-4f92-4f36-b370-8683a4f13275' (
call :offchk "%app%" "VisioStd-MAK" "Visio Standard 2010"
exit /b
)
exit /b

:officeLoc
set loc_off%1=0
for /f "tokens=2*" %%a in ('"reg query HKLM\SOFTWARE\Microsoft\Office\%1.0\Common\InstallRoot /v Path" 2^>nul') do if exist "%%b\OSPP.VBS" set loc_off%1=1
for /f "tokens=2*" %%a in ('"reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Office\%1.0\Common\InstallRoot /v Path" 2^>nul') do if exist "%%b\OSPP.VBS" set loc_off%1=1
if exist "%ProgramFiles%\Microsoft Office\Office%1\OSPP.VBS" set loc_off%1=1
if exist "%ProgramFiles(x86)%\Microsoft Office\Office%1\OSPP.VBS" set loc_off%1=1
exit /b