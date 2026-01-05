#!/bin/bash
# Script để dừng cả 2 servers

echo "Đang dừng servers..."

# Stop Environment Server
if screen -list | grep -q "env_server"; then
    screen -X -S env_server quit
    echo "✓ Environment Server đã dừng"
else
    echo "⚠ Environment Server không chạy"
fi

# Stop Simulation Server
if screen -list | grep -q "sim_server"; then
    screen -X -S sim_server quit
    echo "✓ Simulation Server đã dừng"
else
    echo "⚠ Simulation Server không chạy"
fi

echo ""
echo "Hoàn tất!"


