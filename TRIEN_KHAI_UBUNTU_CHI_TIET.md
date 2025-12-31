# Hướng Dẫn Triển Khai Chi Tiết - Ubuntu VM

Hướng dẫn từng bước để triển khai Generative Agents trên VM Ubuntu và truy cập từ laptop qua `http://10.0.12.81:8000`.

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

### 1.1. Kết Nối SSH Vào VM

**Từ Laptop Windows (PowerShell hoặc CMD):**
```powershell
ssh username@10.0.12.81
```

**Lần đầu kết nối**, bạn sẽ được hỏi xác nhận fingerprint, nhập `yes`.

### 1.2. Cập Nhật Hệ Thống

```bash
# Cập nhật package list
sudo apt update

# Nâng cấp packages (tùy chọn)
sudo apt upgrade -y
```

### 1.3. Cài Đặt Python và Dependencies

```bash
# Cài Python 3.9 và các công cụ cần thiết
sudo apt install -y python3.9 python3.9-venv python3-pip git

# Cài build tools (cần cho một số Python packages)
sudo apt install -y build-essential python3-dev python3.9-dev

# Cài screen hoặc tmux (để giữ servers chạy khi disconnect)
sudo apt install -y screen
# hoặc
sudo apt install -y tmux
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

**Nếu chưa có model llama3.1:**
```bash
ollama pull llama3.1
ollama pull nomic-embed-text
```

---

## 📦 Bước 2: Upload Code Lên VM

### Option 1: SCP (Khuyến Nghị)

**Từ Laptop Windows (PowerShell):**

```powershell
# Từ thư mục chứa dự án trên Windows
cd "D:\Ths\KLTN\LLM\Defense LLM\Generatve Agent"

# Upload toàn bộ thư mục generative_agents
scp -r generative_agents username@10.0.12.81:~/
```

**Lưu ý:** Quá trình upload có thể mất vài phút tùy vào kích thước dự án.

### Option 2: Git Clone (Nếu có Git Repository)

```bash
# Trên VM
cd ~
git clone <your-repo-url> generative_agents
cd generative_agents
```

### Option 3: Zip và Upload

**Trên Windows:**
```powershell
# Zip dự án
Compress-Archive -Path "generative_agents" -DestinationPath "generative_agents.zip"

# Upload zip file
scp generative_agents.zip username@10.0.12.81:~/
```

**Trên VM:**
```bash
cd ~
unzip generative_agents.zip
cd generative_agents
```

### Option 4: WinSCP/FileZilla (GUI)

1. Mở WinSCP hoặc FileZilla
2. Kết nối đến `10.0.12.81` với username/password
3. Upload thư mục `generative_agents` lên home directory (`~/`)

---

## ⚙️ Bước 3: Setup Môi Trường

### 3.1. Di Chuyển Đến Thư Mục Dự Án

```bash
cd ~/generative_agents
```

### 3.2. Chạy Script Setup Tự Động

```bash
# Cấp quyền thực thi
chmod +x setup_ubuntu.sh

# Chạy script
./setup_ubuntu.sh
```

Script sẽ tự động:
- Tạo virtualenv
- Cài đặt dependencies
- Cấu hình firewall

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

**Lưu ý:** Quá trình cài đặt có thể mất 5-10 phút.

---

## 🔧 Bước 4: Cấu Hình Dự Án

### 4.1. Cấu Hình Ollama (utils.py)

File này đã được sửa để dùng `localhost:11434`. Kiểm tra lại:

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

File `base.py` đã được sửa. Kiểm tra lại:

```bash
nano environment/frontend_server/frontend_server/settings/base.py
```

**Tìm dòng:**
```python
ALLOWED_HOSTS = ['*']  # Allows access from any IP
```

Nếu chưa có, sửa từ:
```python
ALLOWED_HOSTS = []
```

Thành:
```python
ALLOWED_HOSTS = ['*']  # Development: allows access from any IP
```

**Lưu file:** `Ctrl+O`, `Enter`, `Ctrl+X`

### 4.3. Cấu Hình Firewall

```bash
# Cho phép port 8000 (Django)
sudo ufw allow 8000/tcp

# Kiểm tra firewall status
sudo ufw status

# Nếu firewall chưa enable
sudo ufw enable
```

---

## ✅ Bước 5: Kiểm Tra

### 5.1. Kiểm Tra Ollama Connection

```bash
cd ~/generative_agents
source venv/bin/activate
cd reverie/backend_server
python test_ollama_connection.py
```

**Kết quả mong đợi:**
```
============================================================
KIỂM TRA CẤU HÌNH OLLAMA
============================================================

1. LLM Provider: ollama
   ✓ Provider được cấu hình đúng

2. Kiểm tra kết nối Ollama tại: http://localhost:11434
   ✓ Kết nối Ollama thành công

3. Kiểm tra model text generation: llama3.1
   ✓ Model 'llama3.1' hoạt động tốt

4. Kiểm tra model embedding: nomic-embed-text
   ✓ Model embedding 'nomic-embed-text' hoạt động tốt
```

Nếu có lỗi, xem phần Troubleshooting.

### 5.2. Kiểm Tra Django

```bash
cd ~/generative_agents
source venv/bin/activate
cd environment/frontend_server
python manage.py check
```

**Kết quả mong đợi:** Không có lỗi.

### 5.3. Kiểm Tra Network

```bash
# Kiểm tra IP của VM
hostname -I

# Đảm bảo có 10.0.12.81 trong output
```

---

## 🎮 Bước 6: Chạy Servers

### 6.1. Sử Dụng Screen (Khuyến Nghị)

Screen cho phép giữ servers chạy khi disconnect SSH.

#### Tạo Screen Session cho Environment Server

```bash
# Tạo screen session
screen -S env_server

# Trong screen session
cd ~/generative_agents
source venv/bin/activate
cd environment/frontend_server
python manage.py runserver 0.0.0.0:8000
```

**Detach khỏi screen:** Nhấn `Ctrl+A`, sau đó `D`

#### Tạo Screen Session cho Simulation Server

**Mở terminal/SSH session mới:**
```bash
# SSH vào VM lần nữa (hoặc mở tab mới)
ssh username@10.0.12.81

# Tạo screen session
screen -S sim_server

# Trong screen session
cd ~/generative_agents
source venv/bin/activate
cd reverie/backend_server
python reverie.py
```

**Detach khỏi screen:** Nhấn `Ctrl+A`, sau đó `D`

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

### 6.2. Hoặc Chạy Trực Tiếp (Không Dùng Screen)

**Terminal 1 - Environment Server:**
```bash
cd ~/generative_agents
source venv/bin/activate
cd environment/frontend_server
python manage.py runserver 0.0.0.0:8000
```

**Terminal 2 - Simulation Server:**
```bash
# SSH vào VM lần nữa
ssh username@10.0.12.81

cd ~/generative_agents
source venv/bin/activate
cd reverie/backend_server
python reverie.py
```

**⚠️ Lưu ý:** Nếu disconnect SSH, servers sẽ dừng. Nên dùng screen.

### 6.3. Khi Simulation Server Khởi Động

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
# Kiểm tra port 8000
sudo netstat -tlnp | grep 8000

# Hoặc
sudo ss -tlnp | grep 8000
```

Bạn sẽ thấy Django đang listen trên `0.0.0.0:8000`.

### 7.2. Truy Cập Từ Laptop Windows

**Mở trình duyệt** (Chrome, Edge, Firefox) và truy cập:

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

2. **Quan sát** trên trình duyệt: Agents sẽ di chuyển trên bản đồ

3. **Sau khi hoàn thành**, bạn có thể:
   - `run 100` - Chạy thêm 100 steps
   - `fin` - Lưu và thoát
   - `exit` - Thoát không lưu

---

## 🔧 Bước 8: Tối Ưu và Bảo Mật

### 8.1. Tạo Systemd Services (Tùy Chọn)

Để servers tự động khởi động khi VM reboot:

#### Tạo Service cho Environment Server

```bash
sudo nano /etc/systemd/system/generative-agents-env.service
```

**Nội dung:**
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
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Thay `your_username` bằng username của bạn!**

**Kích hoạt:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable generative-agents-env
sudo systemctl start generative-agents-env
sudo systemctl status generative-agents-env
```

### 8.2. Giới Hạn ALLOWED_HOSTS (Bảo Mật)

Thay vì `ALLOWED_HOSTS = ['*']`, nên dùng:

```python
ALLOWED_HOSTS = ['10.0.12.81', 'localhost', '127.0.0.1']
```

### 8.3. Tạo Script Khởi Động Nhanh

**Tạo file `start_servers.sh`:**
```bash
nano ~/start_servers.sh
```

**Nội dung:**
```bash
#!/bin/bash

cd ~/generative_agents
source venv/bin/activate

# Start environment server in screen
screen -dmS env_server bash -c "cd environment/frontend_server && python manage.py runserver 0.0.0.0:8000"

# Start simulation server in screen
screen -dmS sim_server bash -c "cd reverie/backend_server && python reverie.py"

echo "Servers started in screen sessions"
echo "View with: screen -r env_server or screen -r sim_server"
```

**Cấp quyền:**
```bash
chmod +x ~/start_servers.sh
```

**Sử dụng:**
```bash
~/start_servers.sh
```

---

## 🆘 Troubleshooting

### Lỗi: Cannot connect to http://10.0.12.81:8000

**Kiểm tra:**

1. **Firewall:**
   ```bash
   sudo ufw status
   sudo ufw allow 8000/tcp
   ```

2. **Server đang chạy:**
   ```bash
   sudo netstat -tlnp | grep 8000
   ```

3. **ALLOWED_HOSTS:**
   ```bash
   grep ALLOWED_HOSTS environment/frontend_server/frontend_server/settings/base.py
   ```
   Phải có `'*'` hoặc `'10.0.12.81'`

4. **Network connectivity từ laptop:**
   ```powershell
   # Trên Windows
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
sudo systemctl restart ollama
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
sudo lsof -i :8000
# hoặc
sudo fuser -k 8000/tcp

# Kill process cụ thể
sudo kill -9 <PID>
```

### Lỗi: Permission denied

**Giải pháp:**

```bash
# Cấp quyền cho thư mục
chmod -R 755 ~/generative_agents

# Hoặc chạy với user thường (không dùng sudo cho Python)
```

### Lỗi: Screen session not found

**Giải pháp:**

```bash
# Xem tất cả sessions (kể cả detached)
screen -ls

# Attach với force
screen -r -d env_server
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
htop  # Nếu đã cài: sudo apt install htop
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

## 📝 Checklist Triển Khai

- [ ] Python 3.9.x đã cài trên VM
- [ ] Ollama đang chạy với model llama3.1
- [ ] Code đã upload lên VM
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

## 🎯 Tóm Tắt Các Lệnh Quan Trọng

### Setup
```bash
cd ~/generative_agents
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

# Network
sudo netstat -tlnp | grep 8000
```

---

## 🎉 Hoàn Tất!

Bây giờ bạn có thể:
- ✅ Truy cập từ laptop: `http://10.0.12.81:8000`
- ✅ Chạy simulation lớn với 32GB RAM
- ✅ Ollama chạy local, nhanh hơn
- ✅ Servers chạy ổn định trên VM

**Chúc bạn thành công!** 🚀

