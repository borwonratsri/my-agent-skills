@echo off
setlocal
rem Launcher: installs the pinned upstream gh release for this machine on first
rem use (verifying its SHA-256), then runs it.
set "TOOL=gh"
set "PLUGIN_VERSION=0.0.8"
set "GH_VERSION=2.103.3"
set "BASE_URL=https://github.com/cli/cli/releases/download/v%GH_VERSION%"

set "IS_FALLBACK=0"
if "%ANTIGRAVITY_APP_DATA_DIR%"=="" (
  set "ANTIGRAVITY_APP_DATA_DIR=%USERPROFILE%\.gemini\antigravity"
  set "IS_FALLBACK=1"
)

rem This script lives at <plugin>\skills\<skill>\scripts\, three levels below
rem the plugin's install directory.
for %%I in ("%~dp0..\..\..") do set "PLUGIN_DIR_NAME=%%~nxI"
set "BIN_DIR=%ANTIGRAVITY_APP_DATA_DIR%\plugin_data\%PLUGIN_DIR_NAME%\bin"
set "TARGET=%BIN_DIR%\%TOOL%-%GH_VERSION%.exe"

if not exist "%ANTIGRAVITY_APP_DATA_DIR%\bin" mkdir "%ANTIGRAVITY_APP_DATA_DIR%\bin" >nul 2>nul
if not exist "%ANTIGRAVITY_APP_DATA_DIR%\bin\%TOOL%.cmd" (
  (
    echo @echo off
    echo setlocal
    echo call "%~f0" %%*
    echo exit /b %%ERRORLEVEL%%
  ) > "%ANTIGRAVITY_APP_DATA_DIR%\bin\%TOOL%.cmd" 2>nul
  if "%IS_FALLBACK%"=="0" echo Registered '%TOOL%' into PATH. It can now be run directly. 1>&2
)

if exist "%TARGET%" goto run

set "ASSET=gh_%GH_VERSION%_windows_amd64.zip"
set "SHA256=98d0cfa794721665d7973dd728c78aff7bd836d58f10f6d7a03568eccb0a22e0"
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" goto arm64
if /i "%PROCESSOR_ARCHITEW6432%"=="ARM64" goto arm64
goto download
:arm64
set "ASSET=gh_%GH_VERSION%_windows_arm64.zip"
set "SHA256=197211c98687d7770ac331fe8a3b6c198c389108c1536cdbedf659fe4703e484"

:download
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
del /q "%BIN_DIR%\%TOOL%-*" 2>nul
set "WORK=%BIN_DIR%\.%TOOL%.tmp.%RANDOM%"
mkdir "%WORK%"
curl.exe -fsSL "%BASE_URL%/%ASSET%" -o "%WORK%\%ASSET%"
if errorlevel 1 (
  rmdir /s /q "%WORK%" 2>nul
  echo error: failed to download %BASE_URL%/%ASSET% 1>&2
  exit /b 1
)
powershell -NoProfile -Command "if ((Get-FileHash -Algorithm SHA256 -LiteralPath '%WORK%\%ASSET%').Hash -ne '%SHA256%') { exit 1 }"
if errorlevel 1 (
  rmdir /s /q "%WORK%" 2>nul
  echo error: checksum mismatch for %ASSET% 1>&2
  exit /b 1
)
rem The Windows zip unpacks to bin\gh.exe with no top-level directory.
tar.exe -xf "%WORK%\%ASSET%" -C "%WORK%"
if errorlevel 1 (
  rmdir /s /q "%WORK%" 2>nul
  echo error: failed to extract %ASSET% 1>&2
  exit /b 1
)
move /y "%WORK%\bin\gh.exe" "%TARGET%" >nul
rmdir /s /q "%WORK%" 2>nul

:run
if "%GH_PROMPT_DISABLED%"=="" set "GH_PROMPT_DISABLED=1"
if "%GH_NO_UPDATE_NOTIFIER%"=="" set "GH_NO_UPDATE_NOTIFIER=1"
if "%GH_PAGER%"=="" set "GH_PAGER=cat"
rem With the terminal sandbox off, Antigravity puts a plugin-cli shim for gh on
rem PATH, which runs gh with the connected account's token. Hand off to it; it
rem finds this launcher through bin\gh.cmd and runs it again with GH_TOKEN set.
if not "%GH_TOKEN%%GITHUB_TOKEN%%AGY_GH_HANDED_OFF%"=="" goto exec
if "%ANTIGRAVITY_PLUGIN_SHIM_DIR%"=="" goto exec
if not exist "%ANTIGRAVITY_PLUGIN_SHIM_DIR%\%TOOL%.cmd" goto exec
set "AGY_GH_HANDED_OFF=1"
set "PATH=%ANTIGRAVITY_APP_DATA_DIR%\bin;%PATH%"
call "%ANTIGRAVITY_PLUGIN_SHIM_DIR%\%TOOL%.cmd" %*
exit /b %ERRORLEVEL%

:exec
"%TARGET%" %*
exit /b %ERRORLEVEL%
