@echo off

pushd %~dp0

set source=%~f1
set target=%~f2\Interface\AddOns

if not exist "%source%" (
    set invalid=%source%
    goto invalid
)
if not exist "%target%" (
    set invalid=%target%
    goto invalid
)

echo Linking directories in %source% to %target%...

for /f %%d in ('dir /b "%source%"') do if exist "%source%\%%d\*" (
    mklink /D "%target%\%%d" "%source%\%%d"
)

popd

goto :eof

:missing
echo %0: Missing argument, e.g. %0 ".\classic" "C:\World of Warcraft\_classic_"
exit /B 1

:invalid
echo %0: Not a valid path "%invalid%"
exit /B 1
