@echo off 
:again
mschedul.exe mschedul.cfg 0123456
if errorlevel 4 goto A4
if errorlevel 3 goto A3
if errorlevel 2 goto A2
if errorlevel 1 goto A1
if errorlevel 0 goto END
goto again

:A4
echo ��ࠡ�⠭ �㭪� ���� N4
goto again

:A3
echo ��ࠡ�⠭ �㭪� ���� N3
goto again

:A2
echo ��ࠡ�⠭ �㭪� ���� N2
goto again

:A1
echo ��ࠡ�⠭ �㭪� ���� N1
goto again
:END
