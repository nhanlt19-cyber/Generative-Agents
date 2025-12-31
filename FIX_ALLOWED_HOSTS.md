# Sửa Lỗi ALLOWED_HOSTS

## 🔍 Vấn Đề

Lỗi:
```
Invalid HTTP_HOST header: '10.0.12.81:8000'. You may need to add '10.0.12.81' to ALLOWED_HOSTS.
```

## ✅ Đã Sửa

Đã cập nhật cả 2 file settings:
1. ✅ `environment/frontend_server/frontend_server/settings/base.py`
2. ✅ `environment/frontend_server/frontend_server/settings/local.py`

Cả 2 file giờ có:
```python
ALLOWED_HOSTS = ['*']  # Allows access from any IP (10.0.12.81, localhost, etc.)
```

## 🔄 Cách Sửa Thủ Công (Nếu Cần)

### Trên Ubuntu VM:

```bash
# Sửa file local.py
nano /root/Generative-Agents/environment/frontend_server/frontend_server/settings/local.py
```

**Tìm dòng:**
```python
ALLOWED_HOSTS = []
```

**Sửa thành:**
```python
ALLOWED_HOSTS = ['*']  # Hoặc ['10.0.12.81', 'localhost', '127.0.0.1']
```

**Lưu file:** `Ctrl+O`, `Enter`, `Ctrl+X`

### Hoặc Sửa base.py:

```bash
nano /root/Generative-Agents/environment/frontend_server/frontend_server/settings/base.py
```

**Tìm và sửa tương tự.**

## 🔄 Restart Server

Sau khi sửa, **restart Django server**:

```bash
# Dừng server (Ctrl+C trong terminal đang chạy server)
# Hoặc kill process
pkill -f "manage.py runserver"

# Khởi động lại
cd /root/Generative-Agents
source venv/bin/activate
cd environment/frontend_server
python manage.py runserver 0.0.0.0:8000
```

## ✅ Kiểm Tra

Sau khi restart, truy cập lại:
```
http://10.0.12.81:8000
```

Bạn sẽ thấy: "Your environment server is up and running" (không còn lỗi 400).

## 📝 Lưu Ý

- `ALLOWED_HOSTS = ['*']` cho phép truy cập từ bất kỳ IP nào (development)
- Để bảo mật hơn, dùng: `ALLOWED_HOSTS = ['10.0.12.81', 'localhost', '127.0.0.1']`
- File `local.py` override `base.py`, nên cần sửa cả 2 file hoặc chỉ sửa `local.py`

