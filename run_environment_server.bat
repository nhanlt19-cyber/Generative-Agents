@echo off
REM Script để chạy Environment Server (Windows)
REM Đảm bảo virtualenv đã được activate

echo ========================================
echo Starting Environment Server...
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

REM Chuyển đến thư mục frontend
cd environment\frontend_server

echo Dang khoi dong Django server...
echo Truy cap: http://localhost:8000
echo Nhan CTRL+C de dung server
echo.

python manage.py runserver

pause


