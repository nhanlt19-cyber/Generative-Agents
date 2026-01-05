@echo off
REM Script để chạy Simulation Server (Windows)
REM Đảm bảo virtualenv đã được activate

echo ========================================
echo Starting Simulation Server...
echo ========================================
echo.

REM Kiểm tra virtualenv
if not exist venv\Scripts\activate.bat (
    echo [ERROR] Virtualenv chua duoc tao!
    echo Chay setup.bat truoc
    pause
    exit /b 1
)

REM Kích hoạt virtualenv
call venv\Scripts\activate.bat

REM Chuyển đến thư mục backend
cd reverie\backend_server

echo Dang khoi dong Simulation server...
echo.
echo Khi duoc hoi:
echo - "Enter the name of the forked simulation: " -> Nhap: base_the_ville_isabella_maria_klaus
echo - "Enter the name of the new simulation: " -> Nhap ten simulation cua ban
echo - "Enter option: " -> Nhap: run 50
echo.

python reverie.py

pause


