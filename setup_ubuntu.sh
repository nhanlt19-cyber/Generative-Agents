#!/bin/bash
# Script setup tự động cho Ubuntu VM
# Generative Agents Project Setup trên VM

echo "========================================"
echo "Generative Agents - Ubuntu VM Setup"
echo "========================================"
echo ""

# Kiểm tra quyền root (không cần, nhưng cần sudo cho một số lệnh)
if [ "$EUID" -eq 0 ]; then 
    echo "Không nên chạy script này với quyền root!"
    echo "Chạy với user thường, script sẽ dùng sudo khi cần"
    exit 1
fi

# Kiểm tra Python
if ! command -v python3 &> /dev/null; then
    echo "[1/8] Cài đặt Python 3.9..."
    sudo apt update
    sudo apt install -y python3.9 python3.9-venv python3-pip
else
    echo "[1/8] Python đã được cài đặt"
    python3 --version
fi

# Kiểm tra git
if ! command -v git &> /dev/null; then
    echo "[2/8] Cài đặt Git..."
    sudo apt install -y git
else
    echo "[2/8] Git đã được cài đặt"
fi

# Cài đặt dependencies hệ thống
echo "[3/8] Cài đặt system dependencies..."
sudo apt install -y build-essential python3-dev python3.9-dev

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

# Cấu hình firewall
echo ""
echo "[BONUS] Cấu hình firewall..."
read -p "Bạn có muốn mở port 8000 cho Django? (Y/N): " open_port
if [[ $open_port =~ ^[Yy]$ ]]; then
    sudo ufw allow 8000/tcp
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
echo "   - SSH port forwarding: ssh -L 8000:localhost:8000 user@10.0.12.81"
echo "   - Hoặc trực tiếp: http://10.0.12.81:8000"
echo ""
echo "Xem KHUYEN_NGHI_TRIEN_KHAI.md để biết chi tiết"
echo ""

