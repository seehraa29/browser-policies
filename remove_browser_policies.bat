@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::  Browser Policy Removal Script (Windows)
::  Usage: remove_browser_policies.bat <brave|chrome|edge|firefox>
::  Must be run as Administrator
:: ============================================================

:: Require Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] This script must be run as Administrator.
    echo     Right-click the file and select "Run as administrator".
    pause
    exit /b 1
)

if "%~1"=="" goto :usage

set "BROWSER=%~1"

:: Normalise to lowercase via substitution (cmd has no tolower, so handle each)
if /i "%BROWSER%"=="brave"   goto :remove_brave
if /i "%BROWSER%"=="chrome"  goto :remove_chrome
if /i "%BROWSER%"=="edge"    goto :remove_edge
if /i "%BROWSER%"=="firefox" goto :remove_firefox

echo [!] Unknown browser: %BROWSER%
goto :usage

:: ---- BRAVE ----------------------------------------------------------
:remove_brave
echo ============================================================
echo  Removing Brave Browser Policies
echo ============================================================
set "REG_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Policies\BraveSoftware\Brave"
goto :remove_reg_key

:: ---- CHROME ---------------------------------------------------------
:remove_chrome
echo ============================================================
echo  Removing Google Chrome Policies
echo ============================================================
set "REG_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome"
goto :remove_reg_key

:: ---- EDGE -----------------------------------------------------------
:remove_edge
echo ============================================================
echo  Removing Microsoft Edge Policies
echo ============================================================
set "REG_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge"
goto :remove_reg_key

:: ---- FIREFOX --------------------------------------------------------
:remove_firefox
echo ============================================================
echo  Removing Firefox Policies
echo ============================================================

:: Firefox uses a JSON file, not the registry
set "REMOVED=0"

:: Check default Program Files locations
for %%D in (
    "%ProgramFiles%\Mozilla Firefox\distribution\policies.json"
    "%ProgramFiles(x86)%\Mozilla Firefox\distribution\policies.json"
) do (
    if exist %%D (
        del /f /q %%D
        echo [✓] Removed: %%D
        set "REMOVED=1"
    )
)

if "%REMOVED%"=="0" (
    echo [i] No Firefox policy file found. Nothing to remove.
) else (
    echo [i] Please restart Firefox for changes to take effect.
)
goto :done

:: ---- Registry-based removal (Brave / Chrome / Edge) -----------------
:remove_reg_key
echo [i] Registry key: %REG_KEY%
echo.

:: Check if the key exists before attempting deletion
reg query "%REG_KEY%" >nul 2>&1
if %errorLevel% neq 0 (
    echo [i] Registry key does not exist. Nothing to remove.
    goto :done
)

:: Delete the key and all its subkeys (/f = no prompt, /va removes all values)
reg delete "%REG_KEY%" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo [✓] Removed registry key and all values.
) else (
    echo [!] Failed to remove registry key. Check permissions.
    goto :fail
)

:: For Edge, also remove the Recommended subkey if it exists
if /i "%BROWSER%"=="edge" (
    set "RECOMMENDED_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\Recommended"
    reg query "!RECOMMENDED_KEY!" >nul 2>&1
    if !errorLevel! equ 0 (
        reg delete "!RECOMMENDED_KEY!" /f >nul 2>&1
        echo [✓] Removed Edge\Recommended subkey.
    )
)

echo [i] Please restart the browser for changes to take effect.
goto :done

:: ---- Helpers --------------------------------------------------------
:usage
echo.
echo Usage: %~nx0 ^<brave^|chrome^|edge^|firefox^>
echo.
echo   brave    — Remove Brave Browser registry policies
echo   chrome   — Remove Google Chrome registry policies
echo   edge     — Remove Microsoft Edge registry policies
echo   firefox  — Remove Firefox policies.json file
echo.
pause
exit /b 1

:fail
pause
exit /b 1

:done
echo.
echo [✓] Done.
pause
endlocal
