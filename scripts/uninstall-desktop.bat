@echo off
setlocal
REM Uninstall Drone Flight Test Reporter from this Windows computer.

set "APP_ID=drone-flight-test-reporter"
set "APP_NAME=Drone Flight Test Reporter"
set "INSTALL_DIR=%LOCALAPPDATA%\%APP_ID%"
set "START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs"
set "DESKTOP=%USERPROFILE%\Desktop"

echo Uninstalling %APP_NAME%...

if exist "%INSTALL_DIR%" (
  rmdir /s /q "%INSTALL_DIR%"
  echo Removed app files: %INSTALL_DIR%
) else (
  echo No installed app files found at: %INSTALL_DIR%
)

del /f /q "%START_MENU%\%APP_NAME%.lnk" >nul 2>&1
del /f /q "%DESKTOP%\%APP_NAME%.lnk" >nul 2>&1

echo.
echo Uninstall complete.
echo.
echo Optional cleanup for cloned source / zip folders:
echo   rmdir /s /q "%USERPROFILE%\drone-flight-test-reporter-web"
echo   rmdir /s /q "%USERPROFILE%\Downloads\drone-flight-test-reporter-desktop-1.0.4"
endlocal
