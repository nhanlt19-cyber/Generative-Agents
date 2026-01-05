# Sửa Lỗi Timeout và Parsing Error

## 🔍 Vấn Đề

Khi chạy simulation, bạn gặp 2 lỗi:

1. **Ollama Timeout ERROR**: Request mất quá 120 giây
2. **IndexError: list index out of range**: Lỗi parsing response từ Ollama

## ✅ Đã Sửa

### 1. Tăng Timeout

**File:** `reverie/backend_server/persona/prompt_template/ollama_interface.py`

- Timeout đã được tăng từ **120 giây** → **300 giây** (5 phút)
- Áp dụng cho cả `ollama_chat_request` và `ollama_generate_request`

**Lý do:** Prompt dài (như task decomposition) cần nhiều thời gian để xử lý.

### 2. Cải Thiện Error Handling

**File:** `reverie/backend_server/persona/prompt_template/run_gpt_prompt.py`

**Hàm `__func_clean_up` đã được cải thiện:**
- ✅ Kiểm tra response rỗng hoặc có lỗi
- ✅ Skip lines không đúng format thay vì crash
- ✅ Xử lý lỗi parsing duration
- ✅ Return default safe response nếu không parse được

## 🔧 Các Thay Đổi Chi Tiết

### Timeout:
```python
# Trước
timeout=120

# Sau
timeout=300  # 5 phút
```

### Error Handling:
```python
# Kiểm tra response hợp lệ
if not gpt_response or "Ollama ERROR" in gpt_response:
    return [["sleeping", duration]]  # Safe default

# Skip lines không đúng format
if len(k) < 2:
    print(f"Warning: Skipping line with invalid format: {i}")
    continue

# Xử lý lỗi parsing
try:
    duration = int(duration_str)
    cr += [[task, duration]]
except (ValueError, IndexError) as e:
    print(f"Warning: Could not parse duration: {e}")
    continue
```

## 🚀 Cách Áp Dụng

### 1. Cập Nhật Code Trên VM

Nếu chưa pull code mới:
```bash
cd /root/Generative-Agents
git pull  # Nếu dùng git
# Hoặc upload file mới
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
run 10  # Test với số steps nhỏ trước
```

## 🔍 Nguyên Nhân Timeout

### Có Thể Do:

1. **Prompt quá dài:**
   - Task decomposition prompt rất dài
   - Model cần nhiều thời gian để xử lý

2. **Model chậm:**
   - `llama3.1` có thể chậm hơn trên CPU
   - Cần GPU để tăng tốc

3. **RAM không đủ:**
   - Model swap ra disk → chậm
   - Kiểm tra: `free -h`

4. **Nhiều requests đồng thời:**
   - Nhiều agents cùng request → chậm

## 💡 Giải Pháp Nếu Vẫn Timeout

### Option 1: Dùng Model Nhỏ Hơn

```bash
# Tải model nhỏ hơn
ollama pull mistral

# Sửa trong utils.py
ollama_model_name = "mistral"
```

### Option 2: Tăng Timeout Hơn Nữa

Nếu vẫn timeout, có thể tăng thêm:

```python
# Trong ollama_interface.py
timeout=600  # 10 phút
```

### Option 3: Giảm Prompt Length

Có thể cần optimize prompt template để ngắn hơn (phức tạp hơn).

### Option 4: Dùng GPU

Nếu có GPU, cài CUDA để tăng tốc:
```bash
# Cài CUDA drivers
# Ollama sẽ tự động dùng GPU nếu có
```

## 📊 Monitoring

### Kiểm Tra Performance:

```bash
# RAM usage
free -h

# CPU usage
top

# Ollama logs
journalctl -u ollama -f
```

### Kiểm Tra Response Time:

Code sẽ hiển thị timeout errors nếu có. Xem terminal output để biết:
- Request nào bị timeout
- Prompt nào quá dài
- Model nào đang chậm

## ✅ Checklist

- [x] Timeout đã được tăng lên 300 giây
- [x] Error handling đã được cải thiện
- [x] Code sẽ skip invalid lines thay vì crash
- [x] Có default safe response
- [ ] Test lại simulation (bạn làm)
- [ ] Monitor performance (bạn làm)

## 🎯 Kết Quả Mong Đợi

Sau khi sửa:
- ✅ Không còn timeout errors (hoặc ít hơn)
- ✅ Không còn IndexError khi parsing
- ✅ Simulation tiếp tục chạy ngay cả khi có lỗi nhỏ
- ✅ Có warnings thay vì crash

## 📝 Lưu Ý

- **Timeout 300 giây** có thể vẫn không đủ cho prompt rất dài
- Nếu vẫn timeout, cân nhắc dùng model nhỏ hơn hoặc optimize prompt
- **Error handling** giờ sẽ skip invalid lines thay vì crash
- Simulation sẽ tiếp tục chạy với default values nếu parse fail

## 🆘 Nếu Vẫn Có Vấn Đề

1. **Xem logs chi tiết** trong terminal
2. **Kiểm tra response** từ Ollama (sẽ được print ra)
3. **Test với model nhỏ hơn** (mistral)
4. **Kiểm tra RAM/CPU** usage

