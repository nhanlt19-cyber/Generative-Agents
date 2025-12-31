# Quick Start - Sử Dụng Ollama

## 5 Bước Nhanh

### 1. Cài Ollama
- Windows: Tải từ https://ollama.ai/download
- Linux/Mac: `curl -fsSL https://ollama.ai/install.sh | sh`

### 2. Tải Model
```bash
ollama pull llama3
ollama pull nomic-embed-text
```

### 3. Cấu hình
Mở `reverie/backend_server/utils.py`:
```python
llm_provider = "ollama"
ollama_model_name = "llama3"
ollama_embedding_model_name = "nomic-embed-text"
```

### 4. Kiểm tra
```bash
cd reverie/backend_server
python test_ollama_connection.py
```

### 5. Chạy
```bash
# Terminal 1
cd environment/frontend_server
python manage.py runserver

# Terminal 2
cd reverie/backend_server
python reverie.py
```

## Model Khuyến Nghị

| Model | Kích thước | Tốc độ | Chất lượng | RAM cần |
|-------|------------|--------|------------|---------|
| mistral | ~4GB | ⚡⚡⚡ | ⭐⭐⭐ | 8GB |
| llama2 | ~4GB | ⚡⚡ | ⭐⭐⭐⭐ | 8GB |
| llama3 | ~4.7GB | ⚡⚡ | ⭐⭐⭐⭐⭐ | 16GB |
| qwen2.5 | ~4GB | ⚡⚡ | ⭐⭐⭐⭐ | 8GB |

**Cho embeddings**: `nomic-embed-text` (~274MB)

## Troubleshooting Nhanh

| Lỗi | Giải pháp |
|------|-----------|
| Connection refused | Chạy `ollama serve` hoặc khởi động lại Ollama |
| Model not found | `ollama pull <tên_model>` |
| Out of memory | Dùng model nhỏ hơn hoặc tăng RAM |
| Embedding lỗi | Tải `nomic-embed-text` |

## Chuyển Đổi Giữa OpenAI và Ollama

Chỉ cần thay đổi trong `utils.py`:
```python
llm_provider = "openai"  # hoặc "ollama"
```

## Tài Liệu Đầy Đủ

Xem `OLLAMA_SETUP_GUIDE.md` để biết chi tiết.

