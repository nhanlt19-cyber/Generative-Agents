#!/bin/bash
# Script để kiểm tra trạng thái servers

echo "========================================"
echo "Kiểm Tra Trạng Thái Servers"
echo "========================================"
echo ""

# Kiểm tra screen sessions
echo "1. Screen Sessions:"
screen -ls
echo ""

# Kiểm tra port 8000
echo "2. Port 8000 (Django):"
if sudo netstat -tlnp 2>/dev/null | grep -q ":8000"; then
    echo "   ✓ Django đang chạy trên port 8000"
    sudo netstat -tlnp 2>/dev/null | grep ":8000"
else
    echo "   ✗ Django không chạy trên port 8000"
fi
echo ""

# Kiểm tra Ollama
echo "3. Ollama:"
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "   ✓ Ollama đang chạy"
    echo "   Models:"
    ollama list 2>/dev/null | tail -n +2
else
    echo "   ✗ Ollama không chạy hoặc không thể kết nối"
fi
echo ""

# Kiểm tra network
echo "4. Network:"
IP=$(hostname -I | awk '{print $1}')
echo "   IP: $IP"
if [ "$IP" = "10.0.12.81" ] || hostname -I | grep -q "10.0.12.81"; then
    echo "   ✓ IP đúng (10.0.12.81)"
else
    echo "   ⚠ IP không phải 10.0.12.81"
fi
echo ""

# Kiểm tra firewall
echo "5. Firewall:"
if sudo ufw status | grep -q "8000/tcp"; then
    echo "   ✓ Port 8000 đã được mở"
else
    echo "   ⚠ Port 8000 chưa được mở"
    echo "   Chạy: sudo ufw allow 8000/tcp"
fi
echo ""

echo "========================================"
echo "Kiểm tra hoàn tất!"
echo "========================================"

