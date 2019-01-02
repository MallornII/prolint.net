echo off
set ProKey=none
for /F "tokens=* USEBACKQ" %%r in (`reg query HKLM\Software\PSC\PROGRESS ^| findstr 11`) do (
    set ProKey=%%r	
)

if "%ProKey%"=="none" (
mshta "javascript:alert('Progress version 11 not found');close()"
exit 0
)

for /f "tokens=3" %%a in ('reg query "%ProKey%"  /v installPath ^| findstr /ri "REG_SZ"') do set DLC=%%a

set PROPATH=%cd%,%cd%\Prolint.pl

start %DLC%\bin\prowin.exe -p Prolint/launch.r -pf %cd%\prolint.pf