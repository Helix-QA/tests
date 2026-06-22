@echo off
echo Закрываю все процессы Google Chrome...

taskkill /F /IM chrome.exe >nul 2>&1

echo.
echo Готово! Все сеансы Chrome были завершены.
timeout /t 2 >nul