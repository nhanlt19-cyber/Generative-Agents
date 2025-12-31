#!/bin/bash
# Script để khởi động cả 2 servers trong screen sessions - ROOT
# Sử dụng trên Ubuntu VM

# Kiểm tra đang chạy dưới root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  Script này được thiết kế cho root user"
    echo "Nếu không phải root, dùng: ./start_servers.sh"
fi

cd ~/generative_agents 2>/dev/null || cd /root/generative_agents 2>/dev/null || cd "$(dirname "$0")/.."

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
    apt install -y screen
fi

# Xác định working directory
WORK_DIR=$(pwd)

# Start Environment Server
echo "Khởi động Environment Server..."
screen -dmS env_server bash -c "cd $WORK_DIR/environment/frontend_server && source $WORK_DIR/venv/bin/activate && python manage.py runserver 0.0.0.0:8000"

# Đợi một chút
sleep 2

# Start Simulation Server
echo "Khởi động Simulation Server..."
screen -dmS sim_server bash -c "cd $WORK_DIR/reverie/backend_server && source $WORK_DIR/venv/bin/activate && python reverie.py"

echo ""
echo "========================================"
echo "Servers đã được khởi động!"
echo "========================================"
echo ""
echo "⚠️  Đang chạy dưới quyền ROOT"
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

