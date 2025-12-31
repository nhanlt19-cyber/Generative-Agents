# Hướng Dẫn Chạy Dự Án Generative Agents Từ Đầu

Hướng dẫn này sẽ giúp bạn setup và chạy dự án "Generative Agents: Interactive Simulacra of Human Behavior" từ đầu, sử dụng virtualenv và Ollama.

## 📋 Yêu Cầu Hệ Thống

- **Python**: 3.9.12 (khuyến nghị) hoặc 3.9.x
- **RAM**: Tối thiểu 8GB (khuyến nghị 16GB+)
- **Disk**: Ít nhất 5GB trống
- **OS**: Windows, Linux, hoặc macOS
- **Ollama**: Đã cài đặt và chạy trên VM `10.0.12.81:11434` với model `llama3.1`

## 🚀 Bước 1: Chuẩn Bị Môi Trường

### 1.1. Kiểm tra Python

```bash
python --version
# Hoặc
python3 --version
```

Đảm bảo bạn có Python 3.9.x. Nếu chưa có, tải từ [python.org](https://www.python.org/downloads/).

### 1.2. Tạo Virtual Environment

Mở terminal/command prompt và di chuyển đến thư mục dự án:

```bash
cd "D:\Ths\KLTN\LLM\Defense LLM\Generatve Agent\generative_agents"
```

**Windows:**
```bash
# Tạo virtualenv
python -m venv venv

# Kích hoạt virtualenv
venv\Scripts\activate
```

**Linux/Mac:**
```bash
# Tạo virtualenv
python3 -m venv venv

# Kích hoạt virtualenv
source venv/bin/activate
```

Sau khi kích hoạt, bạn sẽ thấy `(venv)` ở đầu dòng command prompt.

### 1.3. Nâng cấp pip (khuyến nghị)

```bash
python -m pip install --upgrade pip
```

## 📦 Bước 2: Cài Đặt Dependencies

### 2.1. Cài đặt dependencies chính

```bash
pip install -r requirements.txt
```

Quá trình này có thể mất vài phút. Nếu gặp lỗi, xem phần Troubleshooting bên dưới.

### 2.2. Cài đặt dependencies cho frontend (Django)

```bash
cd environment/frontend_server
pip install -r requirements.txt
cd ../..
```

### 2.3. Tải dữ liệu NLTK (nếu cần)

Một số module có thể cần dữ liệu NLTK:

```python
python -c "import nltk; nltk.download('punkt'); nltk.download('stopwords')"
```

## ⚙️ Bước 3: Cấu Hình Dự Án

### 3.1. Kiểm tra file utils.py

File `reverie/backend_server/utils.py` đã được cấu hình với Ollama. Kiểm tra lại:

```python
# LLM Provider Configuration
llm_provider = "ollama"  # Đảm bảo là "ollama"

# Ollama Configuration
ollama_base_url = "http://10.0.12.81:11434"
ollama_model_name = "llama3.1"
ollama_embedding_model_name = "nomic-embed-text"
```

### 3.2. Kiểm tra kết nối Ollama

Chạy script kiểm tra:

```bash
cd reverie/backend_server
python test_ollama_connection.py
```

Nếu tất cả đều ✓, bạn có thể tiếp tục. Nếu có lỗi:
- Kiểm tra Ollama trên VM đang chạy
- Kiểm tra network connectivity: `ping 10.0.12.81`
- Kiểm tra firewall không chặn port 11434

## 🧪 Bước 4: Kiểm Tra Cài Đặt

### 4.1. Test import các module chính

```bash
cd reverie/backend_server
python -c "from utils import *; print('Utils OK')"
python -c "from persona.prompt_template.gpt_structure import *; print('GPT Structure OK')"
python -c "from persona.prompt_template.ollama_interface import *; print('Ollama Interface OK')"
```

### 4.2. Test Django

```bash
cd ../../environment/frontend_server
python manage.py check
```

Nếu không có lỗi, bạn đã sẵn sàng!

## 🎮 Bước 5: Chạy Simulation

### 5.1. Khởi động Environment Server (Terminal 1)

Mở terminal mới (giữ virtualenv đang active) hoặc activate lại:

```bash
# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

Sau đó:

```bash
cd environment/frontend_server
python manage.py runserver
```

Bạn sẽ thấy output tương tự:
```
Starting development server at http://127.0.0.1:8000/
Quit the server with CTRL-BREAK.
```

**Kiểm tra**: Mở trình duyệt và truy cập `http://localhost:8000/`. Bạn sẽ thấy thông báo "Your environment server is up and running".

⚠️ **Lưu ý**: Giữ terminal này mở và server đang chạy!

### 5.2. Khởi động Simulation Server (Terminal 2)

Mở terminal mới và activate virtualenv:

```bash
# Windows
cd "D:\Ths\KLTN\LLM\Defense LLM\Generatve Agent\generative_agents"
venv\Scripts\activate

# Linux/Mac
cd /path/to/generative_agents
source venv/bin/activate
```

Sau đó:

```bash
cd reverie/backend_server
python reverie.py
```

Bạn sẽ thấy prompt:
```
Enter the name of the forked simulation: 
```

**Nhập**: `base_the_ville_isabella_maria_klaus`

Sau đó prompt sẽ hỏi:
```
Enter the name of the new simulation: 
```

**Nhập**: Tên simulation của bạn, ví dụ: `my-first-simulation`

Sau đó bạn sẽ thấy:
```
Enter option: 
```

⚠️ **Lưu ý**: Giữ terminal này mở!

### 5.3. Chạy Simulation

1. **Mở trình duyệt**: Truy cập `http://localhost:8000/simulator_home`
   - Bạn sẽ thấy bản đồ Smallville và danh sách agents
   - Có thể di chuyển bằng phím mũi tên

2. **Chạy simulation**: Trong Terminal 2 (simulation server), nhập:
   ```
   run 50
   ```
   (Số 50 là số game steps. Mỗi step = 10 giây trong game)

3. **Quan sát**: Bạn sẽ thấy agents di chuyển trên bản đồ trong trình duyệt

4. **Sau khi hoàn thành**: Prompt "Enter option: " sẽ xuất hiện lại. Bạn có thể:
   - `run 50` - Chạy thêm 50 steps
   - `fin` - Lưu và thoát
   - `exit` - Thoát không lưu

## 💾 Bước 6: Lưu và Replay Simulation

### 6.1. Lưu Simulation

Khi simulation hoàn thành, nhập `fin` trong simulation server để lưu.

### 6.2. Replay Simulation

1. Đảm bảo environment server đang chạy
2. Truy cập: `http://localhost:8000/replay/<simulation-name>/<starting-step>`
   
   Ví dụ:
   ```
   http://localhost:8000/replay/my-first-simulation/1
   ```

### 6.3. Demo Simulation (với sprites)

Để có sprites đẹp hơn, cần compress simulation trước:

```python
# Mở Python trong terminal
cd reverie
python
```

```python
from compress_sim_storage import compress
compress("my-first-simulation")
```

Sau đó truy cập:
```
http://localhost:8000/demo/my-first-simulation/1/3
```
(Số 3 là tốc độ: 1=chậm nhất, 5=nhanh nhất)

## 🔧 Troubleshooting

### Lỗi: ModuleNotFoundError

**Nguyên nhân**: Chưa cài đặt dependencies hoặc virtualenv chưa active

**Giải pháp**:
```bash
# Đảm bảo virtualenv đang active
# Windows: venv\Scripts\activate
# Linux/Mac: source venv/bin/activate

# Cài lại dependencies
pip install -r requirements.txt
```

### Lỗi: Django không tìm thấy

**Giải pháp**:
```bash
cd environment/frontend_server
pip install -r requirements.txt
```

### Lỗi: Ollama connection failed

**Kiểm tra**:
1. Ollama trên VM đang chạy: `curl http://10.0.12.81:11434/api/tags`
2. Network connectivity: `ping 10.0.12.81`
3. Firewall không chặn port 11434

**Giải pháp**: Xem `REMOTE_OLLAMA_SETUP.md`

### Lỗi: Port 8000 đã được sử dụng

**Giải pháp**:
```bash
# Tìm process đang dùng port 8000
# Windows
netstat -ano | findstr :8000

# Linux/Mac
lsof -i :8000

# Hoặc dùng port khác
python manage.py runserver 8001
```

### Lỗi: Python version không đúng

**Yêu cầu**: Python 3.9.x

**Kiểm tra**:
```bash
python --version
```

**Nếu không đúng**, cài Python 3.9.12 từ [python.org](https://www.python.org/downloads/)

### Lỗi khi cài đặt packages

Một số package có thể cần compiler:

**Windows**: Cài [Visual C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)

**Linux**: 
```bash
sudo apt-get install build-essential python3-dev
```

**Mac**: 
```bash
xcode-select --install
```

## 📝 Tóm Tắt Các Lệnh Quan Trọng

### Setup
```bash
# Tạo virtualenv
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (Linux/Mac)
source venv/bin/activate

# Cài dependencies
pip install -r requirements.txt
cd environment/frontend_server
pip install -r requirements.txt
cd ../..
```

### Chạy Simulation
```bash
# Terminal 1: Environment Server
cd environment/frontend_server
python manage.py runserver

# Terminal 2: Simulation Server
cd reverie/backend_server
python reverie.py
# Nhập: base_the_ville_isabella_maria_klaus
# Nhập: my-simulation-name
# Nhập: run 50
```

### Kiểm tra
```bash
# Test Ollama connection
cd reverie/backend_server
python test_ollama_connection.py
```

## 🎯 Checklist Trước Khi Chạy

- [ ] Python 3.9.x đã cài đặt
- [ ] Virtualenv đã tạo và activate
- [ ] Tất cả dependencies đã cài đặt
- [ ] File `utils.py` đã cấu hình đúng với Ollama
- [ ] Ollama trên VM đang chạy và có thể kết nối
- [ ] `test_ollama_connection.py` chạy thành công
- [ ] Django server có thể khởi động

## 📚 Tài Liệu Tham Khảo

- `OLLAMA_SETUP_GUIDE.md` - Hướng dẫn chi tiết về Ollama
- `REMOTE_OLLAMA_SETUP.md` - Cấu hình Ollama trên VM
- `QUICK_START_OLLAMA.md` - Quick start guide
- `CHANGES_SUMMARY.md` - Tóm tắt các thay đổi

## 💡 Tips

1. **Lưu simulation thường xuyên**: Dùng `fin` để lưu, tránh mất dữ liệu
2. **Bắt đầu với số steps nhỏ**: Test với `run 10` trước khi chạy simulation lớn
3. **Monitor Ollama**: Kiểm tra logs trên VM nếu có vấn đề
4. **Sử dụng Chrome/Safari**: Firefox có thể có một số vấn đề hiển thị
5. **Kiểm tra RAM**: Simulation lớn có thể cần nhiều RAM

## 🆘 Cần Giúp Đỡ?

Nếu gặp vấn đề:
1. Kiểm tra phần Troubleshooting
2. Xem logs trong terminal
3. Kiểm tra `test_ollama_connection.py` output
4. Đảm bảo cả 2 server đang chạy

Chúc bạn thành công! 🎉

