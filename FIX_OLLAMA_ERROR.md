# Sửa Lỗi "Ollama ERROR" Trong Simulation

## 🔍 Vấn Đề

Khi chạy simulation, bạn thấy:
```
Activity: Isabella is Ollama ERROR
```

## 🔍 Nguyên Nhân Có Thể

1. **Ollama không chạy** hoặc không thể kết nối
2. **Model chưa được tải** hoặc tên model sai
3. **Timeout** - Request quá lâu
4. **Connection refused** - Ollama không lắng nghe trên port 11434
5. **Model không hỗ trợ** một số tính năng

## ✅ Các Bước Kiểm Tra

### 1. Kiểm Tra Ollama Đang Chạy

```bash
# Trên Ubuntu VM
systemctl status ollama

# Hoặc
ps aux | grep ollama

# Kiểm tra port
netstat -tlnp | grep 11434
```

**Nếu không chạy:**
```bash
systemctl start ollama
# hoặc
ollama serve
```

### 2. Kiểm Tra Model Đã Tải

```bash
ollama list
```

**Phải thấy:**
- `llama3.1` (hoặc model bạn đang dùng)
- `nomic-embed-text` (cho embeddings)

**Nếu chưa có:**
```bash
ollama pull llama3.1
ollama pull nomic-embed-text
```

### 3. Test Kết Nối

```bash
# Test API
curl http://localhost:11434/api/tags

# Test chat
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.1",
  "messages": [{"role": "user", "content": "Hello"}],
  "stream": false
}'
```

### 4. Chạy Debug Script

```bash
cd /root/Generative-Agents/reverie/backend_server
source /root/Generative-Agents/venv/bin/activate
python debug_ollama.py
```

Script này sẽ test tất cả các chức năng và hiển thị lỗi chi tiết.

### 5. Kiểm Tra Logs Chi Tiết

Khi chạy simulation, xem terminal output để thấy lỗi chi tiết. Code đã được cập nhật để hiển thị:
- Connection errors
- Timeout errors  
- HTTP errors
- Chi tiết exception

## 🔧 Các Giải Pháp

### Giải Pháp 1: Restart Ollama

```bash
# Restart Ollama service
systemctl restart ollama

# Hoặc kill và start lại
pkill ollama
ollama serve
```

### Giải Pháp 2: Kiểm Tra Model Name

```bash
# Kiểm tra tên model chính xác
ollama list

# Sửa trong utils.py nếu cần
nano /root/Generative-Agents/reverie/backend_server/utils.py
```

Đảm bảo `ollama_model_name` khớp với model đã tải.

### Giải Pháp 3: Tăng Timeout

Nếu model chậm, có thể cần tăng timeout. Sửa trong `ollama_interface.py`:

```python
# Thay đổi từ 120 thành 300 (5 phút)
response = requests.post(url, json=payload, timeout=300)
```

### Giải Pháp 4: Kiểm Tra RAM

Model lớn cần nhiều RAM. Kiểm tra:

```bash
free -h
```

Nếu RAM đầy, Ollama có thể không phản hồi.

### Giải Pháp 5: Dùng Model Nhỏ Hơn

Nếu `llama3.1` quá lớn, thử model nhỏ hơn:

```bash
ollama pull mistral
```

Sửa trong `utils.py`:
```python
ollama_model_name = "mistral"
```

## 📊 Debug Chi Tiết

### Xem Logs Ollama

```bash
# Xem logs systemd
journalctl -u ollama -f

# Hoặc nếu chạy manual
ollama serve  # Xem output trực tiếp
```

### Test Thủ Công

```python
# Trong Python
import requests

url = "http://localhost:11434/api/chat"
payload = {
    "model": "llama3.1",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": False
}

response = requests.post(url, json=payload, timeout=120)
print(response.status_code)
print(response.json())
```

## ✅ Checklist

- [ ] Ollama đang chạy (`systemctl status ollama`)
- [ ] Model đã tải (`ollama list`)
- [ ] Có thể kết nối (`curl http://localhost:11434/api/tags`)
- [ ] Model name đúng trong `utils.py`
- [ ] Đủ RAM (`free -h`)
- [ ] Chạy `debug_ollama.py` thành công
- [ ] Xem logs chi tiết khi chạy simulation

## 🚀 Sau Khi Sửa

1. **Restart simulation server:**
```bash
# Dừng server
screen -X -S sim_server quit

# Khởi động lại
cd /root/Generative-Agents
source venv/bin/activate
cd reverie/backend_server
python reverie.py
```

2. **Chạy lại simulation:**
```
run 10  # Test với số steps nhỏ trước
```

## 📝 Lưu Ý

- Code đã được cập nhật để hiển thị lỗi chi tiết hơn
- Chạy `debug_ollama.py` để test trước khi chạy simulation
- Nếu vẫn lỗi, xem terminal output để thấy chi tiết exception

