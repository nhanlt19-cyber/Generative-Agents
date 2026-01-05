# Hướng Dẫn Force Add utils.py

## ✅ Đã Thực Hiện

1. ✅ Đã comment dòng `reverie/backend_server/utils.py` trong `.gitignore`
2. ✅ File `utils.py` giờ có thể được commit

## 🚀 Các Bước Để Commit utils.py

### Bước 1: Kiểm Tra Git Repository

```bash
# Kiểm tra xem đã là git repo chưa
git status
```

**Nếu chưa có git repo:**
```bash
# Khởi tạo git repository
git init

# Thêm remote (nếu chưa có)
git remote add origin <your-github-repo-url>
```

### Bước 2: Add File utils.py

```bash
# Force add file (nếu đã từng bị ignore)
git add -f reverie/backend_server/utils.py

# Hoặc add bình thường (nếu chưa từng bị ignore)
git add reverie/backend_server/utils.py

# Kiểm tra file đã được add
git status
```

### Bước 3: Commit

```bash
git commit -m "Add utils.py with Ollama configuration for Ubuntu VM deployment"
```

### Bước 4: Push Lên GitHub

```bash
# Push lên branch chính
git push origin main
# hoặc
git push origin master
```

## 📝 Lệnh Đầy Đủ (Copy & Paste)

```bash
# 1. Kiểm tra status
git status

# 2. Add file
git add -f reverie/backend_server/utils.py
git add .gitignore  # Cũng commit thay đổi .gitignore

# 3. Commit
git commit -m "Add utils.py with Ollama configuration and update .gitignore"

# 4. Push
git push origin main
```

## 🔍 Kiểm Tra

Sau khi push, kiểm tra trên GitHub:
- File `reverie/backend_server/utils.py` đã xuất hiện
- File `.gitignore` đã được cập nhật

## ⚠️ Lưu Ý

Vì bạn chỉ dùng Ollama (không có API keys thật), nên việc commit `utils.py` là an toàn. File này chỉ chứa:
- Cấu hình Ollama (localhost)
- Model names (llama3.1)
- Không có API keys nhạy cảm

## ✅ Hoàn Tất!

File `utils.py` giờ sẽ được commit và push lên GitHub cùng với code của bạn.


