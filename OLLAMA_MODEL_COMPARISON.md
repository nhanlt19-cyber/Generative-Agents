# So Sánh Model: OpenAI vs Ollama

## ❌ Ollama KHÔNG Có Model "gpt-3.5-turbo"

**Lý do:**
- `gpt-3.5-turbo` là model độc quyền của OpenAI
- Ollama là platform mã nguồn mở với các model riêng
- Ollama không thể chạy model của OpenAI

## ✅ Code Đã Tự Động Xử Lý

Code đã được thiết kế để **tự động** dùng model Ollama khi `llm_provider = "ollama"`:

### Trong `gpt_structure.py`:

```python
def ChatGPT_single_request(prompt):
    if llm_provider == "ollama":
        return ollama_chat_request(prompt, model=ollama_model_name)  # Dùng model Ollama
    else:
        completion = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",  # Chỉ dùng khi llm_provider == "openai"
            messages=[{"role": "user", "content": prompt}]
        )
        return completion["choices"][0]["message"]["content"]
```

**Kết luận:** Khi `llm_provider = "ollama"`, code sẽ **KHÔNG** gọi "gpt-3.5-turbo", mà sẽ dùng model từ `ollama_model_name` trong `utils.py`.

## 📊 So Sánh Model Tương Đương

### GPT-3.5-Turbo (OpenAI)
- **Kích thước:** ~175B parameters (không công khai chính xác)
- **Chất lượng:** Rất tốt cho general tasks
- **Tốc độ:** Rất nhanh (cloud)
- **Chi phí:** Trả phí theo usage

### Model Ollama Tương Đương

| Model Ollama | Kích thước | Chất lượng | Tốc độ | RAM cần | So sánh với GPT-3.5 |
|--------------|------------|------------|--------|---------|---------------------|
| **llama3.1** | ~8B/70B | ⭐⭐⭐⭐⭐ | ⚡⚡ | 8GB/40GB | Gần bằng hoặc tốt hơn |
| **llama3** | ~8B/70B | ⭐⭐⭐⭐⭐ | ⚡⚡ | 8GB/40GB | Gần bằng |
| **llama2** | ~7B/13B/70B | ⭐⭐⭐⭐ | ⚡⚡ | 8GB/16GB/40GB | Hơi kém hơn |
| **mistral** | ~7B | ⭐⭐⭐⭐ | ⚡⚡⚡ | 8GB | Tốt, nhanh |
| **qwen2.5** | ~7B | ⭐⭐⭐⭐ | ⚡⚡ | 8GB | Tốt, đa ngôn ngữ |

## 🎯 Khuyến Nghị Model Cho Generative Agents

### Cho Chất Lượng Tốt Nhất (Tương Đương GPT-3.5):
```python
ollama_model_name = "llama3.1"  # Hoặc "llama3"
```
- ✅ Chất lượng gần bằng GPT-3.5
- ✅ Hiểu context tốt
- ✅ Phù hợp cho simulation phức tạp

### Cho Tốc Độ (Nhanh Hơn):
```python
ollama_model_name = "mistral"
```
- ✅ Nhanh hơn
- ✅ Chất lượng tốt
- ✅ Phù hợp cho simulation nhanh

### Cho RAM Hạn Chế:
```python
ollama_model_name = "mistral"  # 7B, cần ~8GB RAM
# hoặc
ollama_model_name = "llama3:8b"  # 8B version
```

## 🔍 Kiểm Tra Model Đang Dùng

### Trong Code:
File `reverie/backend_server/utils.py`:
```python
ollama_model_name = "llama3.1"  # Model này sẽ được dùng thay cho gpt-3.5-turbo
```

### Khi Chạy:
Code sẽ tự động dùng `ollama_model_name` thay vì "gpt-3.5-turbo" khi:
- `llm_provider = "ollama"`

## 📝 Các Hàm Đã Được Cập Nhật

Tất cả các hàm sau đã được cập nhật để dùng Ollama model:

1. ✅ `ChatGPT_single_request()` - Dùng `ollama_model_name`
2. ✅ `ChatGPT_request()` - Dùng `ollama_model_name`
3. ✅ `GPT4_request()` - Dùng `ollama_model_name` (có thể dùng model lớn hơn)
4. ✅ `GPT_request()` - Dùng `ollama_model_name`
5. ✅ `get_embedding()` - Dùng `ollama_embedding_model_name`

## 🚀 Cách Thay Đổi Model

### Thay Đổi Model Text Generation:

```bash
# Trên VM Ubuntu
nano /root/Generative-Agents/reverie/backend_server/utils.py
```

Sửa:
```python
ollama_model_name = "llama3.1"  # Thay đổi model ở đây
```

**Các lựa chọn:**
- `"llama3.1"` - Tốt nhất (khuyến nghị)
- `"llama3"` - Tốt
- `"llama2"` - Ổn định
- `"mistral"` - Nhanh
- `"qwen2.5"` - Đa ngôn ngữ

### Tải Model Mới:

```bash
ollama pull llama3.1
# hoặc
ollama pull mistral
```

## ⚠️ Lưu Ý

1. **Model phải được tải trước:**
   ```bash
   ollama list  # Xem model đã tải
   ollama pull <model_name>  # Tải model mới
   ```

2. **Model name phải chính xác:**
   - Dùng tên chính xác từ `ollama list`
   - Ví dụ: `llama3.1` không phải `llama-3.1`

3. **RAM requirements:**
   - Model lớn cần nhiều RAM
   - Kiểm tra: `free -h`

## 🔄 Migration từ OpenAI sang Ollama

### Trước (OpenAI):
```python
llm_provider = "openai"
# Code sẽ dùng: "gpt-3.5-turbo"
```

### Sau (Ollama):
```python
llm_provider = "ollama"
ollama_model_name = "llama3.1"
# Code sẽ tự động dùng: "llama3.1" thay cho "gpt-3.5-turbo"
```

**Không cần sửa code khác!** Code đã tự động xử lý.

## 📊 Performance Comparison

### GPT-3.5-Turbo (OpenAI):
- Response time: ~1-3 giây
- Quality: ⭐⭐⭐⭐⭐
- Cost: $0.0015/1K tokens

### Llama3.1 (Ollama):
- Response time: ~2-10 giây (tùy hardware)
- Quality: ⭐⭐⭐⭐⭐
- Cost: $0 (local)

### Mistral (Ollama):
- Response time: ~1-5 giây
- Quality: ⭐⭐⭐⭐
- Cost: $0 (local)

## ✅ Kết Luận

1. ✅ **Ollama KHÔNG có gpt-3.5-turbo** - Đây là bình thường
2. ✅ **Code đã tự động dùng model Ollama** khi `llm_provider = "ollama"`
3. ✅ **Llama3.1 là lựa chọn tốt nhất** để thay thế GPT-3.5-turbo
4. ✅ **Không cần sửa code** - Chỉ cần đặt `llm_provider = "ollama"` và chọn model trong `utils.py`

## 🎯 Khuyến Nghị

**Cho dự án Generative Agents:**
```python
ollama_model_name = "llama3.1"  # Tốt nhất, gần bằng GPT-3.5
```

**Nếu cần nhanh hơn:**
```python
ollama_model_name = "mistral"  # Nhanh, chất lượng tốt
```

**Nếu RAM hạn chế:**
```python
ollama_model_name = "mistral"  # 7B, chỉ cần ~8GB RAM
```


