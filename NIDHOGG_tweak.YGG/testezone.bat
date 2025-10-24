@echo off
setlocal EnableDelayedExpansion

for /f "skip=1" %%t in ('wmic /namespace:\\root\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature') do (
    if not "%%t"=="" (
        set /a tempC=((%%t/10)-273)
        echo Temperatura CPU: !tempC! °C
    )
)
pause
