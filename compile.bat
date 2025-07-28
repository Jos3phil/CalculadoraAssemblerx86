@echo off
cls
echo ===============================================
echo COMPILANDO CALCULADORA CIENTIFICA
echo ===============================================
echo.

REM Verificar que MASM32 esté instalado
if not exist "C:\masm32\bin\ml.exe" (
    echo ERROR: MASM32 no encontrado en C:\masm32\
    echo.
    echo Por favor instala MASM32 SDK desde:
    echo http://www.masm32.com/
    echo.
    echo Instalar en: C:\masm32\
    pause
    exit /b 1
)

echo Compilando recursos...
C:\masm32\bin\rc.exe /v CALCULATOR.RC
if errorlevel 1 (
    echo ERROR: No se pudo compilar los recursos
    pause
    exit /b 1
)

echo Compilando codigo principal...
C:\masm32\bin\ml.exe /c /coff /Cp /nologo CALCULATOR.ASM
if errorlevel 1 (
    echo ERROR: No se pudo compilar el codigo assembly
    pause
    exit /b 1
)

echo Enlazando ejecutable...
C:\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 ^
    /OUT:calculator.exe CALCULATOR.obj CALCULATOR.res ^
    C:\masm32\lib\kernel32.lib C:\masm32\lib\user32.lib ^
    C:\masm32\lib\gdi32.lib C:\masm32\lib\msvcrt.lib C:\masm32\lib\masm32.lib
if errorlevel 1 (
    echo ERROR: No se pudo enlazar el ejecutable
    pause
    exit /b 1
)

echo Limpiando archivos temporales...
if exist CALCULATOR.obj del CALCULATOR.obj
if exist CALCULATOR.res del CALCULATOR.res

echo.
echo ===============================================
echo COMPILACION EXITOSA!
echo Ejecutable: calculator.exe
echo ===============================================
echo.
echo Presiona cualquier tecla para ejecutar la calculadora...
pause > nul

REM Ejecutar la calculadora
if exist calculator.exe (
    echo Iniciando calculadora...
    start calculator.exe
) else (
    echo ERROR: No se encontro calculator.exe
    pause
)
