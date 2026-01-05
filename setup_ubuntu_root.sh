#!/bin/bash
# Script setup tự động cho Ubuntu VM - Chạy dưới quyền ROOT
# Generative Agents Project Setup trên VM

echo "========================================"
echo "Generative Agents - Ubuntu VM Setup (ROOT)"
echo "========================================"
echo ""
echo "⚠️  CẢNH BÁO: Đang chạy dưới quyền ROOT"
echo "Chỉ sử dụng cho development/test, không dùng cho production!"
echo ""

# Kiểm tra đang chạy dưới root
if [ "$EUID" -ne 0 ]; then 
    echo "Script này yêu cầu quyền root!"
    echo "Chạy: sudo bash setup_ubuntu_root.sh"
    exit 1
fi

# Kiểm tra Python
if ! command -v python3 &> /dev/null; then
    echo "[1/8] Cài đặt Python 3.9..."
    apt update
    apt install -y python3.9 python3.9-venv python3-pip git
else
    echo "[1/8] Python đã được cài đặt"
    python3 --version
fi

# Kiểm tra git
if ! command -v git &> /dev/null; then
    echo "[2/8] Cài đặt Git..."
    apt install -y git
else
    echo "[2/8] Git đã được cài đặt"
fi

# Cài đặt dependencies hệ thống
echo "[3/8] Cài đặt system dependencies..."
apt install -y build-essential python3-dev python3.9-dev

# Tạo virtualenv
echo "[4/8] Tạo virtual environment..."
if [ -d "venv" ]; then
    echo "Virtualenv đã tồn tại, bỏ qua..."
else
    python3.9 -m venv venv
    if [ $? -ne 0 ]; then
        echo "[ERROR] Không thể tạo virtualenv!"
        exit 1
    fi
    echo "✓ Virtualenv đã được tạo"
fi

# Activate virtualenv
echo "[5/8] Kích hoạt virtualenv..."
source venv/bin/activate
if [ $? -ne 0 ]; then
    echo "[ERROR] Không thể kích hoạt virtualenv!"
    exit 1
fi

# Upgrade pip
echo "[6/8] Nâng cấp pip..."
python -m pip install --upgrade pip

# Cài đặt dependencies chính
echo "[7/8] Cài đặt Python dependencies..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "[WARNING] Có lỗi khi cài đặt dependencies chính!"
    read -p "Bạn có muốn tiếp tục? (Y/N): " continue
    if [[ ! $continue =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Cài đặt dependencies frontend
echo "[8/8] Cài đặt frontend dependencies..."
cd environment/frontend_server
pip install -r requirements.txt
cd ../..

# Cấu hình firewall (không cần sudo vì đã là root)
echo ""
echo "[BONUS] Cấu hình firewall..."
read -p "Bạn có muốn mở port 8000 cho Django? (Y/N): " open_port
if [[ $open_port =~ ^[Yy]$ ]]; then
    ufw allow 8000/tcp
    echo "✓ Port 8000 đã được mở"
fi

# Kiểm tra Ollama
echo ""
echo "[BONUS] Kiểm tra Ollama..."
if command -v ollama &> /dev/null; then
    echo "✓ Ollama đã được cài đặt"
    ollama --version
else
    echo "⚠ Ollama chưa được cài đặt"
    echo "Cài đặt Ollama: curl -fsSL https://ollama.ai/install.sh | sh"
fi

echo ""
echo "========================================"
echo "Setup hoàn tất!"
echo "========================================"
echo ""
echo "⚠️  LƯU Ý: Đang chạy dưới quyền ROOT"
echo ""
echo "Bước tiếp theo:"
echo "1. Cấu hình utils.py:"
echo "   - ollama_base_url = 'http://localhost:11434'"
echo "   - ollama_model_name = 'llama3.1'"
echo ""
echo "2. Cấu hình Django ALLOWED_HOSTS:"
echo "   - Thêm '*' hoặc '10.0.12.81' vào ALLOWED_HOSTS"
echo ""
echo "3. Chạy environment server:"
echo "   source venv/bin/activate"
echo "   cd environment/frontend_server"
echo "   python manage.py runserver 0.0.0.0:8000"
echo ""
echo "4. Chạy simulation server:"
echo "   source venv/bin/activate"
echo "   cd reverie/backend_server"
echo "   python reverie.py"
echo ""
echo "5. Truy cập từ laptop:"
echo "   http://10.0.12.81:8000"
echo ""
echo "Xem TRIEN_KHAI_UBUNTU_ROOT.md để biết chi tiết"
echo ""


