#!/usr/bin/env python3
"""
Script để debug Ollama connection và test các API calls
Chạy script này để kiểm tra Ollama hoạt động đúng
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from utils import *
from persona.prompt_template.ollama_interface import (
    ollama_chat_request,
    ollama_generate_request,
    ollama_get_embedding,
    check_ollama_connection
)

print("=" * 60)
print("OLLAMA DEBUG SCRIPT")
print("=" * 60)
print()

# 1. Kiểm tra cấu hình
print("1. Cấu hình:")
print(f"   llm_provider: {llm_provider}")
print(f"   ollama_base_url: {ollama_base_url}")
print(f"   ollama_model_name: {ollama_model_name}")
print(f"   ollama_embedding_model_name: {ollama_embedding_model_name}")
print()

# 2. Kiểm tra kết nối
print("2. Kiểm tra kết nối Ollama:")
if check_ollama_connection():
    print("   ✓ Ollama server đang chạy")
else:
    print("   ✗ KHÔNG THỂ KẾT NỐI ĐẾN OLLAMA")
    print(f"   → Kiểm tra: curl {ollama_base_url}/api/tags")
    print("   → Đảm bảo Ollama đang chạy: systemctl status ollama")
    sys.exit(1)
print()

# 3. Test chat request
print("3. Test Chat Request:")
try:
    test_prompt = "Say 'OK' if you can read this."
    print(f"   Prompt: {test_prompt}")
    response = ollama_chat_request(test_prompt, model=ollama_model_name)
    if "Ollama ERROR" in response:
        print(f"   ✗ Lỗi: {response}")
    else:
        print(f"   ✓ Response: {response[:100]}")
except Exception as e:
    print(f"   ✗ Exception: {type(e).__name__}: {str(e)}")
print()

# 4. Test generate request
print("4. Test Generate Request:")
try:
    test_prompt = "Complete: The sky is"
    print(f"   Prompt: {test_prompt}")
    response = ollama_generate_request(
        test_prompt, 
        model=ollama_model_name,
        max_tokens=10
    )
    if "Ollama ERROR" in response:
        print(f"   ✗ Lỗi: {response}")
    else:
        print(f"   ✓ Response: {response[:100]}")
except Exception as e:
    print(f"   ✗ Exception: {type(e).__name__}: {str(e)}")
print()

# 5. Test embedding
print("5. Test Embedding:")
try:
    test_text = "test embedding"
    embedding = ollama_get_embedding(test_text, model=ollama_embedding_model_name)
    if len(embedding) > 0 and embedding[0] != 0.0:
        print(f"   ✓ Embedding dimension: {len(embedding)}")
        print(f"   ✓ First few values: {embedding[:5]}")
    else:
        print(f"   ⚠ Embedding có thể không hoạt động (zero vector)")
except Exception as e:
    print(f"   ✗ Exception: {type(e).__name__}: {str(e)}")
print()

# 6. Test với prompt dài hơn (giống simulation)
print("6. Test với prompt dài (simulation-like):")
try:
    long_prompt = """You are Isabella Rodriguez. Today is Monday February 13.
    
Your daily plan:
1) wake up and complete the morning routine at 8:00 am
2) eat breakfast at 9:00 am

What will you do at 8:00 AM? Respond with just the activity."""
    
    print(f"   Prompt length: {len(long_prompt)} chars")
    response = ollama_chat_request(long_prompt, model=ollama_model_name)
    if "Ollama ERROR" in response:
        print(f"   ✗ Lỗi: {response}")
    else:
        print(f"   ✓ Response: {response[:200]}")
except Exception as e:
    print(f"   ✗ Exception: {type(e).__name__}: {str(e)}")
    import traceback
    print(f"   Traceback: {traceback.format_exc()[:500]}")
print()

print("=" * 60)
print("DEBUG HOÀN TẤT")
print("=" * 60)
print()
print("Nếu tất cả đều ✓, Ollama hoạt động tốt.")
print("Nếu có lỗi, xem chi tiết ở trên và kiểm tra:")
print("  1. Ollama đang chạy: systemctl status ollama")
print("  2. Model đã tải: ollama list")
print("  3. Kết nối: curl http://localhost:11434/api/tags")
print()


