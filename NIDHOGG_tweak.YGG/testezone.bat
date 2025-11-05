@echo off
title Sistema Exemplo — YGG
color 0A
mode con cols=80 lines=25

::   ===================================================
::
::                    PONTO DE ENTRADA
::
::   ...................................................

:inicio
cls
echo.
echo           ==========================================
echo                    SISTEMA DE EXEMPLO - YGG
echo           ==========================================
echo.
echo              [1] Mostrar informações do sistema
echo              [2] Limpar tela
echo              [3] Mudar cor
echo              [0] Sair
echo.
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="1" goto infos
if "%opcao%"=="2" goto limpar
if "%opcao%"=="3" goto cor
if "%opcao%"=="0" goto sair
goto inicio


::   ===================================================
::
::              SEÇÃO DE INFORMAÇÕES DO SISTEMA
::
::   ...................................................

:infos
cls
echo.
echo ================== INFORMACOES ==================
echo.
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
echo.
pause
goto inicio


::   ===================================================
::
::                 SEÇÃO DE LIMPEZA DE TELA
::
::   ...................................................

:limpar
cls
echo.
echo Tela limpa com sucesso!
timeout /t 2 >nul
goto inicio


::   ===================================================
::
::                  SEÇÃO DE MUDANÇA DE COR
::
::   ...................................................

:cor
cls
echo.
echo Cores disponiveis:
echo.
echo 0 = Preto       8 = Cinza
echo 1 = Azul        9 = Azul claro
echo 2 = Verde       A = Verde claro
echo 3 = Azul claro  B = Ciano
echo 4 = Vermelho    C = Vermelho claro
echo 5 = Roxo        D = Magenta claro
echo 6 = Amarelo     E = Amarelo claro
echo 7 = Branco      F = Branco brilhante
echo.
set /p novaCor=Digite o código da nova cor (ex: 0A): 
color %novaCor%
goto inicio


::   ===================================================
::
::                       FINALIZAÇÃO
::
::   ...................................................

:sair
cls
echo.
echo Encerrando o sistema...
timeout /t 2 >nul
exit
