#!/bin/bash
# Script setup tự động cho Linux/Mac
# Generative Agents Project Setup

echo "========================================"
echo "Generative Agents - Setup Script"
echo "========================================"
echo ""

# Kiểm tra Python
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python chưa được cài đặt!"
    echo "Vui lòng cài đặt Python 3.9.x từ https://www.python.org/downloads/"
    exit 1
fi

echo "[1/5] Tạo virtual environment..."
if [ -d "venv" ]; then
    echo "Virtualenv đã tồn tại, bỏ qua..."
else
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "[ERROR] Không thể tạo virtualenv!"
        exit 1
    fi
    echo "✓ Virtualenv đã được tạo"
fi

echo ""
echo "[2/5] Kích hoạt virtualenv..."
source venv/bin/activate
if [ $? -ne 0 ]; then
    echo "[ERROR] Không thể kích hoạt virtualenv!"
    exit 1
fi

echo ""
echo "[3/5] Nâng cấp pip..."
python -m pip install --upgrade pip

echo ""
echo "[4/5] Cài đặt dependencies chính..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "[WARNING] Có lỗi khi cài đặt dependencies chính!"
    read -p "Bạn có muốn tiếp tục? (Y/N): " continue
    if [[ ! $continue =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "[5/5] Cài đặt dependencies cho frontend..."
cd environment/frontend_server
pip install -r requirements.txt
cd ../..

echo ""
echo "========================================"
echo "Setup hoàn tất!"
echo "========================================"
echo ""
echo "Bước tiếp theo:"
echo "1. Kích hoạt virtualenv: source venv/bin/activate"
echo "2. Kiểm tra Ollama: cd reverie/backend_server && python test_ollama_connection.py"
echo "3. Chạy environment server: cd environment/frontend_server && python manage.py runserver"
echo "4. Chạy simulation server: cd reverie/backend_server && python reverie.py"
echo ""
echo "Xem HUONG_DAN_CHAY_DU_AN.md để biết chi tiết"
echo ""


