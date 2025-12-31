# Giải Thích Về .gitignore và utils.py

## 🔍 Vấn Đề

File `reverie/backend_server/utils.py` **KHÔNG** được push lên GitHub vì nó nằm trong `.gitignore`.

**Lý do:** File này thường chứa:
- API keys (OpenAI API key)
- Thông tin nhạy cảm
- Cấu hình cá nhân

## ✅ Giải Pháp

### Option 1: Giữ utils.py trong .gitignore (Khuyến Nghị)

**Cách làm:**
1. Tạo file template: `utils.py.example` (đã tạo sẵn)
2. Commit file template lên GitHub
3. Mỗi người copy `utils.py.example` → `utils.py` và cấu hình riêng

**Ưu điểm:**
- ✅ Bảo mật: API keys không bị lộ
- ✅ Mỗi người có cấu hình riêng
- ✅ Template có sẵn để tham khảo

**Cách sử dụng:**
```bash
# Trên VM Ubuntu
cd /root/generative_agents/reverie/backend_server
cp utils.py.example utils.py
nano utils.py  # Chỉnh sửa cấu hình
```

### Option 2: Xóa khỏi .gitignore (Không Khuyến Nghị)

**Nếu bạn muốn commit `utils.py` lên GitHub:**

```bash
# 1. Xóa dòng trong .gitignore
nano .gitignore
# Xóa dòng: reverie/backend_server/utils.py

# 2. Force add file
git add -f reverie/backend_server/utils.py

# 3. Commit
git commit -m "Add utils.py with Ollama configuration"

# 4. Push
git push
```

**⚠️ CẢNH BÁO:**
- ❌ API keys sẽ bị lộ trên GitHub
- ❌ Mọi người có thể thấy cấu hình của bạn
- ❌ Không an toàn cho production

### Option 3: Dùng Environment Variables (Tốt Nhất Cho Production)

Thay vì lưu trong file, dùng biến môi trường:

**Tạo file `.env`:**
```bash
LLM_PROVIDER=ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL_NAME=llama3.1
OPENAI_API_KEY=your_key_here
```

**Sửa `utils.py`:**
```python
import os
llm_provider = os.getenv('LLM_PROVIDER', 'ollama')
ollama_base_url = os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434')
```

**Thêm vào `.gitignore`:**
```
.env
```

## 📝 File Đã Tạo

Tôi đã tạo file `reverie/backend_server/utils.py.example` với:
- ✅ Cấu hình Ollama mặc định
- ✅ Comments đầy đủ
- ✅ Template sẵn sàng sử dụng

## 🚀 Hướng Dẫn Sử Dụng

### Khi Clone Repo Mới:

```bash
# 1. Clone repo
git clone <your-repo-url>
cd generative_agents

# 2. Copy template
cp reverie/backend_server/utils.py.example reverie/backend_server/utils.py

# 3. Chỉnh sửa
nano reverie/backend_server/utils.py
# Hoặc
vim reverie/backend_server/utils.py
```

### Khi Đã Có File utils.py:

File `utils.py` của bạn sẽ không bị commit, giữ nguyên cấu hình riêng.

## 🔒 Bảo Mật

**Best Practices:**
1. ✅ **KHÔNG** commit `utils.py` có API keys thật
2. ✅ Dùng `utils.py.example` làm template
3. ✅ Thêm `.env` vào `.gitignore` nếu dùng environment variables
4. ✅ Rotate API keys nếu vô tình commit

## 📋 Checklist

- [x] File `utils.py.example` đã được tạo
- [x] File `utils.py` vẫn trong `.gitignore` (an toàn)
- [ ] Commit `utils.py.example` lên GitHub
- [ ] Thêm hướng dẫn vào README về cách tạo `utils.py`

## 💡 Lưu Ý

Nếu bạn **thực sự** muốn commit `utils.py` (ví dụ: chỉ có cấu hình Ollama, không có API keys thật):

1. **Đảm bảo** không có API keys thật trong file
2. Xóa dòng khỏi `.gitignore`
3. Force add: `git add -f reverie/backend_server/utils.py`
4. Commit và push

**Nhưng khuyến nghị:** Giữ nguyên như hiện tại, dùng `utils.py.example`!

