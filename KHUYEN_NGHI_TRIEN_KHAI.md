# Khuyến Nghị Triển Khai - Windows vs Ubuntu VM

## 📊 So Sánh Hai Phương Án

### Phương Án 1: Cài trên Laptop Windows (8GB RAM)
### Phương Án 2: Cài trên VM Ubuntu (32GB RAM, 10.0.12.81)

## 🔍 Phân Tích Chi Tiết

### Phương Án 1: Laptop Windows 8GB RAM

#### ✅ Ưu Điểm
- **Dễ truy cập**: Không cần SSH, làm việc trực tiếp
- **UI/UX tốt**: Trình duyệt chạy mượt, không có latency
- **Development thuận tiện**: Debug và chỉnh sửa code dễ dàng
- **Không phụ thuộc network**: Không lo mất kết nối

#### ❌ Nhược Điểm
- **RAM hạn chế**: 8GB có thể không đủ cho simulation lớn
- **Performance**: Có thể chậm với nhiều agents
- **Resource conflict**: Phải chia sẻ với các ứng dụng khác
- **Nhiệt độ**: Laptop có thể nóng khi chạy lâu

#### 📈 Resource Requirements
- **Minimum**: 8GB RAM (bạn đang ở mức tối thiểu)
- **Recommended**: 16GB+ RAM
- **Với 8GB**: Chỉ nên chạy simulation nhỏ (3 agents), số steps ít

### Phương Án 2: VM Ubuntu 32GB RAM

#### ✅ Ưu Điểm
- **Tài nguyên dồi dào**: 32GB RAM đủ cho simulation lớn
- **Performance tốt**: Có thể chạy nhiều agents, simulation dài
- **Tập trung hóa**: Tất cả trên 1 server, dễ quản lý
- **Ollama local**: Không cần network call, nhanh hơn
- **Không ảnh hưởng laptop**: Laptop vẫn nhẹ, có thể làm việc khác

#### ❌ Nhược Điểm
- **Cần SSH**: Phải kết nối qua network
- **Latency**: Có thể có độ trễ nhỏ khi truy cập web UI
- **Phụ thuộc network**: Cần kết nối ổn định
- **Setup phức tạp hơn**: Cần cấu hình SSH, port forwarding

#### 📈 Resource Requirements
- **RAM**: 32GB (dư dả)
- **Có thể chạy**: 25 agents, simulation dài, nhiều simulation đồng thời

## 🎯 Khuyến Nghị

### **Khuyến nghị: Phương Án 2 (VM Ubuntu)**

**Lý do:**
1. **RAM đủ**: 32GB vs 8GB - chênh lệch lớn
2. **Ollama đã có sẵn**: Không cần network call, nhanh hơn
3. **Scalability**: Có thể mở rộng simulation lớn sau này
4. **Laptop nhẹ**: Không làm chậm laptop khi làm việc khác

### **Khi nào nên dùng Phương Án 1 (Windows):**
- Chỉ test/debug nhanh
- Simulation nhỏ (3 agents, < 50 steps)
- Không có kết nối mạng ổn định
- Cần development trực tiếp trên laptop

## 🏗️ Kiến Trúc Đề Xuất

### **Kiến Trúc Hybrid (Tốt Nhất)**

```
┌─────────────────┐         ┌──────────────────┐
│  Laptop Windows │  SSH    │   VM Ubuntu      │
│  (Development)  │────────▶│  (Production)    │
│                 │         │                  │
│  - Edit code    │         │  - App chạy      │
│  - Git          │         │  - Ollama        │
│  - Browser      │         │  - 32GB RAM      │
└─────────────────┘         └──────────────────┘
```

**Workflow:**
1. **Develop trên Windows**: Edit code, test local
2. **Deploy lên VM**: Chạy simulation thật trên VM
3. **Truy cập qua browser**: Port forwarding để xem UI

## 📋 Hướng Dẫn Triển Khai

### Phương Án 2: Triển Khai Trên VM Ubuntu

#### Bước 1: Chuẩn Bị VM Ubuntu

```bash
# Trên VM Ubuntu, cài đặt Python và dependencies
sudo apt update
sudo apt install python3.9 python3.9-venv python3-pip git -y

# Cài đặt các dependencies hệ thống
sudo apt install build-essential python3-dev -y
```

#### Bước 2: Clone/Upload Code

```bash
# Nếu code đã có trên VM
cd ~
git clone <your-repo> generative_agents
# hoặc upload code lên VM qua SCP/SFTP

cd generative_agents
```

#### Bước 3: Setup Virtualenv

```bash
# Tạo virtualenv
python3.9 -m venv venv

# Activate
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip
```

#### Bước 4: Cài Đặt Dependencies

```bash
# Cài dependencies chính
pip install -r requirements.txt

# Cài dependencies frontend
cd environment/frontend_server
pip install -r requirements.txt
cd ../..
```

#### Bước 5: Cấu Hình

File `reverie/backend_server/utils.py`:
```python
llm_provider = "ollama"
ollama_base_url = "http://localhost:11434"  # Local vì cùng VM
ollama_model_name = "llama3.1"
ollama_embedding_model_name = "nomic-embed-text"
```

#### Bước 6: Cấu Hình Django để chấp nhận remote connections

File `environment/frontend_server/frontend_server/settings/local.py` hoặc `base.py`:
```python
ALLOWED_HOSTS = ['*']  # Hoặc ['10.0.12.81', 'localhost']
```

Hoặc khi chạy:
```bash
python manage.py runserver 0.0.0.0:8000
```

#### Bước 7: Chạy Servers

**Terminal 1 - Environment Server:**
```bash
cd ~/generative_agents
source venv/bin/activate
cd environment/frontend_server
python manage.py runserver 0.0.0.0:8000
```

**Terminal 2 - Simulation Server:**
```bash
cd ~/generative_agents
source venv/bin/activate
cd reverie/backend_server
python reverie.py
```

#### Bước 8: Truy Cập Từ Laptop Windows

**Option 1: Port Forwarding (SSH Tunnel)**
```bash
# Trên laptop Windows (PowerShell hoặc CMD)
ssh -L 8000:localhost:8000 user@10.0.12.81

# Sau đó truy cập: http://localhost:8000
```

**Option 2: Truy Cập Trực Tiếp**
```
http://10.0.12.81:8000
```
(Cần đảm bảo firewall cho phép port 8000)

### Phương Án 1: Triển Khai Trên Windows (Nếu Cần)

Nếu vẫn muốn chạy trên Windows với 8GB RAM:

#### Tối Ưu Hóa:
1. **Đóng các ứng dụng khác** khi chạy simulation
2. **Chạy simulation nhỏ**: 3 agents, < 100 steps
3. **Tăng virtual memory** (swap file)
4. **Monitor RAM usage**: Task Manager

#### Cấu Hình Windows:
```powershell
# Tăng virtual memory (nếu cần)
# Control Panel > System > Advanced > Performance Settings
# Virtual Memory > Custom size: 16384 MB
```

## 🔧 Cấu Hình Network (Cho Phương Án 2)

### Firewall trên VM Ubuntu

```bash
# Cho phép port 8000
sudo ufw allow 8000/tcp
sudo ufw reload
```

### SSH Port Forwarding (Khuyến nghị)

**Trên Laptop Windows:**
```bash
# Cài PuTTY hoặc dùng OpenSSH (Windows 10+)
ssh -L 8000:localhost:8000 -N user@10.0.12.81
```

**Hoặc dùng PuTTY:**
1. Connection > SSH > Tunnels
2. Source port: 8000
3. Destination: localhost:8000
4. Add
5. Connect

Sau đó truy cập `http://localhost:8000` trên laptop.

## 📊 So Sánh Performance

| Tiêu chí | Windows 8GB | Ubuntu 32GB |
|----------|-------------|-------------|
| RAM available | ~4-5GB | ~28-30GB |
| Max agents | 3-5 | 25+ |
| Max steps | 50-100 | 1000+ |
| Simulation time | Chậm | Nhanh |
| Stability | Có thể crash | Ổn định |
| Multi-tasking | Khó | Dễ |

## 🎯 Kết Luận

### **Khuyến nghị cuối cùng: Phương Án 2 (VM Ubuntu)**

**Lý do chính:**
1. ✅ RAM đủ (32GB vs 8GB)
2. ✅ Ollama local, nhanh hơn
3. ✅ Có thể chạy simulation lớn
4. ✅ Không làm chậm laptop
5. ✅ Dễ scale sau này

**Setup ban đầu có thể phức tạp hơn, nhưng:**
- Chỉ setup 1 lần
- Có thể dùng SSH port forwarding để truy cập dễ dàng
- Performance tốt hơn nhiều

### **Workflow Đề Xuất:**

1. **Development**: Code trên Windows, test nhỏ
2. **Production**: Deploy và chạy trên VM Ubuntu
3. **Access**: SSH port forwarding để xem UI trên laptop

## 📝 Checklist Triển Khai VM Ubuntu

- [ ] Python 3.9.x đã cài trên VM
- [ ] Code đã upload/clone lên VM
- [ ] Virtualenv đã tạo và activate
- [ ] Dependencies đã cài đặt
- [ ] Ollama đang chạy trên VM (localhost)
- [ ] Django configured với ALLOWED_HOSTS
- [ ] Firewall cho phép port 8000
- [ ] SSH port forwarding setup (nếu cần)
- [ ] Test connection từ laptop

## 🆘 Troubleshooting

### Lỗi: Cannot connect to VM

**Kiểm tra:**
```bash
# Trên VM
sudo netstat -tlnp | grep 8000
sudo ufw status
```

### Lỗi: Django ALLOWED_HOSTS

**Giải pháp:**
```python
# settings.py
ALLOWED_HOSTS = ['*']  # Development only
# Hoặc
ALLOWED_HOSTS = ['10.0.12.81', 'localhost']
```

### Lỗi: SSH connection refused

**Kiểm tra SSH service:**
```bash
sudo systemctl status ssh
sudo systemctl start ssh
```

---

**Kết luận: Với 32GB RAM trên VM, đây là lựa chọn tốt nhất cho dự án này!**

