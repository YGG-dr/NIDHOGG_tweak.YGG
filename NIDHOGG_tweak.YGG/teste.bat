@echo off
REM ::==================================================::
REM ::                                                  ::
REM ::       --- Níðhöggr v2 • Made by ¥ऊ€_แㄨΘ ---     ::
REM ::                                                  ::
REM ::==================================================::

:: ===================================================
:: CONFIGURAÇÕES GLOBAIS
:: ===================================================
setlocal EnableDelayedExpansion
title Níðhöggr v2 - YGG Optimizer
color 0A

set "YGG_DIR=C:\ygg"
set "LOG_FILE=%YGG_DIR%\ygg_log.txt"
set "BACKUP_DIR=%YGG_DIR%\backup"
set "MODE=SAFE"  :: Padrão: SAFE (ou use argumento extreme/safe)

if not exist "%YGG_DIR%"    mkdir "%YGG_DIR%"    2>nul
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" 2>nul

:: ===================================================
:: FUNÇÃO DE LOG
:: ===================================================
:log
:: TECH: escreve no arquivo de log com timestamp
:: NOTE: útil para auditoria e resolver falhas depois
echo [%date% %time%] %* >> "%LOG_FILE%"
goto :eof

:: ===================================================
:: VERIFICAÇÃO DE ADMINISTRADOR
:: ===================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Este script precisa de privilégios de administrador.
    call :log ""
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs"
    exit /b
)
call :log "Admin check passed"

:: ===================================================
:: FUNÇÃO DE BACKUP DE REGISTRO (usada antes de alterações)
:: ===================================================
:setBackup


:: ===================================================
:: EXECUÇÃO SEGURA DO POWERSHELL
:: ===================================================
:psrun
:: %1 = comando PS (entre aspas)
set "PS_CMD=%~1"
if "%PS_CMD%"=="" goto :eof
call :log "Running PowerShell: %PS_CMD%"
Powershell -NoProfile -ExecutionPolicy Bypass -Command "%PS_CMD%" >nul 2>&1
if %errorlevel% neq 0 call :log "PowerShell failed: %PS_CMD%"
goto :eof

:: ===================================================
:: MODO SAFE OU EXTREME (argumento)
:: ===================================================
if /i "%~1"=="extreme" set "MODE=EXTREME"
if /i "%~1"=="safe"    set "MODE=SAFE"
call :log "Starting Nidhoggr v2 with mode %MODE%"

:: ===================================================
:: FUNÇÃO PROGRESSO (simples)
:: ===================================================
:progress
:: %1 = mensagem ; %2 = segundos (integer)
set "PROG_MSG=%~1"
set /a SECS=%~2
<nul set /p ="%PROG_MSG% "
for /L %%i in (1,1,%SECS%) do (
    <nul set /p ="." 
    ping -n 2 127.0.0.1 >nul
)
echo.
goto :eof

:: ===================================================
:: MENU PRINCIPAL
:: ===================================================
:mainmenu
cls
echo ===================================================
echo.
echo           Níðhöggr v2 — Menu (Modo: %MODE%)
echo.
echo ..................................................
echo 01. Otimizações gerais do sistema.
echo 02. Otimizações de energia.
echo 03. Ajustes de mouse e teclado.
echo 04. Otimizações da placa de vídeo.
echo 05. Otimizações do processador.
echo 06. Limpeza e armazenamento.
echo 07. Remoção de bloatwares.
echo 08. Otimização da rede.
echo 09. Otimização da memoria.
echo 10. Criar checkpoint.
echo 11. Baixar e atualizar recursos.
echo.
echo R. Restaurar
echo X. Sair
echo.
set /p "CHOICE=O que você quer que YGG faça?: "
echo ===================================================

if /i "%CHOICE%"=="1"  goto opt_general
if /i "%CHOICE%"=="2"  goto opt_power
if /i "%CHOICE%"=="3"  goto opt_input
if /i "%CHOICE%"=="4"  goto opt_gpu
if /i "%CHOICE%"=="5"  goto opt_cpu
if /i "%CHOICE%"=="6"  goto opt_storage
if /i "%CHOICE%"=="7"  goto opt_debloat
if /i "%CHOICE%"=="8"  goto opt_network
if /i "%CHOICE%"=="9"  goto opt_memory
if /i "%CHOICE%"=="10" goto create_restore
if /i "%CHOICE%"=="11" goto resources
if /i /i "%CHOICE%"=="R"  goto revertmenu
if /i "%CHOICE%"=="X"  goto :exit

echo [!] YGG não entendeu seu pedido.
pause >nul
goto mainmenu

:: ===================================================
:: CRIAR CHECKPOINT / RESTORE POINT
:: ===================================================
:create_restore
cls
echo YGG está criando um checkpoint...
:: TECH: Verifica se System Restore está habilitado (simples tentativa)
powershell -NoProfile -Command "Get-ComputerRestorePoint" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Verifique se a Proteção do Sistema está habilitada na unidade C: antes.
    call :log "Restore point failed: Get-ComputerRestorePoint returned %errorlevel%"
) else (
    Powershell -NoProfile -Command "Checkpoint-Computer -Description 'YGG checkpoint' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
    if %errorlevel% equ 0 (
        echo Ponto de restauração criado com sucesso.
        call :log "Checkpoint created"
    ) else (
        echo Falha ao criar ponto de restauração.
        call :log "Checkpoint creation failed with %errorlevel%"
    )
)
pause >nul
goto mainmenu

:: ===================================================
:: DOWNLOAD DE RECURSOS
:: ===================================================
:resources
cls
echo YGG está baixando pacotes para %YGG_DIR% ...
call :progress "Baixando resources" 3
set "RESOURCE_URL=https://github.com/ygg4L/yggresources/raw/49a210cc246950fbe006397db88d11ef1447e4c1/8.0.zip"
if exist "%temp%\ygg.zip" del "%temp%\ygg.zip" >nul 2>&1
curl -g -k -L -# -o "%temp%\ygg.zip" "%RESOURCE_URL%" >nul 2>&1
if exist "%temp%\ygg.zip" (
    Powershell -NoProfile -Command "Expand-Archive -LiteralPath '%temp%\ygg.zip' -DestinationPath '%YGG_DIR%' -Force" >nul 2>&1
    echo Recursos baixados e extraídos em %YGG_DIR%.
    call :log "Resources downloaded to %YGG_DIR%"
) else (
    echo Falha no download. Verifique a URL ou conexão.
    call :log "Resource download failed"
)
pause >nul
goto mainmenu

:: ===================================================
:: OTIMIZAÇÕES GERAIS
:: ===================================================
:opt_general
cls
echo YGG está aplicando otimizações gerais...
call :log "General optimizations started (mode %MODE%)"

:: TECH: reduzir animações do Windows
:: NOTE: melhora a sensação de rapidez, principalmente em máquinas fracas
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1

if /i "%MODE%"=="EXTREME" (
    call :log "EXTREME: disabling WSearch"
    sc config "WSearch" start= disabled >nul 2>&1
    sc stop "WSearch" >nul 2>&1
)

call :progress "Aplicando ajustes" 2
echo Concluído.
call :log "General optimizations finished"
pause >nul
goto mainmenu

:: ===================================================
:: OTIMIZAÇÕES DE ENERGIA
:: ===================================================
:opt_power
cls
echo YGG está alterando o plano de energia...
call :log "Power tweaks started"

:: TECH: criar ou usar plano de alto desempenho (conservador)
:: NOTE: Em laptops, isso aumenta consumo; o usuário deve decidir.
powercfg -duplicatescheme SCHEME_MIN >nul 2>&1
powercfg -change -standby-timeout-ac 0 >nul 2>&1
powercfg -change -hibernate-timeout-ac 0 >nul 2>&1

call :progress "Configurando plano de energia" 2
echo Pronto.
call :log "Power tweaks applied"
pause >nul
goto mainmenu

:: ===================================================
:: MOUSE E TECLADO
:: ===================================================
:opt_input
cls
echo YGG ajustando mouse e teclado...
call :log "Input tweaks"

reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d 10 /f >nul 2>&1

echo Ajustes aplicados.
call :log "Input tweaks applied"
pause >nul
goto mainmenu

:: ===================================================
:: GPU
:: ===================================================
:opt_gpu
cls
echo YGG: Otimizacoes de GPU (guia/manual).
call :log "GPU optimizations - manual guidance"
echo Se o NVProfileInspector estiver em %YGG_DIR% use-o para perfis de jogo.
pause >nul
goto mainmenu

:: ===================================================
:: CPU
:: ===================================================
:opt_cpu
cls
echo YGG está otimizando a CPU...
call :log "CPU optimizations started"

:: Back up relevante (exemplo genérico)
call :setBackup "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings" "cpu_powersettings"

if /i "%MODE%"=="EXTREME" (
    echo [!] Modo EXTREME: operações agressivas (core parking) estão comentadas por segurança.
    :: NOTE: Descomente e adapte com GUID correto somente se souber o que faz.
) else (
    :: TECH: configurar limites conservadores de processador
    powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5 >nul 2>&1
    powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >nul 2>&1
    powercfg -S SCHEME_CURRENT >nul 2>&1
)

call :log "CPU optimizations finished"
echo Pronto.
pause >nul
goto mainmenu

:: ===================================================
:: LIMPEZA E ARMAZENAMENTO
:: ===================================================
:opt_storage
cls
echo YGG limpando arquivos temporarios...
call :log "Storage cleanup started"

:: TECH: apagar temp (com cautela)
rd /s /q "%temp%" >nul 2>&1 || del /s /q "%temp%\*" >nul 2>&1
rd /s /q "C:\Windows\Temp" >nul 2>&1 || del /s /q "C:\Windows\Temp\*" >nul 2>&1

if /i "%MODE%"=="EXTREME" (
    call :log "EXTREME: running DISM cleanup"
    Powershell -NoProfile -Command "Start-Process -FilePath dism.exe -ArgumentList '/online','/Cleanup-Image','/StartComponentCleanup','/ResetBase' -Wait -NoNewWindow" >nul 2>&1
)

call :progress "Limpando" 3
echo Limpeza concluida.
call :log "Storage cleanup finished"
pause >nul
goto mainmenu

:: ===================================================
:: REMOÇÃO DE BLOATWARE
:: ===================================================
:opt_debloat
cls
echo Remoção de aplicativos (bloatware):
echo 1) Remoção segura (SAFE)
echo 2) Remoção completa (EXTREME) - DANGEROUS
echo M) Voltar
set /p "DCH=Escolha: "

if /i "%DCH%"=="M" goto mainmenu

if /i "%DCH%"=="1" (
    call :log "Debloat SAFE started"
    call :psrun "Get-AppxPackage -AllUsers *3D* | Remove-AppxPackage"
    call :psrun "Get-AppxPackage -AllUsers *Microsoft.XboxGamingOverlay* | Remove-AppxPackage"
    echo Remoção (SAFE) concluída.
    call :log "Debloat SAFE finished"
) else if /i "%DCH%"=="2" (
    echo [!] Modo EXTREME selecionado. Fazendo backup antes de remover muitos Appx.
    call :psrun "Get-AppxPackage -AllUsers | Export-CliXml -Path '%YGG_DIR%\allusers_appx.xml'"
    call :log "Debloat EXTREME backup exported"
    :: Exemplos de remoção agressiva (cuidado)
    call :psrun "Get-AppxPackage -AllUsers *Microsoft.Xbox* | Remove-AppxPackage"
    call :psrun "Get-AppxPackage -AllUsers *Microsoft.549981C3F5F10* | Remove-AppxPackage"
    echo Remoção (EXTREME) concluída.
    call :log "Debloat EXTREME finished"
) else (
    echo Opcao invalida.
)
pause >nul
goto mainmenu

:: ===================================================
:: REDE
:: ===================================================
:opt_network
cls
echo YGG aplicando otimizações de rede...
call :log "Network tweaks started"

:: Backup chave tcpip
call :setBackup "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "tcpip_params"

:: Ajustes conservadores
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f >nul 2>&1

if /i "%MODE%"=="EXTREME" (
    echo [!] EXTREME: IPv6 pode ser desativado - operação perigosa.
    :: Desativar IPv6 comentado por segurança. Descomente se souber o que faz:
    :: reg add "HKLM\SYSTEM\CurrentControlSet\Services\TCPIP6\Parameters" /v DisabledComponents /t REG_DWORD /d 0xffffffff /f >nul 2>&1
)

call :progress "Aplicando rede" 2
echo Otimizacoes de rede aplicadas.
call :log "Network tweaks applied"
pause >nul
goto mainmenu

:: ===================================================
:: MEMÓRIA
:: ===================================================
:opt_memory
cls
echo YGG ajustando memoria e paginação...
call :log "Memory tweaks started"

call :setBackup "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "memory_mgmt"

if /i "%MODE%"=="EXTREME" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PagingFiles /t REG_MULTI_SZ /d "C:\pagefile.sys 1024 4096" /f >nul 2>&1
    echo Paging file definido (EXTREME).
else (
    :: Restaurar gerenciado pelo sistema (remover entrada personalizada)
    reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PagingFiles /f >nul 2>&1
    echo Paging file setado para gerenciado pelo sistema.
)
call :log "Memory tweaks finished"
pause >nul
goto mainmenu

:: ===================================================
:: RESTAURAR / REVERT
:: ===================================================
:revertmenu
cls
echo Restauração / Reversão:
echo 1) Usar Restauração do Sistema (rstrui)
echo 2) Restaurar backups do registro (pasta: %BACKUP_DIR%)
echo M) Voltar
set /p "RCH=Escolha: "
if /i "%RCH%"=="1" (
    rstrui.exe
    goto mainmenu
)
if /i "%RCH%"=="2" (
    echo Importando backups de %BACKUP_DIR% ...
    for %%f in ("%BACKUP_DIR%\*.reg") do (
        echo Importando %%~nxf ...
        reg import "%%f" >nul 2>&1
        if %errorlevel% equ 0 (
            call :log "Imported %%f"
        ) else (
            call :log "Failed to import %%f"
        )
    )
    echo Importacao concluida.
    pause >nul
    goto mainmenu
)
goto mainmenu

:: ===================================================
:: SAÍDA
:: ===================================================
:exit
cls
echo Saindo do Níðhöggr v2...
echo Algumas alteracoes exigem reinicializacao.
call :log "User exited Nidhoggr v2"
endlocal
exit /b 0