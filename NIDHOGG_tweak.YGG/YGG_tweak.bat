@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title Nõhǫggr
color 0d
if not "%1" == "max" start /MAX cmd /c %0 max & exit/b

::   ===================================================
::
::                     NõHǫGGR v2.1
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
if not exist "%YGG_DIR%" (
    mkdir "%YGG_DIR%" 2>nul
    if errorlevel 1 (
        echo [⚠. ERRO .⚠] YGG falhou ao criar o diretório %YGG_DIR% ;-;.
        pause
        exit /b 1
    )
)
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" 2>nul


::   ===================================================
::
::                     FUNÇÃO DE LOG
::
::   ...................................................
:log
>> "%LOG_FILE%" echo [%date% %time%] %*
goto :eof


::   ===================================================
::
::                FUNÇÃO DE CHECAGEM DE ADMIN
::
::   ...................................................
:check_admin
net session >nul 2>&1
if %errorlevel% equ 0 (
    echo Obrigado pelas permissões de administrador, ^-^.
    call :log "Permissões de administrador confirmadas."
    goto :eof
)

call :popup "Por favor, eleve-me a administrador para operar corretamente." "Elevação necessária"
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
set "PSRC=%errorlevel%"

if %PSRC% equ 0 (
    call :log "Start-Process executado com sucesso; encerrando instância atual para permitir instância elevada."
    exit /b 0
) else (
    call :log "Start-Process falhou ou foi cancelado (código %PSRC%)."
    call :echo_color 0c "A elevação foi cancelada ou falhou."
    echo Deseja continuar sem privilégios de administrador? [S/N]
    set /p "ANS=> "
    if /i "%ANS%"=="S" (
        call :log "Usuário optou por continuar sem admin (Start-Process falhou)"
        goto :eof
    ) else (
        call :log "Usuário optou por encerrar após a falha na elevação."
        exit /b 1
    )
)
goto :eof


::   ===================================================
::
::                 FUNÇÃO DE BACKUP DE REGISTRO
::          Usage: call :setBackup "HKLM\SOFTWARE\..." "TAG"
::
::   ...................................................
:setBackup
setlocal
set "REG_KEY=%~1"
set "TAG=%~2"

if "%REG_KEY%"=="" (
    echo [⚠. ERRO .⚠] YGG não tem nenhuma chave especificada...
    endlocal
    exit /b 1
)
if "%TAG%"=="" (
    echo [⚠. ERRO .⚠] YGG não tem nenhuma tag especificada...
    endlocal
    exit /b 1
)

for /f "delims=" %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set "TS=%%T"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

set "SAFEFILE=%BACKUP_DIR%\%TAG%_%TS%.reg"

reg export "%REG_KEY%" "%SAFEFILE%" /y >nul 2>&1
if errorlevel 1 (
    call :echo_color 0c "[⚠. ERRO .⚠] Falha ao criar backup de %REG_KEY%"
    call :log "Falha no backup: %REG_KEY%"
    endlocal
    exit /b 1
) else (
    call :echo_color 0a "[OK] Backup criado: %SAFEFILE%"
    call :log "Backup criado: %REG_KEY% -> %SAFEFILE%"
)
endlocal
goto :eof


::   ===================================================
::
::        FUNÇÃO PARA EXECUTAR POWERSHELL TEMPORÁRIO
::            Usage: call :psrun <command...>
::
::   ...................................................
:psrun
setlocal EnableDelayedExpansion
set "PS_CMD=%*"
if "%PS_CMD%"=="" endlocal & goto :eof

set "TMP_PS=%TEMP%\ygg_psrun_%RANDOM%.ps1"
(
    echo %PS_CMD%
) > "%TMP_PS%"

call :log "Executando o PowerShell: %TMP_PS% => %PS_CMD%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%TMP_PS%" >nul 2>&1
set "RC=%errorlevel%"
del "%TMP_PS%" >nul 2>&1

if %RC% neq 0 call :log "Falha no PowerShell: %PS_CMD% (Código %RC%)"
endlocal
goto :eof


::   ===================================================
::
::                     BARRA DE PROGRESSO
::           Usage: call :progress "Mensagem" segundos
::
::   ...................................................
:progress
set "PROG_MSG=%~1"
set /a SECS=%~2 2>nul
if "%SECS%"=="" set /a SECS=3

<nul set /p = "%PROG_MSG% "
for /L %%i in (1,1,%SECS%) do (
    <nul set /p ="." 
    ping -n 2 127.0.0.1 >nul
)
echo.
goto :eof


::   ===================================================
::
::                  POPUP (MessageBox)
::      Usage: call :popup "mensagem" "titulo"
::
::   ...................................................
:popup
setlocal
set "MB_MSG=%~1"
set "MB_TITLE=%~2"
if "%MB_TITLE%"=="" set "MB_TITLE=YGG"

set "MB_MSG_ESC=%MB_MSG:"=""%"
powershell -NoProfile -Command ^
"Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('%MB_MSG_ESC%','%MB_TITLE%',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)" >nul 2>&1
endlocal
goto :eof


::   ===================================================
::
::                     ECHO COLORIDO
::     Usage: call :echo_color <hexColor> "Mensagem"
::     Ex: call :echo_color 0a "Texto verde"
::
::   ...................................................
:echo_color
setlocal
set "COLOR=%~1"
set "MSG=%~2"
if "%COLOR%"=="" set "COLOR=0d"
color %COLOR% 2>nul
echo %MSG%
color 0d 2>nul
endlocal
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
    call :echo_color 0c "[⚠. ERRO .⚠] Falha ao criar checkpoint. Verifique Proteção do Sistema (System Restore)."
    call :log "Falha ao criar checkpoint."
)
pause >nul
goto mainmenu


::   ===================================================
::
::                      RESTORE (R)
::      Restaura backup .reg existente ou selecionado
::
::   ...................................................
:restore
cls
echo Procurando backups em %BACKUP_DIR%...
if not exist "%BACKUP_DIR%\*.reg" (
    call :echo_color 0c "Nenhum backup encontrado em %BACKUP_DIR%."
    pause >nul
    goto mainmenu
)

setlocal enabledelayedexpansion
set i=0
for /f "delims=" %%F in ('dir /b /o:-d "%BACKUP_DIR%\*.reg"') do (
    set /a i+=1
    set "file[!i!]=%%F"
    echo [!i!] %%F
)
echo.
echo Selecione o número do backup a restaurar (0 = cancelar):
set /p "SEL=> "
if "%SEL%"=="" goto :restore_cancel
if "%SEL%"=="0" goto :restore_cancel

set "TARGET=!file[%SEL%]!"
if not defined TARGET (
    call :echo_color 0c "Seleção inválida."
    endlocal
    pause
    goto mainmenu
)

echo Você quer importar "%TARGET%"? [S/N]
set /p "CONF=> "
if /i "%CONF%" NEQ "S" (
    endlocal
    goto mainmenu
)

set "TARGET_FULL=%BACKUP_DIR%\%TARGET%"
reg import "%TARGET_FULL%" >nul 2>&1
if %errorlevel% equ 0 (
    call :echo_color 0a "[OK] Importado: %TARGET% (pode ser necessário reiniciar)."
    call :log "Restauração realizada: %TARGET_FULL%"
) else (
    call :echo_color 0c "[⚠. ERRO .⚠] Falha ao importar %TARGET%. Verifique permissões e formato do arquivo."
    call :log "Falha ao importar: %TARGET_FULL% (código %errorlevel%)"
)
endlocal
pause >nul
goto mainmenu

:restore_cancel
endlocal
goto mainmenu


::   ===================================================
::
::                     MENU PRINCIPAL
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
echo Bem-vindo(a) ao Nõhǫggr.
echo.
if "%MODE%" equ "EXTREME" (
    call :popup "Tenha muito cuidado: você está usando o modo %MODE%" "Aviso"
    call :echo_color 0e "Opere com muito cuidado!"
)
echo.
echo [01] ~ Otimizações gerais do sistema
echo [02] ~ Otimizações de energia
echo [03] ~ Ajustes de mouse e teclado
echo [04] ~ Otimizações da GPU
echo [05] ~ Otimizações da CPU
echo [06] ~ Limpeza e armazenamento
echo [07] ~ Remoção de bloatwares
echo [08] ~ Otimização da rede
echo [09] ~ Otimização da memória
echo.
echo [10] ~ Criar checkpoint
echo [11] ~ Baixar e atualizar recursos
echo.
echo R. Restaurar
echo X. Sair
echo.
set /p "CHOICE=> "
echo ===================================================

if /i "%CHOICE%"=="10" goto create_restore
if /i "%CHOICE%"=="X"  goto :exit
if /i "%CHOICE%"=="R"  goto restore

if /i "%CHOICE%"=="01" call :echo_color 0b "Opção 01 selecionada — (implementação pendente)."
if /i "%CHOICE%"=="02" call :echo_color 0b "Opção 02 selecionada — (implementação pendente)."
if /i "%CHOICE%"=="03" call :echo_color 0b "Opção 03 selecionada — (implementação pendente)."
pause >nul
goto mainmenu


::   ===================================================
::
::                         SAÍDA
::
::   ...................................................
:exit
cls
echo Saindo do Nõhǫggr V2.1...
echo Algumas alterações podem exigir reinicialização.
call :log "Nõhǫggr encerrado."
endlocal
exit /b 0


::   ===================================================
::
::                      PONTO DE ENTRADA
::
::   ...................................................
call :check_admin
call :mainmenu

pause
