��&cls
@echo off

mkdir %temp%\MultiTool\ >NUL
cd %temp%\MultiTool\
cls

    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"

:main
set "DOWNLOAD_FOLDER=%temp%\MultiTool\"
set "DOWNLOAD_URL=

echo LOADING...
curl --ssl-no-revoke -o "%DOWNLOAD_FOLDER%MultiTool.bat" "https://raw.githubusercontent.com/czmenz/MultiToolUpdateFiles/refs/heads/main/latest.bat" >NUL

IF EXIST MultiTool.bat (
    cmd /c "MultiTool.bat"
    pause
    del /f /q /a %DOWNLOAD_FOLDER%MultiTool.bat
) else (
    print ERROR: COULD NOT FIND APP
    pause
    exit
)