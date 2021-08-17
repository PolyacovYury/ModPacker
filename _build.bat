@echo off
@chcp 1251
iscc __init__.iss
if not %ERRORLEVEL% == 0 pause
