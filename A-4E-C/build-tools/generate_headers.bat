@echo off
set script_path=%~dp0
cd %script_path%
cd ..
"%script_path%\lua\lua54.exe" "%script_path%\generate_headers.lua" "%CD%"