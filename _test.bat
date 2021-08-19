call _build.bat
if %ERRORLEVEL% == 0 build\PYmodsInstaller.exe /LOG="build\debug.log"
