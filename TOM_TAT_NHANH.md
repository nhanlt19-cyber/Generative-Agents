# Tóm Tắt Nhanh - Chạy Dự Án

## 🚀 Setup Nhanh (Lần Đầu)

### Windows
```bash
# 1. Chạy script setup tự động
setup.bat

# 2. Hoặc làm thủ công:
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
cd environment\frontend_server
pip install -r requirements.txt
cd ..\..
```

### Linux/Mac
```bash
# 1. Chạy script setup tự động
chmod +x setup.sh
./setup.sh

# 2. Hoặc làm thủ công:
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd environment/frontend_server
pip install -r requirements.txt
cd ../..
```

## ✅ Kiểm Tra Trước Khi Chạy

```bash
# 1. Kích hoạt virtualenv
# Windows: venv\Scripts\activate
# Linux/Mac: source venv/bin/activate

# 2. Kiểm tra Ollama connection
cd reverie/backend_server
python test_ollama_connection.py
```

Tất cả phải ✓ mới tiếp tục!

## 🎮 Chạy Simulation

### Cách 1: Dùng Script (Windows)

**Terminal 1 - Environment Server:**
```bash
run_environment_server.bat
```

**Terminal 2 - Simulation Server:**
```bash
run_simulation_server.bat
```

### Cách 2: Thủ Công

**Terminal 1 - Environment Server:**
```bash
# Kích hoạt virtualenv trước
venv\Scripts\activate  # Windows
# hoặc
source venv/bin/activate  # Linux/Mac

cd environment/frontend_server
python manage.py runserver
```

**Terminal 2 - Simulation Server:**
```bash
# Kích hoạt virtualenv trước
venv\Scripts\activate  # Windows
# hoặc
source venv/bin/activate  # Linux/Mac

cd reverie/backend_server
python reverie.py
```

Khi được hỏi:
- `Enter the name of the forked simulation: ` → `base_the_ville_isabella_maria_klaus`
- `Enter the name of the new simulation: ` → `my-simulation`
- `Enter option: ` → `run 50`

## 🌐 Truy Cập

- **Environment**: http://localhost:8000
- **Simulator Home**: http://localhost:8000/simulator_home
- **Replay**: http://localhost:8000/replay/<simulation-name>/1
- **Demo**: http://localhost:8000/demo/<simulation-name>/1/3

## ⚙️ Cấu Hình

File `reverie/backend_server/utils.py`:
```python
llm_provider = "ollama"
ollama_base_url = "http://10.0.12.81:11434"
ollama_model_name = "llama3.1"
```

## 🔧 Lệnh Hữu Ích

```bash
# Kiểm tra Python version
python --version

# Kiểm tra virtualenv đang active
which python  # Linux/Mac
where python   # Windows

# Deactivate virtualenv
deactivate

# Xem danh sách packages đã cài
pip list
```

## 📚 Tài Liệu Đầy Đủ

- `HUONG_DAN_CHAY_DU_AN.md` - Hướng dẫn chi tiết từ đầu
- `OLLAMA_SETUP_GUIDE.md` - Hướng dẫn Ollama
- `REMOTE_OLLAMA_SETUP.md` - Cấu hình Ollama trên VM

## ⚠️ Lưu Ý

1. **Luôn activate virtualenv** trước khi chạy
2. **Chạy 2 terminal riêng** cho 2 server
3. **Kiểm tra Ollama** trước khi chạy simulation
4. **Lưu simulation** bằng lệnh `fin` trong simulation server

## 🆘 Lỗi Thường Gặp

| Lỗi | Giải pháp |
|-----|-----------|
| ModuleNotFoundError | Activate virtualenv và cài lại: `pip install -r requirements.txt` |
| Ollama connection failed | Kiểm tra VM đang chạy và network connectivity |
| Port 8000 đã dùng | Dùng port khác: `python manage.py runserver 8001` |
| Python version sai | Cài Python 3.9.x |

---

**Xem `HUONG_DAN_CHAY_DU_AN.md` để biết chi tiết đầy đủ!**


