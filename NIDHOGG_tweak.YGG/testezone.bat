@echo off
setlocal

call :popup "Bom dia! Deseja continuar?" "Mensagem do Sistema"
goto fim

:popup
:: %1 = mensagem; %2 = título (opcional)
set "MB_MSG=%~1"
set "MB_TITLE=%~2"
if "%MB_TITLE%"=="" set "MB_TITLE=YGG"

:: PowerShell sem problemas com aspas
powershell -NoProfile -Command "[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $r = [System.Windows.Forms.MessageBox]::Show('%MB_MSG%','%MB_TITLE%',[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Warning); if ($r -eq [System.Windows.Forms.DialogResult]::Yes) { exit 0 } else { exit 1 }"

:: Resultado do popup
if %ERRORLEVEL%==0 (
    echo Yae...
    goto popup_yes
) else (
    echo Awn...
    goto popup_no
)

:popup_yes
goto fim

:popup_no
goto fim

:fim
pause
endlocal
exit /b
