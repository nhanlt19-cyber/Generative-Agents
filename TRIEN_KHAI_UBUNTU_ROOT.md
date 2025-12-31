# Hướng Dẫn Triển Khai Chi Tiết - Ubuntu VM (ROOT)

⚠️ **CẢNH BÁO**: Hướng dẫn này dành cho việc chạy dưới quyền ROOT. Chỉ sử dụng cho development/test, **KHÔNG** dùng cho production!

## 📋 Mục Lục

1. [Chuẩn Bị](#chuẩn-bị)
2. [Upload Code Lên VM](#upload-code-lên-vm)
3. [Setup Môi Trường](#setup-môi-trường)
4. [Cấu Hình Dự Án](#cấu-hình-dự-án)
5. [Kiểm Tra](#kiểm-tra)
6. [Chạy Servers](#chạy-servers)
7. [Truy Cập Từ Laptop](#truy-cập-từ-laptop)
8. [Troubleshooting](#troubleshooting)

---

## 🚀 Bước 1: Chuẩn Bị

### 1.1. Kết Nối SSH Vào VM (với root)

**Từ Laptop Windows:**
```powershell
ssh root@10.0.12.81
```

**Hoặc nếu cần sudo:**
```powershell
ssh username@10.0.12.81
sudo su -
```

### 1.2. Cập Nhật Hệ Thống

```bash
# Cập nhật package list (không cần sudo vì đã là root)
apt update

# Nâng cấp packages (tùy chọn)
apt upgrade -y
```

### 1.3. Cài Đặt Python và Dependencies

```bash
# Cài Python 3.9 và các công cụ cần thiết (không cần sudo)
apt install -y python3.9 python3.9-venv python3-pip git

# Cài build tools
apt install -y build-essential python3-dev python3.9-dev

# Cài screen hoặc tmux
apt install -y screen
```

### 1.4. Kiểm Tra Ollama

```bash
# Kiểm tra Ollama đã cài chưa
ollama --version

# Kiểm tra Ollama đang chạy
curl http://localhost:11434/api/tags

# Kiểm tra model đã tải
ollama list
```

**Nếu chưa có model:**
```bash
ollama pull llama3.1
ollama pull nomic-embed-text
```

---

## 📦 Bước 2: Upload Code Lên VM

### Option 1: SCP (Khuyến Nghị)

**Từ Laptop Windows (PowerShell):**

```powershell
# Upload toàn bộ thư mục
scp -r generative_agents root@10.0.12.81:/root/
```

### Option 2: Git Clone

```bash
# Trên VM (với root)
cd /root
git clone <your-repo-url> generative_agents
cd generative_agents
```

### Option 3: WinSCP/FileZilla

1. Kết nối đến `10.0.12.81` với user `root`
2. Upload thư mục `generative_agents` lên `/root/`

---

## ⚙️ Bước 3: Setup Môi Trường

### 3.1. Di Chuyển Đến Thư Mục Dự Án

```bash
cd /root/generative_agents
```

### 3.2. Chạy Script Setup Tự Động

```bash
# Cấp quyền thực thi
chmod +x setup_ubuntu_root.sh

# Chạy script (đã là root nên không cần sudo)
./setup_ubuntu_root.sh
```

### 3.3. Hoặc Setup Thủ Công

```bash
# Tạo virtual environment
python3.9 -m venv venv

# Kích hoạt virtualenv
source venv/bin/activate

# Nâng cấp pip
pip install --upgrade pip

# Cài đặt dependencies chính
pip install -r requirements.txt

# Cài đặt dependencies cho frontend
cd environment/frontend_server
pip install -r requirements.txt
cd ../..
```

---

## 🔧 Bước 4: Cấu Hình Dự Án

### 4.1. Cấu Hình Ollama (utils.py)

```bash
nano reverie/backend_server/utils.py
```

**Đảm bảo có:**
```python
llm_provider = "ollama"
ollama_base_url = "http://localhost:11434"  # Local vì cùng VM
ollama_model_name = "llama3.1"
ollama_embedding_model_name = "nomic-embed-text"
```

**Lưu file:** `Ctrl+O`, `Enter`, `Ctrl+X`

### 4.2. Cấu Hình Django ALLOWED_HOSTS

```bash
nano environment/frontend_server/frontend_server/settings/base.py
```

**Tìm và sửa:**
```python
ALLOWED_HOSTS = ['*']  # Allows access from any IP
```

**Lưu file:** `Ctrl+O`, `Enter`, `Ctrl+X`

### 4.3. Cấu Hình Firewall

```bash
# Cho phép port 8000 (không cần sudo vì đã là root)
ufw allow 8000/tcp

# Kiểm tra firewall status
ufw status

# Nếu firewall chưa enable
ufw enable
```

---

## ✅ Bước 5: Kiểm Tra

### 5.1. Kiểm Tra Ollama Connection

```bash
cd /root/generative_agents
source venv/bin/activate
cd reverie/backend_server
python test_ollama_connection.py
```

**Kết quả mong đợi:** Tất cả đều ✓

### 5.2. Kiểm Tra Django

```bash
cd /root/generative_agents
source venv/bin/activate
cd environment/frontend_server
python manage.py check
```

**Kết quả mong đợi:** Không có lỗi

### 5.3. Kiểm Tra Network

```bash
# Kiểm tra IP của VM
hostname -I

# Đảm bảo có 10.0.12.81
```

---

## 🎮 Bước 6: Chạy Servers

### 6.1. Sử Dụng Script (Khuyến Nghị)

```bash
cd /root/generative_agents
chmod +x start_servers_root.sh
./start_servers_root.sh
```

### 6.2. Hoặc Chạy Thủ Công Với Screen

#### Tạo Screen Session cho Environment Server

```bash
# Tạo screen session
screen -S env_server

# Trong screen session
cd /root/generative_agents
source venv/bin/activate
cd environment/frontend_server
python manage.py runserver 0.0.0.0:8000
```

**Detach:** `Ctrl+A`, sau đó `D`

#### Tạo Screen Session cho Simulation Server

**Mở SSH session mới:**
```bash
ssh root@10.0.12.81

# Tạo screen session
screen -S sim_server

# Trong screen session
cd /root/generative_agents
source venv/bin/activate
cd reverie/backend_server
python reverie.py
```

**Detach:** `Ctrl+A`, sau đó `D`

#### Quản Lý Screen Sessions

```bash
# Xem danh sách sessions
screen -ls

# Attach lại session
screen -r env_server
screen -r sim_server

# Kill session
screen -X -S env_server quit
```

### 6.3. Hoặc Chạy Trực Tiếp (Không Dùng Screen)

**Terminal 1 - Environment Server:**
```bash
cd /root/generative_agents
source venv/bin/activate
cd environment/frontend_server
python manage.py runserver 0.0.0.0:8000
```

**Terminal 2 - Simulation Server:**
```bash
# SSH vào VM lần nữa
ssh root@10.0.12.81

cd /root/generative_agents
source venv/bin/activate
cd reverie/backend_server
python reverie.py
```

**⚠️ Lưu ý:** Nếu disconnect SSH, servers sẽ dừng. Nên dùng screen.

### 6.4. Khi Simulation Server Khởi Động

Bạn sẽ thấy:
```
Enter the name of the forked simulation: 
```

**Nhập:** `base_the_ville_isabella_maria_klaus`

Sau đó:
```
Enter the name of the new simulation: 
```

**Nhập:** Tên simulation của bạn, ví dụ: `my-first-simulation`

Sau đó:
```
Enter option: 
```

**Giữ terminal này mở!**

---

## 🌐 Bước 7: Truy Cập Từ Laptop

### 7.1. Kiểm Tra Servers Đang Chạy

**Trên VM:**
```bash
# Kiểm tra port 8000 (không cần sudo)
netstat -tlnp | grep 8000

# Hoặc
ss -tlnp | grep 8000
```

Bạn sẽ thấy Django đang listen trên `0.0.0.0:8000`.

### 7.2. Truy Cập Từ Laptop Windows

**Mở trình duyệt** và truy cập:

```
http://10.0.12.81:8000
```

**Bạn sẽ thấy:** "Your environment server is up and running"

### 7.3. Truy Cập Simulator

```
http://10.0.12.81:8000/simulator_home
```

**Bạn sẽ thấy:**
- Bản đồ Smallville
- Danh sách agents
- Có thể di chuyển bằng phím mũi tên

### 7.4. Chạy Simulation

1. **Trong simulation server** (trên VM), nhập:
   ```
   run 50
   ```

2. **Quan sát** trên trình duyệt: Agents sẽ di chuyển

3. **Sau khi hoàn thành**, bạn có thể:
   - `run 100` - Chạy thêm 100 steps
   - `fin` - Lưu và thoát
   - `exit` - Thoát không lưu

---

## 🔧 Bước 8: Tối Ưu và Bảo Mật

### 8.1. Tạo Systemd Services (Tùy Chọn)

#### Tạo Service cho Environment Server

```bash
nano /etc/systemd/system/generative-agents-env.service
```

**Nội dung:**
```ini
[Unit]
Description=Generative Agents Environment Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/generative_agents/environment/frontend_server
Environment="PATH=/root/generative_agents/venv/bin"
ExecStart=/root/generative_agents/venv/bin/python manage.py runserver 0.0.0.0:8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Kích hoạt:**
```bash
systemctl daemon-reload
systemctl enable generative-agents-env
systemctl start generative-agents-env
systemctl status generative-agents-env
```

### 8.2. Giới Hạn ALLOWED_HOSTS (Bảo Mật)

Thay vì `ALLOWED_HOSTS = ['*']`, nên dùng:

```python
ALLOWED_HOSTS = ['10.0.12.81', 'localhost', '127.0.0.1']
```

### 8.3. Tạo Script Khởi Động Nhanh

**Tạo file `/root/start_servers.sh`:**
```bash
nano /root/start_servers.sh
```

**Nội dung:**
```bash
#!/bin/bash

cd /root/generative_agents
source venv/bin/activate

# Start environment server in screen
screen -dmS env_server bash -c "cd /root/generative_agents/environment/frontend_server && source /root/generative_agents/venv/bin/activate && python manage.py runserver 0.0.0.0:8000"

# Start simulation server in screen
screen -dmS sim_server bash -c "cd /root/generative_agents/reverie/backend_server && source /root/generative_agents/venv/bin/activate && python reverie.py"

echo "Servers started in screen sessions"
echo "View with: screen -r env_server or screen -r sim_server"
```

**Cấp quyền:**
```bash
chmod +x /root/start_servers.sh
```

**Sử dụng:**
```bash
/root/start_servers.sh
```

---

## 🆘 Troubleshooting

### Lỗi: Cannot connect to http://10.0.12.81:8000

**Kiểm tra:**

1. **Firewall:**
   ```bash
   ufw status
   ufw allow 8000/tcp
   ```

2. **Server đang chạy:**
   ```bash
   netstat -tlnp | grep 8000
   ```

3. **ALLOWED_HOSTS:**
   ```bash
   grep ALLOWED_HOSTS environment/frontend_server/frontend_server/settings/base.py
   ```

4. **Network connectivity từ laptop:**
   ```powershell
   ping 10.0.12.81
   telnet 10.0.12.81 8000
   ```

### Lỗi: Ollama connection failed

**Kiểm tra:**

```bash
# Ollama đang chạy
curl http://localhost:11434/api/tags

# Model đã tải
ollama list

# Restart Ollama nếu cần
systemctl restart ollama
```

### Lỗi: ModuleNotFoundError

**Giải pháp:**

```bash
# Đảm bảo virtualenv đang active
source venv/bin/activate

# Cài lại dependencies
pip install -r requirements.txt
cd environment/frontend_server
pip install -r requirements.txt
```

### Lỗi: Port 8000 already in use

**Tìm và kill process:**

```bash
# Tìm process
lsof -i :8000
# hoặc
fuser -k 8000/tcp

# Kill process cụ thể
kill -9 <PID>
```

### Lỗi: Permission denied

**⚠️ Lưu ý:** Khi chạy dưới root, thường không có lỗi permission. Nếu có, kiểm tra:

```bash
# Kiểm tra quyền
ls -la /root/generative_agents

# Cấp quyền nếu cần
chmod -R 755 /root/generative_agents
```

---

## 📊 Monitoring

### Kiểm Tra RAM Usage

```bash
free -h
```

### Kiểm Tra CPU Usage

```bash
top
# hoặc
htop  # Nếu đã cài: apt install htop
```

### Kiểm Tra Disk Usage

```bash
df -h
```

### Kiểm Tra Processes

```bash
ps aux | grep python
```

---

## ⚠️ Lưu Ý Quan Trọng Khi Chạy Dưới ROOT

1. **Bảo mật:**
   - ⚠️ Không nên expose ra internet công cộng
   - ⚠️ Chỉ dùng trong mạng nội bộ
   - ⚠️ Không dùng cho production

2. **Permissions:**
   - Tất cả files sẽ được tạo với quyền root
   - Cần cẩn thận khi chia sẻ files

3. **Security:**
   - Django secret key nên được bảo vệ
   - Không commit credentials vào git

4. **Best Practice:**
   - Nên tạo user riêng cho production
   - Chỉ dùng root cho development/test

---

## 📝 Checklist Triển Khai

- [ ] Python 3.9.x đã cài trên VM
- [ ] Ollama đang chạy với model llama3.1
- [ ] Code đã upload lên `/root/generative_agents`
- [ ] Virtualenv đã tạo và activate
- [ ] Dependencies đã cài đặt
- [ ] `utils.py` đã cấu hình (localhost:11434)
- [ ] `ALLOWED_HOSTS` đã cấu hình ('*')
- [ ] Firewall đã mở port 8000
- [ ] `test_ollama_connection.py` chạy thành công
- [ ] Environment server đang chạy (0.0.0.0:8000)
- [ ] Simulation server đang chạy
- [ ] Có thể truy cập http://10.0.12.81:8000 từ laptop
- [ ] Simulation chạy được

---

## 🎯 Tóm Tắt Các Lệnh Quan Trọng (ROOT)

### Setup
```bash
cd /root/generative_agents
python3.9 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd environment/frontend_server && pip install -r requirements.txt && cd ../..
```

### Chạy Servers
```bash
# Environment Server
screen -S env_server
source venv/bin/activate
cd environment/frontend_server
python manage.py runserver 0.0.0.0:8000

# Simulation Server
screen -S sim_server
source venv/bin/activate
cd reverie/backend_server
python reverie.py
```

### Kiểm Tra
```bash
# Ollama
curl http://localhost:11434/api/tags

# Django
python manage.py check

# Network (không cần sudo)
netstat -tlnp | grep 8000
```

### Scripts Helper
```bash
# Start servers
./start_servers_root.sh

# Check status
./check_status_root.sh

# Stop servers
screen -X -S env_server quit
screen -X -S sim_server quit
```

---

## 🎉 Hoàn Tất!

Bây giờ bạn có thể:
- ✅ Truy cập từ laptop: `http://10.0.12.81:8000`
- ✅ Chạy simulation lớn với 32GB RAM
- ✅ Ollama chạy local, nhanh hơn
- ✅ Servers chạy ổn định trên VM (dưới root)

**⚠️ Nhớ:** Chỉ dùng cho development/test, không dùng cho production!

**Chúc bạn thành công!** 🚀

