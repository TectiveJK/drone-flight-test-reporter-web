@echo off
setlocal
REM Install Drone Flight Test Reporter as a desktop app on Windows.

set "APP_ID=drone-flight-test-reporter"
set "APP_NAME=Drone Flight Test Reporter"
set "INSTALL_DIR=%LOCALAPPDATA%\%APP_ID%"
set "START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs"
set "DESKTOP=%USERPROFILE%\Desktop"

cd /d "%~dp0"
if exist "index.html" (
  set "SOURCE_ROOT=%cd%"
) else if exist "..\index.html" (
  pushd ..
  set "SOURCE_ROOT=%cd%"
  popd
) else (
  echo Could not find app files next to this installer.
  exit /b 1
)

echo Installing %APP_NAME% to %INSTALL_DIR%
if exist "%INSTALL_DIR%" rmdir /s /q "%INSTALL_DIR%"
mkdir "%INSTALL_DIR%"

xcopy "%SOURCE_ROOT%\*" "%INSTALL_DIR%\" /E /I /Y /Q >nul

REM Prefer Chrome, then Edge.
set "BROWSER="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"

if not defined BROWSER (
  echo Chrome or Edge was not found. Install Chrome, then run this installer again.
  exit /b 1
)

(
  echo @echo off
  echo setlocal
  echo cd /d "%%~dp0"
  echo for /f %%%%p in ('powershell -NoProfile -Command "$l=New-Object System.Net.Sockets.TcpListener([Net.IPAddress]::Loopback,0);$l.Start();$p=$l.LocalEndpoint.Port;$l.Stop();$p"'^) do set PORT=%%%%p
  echo start /b python -m http.server %%PORT%% --bind 127.0.0.1
  echo timeout /t 1 /nobreak ^>nul
  echo start "" "%BROWSER%" --new-window --app="http://127.0.0.1:%%PORT%%/index.html"
) > "%INSTALL_DIR%\launch-desktop.bat"

powershell -NoProfile -Command ^
  "$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut('%START_MENU%\%APP_NAME%.lnk'); $sc.TargetPath = '%INSTALL_DIR%\launch-desktop.bat'; $sc.WorkingDirectory = '%INSTALL_DIR%'; $sc.IconLocation = '%INSTALL_DIR%\icons\icon-512.png'; $sc.Save(); $sc2 = $ws.CreateShortcut('%DESKTOP%\%APP_NAME%.lnk'); $sc2.TargetPath = '%INSTALL_DIR%\launch-desktop.bat'; $sc2.WorkingDirectory = '%INSTALL_DIR%'; $sc2.IconLocation = '%INSTALL_DIR%\icons\icon-512.png'; $sc2.Save()"

echo.
echo Installed successfully.
echo Open "%APP_NAME%" from the Start Menu or Desktop shortcut.
echo.
set /p ANSWER=Launch now? [Y/n] 
if /I "%ANSWER%"=="n" goto :eof
start "" "%INSTALL_DIR%\launch-desktop.bat"
