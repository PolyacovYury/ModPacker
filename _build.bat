@echo off
@chcp 1251
py -3 src/component_generator.py
if not %ERRORLEVEL% == 0 pause
iscc __init__.iss
if not %ERRORLEVEL% == 0 pause
