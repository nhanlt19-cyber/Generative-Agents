# Hướng Dẫn Triển Khai Trên VM Ubuntu

Hướng dẫn chi tiết để triển khai Generative Agents trên VM Ubuntu (10.0.12.81) với 32GB RAM.

## 📋 Yêu Cầu

- VM Ubuntu 24.04 (hoặc 22.04+)
- 32GB RAM (đã có)
- Ollama đã cài và chạy với model llama3.1
- Quyền sudo
- Kết nối mạng ổn định

## 🚀 Bước 1: Chuẩn Bị VM

### 1.1. Kết nối SSH

```bash
# Từ laptop Windows
ssh user@10.0.12.81
```

### 1.2. Cập nhật hệ thống

```bash
sudo apt update
sudo apt upgrade -y
```

### 1.3. Cài đặt Python và dependencies

```bash
sudo apt install -y python3.9 python3.9-venv python3-pip git
sudo apt install -y build-essential python3-dev python3.9-dev
```

## 📦 Bước 2: Upload Code Lên VM

### Option 1: Git Clone (Nếu có repo)

```bash
cd ~
git clone <your-repo-url> generative_agents
cd generative_agents
```

### Option 2: SCP từ Windows

**Trên Windows (PowerShell):**
```powershell
# Từ thư mục dự án
scp -r "D:\Ths\KLTN\LLM\Defense LLM\Generatve Agent\generative_agents" user@10.0.12.81:~/
```

**Hoặc dùng WinSCP, FileZilla để upload thư mục**

### Option 3: Zip và Upload

**Trên Windows:**
```powershell
# Zip dự án
Compress-Archive -Path "generative_agents" -DestinationPath "generative_agents.zip"

# Upload
scp generative_agents.zip user@10.0.12.81:~/
```

**Trên VM:**
```bash
cd ~
unzip generative_agents.zip
cd generative_agents
```

## ⚙️ Bước 3: Setup Dự Án

### 3.1. Chạy script tự động

```bash
cd ~/generative_agents
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh
```

### 3.2. Hoặc setup thủ công

```bash
# Tạo virtualenv
python3.9 -m venv venv

# Activate
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Cài dependencies
pip install -r requirements.txt
cd environment/frontend_server
pip install -r requirements.txt
cd ../..
```

## 🔧 Bước 4: Cấu Hình

### 4.1. Cấu hình utils.py

```bash
nano reverie/backend_server/utils.py
```

Cập nhật:
```python
llm_provider = "ollama"
ollama_base_url = "http://localhost:11434"  # Local vì cùng VM
ollama_model_name = "llama3.1"
ollama_embedding_model_name = "nomic-embed-text"
```

### 4.2. Cấu hình Django ALLOWED_HOSTS

```bash
nano environment/frontend_server/frontend_server/settings/base.py
```

Tìm `ALLOWED_HOSTS` và thêm:
```python
ALLOWED_HOSTS = ['*']  # Development
# Hoặc
ALLOWED_HOSTS = ['10.0.12.81', 'localhost', '127.0.0.1']
```

### 4.3. Kiểm tra Ollama

```bash
# Kiểm tra Ollama đang chạy
curl http://localhost:11434/api/tags

# Kiểm tra model
ollama list
```

## 🧪 Bước 5: Kiểm Tra

### 5.1. Test Ollama connection

```bash
cd ~/generative_agents
source venv/bin/activate
cd reverie/backend_server
python test_ollama_connection.py
```

Tất cả phải ✓!

### 5.2. Test Django

```bash
cd ~/generative_agents
source venv/bin/activate
cd environment/frontend_server
python manage.py check
```

## 🔥 Bước 6: Cấu Hình Firewall

```bash
# Cho phép port 8000
sudo ufw allow 8000/tcp
sudo ufw reload

# Kiểm tra
sudo ufw status
```

## 🎮 Bước 7: Chạy Servers

### 7.1. Sử dụng screen hoặc tmux (Khuyến nghị)

Cài đặt:
```bash
sudo apt install -y screen
# hoặc
sudo apt install -y tmux
```

### 7.2. Chạy Environment Server

**Terminal 1 hoặc Screen session:**
```bash
cd ~/generative_agents
source venv/bin/activate
cd environment/frontend_server
python manage.py runserver 0.0.0.0:8000
```

**Hoặc với screen:**
```bash
screen -S env_server
cd ~/generative_agents
source venv/bin/activate
cd environment/frontend_server
python manage.py runserver 0.0.0.0:8000
# Nhấn Ctrl+A, D để detach
```

### 7.3. Chạy Simulation Server

**Terminal 2 hoặc Screen session:**
```bash
cd ~/generative_agents
source venv/bin/activate
cd reverie/backend_server
python reverie.py
```

**Hoặc với screen:**
```bash
screen -S sim_server
cd ~/generative_agents
source venv/bin/activate
cd reverie/backend_server
python reverie.py
# Nhấn Ctrl+A, D để detach
```

### 7.4. Quản lý screen sessions

```bash
# Xem danh sách sessions
screen -ls

# Attach lại session
screen -r env_server
screen -r sim_server

# Kill session
screen -X -S env_server quit
```

## 🌐 Bước 8: Truy Cập Từ Laptop Windows

### Option 1: SSH Port Forwarding (Khuyến nghị - Bảo mật hơn)

**Trên Laptop Windows (PowerShell):**
```powershell
# Mở SSH tunnel
ssh -L 8000:localhost:8000 user@10.0.12.81

# Giữ terminal này mở, sau đó truy cập:
# http://localhost:8000
```

**Hoặc dùng PuTTY:**
1. Connection > SSH > Tunnels
2. Source port: `8000`
3. Destination: `localhost:8000`
4. Add
5. Connect

### Option 2: Truy Cập Trực Tiếp

```
http://10.0.12.81:8000
```

⚠️ **Lưu ý**: Cần đảm bảo firewall cho phép và network có thể truy cập.

## 🔄 Bước 9: Chạy Simulation

1. **Truy cập**: `http://localhost:8000/simulator_home` (nếu dùng port forwarding)
   hoặc `http://10.0.12.81:8000/simulator_home`

2. **Trong simulation server**, nhập:
   ```
   base_the_ville_isabella_maria_klaus
   my-simulation
   run 100
   ```

3. **Quan sát** agents di chuyển trên bản đồ

## 🛠️ Systemd Service (Tùy chọn - Chạy tự động)

### Tạo service cho Environment Server

```bash
sudo nano /etc/systemd/system/generative-agents-env.service
```

Nội dung:
```ini
[Unit]
Description=Generative Agents Environment Server
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/home/your_username/generative_agents/environment/frontend_server
Environment="PATH=/home/your_username/generative_agents/venv/bin"
ExecStart=/home/your_username/generative_agents/venv/bin/python manage.py runserver 0.0.0.0:8000
Restart=always

[Install]
WantedBy=multi-user.target
```

Kích hoạt:
```bash
sudo systemctl daemon-reload
sudo systemctl enable generative-agents-env
sudo systemctl start generative-agents-env
sudo systemctl status generative-agents-env
```

## 📊 Monitoring

### Kiểm tra RAM usage

```bash
free -h
htop  # Nếu đã cài
```

### Kiểm tra processes

```bash
ps aux | grep python
```

### Kiểm tra ports

```bash
sudo netstat -tlnp | grep 8000
```

## 🔧 Troubleshooting

### Lỗi: Cannot connect to 10.0.12.81:8000

**Kiểm tra:**
```bash
# Trên VM
sudo netstat -tlnp | grep 8000
sudo ufw status
```

**Giải pháp:**
```bash
sudo ufw allow 8000/tcp
```

### Lỗi: ALLOWED_HOSTS

**Giải pháp:**
```python
# settings/base.py
ALLOWED_HOSTS = ['*']  # Development only
```

### Lỗi: Ollama connection failed

**Kiểm tra:**
```bash
curl http://localhost:11434/api/tags
systemctl status ollama
```

### Lỗi: Port 8000 đã được sử dụng

**Tìm và kill process:**
```bash
sudo lsof -i :8000
sudo kill -9 <PID>
```

## 📝 Checklist

- [ ] Python 3.9.x đã cài
- [ ] Code đã upload lên VM
- [ ] Virtualenv đã tạo
- [ ] Dependencies đã cài
- [ ] utils.py đã cấu hình (localhost:11434)
- [ ] ALLOWED_HOSTS đã cấu hình
- [ ] Firewall đã mở port 8000
- [ ] Ollama đang chạy
- [ ] test_ollama_connection.py thành công
- [ ] Servers đang chạy
- [ ] Có thể truy cập từ laptop

## 💡 Tips

1. **Dùng screen/tmux**: Giữ servers chạy khi disconnect SSH
2. **Monitor RAM**: `htop` hoặc `free -h`
3. **Logs**: Check logs nếu có lỗi
4. **Backup**: Backup simulation data thường xuyên
5. **SSH key**: Setup SSH key để không cần nhập password

## 🎯 Kết Luận

Với 32GB RAM trên VM, bạn có thể:
- ✅ Chạy simulation lớn (25 agents)
- ✅ Chạy simulation dài (1000+ steps)
- ✅ Chạy nhiều simulation đồng thời
- ✅ Không lo về RAM

**Khuyến nghị: Triển khai trên VM Ubuntu!**


