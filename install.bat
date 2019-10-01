@echo off

set platform=%~1
set source=%~dp0%~1
set target=%~f2\_%~1_\Interface\AddOns

if "%platform%" == "" goto missing

if not exist "%source%" (
    set invalid=%source%
    goto invalid
)
if not exist "%target%" (
    set invalid=%target%
    goto invalid
)

echo Linking directories in %source% to %target%...

for /f %%f in ('dir /b "%source%"') do (
    mklink /D "%target%\%%f" "%source%\%%f"
)

goto :eof

:missing
echo %0: missing argument, e.g. %0 classic "C:\World of Warcraft"
exit /B 1

:invalid
echo %0: invalid argument "%invalid%"
exit /B 1
