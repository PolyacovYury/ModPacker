call _build.bat
if %ERRORLEVEL% == 0 start build\PYmodsInstaller.exe /LOG="build\debug.log"
