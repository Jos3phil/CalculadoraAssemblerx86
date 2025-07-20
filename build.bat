@echo off
echo ===============================================
echo COMPILANDO CALCULADORA GRÁFICA
echo ===============================================

REM Limpiar archivos anteriores
if exist calculator.exe del calculator.exe
if exist *.obj del *.obj
if exist *.res del *.res

REM Compilar recursos
echo Compilando recursos...
C:\masm32-sdk\bin\rc.exe /v calculator.rc
if errorlevel 1 goto error_rc

REM Compilar código assembly
echo Compilando código principal...
C:\masm32-sdk\bin\ml.exe /c /coff /Cp /nologo calculator.asm
if errorlevel 1 goto error_asm

REM Enlazar ejecutable
echo Enlazando ejecutable...
C:\masm32-sdk\bin\link.exe /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /OUT:calculator.exe calculator.obj calculator.res C:\masm32-sdk\lib\kernel32.lib C:\masm32-sdk\lib\user32.lib C:\masm32-sdk\lib\gdi32.lib
if errorlevel 1 goto error_link

REM Limpiar archivos temporales
echo Limpiando archivos temporales...
del calculator.res
del calculator.obj

echo ===============================================
echo COMPILACIÓN EXITOSA!
echo Ejecutable: calculator.exe
echo ===============================================
pause
goto end

:error_rc
echo ERROR: No se pudo compilar los recursos
pause
goto end

:error_asm
echo ERROR: No se pudo compilar el código assembly
pause
goto end

:error_link
echo ERROR: No se pudo enlazar el ejecutable
pause
goto end

:end