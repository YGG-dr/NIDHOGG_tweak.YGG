@echo off
setlocal

:: Chamada inicial do popup
call :popup "Bom dia" "Olá"

pause
exit /b

:popup
:: %1 = mensagem; %2 = título (opcional)
set "MB_MSG=%~1"
set "MB_TITLE=%~2"

if "%MB_TITLE%"=="" set "MB_TITLE=YGG"

:: PowerShell para exibir popup com botões Yes/No
powershell -NoProfile -Command ^
 "[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');" ^
 "$r = [System.Windows.Forms.MessageBox]::Show('%MB_MSG%','%MB_TITLE%'," ^
 "[System.Windows.Forms.MessageBoxButtons]::YesNo," ^
 "[System.Windows.Forms.MessageBoxIcon]::Warning);" ^
 "if ($r -eq [System.Windows.Forms.DialogResult]::Yes) { exit 0 } else { exit 1 }"

if %ERRORLEVEL%==0 (
    echo Yae...
    goto popup_yes
) else (
    echo Awn...
    goto popup_no
)

:: nunca deveria chegar aqui
exit /b

:popup_yes
echo Você clicou YES
goto :eof

:popup_no
echo Você clicou NO
goto :eof
