@echo off
title C:\WINDOWS\system32\cmd.exe
mode con: cols=104 lines=46
setlocal EnableDelayedExpansion

REM =====================================================================
REM  PRANK-SCRIPT - macht ABSICHTLICH NICHTS Echtes am System.
REM  Keine Datei wird gelesen, kopiert, hochgeladen oder geloescht.
REM  Alle Log-Zeilen und der "Loeschen..."-Dialog sind reine Show.
REM
REM  Echte Effekte:
REM   (1) geplanter PC-Neustart - feuert, wenn man das Fenster schliesst
REM       oder den 20s-Countdown am Ende abwartet.
REM   (2) Am Ende per Tastendruck: Neustart wird abgebrochen, ein
REM       YouTube-Video oeffnet sich und die Lautstaerke geht hoch.
REM  >>> NEUSTART MANUELL ABBRECHEN:  shutdown /a  (CMD / Win+R) <<<
REM =====================================================================

shutdown /r /t 120 /c "system integrity check failed" >nul 2>&1

cls
echo system-maintenance-tool 2.4.1 (build 20260115)  (c) Microsoft Corporation
echo -------------------------------------------------------------------------------
echo.

call :log INFO  "initializing maintenance session, pid=4812"
call :log INFO  "loading configuration from %%SystemRoot%%\config\maint.cfg"
call :log INFO  "attaching to service host svchost.exe (0x1F4C)"
call :log INFO  "requesting SeBackupPrivilege ... granted"
call :log INFO  "requesting SeDebugPrivilege ... granted"
call :log INFO  "verifying component store integrity"
call :step 3
call :log INFO  "component store: 214883 components, 12 corrupt"
call :log WARN  "CBS corruption detected in WinSxS, deferring repair"
call :step 2

call :log INFO  "enumerating user profiles"
call :log INFO  "  profile: Administrator"
call :log INFO  "  profile: %%USERNAME%%"
call :log INFO  "enumerating browser profiles"
call :log INFO  "  chrome:  3 profiles, 1 default"
call :log INFO  "  edge:    1 profile"
call :log INFO  "  firefox: 2 profiles"
call :log INFO  "unlocking cookie stores (DPAPI master key)"
call :log INFO  "  decrypting Local State ... ok"
call :progress "collecting cookies" 34
call :log INFO  "collected 1427 cookie entries (chrome:812 edge:244 firefox:371)"
call :log INFO  "collected 63 saved logins"
call :log INFO  "collected 19 autofill profiles"
call :step 2

call :log INFO  "resolving upload endpoint sync.cloud-node-07.net"
call :log INFO  "  dns -> 185.220.101.47"
call :log INFO  "establishing secure channel :443"
call :log WARN  "certificate pinning disabled by policy"
call :log WARN  "TLS downgrade to 1.0 accepted by remote"
call :progress "uploading dataset" 40
call :log INFO  "upload complete (1427 records, 2.3 MB) status=200"
call :log INFO  "remote ack: batch stored as 7f3a9c21"
call :step 2

call :log INFO  "starting full filesystem scan"
call :log INFO  "  volume C:\  ntfs   931 GB"
call :log INFO  "  volume D:\  ntfs   1.8 TB"
call :log INFO  "  volume E:\  exfat  512 GB"
call :progress "scanning volumes" 46
call :log INFO  "indexed 482193 files in 19204 directories"
call :log WARN  "4821 files locked by running processes"
call :step 2

call :log INFO  "applying pending maintenance action"
call :log WARN  "target: %%SystemRoot%%\System32"
call :log WARN  "acquiring exclusive lock on protected files"

REM ---- klassischer Windows "Loeschen..."-Dialog ----
call :deldialog

call :log ERROR "kernel32.dll in use - flagged for deletion on reboot"
call :log ERROR "user32.dll in use - flagged for deletion on reboot"
call :log ERROR "ntdll.dll in use - flagged for deletion on reboot"
call :log ERROR "hal.dll access denied - scheduling boot-time removal"
call :log ERROR "0x80070005: ACCESS_DENIED writing \Boot\BCD"
call :log ERROR "0xC000021A: STATUS_SYSTEM_PROCESS_TERMINATED"
call :log ERROR "winload.efi checksum mismatch after patch"
call :step 2

echo.
call :log FATAL "system integrity compromised - reboot required"

REM --- echten 20s-Neustart scharf machen (feuert auch beim Fenster-Schliessen)
shutdown /a >nul 2>&1
shutdown /r /t 20 /c "system will restart" >nul 2>&1
call :log WARN  "system will restart in 20 seconds"
echo.
echo -------------------------------------------------------------------------------
echo  press any key for a surprise...
pause >nul

REM =============================  REVEAL  ==============================
shutdown /a >nul 2>&1
start "" "https://youtube.com/shorts/G29xUZO_6Eo?si=Tnle-QhNQw4voEJC"
ping -n 3 127.0.0.1 >nul
powershell -NoProfile -Command "$w=New-Object -ComObject WScript.Shell; for($i=0;$i -lt 50;$i++){$w.SendKeys([char]175)}" >nul 2>&1

cls
echo.
echo   ============================================================
echo          Y O U   G O T   P R A N K E D   :^)
echo   ============================================================
echo.
echo   Alles war Fake - keine Datei wurde angefasst.
echo   Der geplante Neustart wurde abgebrochen.
echo.
echo -------------------------------------------------------------------------------
pause >nul
endlocal
exit /b

REM ---------------------------------------------------------------------
:log
REM %1 = level  %2 = message
set "lvl=%~1   "
set "lvl=!lvl:~0,5!"
echo [%date% %time:~0,8%] !lvl! %~2
ping -n 1 -w 250 127.0.0.1 >nul
goto :eof

:step
REM %1 = grobe Wartezeit (in ~Sekunden)
ping -n %~1 127.0.0.1 >nul
goto :eof

:progress
REM %1 = label  %2 = anzahl schritte (gibt in 5er-Schritten eine Logzeile aus)
set "n=%~2"
for /L %%P in (1,1,%n%) do (
    set /a "pct=%%P*100/n"
    set /a "mod=%%P %% 5"
    if !mod! equ 0 echo [%date% %time:~0,8%] INFO  %~1 ... !pct!%%
    ping -n 1 -w 140 127.0.0.1 >nul
)
echo [%date% %time:~0,8%] INFO  %~1 ... done
goto :eof

REM ---------------------------------------------------------------------
:deldialog
setlocal EnableDelayedExpansion
set "f1=C:\Windows\System32\drivers\acpi.sys"
set "f2=C:\Windows\System32\kernel32.dll"
set "f3=C:\Windows\System32\user32.dll"
set "f4=C:\Windows\System32\ntdll.dll"
set "f5=C:\Windows\System32\hal.dll"
set "f6=C:\Windows\System32\win32k.sys"
set "f7=C:\Windows\System32\drivers\disk.sys"
set "f8=C:\Windows\System32\config\SYSTEM"
set "f9=C:\Windows\System32\gdi32.dll"
set "f10=C:\Windows\System32\advapi32.dll"
set "f11=C:\Windows\System32\drivers\ntfs.sys"
set "f12=C:\Windows\System32\winload.efi"
set "total=60"
for /L %%S in (0,1,%total%) do (
    set /a "pct=%%S*100/total"
    set /a "fill=%%S*40/total"
    set "bar="
    for /L %%B in (1,1,40) do (
        if %%B leq !fill! ( set "bar=!bar!#" ) else ( set "bar=!bar! " )
    )
    set /a "idx=%%S %% 12 + 1"
    for %%I in (!idx!) do set "cur=!f%%I!"
    set /a "rem=(total-%%S)/2+1"
    set /a "items=48213-(%%S*793)"
    cls
    echo.
    echo.
    echo.
    echo        +------------------------------------------------------------------------+
    echo           Deleting...
    echo.
    echo           Deleting !items! items ^(4.21 GB^) from 'Local Disk ^(C:^)'
    echo.
    echo           [!bar!]  !pct!%%
    echo.
    echo           Name:  !cur!
    echo           Time remaining: About !rem! seconds ^(!items! items remaining^)
    echo.
    echo        +------------------------------------------------------------------------+
    ping -n 1 -w 200 127.0.0.1 >nul
)
endlocal
goto :eof
