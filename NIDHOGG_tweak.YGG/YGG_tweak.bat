@echo off 
@REM
REM ::==================================================::
REM ::                                                  ::
REM ::       --- Níðhöggr v2 • Made by ¥ऊ€_แㄨΘ ---     ::
REM ::                                                  ::
REM ::==================================================:: 

::   ===================================================
::    
::                  CONFIGURAÇÕES GLOBAIS
::
::   ...................................................

setlocal EnableDelayedExpansion 
title Níðhöggr v2 — Made by YGG
color 0d

set "YGG_DIR=C:\ygg" 
set "LOG_FILE=%YGG_DIR%\ygg_log.txt" 
set "BACKUP_DIR=%YGG_DIR%\backup" 
set "MODE=SAFE"  :: Padrão é o modo seguro.

if not exist "%YGG_DIR%"    mkdir "%YGG_DIR%"    2>nul 
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" 2>nul

::   =================================================== 

::   ===================================================
::    
::                     FUNÇÃO DE LOG 
::    
::   ...................................................

:log
:: Log cria um arquivo de log com timestamp.
:: Relatório de logs.
echo [%date% %time%] %* >> "%LOG_FILE%"
goto :eof
        
::   ===================================================

::   ===================================================
::
::              VERIFICAÇÃO DE ADMINISTRADOR 
::
::   ...................................................

net session >nul 2>&1 
if %errorlevel% neq 0 ( 
    echo [!] YGG precisa das permissões de administrdor para operar.
    call :log "YGG não pode se elevar a nível de administrador"
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs" >nul 2>&1 
    exit /b
)

call :log "YGG conseguiu se elevar a nível de administrador com sucesso"
    
::   ===================================================

::   ===================================================
::
::              FUNÇÃO DE BACKUP DE REGISTRO  
::
::   ...................................................

:setBackup 
set "REG_KEY=%~1"
set "TAG=%~2"
if "%REG_KEY%"=="" goto :eof 
:: Gera timestamp seguro para filename.
for /f "tokens=1-3 delims=/ " %%a in ("%date%") do set d1=%%c-%%b-%%a
for /f "tokens=1-3 delims=:." %%a in (%%time%%) do set d2=%%c-%%b-%%a
    
set "TS=%date:~10,4%-%date:~4,2%-%date:~7,2%%time:~0,2%-%time:~3,2%-%time:~6,2%" 
set "SAFEFILE=%BACKUP_DIR%\\%~2_%TS%.reg" 
reg export "%REG_KEY%" "%SAFEFILE%" /y >nul 2>&1 
goto :eof

:: %1 = chave do registro, %2 = tag/nome curto.
set "REG_KEY=%~1"
set "TAG=%~2"
if "%REG_KEY%"=="" goto :eof
:: Gera timestamp seguro para filename.
for /f "tokens=1-3 delims=/ " %%a in ("%date%") do set d1=%%c-%%b-%%a
for /f "tokens=1-3 delims=:." %%a in ("%time%") do set t1=%%a-%%b-%%c
set "TS=%d1%_%t1%"
set "SAFEFILE=%BACKUP_DIR%\%TAG%_%TS%.reg"
reg export "%REG_KEY%" "%SAFEFILE%" /y >nul 2>&1
if %errorlevel% equ 0 (
    call :log "Backed up %REG_KEY% to %SAFEFILE%"
) else (
    call :log "Failed to backup %REG_KEY% (may not exist or access denied)"
)
goto :eof
::   ===================================================
    
::   ===================================================
::
::              EXECUÇÃO SEGURA DO POWERSHELL  
::
::   ...................................................

:psrun
:: %1 = comando do PS
set "PS_CMD=%~1" 
if  "%PS_CMD%"=="" goto :eof
call :log "YGG está inicilizando o PowerShell: %PS_CMD%"
Powershell -NoProfile -ExecutionPolicy Bypass -Command "%PS_CMD%" >nul 2>&1 
if %errorlevel% neq 0 call :log "YGG não conseguiu inicializar o PowerShell: %PS_CMD%"
goto :eof

::   ===================================================
    
::   ===================================================
::
::                  MODO SAFE OU EXTREME  
::
::   ...................................................

if /i "%1"=="extreme" set "MODE=EXTREME" 
if /i "%1"=="safe"    set "MODE=SAFE"
call :log "YGG está inicializando o Níðhöggr v2 com o modo %MODE%"

::   ===================================================
    
::   ===================================================
::
::                     MENU PRINCIPAL 
::    
::   ...................................................

:progress
:: %1 = mensagem; %2 = segundos (inteiro)
set "PROG_MSG=%~1"
set /a SECS=%~2
<nul set /p = "%PROG_MSG%"
for /L %%i in (1,1,%SECS%) do (
    <nul set /p ="." 
    ping -n 2 127.0.0.1 >nul
)

::   ===================================================
::
::                     MENU PRINCIPAL 
::    
::   ...................................................

:mainmenu
cls

echo ===================================================
echo.
echo           Níðhöggr v2 — Menu (Modo: %MODE%) 
echo.
echo ..................................................
echo.
echo 01. Otimizações gerais do sistema.
echo 02. Otimizações de energia.
echo 03. Ajustes de mouse e teclado.
echo 04. Otimizações da plca de vídeo.
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
echo
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
if /i "%CHOICE%"=="R"  goto revertmenu 
if /i "%CHOICE%"=="X"  goto :exit

echo [!] YGG não entendeu seu pedido.
pause >nul 
goto mainmenu
echo ===================================================

::   ===================================================

::   ...................................................
::        
::                     CRIAR CHECKPOINT
::        
::   ...................................................
:create_restore
cls
echo YGG está criando um checkpoint... 
Powershell -NoProfile -Command "Get-ComputerRestorePoint" >nul 2>&1
if %errorlevel% neq 0 (
        echo [!] Verifique se a proteção do sistema está habilitado na unidade C: antes.
        call :log "YGG não conseguiu criar o checkpoint: Get-ComputerRestorePoint returned %errorlevel%
else (
        powershell -NoProfile -Command "Checkpoint-Computer -description 'YGG checkpoint' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
        if %errorlevel% equ 0 (
                ehco YGG conseguiu criar o checkpoint com sucesso.
                call :log "O checkpoint foi criado."
        ) else (
                echo [!] YGG não conseguiu criar o checkpoint.
                call :log "O checkpoint não foi criado: %errorlevel%"
        )
)
pause >nul
goto mainmenu

::   ===================================================

::   ===================================================
::
::                    DOWNLOAD DE RECURSOS  
::
::   ...................................................
:resources 
cls 
echo YGG está baixando alguns pacotinhos para o %YGG_DIR%... 
call :progress "YGG está carregando os pacotinhos." 3
set "RESOURCE_URL=https://github.com/YGG-dr/NIDHOGG_tweak.YGG/blob/main/NIDHOGG_tweak.YGG/N%C3%AD%C3%B0h%C3%B6ggr.zip"
if exist "%temp%"\Níðhöggr.zip" del "%temp%"

::   ===================================================
        
::   ===================================================
::
::                      OTIMIZAÇÕES GERAIS  
::
::   ...................................................
        
:opt_general
cls 
echo YGG está fazendo as otimizações gerais da máquina... 
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f >nul 2>&1 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1 
if /i "%MODE%"=="EXTREME" ( 
        sc config "WSearch" start= disabled >nul 2>&1 
        sc stop "WSearch" >nul 2>&1 
)
echo YGG terminou de fazer as configurações gerais da máquina.
pause >nul
goto mainmenu

::   ===================================================

::   ===================================================
::
::                 OTIMIZAÇÕES DE ENERGIA  
::
::   ...................................................
        
:opt_power
cls
echo YGG está alterando seu plano de energia... 
powercfg -duplicatescheme SCHEME_MIN >nul 2>&1 
powercfg -change -standby-timeout-ac 0 >nul 2>&1 
powercfg -change -hibernate-timeout-ac 0 >nul 2>&1 
echo YGG alterou seu plano de energia com sucesso. 
pause >nul
goto mainmenu

::   ===================================================

::   ===================================================
::
::                     MOUSE E TECLADO  
::
::   ...................................................
        
:opt_input 
cls 
echo YGG está ajustando as configurações do seu mouse e teclado...
reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d 10 /f >nul 2>&1 
echo YGG ajustou as configurações do seu mouse e teclado com sucesso.
pause >nul
goto mainmenu

::   ===================================================

::   ===================================================
::
::                          GPU  
::
::   ...................................................
        
:opt_gpu
cls
echo YGG está otimizando sua GPU... 
echo Se o NVP estiver presente, use-o manualmente em %YGG_DIR%. 
pause >nul
goto mainmenu

::   ===================================================
        
::   ===================================================
::
::                          CPU  
::
::   ...................................................

:opt_cpu
cls
echo YGG está otimizando a CPU da máquina... 
if /i "%MODE%"=="EXTREME" ( 
        echo [!] YGG está desativando o core parking da CPU...
) else ( 
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5 >nul 2>&1 
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >nul 2>&1 
        powercfg -S SCHEME_CURRENT >nul 2>&1 ) 
echo YGG otimizou a CPU com sucesso.
pause >nul
goto mainmenu

::   ===================================================
        
::   ===================================================
::
::                  LIMPEZA E ARMAZENAMENTO
::
::   ...................................................
        
:opt_storage
cls
echo YGG está limpando os arquivos temporários da máquina...
rd /s /q "%temp%" >nul 2>&1 || del /s /q "%temp%*" >nul 2>&1
rd /s /q "C:\Windows\Temp" >nul 2>&1 || del /s /q "C:\Windows\Temp*" >nul 2>&1
if /i "%MODE%"=="EXTREME" Powershell -NoProfile -Command "Start-Process -FilePath dism.exe -ArgumentList '/online','/Cleanup-Image','/StartComponentCleanup','/ResetBase' -Wait -NoNewWindow" >nul 2>&1
echo YGG limpou os arquivos temporários com sucesso. 
pause >nul 
goto mainmenu

::   ===================================================
::                     
::                   REMOÇÃO DE BLOATWARE                      
::
::   ...................................................
        
:opt_debloat
cls
echo YGG fará a remoção de aplicativos desnecessários:
echo 1) Remoção segura (SAFE)
echo 2) Remoção completa (EXTREME)
echo M) Voltar
echo.
set /p "DCH=Escolha: "
if /i "%DCH%"=="M" goto mainmenu 
if /i "%DCH%"=="1" Powershell -Command "Get-AppxPackage -AllUsers 3D | Remove-AppxPackage" >nul 2>&1 
if /i "%DCH%"=="2" Powershell -Command "Get-AppxPackage -AllUsers Microsoft.Xbox | Remove-AppxPackage" >nul 2>&1 
echo YGG conseguiu remover o bloatware com sucesso.
pause >nul
goto mainmenu

::   ===================================================
        
::   ===================================================
::
::                          REDE  
::
::   ...................................................
        
:opt_network
cls
echo YGG está aplicando otimizações de rede...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f >nul 2>&1
echo YGG otimizou a rede com sucesso.
pause >nul
goto mainmenu

::   ===================================================
::
::                        MEMÓRIA
::
::
::   ...................................................
        
:opt_memory
cls
echo YGG está ajustando as configurações da memória da sua máquina...
if /i "%MODE%"=="EXTREME" ( 
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PagingFiles /t REG_MULTI_SZ /d "C:\pagefile.sys 1024 4096" /f >nul 2>&1
) else ( 
        reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PagingFiles /f >nul 2>&1 ) 
echo YGG otimizou a memória com sucesso.
pause >nul
goto mainmenu

::   ===================================================
        
::   ===================================================
::
::                      CHECKPOINT
::
::   ...................................................
        
:revertmenu
cls
echo Checkpoint do Níðhöggr:
echo 1) Usar Restauração do Sistema 
echo 2) Restaurar Backups do Registro 
echo M) Voltar set /p "RCH=Escolha: "
if /i "%RCH%"=="1" rstrui.exe
if /i "%RCH%"=="2" for %%f in ("%BACKUP_DIR%*.reg") do reg import "%%f" >nul 2>&1
goto mainmenu

::   ===================================================

::   ===================================================
::        
::                        SAÍDA
::
::   ...................................................

:exit
cls
echo Saindo do Níðhöggr V2...
echo Algumas alterações exigem reinicialização.
endlocal
exit /b 0

