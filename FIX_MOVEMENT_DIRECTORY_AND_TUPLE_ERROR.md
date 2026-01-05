# Sửa Lỗi FileNotFoundError và Tuple Parsing trong act_obj_event_triple

## 🔍 Vấn Đề

Có 2 lỗi:

### Lỗi 1: FileNotFoundError
```
FileNotFoundError: [Errno 2] No such file or directory: 
'../../environment/frontend_server/storage/test-simulation/movement/0.json'
```

### Lỗi 2: Tuple Parsing
```
Output: ('toaster', 'toaster', 'is')
Input: toaster is <fill in>asleep.
```

**Nguyên nhân:**
1. Thư mục `movement` không được tạo tự động trước khi ghi file
2. Output từ LLM không đúng format - trả về tuple không đúng hoặc không đủ phần tử
3. Code giả định `output` luôn là list với ít nhất 2 phần tử

## ✅ Đã Sửa

### 1. Tạo Thư Mục Movement Tự Động

**File:** `reverie/backend_server/reverie.py`

```python
# Ensure movement directory exists
movement_dir = f"{sim_folder}/movement"
os.makedirs(movement_dir, exist_ok=True)
curr_move_file = f"{movement_dir}/{self.step}.json"
```

**Thay đổi:**
- ✅ Tạo thư mục `movement` nếu chưa tồn tại
- ✅ Sử dụng `exist_ok=True` để tránh lỗi nếu đã tồn tại
- ✅ Đảm bảo thư mục được tạo trước khi ghi file

### 2. Cải Thiện Tuple Parsing trong `run_gpt_prompt_act_obj_event_triple`

**File:** `reverie/backend_server/persona/prompt_template/run_gpt_prompt.py`

```python
output = safe_generate_response(prompt, gpt_param, 5, fail_safe,
                                 __func_validate, __func_clean_up)

# Ensure output is a list/tuple with at least 2 elements
if isinstance(output, (list, tuple)):
  if len(output) >= 2:
    output = (act_game_object, output[0], output[1])
  elif len(output) == 1:
    # If only one element, use it for both verb and object
    output = (act_game_object, output[0], output[0])
  else:
    # Empty list, use fail_safe
    output = fail_safe
else:
  # If output is not a list/tuple (e.g., string), use fail_safe
  output = fail_safe

# Final check: ensure output is a tuple with 3 elements
if not isinstance(output, tuple) or len(output) != 3:
  output = fail_safe
```

**Thay đổi:**
- ✅ Kiểm tra `output` là list/tuple trước khi truy cập
- ✅ Xử lý trường hợp có 1 phần tử (dùng cho cả verb và object)
- ✅ Xử lý trường hợp rỗng (dùng fail_safe)
- ✅ Xử lý trường hợp không phải list/tuple (dùng fail_safe)
- ✅ Final check đảm bảo output là tuple với 3 phần tử

### 3. Error Handling trong `generate_act_obj_event_triple`

**File:** `reverie/backend_server/persona/cognitive_modules/plan.py`

```python
def generate_act_obj_event_triple(act_game_object, act_obj_desc, persona): 
  if debug: print ("GNS FUNCTION: <generate_act_obj_event_triple>")
  result = run_gpt_prompt_act_obj_event_triple(act_game_object, act_obj_desc, persona)
  if result is None:
    # Fallback if function returns None
    return (act_game_object, "is", "idle")
  return result[0] if isinstance(result, (list, tuple)) and len(result) > 0 else (act_game_object, "is", "idle")
```

**Thay đổi:**
- ✅ Kiểm tra `result is None` trước khi truy cập
- ✅ Kiểm tra `result` là list/tuple và có phần tử
- ✅ Fallback về `(act_game_object, "is", "idle")` nếu có lỗi

## 🔧 Giải Thích Chi Tiết

### Vấn Đề Ban Đầu:

1. **Thư mục không tồn tại:**
   - Code ghi file vào `{sim_folder}/movement/{step}.json`
   - Nhưng thư mục `movement` không được tạo tự động
   - → `FileNotFoundError`

2. **Tuple parsing:**
   - `__func_clean_up` trả về list: `[i.strip() for i in cr.split(")")[0].split(",")]`
   - Code giả định list có ít nhất 2 phần tử: `output[0], output[1]`
   - Nếu LLM trả về format khác → IndexError hoặc tuple không đúng

### Giải Pháp:

1. **Tạo thư mục tự động:**
   - Sử dụng `os.makedirs(..., exist_ok=True)`
   - Tạo thư mục trước khi ghi file
   - `exist_ok=True` tránh lỗi nếu đã tồn tại

2. **Robust tuple parsing:**
   - Kiểm tra type và length trước khi truy cập
   - Xử lý nhiều trường hợp khác nhau
   - Fallback về fail_safe nếu không hợp lệ

3. **Error handling:**
   - Kiểm tra None trước khi truy cập
   - Kiểm tra type và length
   - Fallback về default value

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

1. ✅ **Tạo thư mục movement** tự động trong `reverie.py`
2. ✅ **Robust tuple parsing** trong `run_gpt_prompt_act_obj_event_triple`
3. ✅ **Error handling** trong `generate_act_obj_event_triple`
4. ✅ **Fallback mechanisms** ở nhiều tầng

## ✅ Kết Quả Mong Đợi

- ✅ Không còn `FileNotFoundError` khi ghi movement file
- ✅ Tuple parsing xử lý tốt hơn với các format khác nhau
- ✅ Simulation tiếp tục chạy ngay cả khi có lỗi parsing
- ✅ Better error handling và fallback

## 🆘 Nếu Vẫn Có Vấn Đề

### 1. Kiểm Tra Thư Mục

```bash
# Kiểm tra thư mục movement đã được tạo chưa
ls -la ../../environment/frontend_server/storage/*/movement/
```

### 2. Kiểm Tra Permissions

```bash
# Đảm bảo có quyền ghi
chmod -R 755 ../../environment/frontend_server/storage/
```

### 3. Debug Output Format

- Kiểm tra output từ LLM có đúng format không
- Kiểm tra `__func_clean_up` có parse đúng không
- Kiểm tra prompt có yêu cầu format rõ ràng không

## 📝 Lưu Ý

- **Thư mục movement** sẽ được tạo tự động khi cần
- **Tuple parsing** giờ sẽ xử lý nhiều format khác nhau
- **Error handling** sẽ return default thay vì crash
- Nếu LLM thường xuyên trả về format không đúng, có thể cần:
  - Cải thiện prompt để yêu cầu format rõ ràng hơn
  - Dùng model tốt hơn
  - Fine-tune model để follow format tốt hơn

## 🔗 Liên Quan

- Lỗi này có thể liên quan đến việc Ollama trả về format khác với GPT-3.5-turbo
- Xem thêm: `FIX_NONETYPE_ACT_OBJ_DESC.md` cho các lỗi parsing khác

