# Cấu Hình Ollama Trên VM Từ Xa

## Thông Tin Cấu Hình Hiện Tại

- **Ollama Server**: `http://10.0.12.81:11434`
- **Model Text Generation**: `llama3.1`
- **Model Embeddings**: `nomic-embed-text` (hoặc có thể dùng `llama3.1`)

## Đã Cập Nhật

File `reverie/backend_server/utils.py` đã được cập nhật với:
```python
ollama_base_url = "http://10.0.12.81:11434"
ollama_model_name = "llama3.1"
```

## Kiểm Tra Kết Nối

### 1. Kiểm tra từ command line
```bash
curl http://10.0.12.81:11434/api/tags
```

Hoặc kiểm tra model có sẵn:
```bash
curl http://10.0.12.81:11434/api/tags | grep llama3.1
```

### 2. Kiểm tra bằng script
```bash
cd reverie/backend_server
python test_ollama_connection.py
```

### 3. Test thủ công
```python
import requests

url = "http://10.0.12.81:11434/api/chat"
payload = {
    "model": "llama3.1",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": False
}

response = requests.post(url, json=payload)
print(response.json())
```

## Lưu Ý Quan Trọng

### 1. Network Connectivity
- Đảm bảo máy local có thể kết nối đến `10.0.12.81:11434`
- Kiểm tra firewall trên VM không chặn port 11434
- Nếu dùng VPN, đảm bảo VPN đang kết nối

### 2. Ollama Server trên VM
Đảm bảo Ollama trên VM đang chạy và lắng nghe trên tất cả interfaces:
```bash
# Trên VM, kiểm tra Ollama đang chạy
ollama serve

# Hoặc nếu dùng systemd
systemctl status ollama
```

Nếu Ollama chỉ lắng nghe localhost, cần cấu hình để lắng nghe trên tất cả interfaces:
```bash
# Set environment variable
export OLLAMA_HOST=0.0.0.0:11434

# Hoặc trong file ~/.ollama/config
OLLAMA_HOST=0.0.0.0:11434
```

### 3. Model Embeddings
Nếu `llama3.1` không hỗ trợ embeddings tốt, bạn có thể:
- Sử dụng `nomic-embed-text` cho embeddings (cần tải trên VM)
- Hoặc sử dụng OpenAI chỉ cho embeddings

### 4. Performance
- Kết nối qua network có thể chậm hơn local
- Cân nhắc tăng timeout trong `ollama_interface.py` nếu cần
- Monitor network latency

## Troubleshooting

### Lỗi: Connection refused
**Nguyên nhân**: Ollama không lắng nghe trên interface công khai
**Giải pháp**: 
```bash
# Trên VM
export OLLAMA_HOST=0.0.12.81:11434
ollama serve
```

### Lỗi: Timeout
**Nguyên nhân**: Network chậm hoặc model quá lớn
**Giải pháp**: Tăng timeout trong code hoặc sử dụng model nhỏ hơn

### Lỗi: Model not found
**Nguyên nhân**: Model chưa được tải trên VM
**Giải pháp**: 
```bash
# Trên VM
ollama pull llama3.1
ollama pull nomic-embed-text  # Nếu cần
```

## Bảo Mật

⚠️ **Cảnh báo**: Ollama đang chạy trên network công khai (10.0.12.81)

**Khuyến nghị**:
1. Sử dụng firewall để giới hạn IP có thể truy cập
2. Cân nhắc sử dụng VPN
3. Không expose Ollama ra internet công cộng
4. Xem xét authentication nếu cần

## Kiểm Tra Nhanh

Chạy lệnh này để kiểm tra tất cả:
```bash
cd reverie/backend_server
python test_ollama_connection.py
```

Nếu tất cả đều ✓, bạn có thể chạy simulation!

