@echo off
@REM

:: YGG sabe que echo off remove os REM, mas o YGG é fresco... UwU

REM ::==================================================::
REM ::                                                  ::
REM ::         --- Níðhöggr v2 • Made by YGG ---        ::
REM ::                                                  ::
REM ::==================================================:: 

::   ===================================================
::    
::                   CONFIGURAÇÕES GLOBAIS
::
::   ...................................................

setlocal EnableDelayedExpansion
title Níðhöggr v2 — Made by YGG
color 0d

set "YGG_DIR=C:\ygg"
set "LOG_FILE=%YGG_DIR%\ygg_log.txt"
set "BACKUP_DIR=%YGG_DIR%\backup"
set "MODE=SAFE" :: Com toda certeza o padrão deve ser o modo safe, uhum.

if not exist "%YGG_DIR%"    mkdir "%YGG_DIR%"    2>nul
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" 2>nul

::   =================================================== 

::   ===================================================
::    
::                     FUNÇÃO DE LOG
::    
::   ...................................................

:log
:: O log cria um arquivo para as logl com o timestamp.
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
    call :popup "YGG precisa de permissões de administrador para ser executado!"
    call :log "Não pode se elevar a nível de administrador"
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
if "%TAG%"=="" goto :eof

:: Gera timestamp seguro para o filename.
for /f "tokens=2-4 delims=/ " %%a in ("date /t") do set "DATA=%%c-%%a-%%b"
for /f "tokens=1-3 delims=:." %%a in ("%time%") do set "HORA=%%a-%%b-%%c"
set "TS=%DATA%_%HORA%"

set "SAFEFILE=%BACKUP_DIR%\\%~2_%TS%.reg"

reg export "%REG_KEY%" "%SAFEFILE%" /y >nul 2>&1

if %errorlevel% equ 0 (
    call :log "Backup feito com sucesso para %REG_KEY% e %SAFEFILE%."
) else (
    call :log "Falha ao criar o backup para %REG_KEY%."
)
    
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
call :log "YGG está inicializando o PowerShell: %PS_CMD%"
Powershell -NoProfile -ExecutionPolicy Bypass -Command "%PS_CMD%" >nul 2>&1 
if %errorlevel% neq 0 (
        call :log "YGG não conseguiu inicializar o PowerShell: %PS_CMD%"
)
goto :eof

::   ===================================================
    
::   ===================================================
::
::                  MODO SAFE OU EXTREME  
::
::   ...................................................

if /i "%1"=="extreme" set "MODE=EXTREME" 
if /i "%1"=="safe"    set "MODE=SAFE"
call :log "Inicializando o Níðhöggr v2 com o modo %MODE%"

::   ===================================================
    
::   ===================================================
::
::                  BARRA DE PROGRESSO 
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
if /i "%CHOICE%"=="R"  goto revertmenu 
if /i "%CHOICE%"=="X"  goto :exit

echo [!] YGG não entendeu seu pedido.
pause >nul 
goto mainmenu
echo ===================================================

::   ===================================================

::   ...................................................
::        
::                 CRIAR CHECKPOINT
::        
::   ...................................................

:create_restore
cls
echo YGG está criando um checkpoint... 
Powershell -NoProfile -Command "Get-ComputerRestorePoint" >nul 2>&1
if %errorlevel% neq 0 (
        echo [!] Verifique se a proteção do sistema está habilitado na unidade C: antes.
        call :log "YGG não conseguiu criar o checkpoint: Get-ComputerRestorePoint returned %errorlevel%"
        call :popup "YGG não conseguiu criar o checkpoint!"
else (
        powershell -NoProfile -Command "Checkpoint-Computer -description 'YGG checkpoint' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
        if %errorlevel% equ 0 (
                echo YGG conseguiu criar o checkpoint com sucesso.
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
::                DOWNLOAD DE RECURSOS  
::
::   ...................................................

:resources 
cls

echo YGG está baixando alguns pacotinhos para o %YGG_DIR%...
call :progress "YGG está carregando os pacotinhos." 3
set "RESOURCE_URL="
if exist "%temp%\Níðhöggr.zip" del "%temp%\Níðhöggr.zip" >nul 2>&1
curl -g -k -l -# -o "%temp%\Níðhöggr.zip" "%RESOURCE_URL%" >nul 2>&1
if exist "%temp%\Níðhöggr.zip" (
        PowerShell -NoProfile -Command "Expand-Archive -LiteralPath '%temp%\Níðhöggr.zip' -DestinationPath '%YGG_DIR%' -Force" >nul 2>&1
        echo YGG baixou os pacotinhos para %YGG_DIR% com sucesso.
        call :log "YGG baixou os pacotinhos para %YGG_DIR%"
) else (
        echo YGG falhou em baixar os pacotinhos para %YGG_DIR%.
        call :log "Falha ao baixar os arquivos"
        call :popup "YGG falhou em baixar os pacotinhos!"
)

pause >nul
goto mainmenu

::   ===================================================
        
::   ===================================================
::
::                   OTIMIZAÇÕES GERAIS  
::
::   ...................................................
        
:opt_general
cls 
echo YGG está fazendo as otimizações gerais da máquina.
call :log "Iniciando otimizações gerais."

reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f >nul 2>&1 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1

if /i "%MODE%"=="EXTREME" ( 
        call :log "[ !- EXTREME MODE -! ] Mostrando WSearch."
        sc config "WSearch" start= disabled >nul 2>&1 
        sc stop "WSearch" >nul 2>&1 
)

call :progress "YGG está aplicando alguns ajustes." 2
echo YGG terminou de fazer as configurações gerais da máquina.
call :log "Otimizações gerais concluidas."
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
call :log "A aplicação do plano de energia foi iniciado."

powercfg -duplicatescheme SCHEME_MIN >nul 2>&1 
powercfg -change -standby-timeout-ac 0 >nul 2>&1 
powercfg -change -hibernate-timeout-ac 0 >nul 2>&1

call :progress "YGG está configuarando o plano de energia..." 2
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
call :log "Otimizando dispositivos de entrada."

reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d 10 /f >nul 2>&1

echo YGG ajustou as configurações do seu mouse e teclado com sucesso.
call :log "A otimização foi feita com sucesso."
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
call :log "A otimização da GPU está sendo feita."
echo Se você tiver o NVP na pasta %YGG_DIR%, então você deve usa-lo para perfis de jogo.
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
call :log "A otimização da CPU foi iniciada."

call :setBackup "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings" "cpu_powersettings"

if /i "%MODE%"=="EXTREME" (
        call :log "[ !- EXTREME MODE -! ] Iniciando a desativação do core parking."
        echo [ !- EXTREME MODE -! ] YGG está desativando o core parking da CPU...
) else (
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5 >nul 2>&1
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >nul 2>&1
        powercfg -S SCHEME_CURRENT >nul 2>&1
)

call :log "A otimização da CPU foi concluida com sucesso."
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
echo YGG está limpando os arquivos temporários do armazenamento...
call :log "A limpeza do armazenamento foi iniciado."

rd /s /q "%temp%" >nul 2>&1 || del /s /q "%temp%*" >nul 2>&1
rd /s /q "C:\Windows\Temp" >nul 2>&1 || del /s /q "C:\Windows\Temp*" >nul 2>&1

if /i "%MODE%"=="EXTREME" (
        call :log "[ !- EXTREME MODE -! ] Iniciando limpeza do DISM."
        Powershell -NoProfile -Command "Start-Process -FilePath dism.exe -ArgumentList '/online','/Cleanup-Image','/StartComponentCleanup','/ResetBase' -Wait -NoNewWindow" >nul 2>&1
)

call :progress "YGG está limpando arquivos inúteis do armazenamento" 3
echo YGG limpou os arquivos temporários com sucesso.
pause >nul
goto mainmenu

::   ===================================================

::   ===================================================
::
::                   REMOÇÃO DE BLOATWARE        
::
::   ...................................................

:opt_debloat
cls
echo YGG fará a remoção de aplicativos desnecessários:
echo 1) Remoção segura.         [  °- SAFE MODE -°  ]
echo 2) Remoção completa.       [ !- EXTREME MODE -! ]
echo M) Voltar.                 
echo.
set /p "DCH=> "

if /i "%DCH%"=="M" goto mainmenu

if /i "%DCH%"=="1" (
        call :log "Remoção de debloats seguros."
        call :psrun "Get-AppxPackage -AllUsers *3D* | Remove-AppxPackage"
        call :psrun "Get-AppxPackage -AllUsers *Microsoft.XboxGamingOverlay* | Remove-AppxPackage"
        echo :log "A remoção de debloats no modo seguro foi concluido."
) else if /i "%DCH%"=="2" (
        echo [!] YGG está fazendo backup antes de remover os apps.
        call :psrun "Get-AppxPackage -AllUsers | Export-CliXml -Path '%YGG_DIR%\allusers_appx.xml'"
        call :log "O backup do debloat foi exportado."
        call :psrun "Get-AppxPackage -AllUsers *Microsoft.Xbox* | Remove-AppxPackage"
        call :psrun "Get-AppxPackage -AllUsers *Microsoft.549981C3F5F10* | Remove-AppxPackage"
        echo YGG removeu com sucesso os debloats do sistema.
        call :log "Remoção dos debloats foi concluido com sucesso."
)

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
echo YGG está aplicando otimizações de rede.
call :log "Iniciando otimização da rede."

call :setBackup "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "tcpip_params"

reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f >nul 2>&1

if /i %MODE%=="EXTREME" (
        echo [ !- EXTREME MODE -! ] YGG pode acabar desativando o IPV6 da sua máquina, isso pode ser perigoso.
        :: reg add "HKLM\SYSTEM\CurrentControlSet\Services\TCPIP6\Parameters" /v DisabledComponents /t REG_DWORD /d 0xffffffff /f >nul 2>&1
)
call :progress "YGG está otimizando a sua rede" 3
echo YGG aplicou as mudanças a sua rede com sucesso.
call :log "Mudanças na rede complestas com sucesso."
pause >nul
goto mainmenu

::   ===================================================

::   ===================================================
::
::                        MEMÓRIA
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
echo M) Voltar

set /p "RCH=Escolha: "
if /i "%RCH%"=="1" rstrui.exe
if /i "%RCH%"=="2" for %%f in ("%BACKUP_DIR%\*.reg") do reg import "%%f" >nul 2>&1
goto mainmenu

::   ===================================================

::   ===================================================
::
::                         POPUP
::
::   ...................................................

:popup
set "MB_MSG=%~1"
set "MB_TITLE=%~2"

if "%MB_TITLE%"=="" set "MB_TITLE=YGG"

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

exit /b

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

::   ===================================================