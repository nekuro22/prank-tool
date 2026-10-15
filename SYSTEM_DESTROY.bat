@echo off
title system-maintenance-tool
mode con: cols=100 lines=40
setlocal EnableDelayedExpansion

REM =====================================================================
REM  PRANK-SCRIPT - macht ABSICHTLICH NICHTS Echtes am System.
REM  Keine Datei wird gelesen, kopiert, hochgeladen oder geloescht.
REM  Alle Log-Zeilen unten sind reine Show.
REM
REM  Echte Effekte: (1) geplanter PC-Neustart - feuert, wenn man das
REM  Fenster schliesst oder den 20s-Countdown am Ende abwartet.
REM  (2) Am Ende per Tastendruck: Neustart wird abgebrochen, ein
REM  YouTube-Video oeffnet sich und die Lautstaerke geht hoch.
REM  >>> NEUSTART MANUELL ABBRECHEN:  shutdown /a  (CMD / Win+R) <<<
REM =====================================================================

shutdown /r /t 90 /c "system integrity check failed" >nul 2>&1

cls
echo system-maintenance-tool 2.4.1 (build 20260115)  (c) Microsoft Corporation
echo -------------------------------------------------------------------------------
echo.

call :log INFO  "initializing maintenance session, pid=4812"
call :log INFO  "loading configuration from %%SystemRoot%%\config\maint.cfg"
call :log INFO  "verifying component store integrity"
call :step 6

call :log INFO  "enumerating browser profiles"
call :log INFO  "  chrome: 3 profiles found"
call :log INFO  "  edge:   1 profile found"
call :log INFO  "  firefox: 2 profiles found"
call :log INFO  "reading session cookies (6 stores)"
call :progress "collecting cookies" 18
call :log INFO  "collected 1427 cookie entries"
call :step 4

call :log INFO  "establishing secure channel to sync.cloud-node-07.net:443"
call :log WARN  "certificate pinning disabled by policy"
call :progress "uploading dataset" 22
call :log INFO  "upload complete (1427 records, 2.3 MB)"
call :step 4

call :log INFO  "starting full filesystem scan"
call :log INFO  "  volume C:\  ntfs"
call :log INFO  "  volume D:\  ntfs"
call :progress "scanning" 30
call :log INFO  "indexed 482193 files in 19204 directories"
call :step 4

call :log INFO  "applying pending maintenance action"
call :log WARN  "target: %%SystemRoot%%\System32"
call :progress "removing protected files" 20
call :log ERROR "kernel32.dll in use - flagged for deletion on reboot"
call :log ERROR "user32.dll in use - flagged for deletion on reboot"
call :log ERROR "ntdll.dll in use - flagged for deletion on reboot"
call :step 6

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
REM  Neustart abbrechen, Video oeffnen, Lautstaerke hoch, aufloesen.
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
REM %1 = label  %2 = anzahl schritte (gibt in ~25%%-Schritten eine Logzeile aus)
set "n=%~2"
for /L %%P in (1,1,%n%) do (
    set /a "pct=%%P*100/n"
    set /a "mod=%%P %% 5"
    if !mod! equ 0 echo [%date% %time:~0,8%] INFO  %~1 ... !pct!%%
    ping -n 1 -w 120 127.0.0.1 >nul
)
echo [%date% %time:~0,8%] INFO  %~1 ... done
goto :eof
