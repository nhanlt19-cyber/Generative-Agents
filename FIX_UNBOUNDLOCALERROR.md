# Sửa Lỗi UnboundLocalError: local variable 'duration' referenced before assignment

## 🔍 Vấn Đề

Lỗi:
```
UnboundLocalError: local variable 'duration' referenced before assignment
```

**Nguyên nhân:**
- Biến `duration` trong hàm `__func_clean_up` bị conflict với biến `duration` được gán trong vòng lặp
- Python nghĩ `duration` là local variable nên không thể access từ outer scope

## ✅ Đã Sửa

### 1. Lưu Outer Scope Duration

**File:** `reverie/backend_server/persona/prompt_template/run_gpt_prompt.py`

```python
def __func_clean_up(gpt_response, prompt=""):
    # Store outer scope duration for fallback
    fallback_duration = duration  # Access duration from outer function scope
    
    # ... rest of code uses fallback_duration for default responses
```

### 2. Đổi Tên Biến Trong Vòng Lặp

```python
# Trước (gây conflict):
duration = int(duration_str)

# Sau (tránh conflict):
task_duration = int(duration_str)  # Rename to avoid conflict
```

### 3. Tăng Timeout Thêm

- Timeout đã được tăng lên **600 giây (10 phút)** cho prompt rất dài
- Áp dụng cho cả `ollama_chat_request` và `ollama_generate_request`

## 🔧 Giải Thích Chi Tiết

### Vấn Đề Scope trong Python:

```python
def outer_function():
    duration = 120  # Outer scope variable
    
    def inner_function():
        # Nếu có assignment duration = ... ở đây
        # Python sẽ coi duration là local variable
        # → Không thể access outer scope duration
        return duration  # ❌ UnboundLocalError
```

### Giải Pháp:

```python
def outer_function():
    duration = 120
    
    def inner_function():
        fallback_duration = duration  # Lưu trước khi có assignment
        # ... code có thể assign duration = ...
        return fallback_duration  # ✅ OK
```

## 🚀 Cách Áp Dụng

### 1. Cập Nhật Code Trên VM

```bash
cd /root/Generative-Agents
# Pull code mới hoặc upload file đã sửa
```

### 2. Restart Simulation Server

```bash
# Dừng server
screen -X -S sim_server quit

# Khởi động lại
cd /root/Generative-Agents
source venv/bin/activate
cd reverie/backend_server
python reverie.py
```

### 3. Test Lại

```
run 10  # Test với số steps nhỏ
```

## 📊 Các Thay Đổi

1. ✅ **Lưu `fallback_duration`** từ outer scope
2. ✅ **Đổi tên biến** trong vòng lặp thành `task_duration`
3. ✅ **Tăng timeout** lên 600 giây (10 phút)
4. ✅ **Sử dụng `fallback_duration`** cho default responses

## ✅ Kết Quả Mong Đợi

- ✅ Không còn `UnboundLocalError`
- ✅ Code có thể access `duration` từ outer scope
- ✅ Timeout ít hơn với 10 phút
- ✅ Simulation tiếp tục chạy ngay cả khi có lỗi

## 🆘 Nếu Vẫn Timeout

Nếu vẫn timeout sau 10 phút:

1. **Dùng model nhỏ hơn:**
   ```bash
   ollama pull mistral
   # Sửa: ollama_model_name = "mistral"
   ```

2. **Kiểm tra RAM:**
   ```bash
   free -h
   ```

3. **Kiểm tra Ollama logs:**
   ```bash
   journalctl -u ollama -f
   ```

4. **Cân nhắc optimize prompt** (phức tạp hơn)

## 📝 Lưu Ý

- **Timeout 600 giây** có thể vẫn không đủ cho prompt cực dài
- Nếu vẫn timeout, nên dùng model nhỏ hơn hoặc có GPU
- **Error handling** giờ sẽ return default thay vì crash

