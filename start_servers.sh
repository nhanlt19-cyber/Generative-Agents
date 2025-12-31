#!/bin/bash
# Script để khởi động cả 2 servers trong screen sessions
# Sử dụng trên Ubuntu VM

cd ~/Generative-Agents || cd "$(dirname "$0")/.."

# Kiểm tra virtualenv
if [ ! -d "venv" ]; then
    echo "ERROR: Virtualenv chưa được tạo!"
    echo "Chạy: python3.9 -m venv venv"
    exit 1
fi

# Activate virtualenv
source venv/bin/activate

# Kiểm tra screen
if ! command -v screen &> /dev/null; then
    echo "Cài đặt screen..."
    sudo apt install -y screen
fi

# Start Environment Server
echo "Khởi động Environment Server..."
screen -dmS env_server bash -c "cd ~/Generative-Agents/environment/frontend_server && source ~/Generative-Agents/venv/bin/activate && python manage.py runserver 0.0.0.0:8000"

# Đợi một chút
sleep 2

# Start Simulation Server
echo "Khởi động Simulation Server..."
screen -dmS sim_server bash -c "cd ~/Generative-Agents/reverie/backend_server && source ~/Generative-Agents/venv/bin/activate && python reverie.py"

echo ""
echo "========================================"
echo "Servers đã được khởi động!"
echo "========================================"
echo ""
echo "Xem logs:"
echo "  screen -r env_server  # Environment Server"
echo "  screen -r sim_server   # Simulation Server"
echo ""
echo "List sessions:"
echo "  screen -ls"
echo ""
echo "Stop servers:"
echo "  screen -X -S env_server quit"
echo "  screen -X -S sim_server quit"
echo ""
echo "Truy cập từ laptop:"
echo "  http://10.0.12.81:8000"
echo ""

