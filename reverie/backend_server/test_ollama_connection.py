"""
Script để kiểm tra kết nối Ollama và cấu hình.
Chạy script này trước khi chạy simulation để đảm bảo Ollama hoạt động đúng.
"""
import sys
import os

# Thêm đường dẫn để import utils
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

try:
    from utils import (
        llm_provider,
        ollama_base_url,
        ollama_model_name,
        ollama_embedding_model_name
    )
    from persona.prompt_template.ollama_interface import (
        check_ollama_connection,
        ollama_chat_request,
        ollama_get_embedding
    )
    
    print("=" * 60)
    print("KIỂM TRA CẤU HÌNH OLLAMA")
    print("=" * 60)
    
    # Kiểm tra provider
    print(f"\n1. LLM Provider: {llm_provider}")
    if llm_provider != "ollama":
        print("   ⚠️  CẢNH BÁO: llm_provider không phải 'ollama'")
        print("   → Vui lòng đặt llm_provider = 'ollama' trong utils.py")
    else:
        print("   ✓ Provider được cấu hình đúng")
    
    # Kiểm tra kết nối
    print(f"\n2. Kiểm tra kết nối Ollama tại: {ollama_base_url}")
    if check_ollama_connection():
        print("   ✓ Kết nối Ollama thành công")
    else:
        print("   ✗ KHÔNG THỂ KẾT NỐI ĐẾN OLLAMA")
        print("   → Vui lòng đảm bảo Ollama đang chạy")
        print("   → Kiểm tra URL: " + ollama_base_url)
        sys.exit(1)
    
    # Kiểm tra model text generation
    print(f"\n3. Kiểm tra model text generation: {ollama_model_name}")
    try:
        test_response = ollama_chat_request("Hello, respond with 'OK'", model=ollama_model_name)
        if "Ollama ERROR" in test_response:
            print(f"   ✗ Model '{ollama_model_name}' không hoạt động")
            print("   → Vui lòng tải model: ollama pull " + ollama_model_name)
        else:
            print(f"   ✓ Model '{ollama_model_name}' hoạt động tốt")
            print(f"   → Response mẫu: {test_response[:50]}...")
    except Exception as e:
        print(f"   ✗ Lỗi khi test model: {str(e)}")
        print("   → Vui lòng tải model: ollama pull " + ollama_model_name)
    
    # Kiểm tra model embedding
    print(f"\n4. Kiểm tra model embedding: {ollama_embedding_model_name}")
    try:
        test_embedding = ollama_get_embedding("test", model=ollama_embedding_model_name)
        if len(test_embedding) > 0 and test_embedding[0] != 0.0:
            print(f"   ✓ Model embedding '{ollama_embedding_model_name}' hoạt động tốt")
            print(f"   → Embedding dimension: {len(test_embedding)}")
        else:
            print(f"   ⚠️  Model embedding có thể không hoạt động đúng")
            print("   → Vui lòng tải model: ollama pull " + ollama_embedding_model_name)
    except Exception as e:
        print(f"   ⚠️  Lỗi khi test embedding: {str(e)}")
        print("   → Vui lòng tải model: ollama pull " + ollama_embedding_model_name)
        print("   → Hoặc sử dụng OpenAI cho embeddings")
    
    print("\n" + "=" * 60)
    print("KIỂM TRA HOÀN TẤT")
    print("=" * 60)
    print("\nNếu tất cả đều ✓, bạn có thể chạy simulation.")
    print("Nếu có lỗi, vui lòng xem hướng dẫn trong OLLAMA_SETUP_GUIDE.md")
    
except ImportError as e:
    print(f"Lỗi import: {str(e)}")
    print("Vui lòng đảm bảo bạn đang chạy script từ thư mục reverie/backend_server")
    sys.exit(1)
except Exception as e:
    print(f"Lỗi không xác định: {str(e)}")
    import traceback
    traceback.print_exc()
    sys.exit(1)


