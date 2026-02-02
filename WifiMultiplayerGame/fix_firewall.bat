@echo off
echo Attempting to add Firewall Rule for Buckshot LAN (Port 5555)...
netsh advfirewall firewall add rule name="Buckshot Multiplayer LAN" dir=in action=allow protocol=TCP localport=5555
if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] Firewall rule added! Other computers should be able to join now.
) else (
    echo.
    echo [ERROR] Failed. Please run this file as ADMINISTRATOR (Right click -> Run as Admin).
)
pause
