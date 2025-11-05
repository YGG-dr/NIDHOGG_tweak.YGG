@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title Níðhöggr
color 0d
mode con cols=80 lines=25

::   ===================================================
::
::                     NÍÐHÖGGR v2.1
::                      Made by YGG
::
::   ===================================================

::   ===================================================
::
::                   CONFIGURAÇÕES GLOBAIS
::
::   ...................................................
set "YGG_DIR=C:\ygg"
set "LOG_FILE=%YGG_DIR%\ygg_log.txt"
set "BACKUP_DIR=%YGG_DIR%\backup"
set "MODE=SAFE"

:: Criar diretórios se não existirem
if not exist "%YGG_DIR%" mkdir "%YGG_DIR%" 2>nul || (
    echo [ERRO] YGG falhou ao criar o diretório %YGG_DIR% ;-;.
    pause
    exit /b
)
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" 2>nul

::   ===================================================

::   ===================================================
::
::                      FUNÇÃO DE LOG
::
::   ...................................................
:log
echo [%date% %time%] %* >> "%LOG_FILE%"
goto :eof


::   ===================================================
::
::               FUNÇÃO DE CHECAGEM DE ADMIN
::
::   ...................................................
:check_admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] YGG precisa de permissões de administrador para operar...
    call :popup "YGG precisa de permissões de administrador!" "YGG"
    call :log "Falha ao elevar privilégios."
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
    exit /b
)

echo Obrigado pelas permissões de administrador, ^-^.
call :log "Permissões de administrador confirmadas."
goto :eof


::   ===================================================
::
::                FUNÇÃO DE BACKUP DE REGISTRO
::
::   ...................................................
:setBackup
setlocal
set "REG_KEY=%~1"
set "TAG=%~2"

if "%REG_KEY%"=="" (
    echo [ERRO] YGG não tem nenhuma chave especificada...
    exit /b 1
)
if "%TAG%"=="" (
    echo [ERRO] YGG não tem nenhuma tag especificada...
    exit /b 1
)

:: Timestamp seguro
for /f "delims=" %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set "TS=%%T"

:: Garante diretório
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: Caminho final do backup
set "SAFEFILE=%BACKUP_DIR%\%TAG%_%TS%.reg"

:: Executa export
reg export "%REG_KEY%" "%SAFEFILE%" /y >nul 2>&1

:: Resultado
if %errorlevel% equ 0 (
    call :echo_color 0a "[OK] Backup criado: %SAFEFILE%"
    call :log "Backup criado: %REG_KEY% -> %SAFEFILE%"
) else (
    call :echo_color 0c "[ERRO] Falha ao criar backup de %REG_KEY%"
    call :log "Falha no backup: %REG_KEY%"
)
endlocal
goto :eof


::   ===================================================
::
::              FUNÇÃO PARA EXECUTAR POWERSHELL
::
::   ...................................................
:psrun
setlocal EnableDelayedExpansion

set "PS_CMD=%*"
if "%PS_CMD%"=="" endlocal & goto :eof

set "TMP_PS=%TEMP%\ygg_psrun_%RANDOM%.ps1"

( 
    echo !PS_CMD!
) > "%TMP_PS%"

call :log "Executando o PowerShell: %TMP_PS% => %PS_CMD%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%TMP_PS%" >nul 2>&1
set "RC=%errorlevel%"

del "%TMP_PS%" >nul 2>&1

if %RC% neq 0 (
    call :log "Falha no PowerShell: %PS_CMD% (Código %RC%)"
)

endlocal
goto :eof



::   ===================================================
::
::                      BARRA DE PROGRESSO
::
::   ...................................................
:progress
set "PROG_MSG=%~1"
set /a SECS=%~2
<nul set /p = "%PROG_MSG%"
for /L %%i in (1,1,%SECS%) do (
    <nul set /p ="." 
    ping -n 2 127.0.0.1 >nul
)
echo.
goto :eof


::   ===================================================
::
::                           POPUP
::
::   ...................................................
:popup
set "MB_MSG=%~1"
set "MB_TITLE=%~2"
if "%MB_TITLE%"=="" set "MB_TITLE=YGG"

:: Escapa aspas internas
set "MB_MSG=%MB_MSG:"=`"%" 

powershell -NoProfile -Command ^
"[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); ^
$r = [System.Windows.Forms.MessageBox]::Show('%MB_MSG%','%MB_TITLE%',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information);"
goto :eof


::   ===================================================
::
::                     FUNÇÃO DE ECHO COLORIDO
::
::   ...................................................
:echo_color
:: %1 = cor, %2 = mensagem
set "COLOR=%~1"
set "MSG=%~2"
color %COLOR%
echo %MSG%
color 0d
goto :eof


::   ===================================================
::
::                     CREATE CHECKPOINT
::
::   ...................................................
:create_restore
cls
echo YGG está criando um checkpoint...
powershell -NoProfile -Command "Checkpoint-Computer -Description 'YGG checkpoint' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
if %errorlevel% equ 0 (
    call :echo_color 0a "[OK] Checkpoint criado com sucesso."
    call :log "Checkpoint criado com sucesso."
) else (
    call :echo_color 0c "[ERRO] Falha ao criar checkpoint. Verifique proteção do sistema."
    call :log "Falha ao criar checkpoint."
)
pause >nul
goto mainmenu


::   ===================================================
::
::                        MENU PRINCIPAL
::
::   ...................................................
:mainmenu
cls
echo ===================================================
echo.
echo             __  __ _____ _   _ _   _ 
echo            |  \/  | ____| \ | | | | |
echo            | |\/| |  _| |  \| | | | |
echo            | |  | | |___| |\  | |_| |
echo            |_|  |_|_____|_| \_|\____/
echo.
echo ..................................................
echo.
echo [01] Otimizações gerais do sistema
echo [02] Otimizações de energia
echo [03] Ajustes de mouse e teclado
echo [04] Otimizações da GPU
echo [05] Otimizações da CPU
echo [06] Limpeza e armazenamento
echo [07] Remoção de bloatwares
echo [08] Otimização da rede
echo [09] Otimização da memória
echo.
echo [10] Criar checkpoint
echo [11] Baixar e atualizar recursos
echo.
echo R. Restaurar
echo X. Sair
echo.
set /p "CHOICE=> "
echo ===================================================

if /i "%CHOICE%"=="10" goto create_restore
if /i "%CHOICE%"=="X"  goto :exit
if /i "%CHOICE%"=="R"  goto restore

echo [! ERROR !] YGG não entendeu seu pedido.
pause >nul
goto mainmenu


::   ===================================================
::
::                            SAÍDA
::
::   ...................................................
:exit
cls
echo Saindo do Níðhöggr V2.1...
echo Algumas alterações podem exigir reinicialização.
call :log "Níðhöggr encerrado."
endlocal
exit /b 0


::   ===================================================
::
::                        PONTO DE ENTRADA
::
::   ...................................................
call :check_admin
call :mainmenu
