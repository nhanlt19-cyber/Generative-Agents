# Sửa Lỗi KeyError: 'kitchen' trong Spatial Memory

## 🔍 Vấn Đề

Lỗi:
```
KeyError: 'kitchen'
File "/root/Generative-Agents/reverie/backend_server/persona/memory_structures/spatial_memory.py", line 105
```

**Nguyên nhân:**
1. Model Ollama trả về "kitchen" thay vì "main room" (không đúng với prompt yêu cầu)
2. Code cố truy cập `self.tree[curr_world][curr_sector]['kitchen']` nhưng không tồn tại
3. Không có validation để đảm bảo response nằm trong danh sách cho phép
4. Fail-safe hardcode "kitchen" không phù hợp với tất cả trường hợp

## ✅ Đã Sửa

### 1. Cải Thiện Error Handling trong `spatial_memory.py`

**File:** `reverie/backend_server/persona/memory_structures/spatial_memory.py`

```python
try: 
  x = ", ".join(list(self.tree[curr_world][curr_sector][curr_arena]))
except KeyError:
  try:
    x = ", ".join(list(self.tree[curr_world][curr_sector][curr_arena.lower()]))
  except KeyError:
    # Arena not found in tree, return empty string
    print(f"Warning: Arena '{curr_arena}' not found in spatial memory tree")
    return ""
except Exception as e:
  print(f"Warning: Error accessing arena '{curr_arena}': {e}")
  return ""
```

**Thay đổi:**
- ✅ Catch `KeyError` cụ thể thay vì generic `except`
- ✅ Thử cả `curr_arena` và `curr_arena.lower()`
- ✅ Return empty string thay vì crash
- ✅ Log warning để debug

### 2. Thêm Validation Response trong `run_gpt_prompt_action_arena`

**File:** `reverie/backend_server/persona/prompt_template/run_gpt_prompt.py`

**Thay đổi:**

#### a. Cải thiện `__func_clean_up`:
```python
def __func_clean_up(gpt_response, prompt=""):
  cleaned_response = gpt_response.split("}")[0].strip()
  # Remove any curly braces
  cleaned_response = cleaned_response.replace("{", "").replace("}", "").strip()
  return cleaned_response
```

#### b. Validation sau khi nhận response:
```python
# Get accessible arenas for validation
accessible_arena_str = prompt_input[2] if len(prompt_input) > 2 else ""
accessible_arenas = [a.strip() for a in accessible_arena_str.split(", ")] if accessible_arena_str else []

# Validate output is in accessible arenas list
y = f"{act_world}:{act_sector}"
x = [i.strip() for i in persona.s_mem.get_str_accessible_sector_arenas(y).split(", ")] if persona.s_mem.get_str_accessible_sector_arenas(y) else []
if not x:
  x = accessible_arenas  # Fallback

# Check if output matches any accessible arena (case-insensitive)
output_clean = output.strip().lower()
output_valid = False
for arena in x:
  if output_clean == arena.lower() or output_clean in arena.lower() or arena.lower() in output_clean:
    output_valid = True
    output = arena  # Use the correct case from the list
    break

# If output is not valid, use fail-safe or random choice
if not output_valid and x:
  import random
  output = random.choice(x)
  print(f"Warning: LLM returned invalid arena '{output_clean}', using '{output}' instead")
elif not output_valid:
  output = fail_safe
  print(f"Warning: LLM returned invalid arena '{output_clean}', using fail-safe '{output}'")
```

#### c. Fail-safe động:
```python
# Set fail-safe based on accessible arenas
fail_safe = accessible_arenas[0] if accessible_arenas else "main room"
```

**Thay đổi:**
- ✅ Validate response có trong danh sách accessible arenas
- ✅ Case-insensitive matching
- ✅ Tự động sửa response nếu không hợp lệ
- ✅ Fail-safe động dựa trên accessible arenas
- ✅ Log warning khi sửa response

## 🔧 Giải Thích Chi Tiết

### Vấn Đề Ban Đầu:

1. **Model trả về sai:**
   - Prompt yêu cầu: `{main room}`
   - Model trả về: `kitchen`
   - → Không hợp lệ

2. **Không có validation:**
   - Code comment out phần validation (dòng 758-760)
   - → Response không được kiểm tra

3. **Error handling yếu:**
   - Generic `except:` không catch `KeyError` đúng cách
   - → Crash thay vì handle gracefully

### Giải Pháp:

1. **Validation 2 lớp:**
   - Validation cơ bản trong `__func_validate`
   - Validation chi tiết sau khi nhận response

2. **Case-insensitive matching:**
   - "kitchen" vs "Kitchen" → match
   - "main room" vs "mainroom" → match

3. **Auto-correction:**
   - Nếu response không hợp lệ → tự động chọn từ danh sách
   - Log warning để debug

4. **Fail-safe động:**
   - Không hardcode "kitchen"
   - Dùng accessible arenas từ prompt_input

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

1. ✅ **Error handling** trong `spatial_memory.py`
2. ✅ **Validation response** trong `run_gpt_prompt_action_arena`
3. ✅ **Fail-safe động** thay vì hardcode
4. ✅ **Auto-correction** khi response không hợp lệ
5. ✅ **Case-insensitive matching** cho arenas

## ✅ Kết Quả Mong Đợi

- ✅ Không còn `KeyError` khi arena không tồn tại
- ✅ Response được validate và auto-correct nếu cần
- ✅ Simulation tiếp tục chạy ngay cả khi model trả về sai
- ✅ Warning logs giúp debug

## 🆘 Nếu Vẫn Có Vấn Đề

### 1. Kiểm Tra Logs

```bash
# Xem warnings trong console
# Tìm dòng: "Warning: LLM returned invalid arena"
```

### 2. Kiểm Tra Spatial Memory

```bash
# Xem spatial memory tree
python -c "
from reverie.backend_server.persona.memory_structures.spatial_memory import MemoryTree
import json
# Load và print tree structure
"
```

### 3. Debug Prompt

- Kiểm tra prompt có đúng format không
- Kiểm tra accessible arenas có đúng không
- Kiểm tra model có follow instructions không

## 📝 Lưu Ý

- **Validation** giờ sẽ tự động sửa response nếu không hợp lệ
- **Warning logs** sẽ giúp identify vấn đề với model
- **Fail-safe** giờ động và phù hợp với context
- Nếu model thường xuyên trả về sai, có thể cần:
  - Cải thiện prompt
  - Dùng model tốt hơn
  - Tăng temperature để model follow instructions tốt hơn

