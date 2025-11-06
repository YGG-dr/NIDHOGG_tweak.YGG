:check_admin
:: Verifica se o script já tem privilégios de administrador
net session >nul 2>&1
if %errorlevel% equ 0 (
    echo Obrigado pelas permissões de administrador, ^-^.
    call :log "Permissões de administrador confirmadas."
    goto :eof
)

:: Se chegou aqui, não tem admin
echo [!] YGG precisa de permissões de administrador para operar...
call :log "Sem privilégios de administrador. Tentando elevar."

:: Mostra um popup informativo (não falha caso PowerShell não funcione)
call :popup "YGG precisa de permissões de administrador! Clique em Sim para elevar ou Não para cancelar." "YGG - Elevacao"

:: Tenta relançar o próprio script elevado (vai abrir o prompt UAC)
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
set "PSRC=%errorlevel%"

:: Se o Start-Process falhar imediatamente (ex: falta do PowerShell), informa e pergunta o que fazer
if %PSRC% neq 0 (
    call :echo_color 0c "[ERRO] Não foi possível iniciar elevação (Start-Process retornou %PSRC%)."
    call :log "Start-Process falhou (código %PSRC%). Continuar sem admin?"
    echo Deseja continuar sem privilégios de administrador? [S/N]
    set /p "ANS=> "
    if /i "%ANS%"=="S" (
        call :log "Usuario optou por continuar sem admin (Start-Process falhou)."
        goto :eof
    ) else (
        call :log "Usuario optou por encerrar apos falha na elevacao."
        exit /b 1
    )
)

:: Aguarda um pouco para que a nova instância (elevada) inicie se o usuário aceitou o UAC.
:: Se o usuário negar o UAC, a instância atual continua aqui e devemos tratar isso.
timeout /t 2 >nul

:: Re-checa privilégio — se agora for administrador, fim da rotina (nova instância fará o resto).
net session >nul 2>&1
if %errorlevel% equ 0 (
    call :log "Elevação bem-sucedida (detectado admin após Start-Process)."
    :: Opcional: sair da instância atual (a instância elevada ficará em execução)
    exit /b 0
)

:: Se chegou aqui, a elevação foi provavelmente cancelada pelo usuário.
call :echo_color 0c "[ERRO] Parece que a elevação foi cancelada ou falhou."
call :log "Elevação possivelmente cancelada pelo usuario."

echo Deseja continuar sem privilégios de administrador? [S/N]
set /p "ANS=> "
if /i "%ANS%"=="S" (
    call :log "Usuario optou por continuar sem admin apos cancelamento da elevacao."
    goto :eof
) else (
    call :log "Usuario optou por encerrar apos cancelamento da elevacao."
    exit /b 1
)
