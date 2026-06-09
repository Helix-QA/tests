@echo off

set PROFILE=C:\temp\chrome_debug_profile

taskkill /IM chrome.exe /F >nul 2>&1
timeout /t 2 >nul

rd /s /q "%PROFILE%" >nul 2>&1

mkdir "%PROFILE%"