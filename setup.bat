@echo off
REM Script setup tự động cho Windows
REM Generative Agents Project Setup

echo ========================================
echo Generative Agents - Setup Script
echo ========================================
echo.

REM Kiểm tra Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python chua duoc cai dat!
    echo Vui long cai dat Python 3.9.x tu https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [1/5] Tao virtual environment...
if exist venv (
    echo Virtualenv da ton tai, bo qua...
) else (
    python -m venv venv
    if errorlevel 1 (
        echo [ERROR] Khong the tao virtualenv!
        pause
        exit /b 1
    )
    echo ✓ Virtualenv da duoc tao
)

echo.
echo [2/5] Kich hoat virtualenv...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERROR] Khong the kich hoat virtualenv!
    pause
    exit /b 1
)

echo.
echo [3/5] Nang cap pip...
python -m pip install --upgrade pip

echo.
echo [4/5] Cai dat dependencies chinh...
pip install -r requirements.txt
if errorlevel 1 (
    echo [WARNING] Co loi khi cai dat dependencies chinh!
    echo Ban co muon tiep tuc? (Y/N)
    set /p continue=
    if /i not "%continue%"=="Y" exit /b 1
)

echo.
echo [5/5] Cai dat dependencies cho frontend...
cd environment\frontend_server
pip install -r requirements.txt
cd ..\..

echo.
echo ========================================
echo Setup hoan tat!
echo ========================================
echo.
echo Buoc tiep theo:
echo 1. Kich hoat virtualenv: venv\Scripts\activate
echo 2. Kiem tra Ollama: cd reverie\backend_server ^&^& python test_ollama_connection.py
echo 3. Chay environment server: cd environment\frontend_server ^&^& python manage.py runserver
echo 4. Chay simulation server: cd reverie\backend_server ^&^& python reverie.py
echo.
echo Xem HUONG_DAN_CHAY_DU_AN.md de biet chi tiet
echo.
pause

