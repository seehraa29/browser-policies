@echo off
setlocal EnableDelayedExpansion
echo ============================================================
echo  Firefox Policy Applicator (Windows)
echo ============================================================

:: Require Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] This script must be run as Administrator.
    echo     Right-click the file and select "Run as administrator".
    pause
    exit /b 1
)

:: Detect Firefox installation
set "FF_DIR="
if exist "%ProgramFiles%\Mozilla Firefox\firefox.exe" (
    set "FF_DIR=%ProgramFiles%\Mozilla Firefox"
) else if exist "%ProgramFiles(x86)%\Mozilla Firefox\firefox.exe" (
    set "FF_DIR=%ProgramFiles(x86)%\Mozilla Firefox"
)

if not defined FF_DIR (
    echo [!] Firefox installation not found.
    echo     Expected location: %ProgramFiles%\Mozilla Firefox\
    pause
    exit /b 1
)

echo [i] Found Firefox at: %FF_DIR%

set "POLICY_DIR=%FF_DIR%\distribution"
set "POLICY_FILE=%POLICY_DIR%\policies.json"

:: Create distribution directory if it doesn't exist
if not exist "%POLICY_DIR%" (
    mkdir "%POLICY_DIR%"
    echo [i] Created directory: %POLICY_DIR%
)

:: Write policies.json
(
echo {
echo   "policies": {
echo     "DisableTelemetry": true,
echo     "NetworkPrediction": false,
echo     "DNSOverHTTPS": {
echo       "Enabled": true,
echo       "ProviderURL": "https://dns.quad9.net/dns-query",
echo       "Locked": true
echo     },
echo     "EnableTrackingProtection": {
echo       "Value": true,
echo       "Locked": true,
echo       "Cryptomining": true,
echo       "Fingerprinting": true,
echo       "EmailTracking": true,
echo       "Category": "strict"
echo     },
echo     "Cookies": {
echo       "Behavior": "reject-tracker-and-partition-foreign",
echo       "Locked": true
echo     },
echo     "TranslateEnabled": false,
echo     "SearchSuggestEnabled": false,
echo     "PasswordManagerEnabled": false,
echo     "AutofillAddressEnabled": true,
echo     "AutofillCreditCardEnabled": false,
echo     "OfferToSaveLogins": false,
echo     "PopupBlocking": {
echo       "Default": "block",
echo       "Locked": true
echo     },
echo     "Permissions": {
echo       "Location": {
echo         "BlockNewRequests": true,
echo         "Locked": true
echo       },
echo       "Notifications": {
echo         "BlockNewRequests": true,
echo         "Locked": true
echo       }
echo     },
echo     "AlternateErrorPages": false,
echo     "NewTabPage": false,
echo     "Homepage": {
echo       "StartPage": "none"
echo     },
echo     "SearchEngines": {
echo       "Default": "Google",
echo       "PreventInstalls": true
echo     },
echo     "ExtensionSettings": {
echo       "*": {
echo         "installation_mode": "blocked"
echo       }
echo     },
echo     "UserMessaging": {
echo       "ExtensionRecommendations": false,
echo       "FeatureRecommendations": false,
echo       "UrlbarInterventions": false,
echo       "MoreFromMozilla": false
echo     }
echo   }
echo }
) > "%POLICY_FILE%"

if %errorLevel% equ 0 (
    echo [✓] Firefox policies applied successfully!
    echo [i] Policy file: %POLICY_FILE%
    echo [i] Please restart Firefox for changes to take effect.
) else (
    echo [!] Failed to write policy file. Check permissions on %POLICY_DIR%.
)

pause
endlocal
