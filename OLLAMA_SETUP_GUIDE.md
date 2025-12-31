# Hướng Dẫn Triển Khai Generative Agents với Ollama

Tài liệu này hướng dẫn cách triển khai dự án "Generative Agents: Interactive Simulacra of Human Behavior" sử dụng Ollama thay vì OpenAI API.

## Tổng Quan

Dự án đã được cập nhật để hỗ trợ cả OpenAI và Ollama. Bạn có thể chuyển đổi giữa hai provider bằng cách thay đổi cấu hình trong file `utils.py`.

## Ưu Điểm của Ollama

1. **Miễn phí**: Không cần trả phí API
2. **Chạy local**: Dữ liệu không rời khỏi máy của bạn
3. **Tùy chỉnh**: Có thể sử dụng các model khác nhau
4. **Không giới hạn rate**: Không bị giới hạn số lượng request

## Yêu Cầu Hệ Thống

- Python 3.9.12 (khuyến nghị)
- RAM: Tối thiểu 8GB (khuyến nghị 16GB+ cho model lớn)
- GPU: Tùy chọn nhưng khuyến nghị cho hiệu suất tốt hơn
- Disk: Ít nhất 10GB trống cho model

## Bước 1: Cài Đặt Ollama

### Windows
1. Tải Ollama từ: https://ollama.ai/download
2. Cài đặt và chạy Ollama
3. Ollama sẽ tự động chạy trên `http://localhost:11434`

### Linux/Mac
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

## Bước 2: Tải Model Ollama

Sau khi cài đặt Ollama, bạn cần tải một model. Các model được khuyến nghị:

### Cho Text Generation (Chat):
- **llama3** (khuyến nghị): Model mới nhất, hiệu suất tốt
  ```bash
  ollama pull llama3
  ```
- **llama2**: Model ổn định
  ```bash
  ollama pull llama2
  ```
- **mistral**: Model nhỏ gọn, nhanh
  ```bash
  ollama pull mistral
  ```
- **qwen2.5**: Model đa ngôn ngữ tốt
  ```bash
  ollama pull qwen2.5
  ```

### Cho Embeddings:
- **nomic-embed-text** (khuyến nghị): Model chuyên dụng cho embeddings
  ```bash
  ollama pull nomic-embed-text
  ```

**Lưu ý**: Nếu model bạn chọn không hỗ trợ embeddings, bạn có thể:
1. Sử dụng model text generation cho embeddings (có thể kém chính xác hơn)
2. Hoặc sử dụng OpenAI chỉ cho embeddings (cần API key)

## Bước 3: Cấu Hình Dự Án

### 3.1. Cập nhật file `reverie/backend_server/utils.py`

Mở file `reverie/backend_server/utils.py` và cấu hình như sau:

```python
# Chọn provider: "openai" hoặc "ollama"
llm_provider = "ollama"

# Cấu hình Ollama
ollama_base_url = "http://localhost:11434"
ollama_model_name = "llama3"  # Thay đổi theo model bạn đã tải
ollama_embedding_model_name = "nomic-embed-text"  # Model cho embeddings
```

### 3.2. Kiểm tra kết nối Ollama

Bạn có thể kiểm tra xem Ollama có đang chạy không bằng cách:

```bash
curl http://localhost:11434/api/tags
```

Hoặc mở trình duyệt và truy cập: `http://localhost:11434/api/tags`

## Bước 4: Cài Đặt Dependencies

Đảm bảo bạn đã cài đặt tất cả dependencies:

```bash
pip install -r requirements.txt
```

**Lưu ý**: File `requirements.txt` đã bao gồm `requests` (cần cho Ollama API calls).

## Bước 5: Chạy Dự Án

### 5.1. Khởi động Environment Server

Mở terminal thứ nhất:
```bash
cd environment/frontend_server
python manage.py runserver
```

Truy cập `http://localhost:8000` để kiểm tra server đã chạy.

### 5.2. Khởi động Simulation Server

Mở terminal thứ hai:
```bash
cd reverie/backend_server
python reverie.py
```

Khi được hỏi:
- "Enter the name of the forked simulation: " → Nhập `base_the_ville_isabella_maria_klaus`
- "Enter the name of the new simulation: " → Nhập tên simulation của bạn (ví dụ: `test-simulation`)

### 5.3. Chạy Simulation

1. Mở trình duyệt và truy cập: `http://localhost:8000/simulator_home`
2. Trong terminal simulation server, nhập: `run 100` (hoặc số bước bạn muốn)

## Xử Lý Sự Cố

### Lỗi: "Ollama ERROR" hoặc Connection Refused

**Nguyên nhân**: Ollama server chưa chạy hoặc không thể kết nối.

**Giải pháp**:
1. Kiểm tra Ollama đang chạy: `ollama list`
2. Khởi động lại Ollama nếu cần
3. Kiểm tra URL trong `utils.py` có đúng không

### Lỗi: Model không tìm thấy

**Nguyên nhân**: Model chưa được tải về.

**Giải pháp**:
```bash
ollama pull <tên_model>
```

Ví dụ: `ollama pull llama3`

### Lỗi: Embedding không hoạt động

**Nguyên nhân**: Model không hỗ trợ embeddings hoặc model embedding chưa được tải.

**Giải pháp**:
1. Tải model embedding: `ollama pull nomic-embed-text`
2. Cập nhật `ollama_embedding_model_name` trong `utils.py`
3. Nếu vẫn không hoạt động, có thể sử dụng OpenAI chỉ cho embeddings (cần API key)

### Performance chậm

**Nguyên nhân**: Model quá lớn hoặc thiếu GPU.

**Giải pháp**:
1. Sử dụng model nhỏ hơn (ví dụ: `mistral` thay vì `llama3`)
2. Cài đặt GPU drivers và CUDA nếu có GPU
3. Giảm số lượng agents trong simulation

## Tùy Chỉnh Nâng Cao

### Sử dụng Model Tùy Chỉnh

Nếu bạn có model tùy chỉnh, chỉ cần thay đổi `ollama_model_name` trong `utils.py`.

### Sử dụng Ollama trên Server Khác

Nếu Ollama chạy trên máy khác, cập nhật `ollama_base_url`:
```python
ollama_base_url = "http://<IP_SERVER>:11434"
```

### Kết Hợp OpenAI và Ollama

Bạn có thể sử dụng OpenAI cho embeddings và Ollama cho text generation:

1. Đặt `llm_provider = "ollama"` trong `utils.py`
2. Trong `gpt_structure.py`, bạn có thể tùy chỉnh hàm `get_embedding()` để luôn dùng OpenAI

## So Sánh với OpenAI

| Tính năng | OpenAI | Ollama |
|-----------|--------|--------|
| Chi phí | Trả phí theo usage | Miễn phí |
| Privacy | Dữ liệu gửi lên server | Chạy local |
| Performance | Rất nhanh | Phụ thuộc hardware |
| Model quality | GPT-4/GPT-3.5 | Phụ thuộc model |
| Rate limits | Có giới hạn | Không giới hạn |
| Setup | Dễ (chỉ cần API key) | Cần cài đặt và tải model |

## Khuyến Nghị

1. **Cho development/testing**: Sử dụng Ollama với model nhỏ (mistral) để tiết kiệm tài nguyên
2. **Cho production**: Cân nhắc sử dụng OpenAI nếu cần hiệu suất cao hoặc không có GPU mạnh
3. **Cho privacy**: Sử dụng Ollama nếu dữ liệu nhạy cảm
4. **Cho cost**: Sử dụng Ollama để tránh chi phí API

## Tài Liệu Tham Khảo

- Ollama Documentation: https://github.com/ollama/ollama
- Generative Agents Paper: https://arxiv.org/abs/2304.03442
- Original Repository: https://github.com/joonspk-research/generative_agents

## Hỗ Trợ

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra logs trong terminal
2. Đảm bảo Ollama đang chạy và model đã được tải
3. Kiểm tra cấu hình trong `utils.py`

