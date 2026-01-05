"""
Author: Modified for Ollama integration

File: ollama_interface.py
Description: Wrapper functions for calling Ollama APIs.
"""

import json
import time
import requests
from typing import Optional, List

from utils import *


def temp_sleep(seconds=0.1):
    time.sleep(seconds)


def ollama_chat_request(prompt: str, model: str = None, base_url: str = None) -> str:
    """
    Make a chat completion request to Ollama API.

    ARGS:
        prompt: a str prompt
        model: Ollama model name (e.g., "llama2", "mistral", "llama3")
        base_url: Ollama API base URL (default: http://localhost:11434)
    RETURNS:
        a str of Ollama's response
    """
    if model is None:
        model = ollama_model_name
    if base_url is None:
        base_url = ollama_base_url

    temp_sleep()

    try:
        url = f"{base_url}/api/chat"
        payload = {
            "model": model,
            "messages": [{"role": "user", "content": prompt}],
            "stream": False,
        }

        response = requests.post(url, json=payload, timeout=300)  # Tăng timeout lên 5 phút cho prompt dài
        response.raise_for_status()

        result = response.json()
        return result["message"]["content"]

    except requests.exceptions.ConnectionError as e:
        print(f"Ollama Connection ERROR: Cannot connect to {base_url}")
        print(f"  Details: {str(e)}")
        print(f"  Check: Is Ollama running? Try: curl {base_url}/api/tags")
        return "Ollama ERROR"
    except requests.exceptions.Timeout as e:
        print(f"Ollama Timeout ERROR: Request took too long (>120s)")
        print(f"  Details: {str(e)}")
        return "Ollama ERROR"
    except requests.exceptions.HTTPError as e:
        print(f"Ollama HTTP ERROR: {e.response.status_code}")
        print(f"  Response: {e.response.text[:200]}")
        return "Ollama ERROR"
    except Exception as e:
        print(f"Ollama ERROR: {type(e).__name__}: {str(e)}")
        import traceback

        print(f"  Traceback: {traceback.format_exc()[:500]}")
        return "Ollama ERROR"


def ollama_generate_request(
    prompt: str,
    model: str = None,
    temperature: float = 0.7,
    max_tokens: int = 512,
    top_p: float = 1.0,
    stop: Optional[List[str]] = None,
    base_url: str = None,
) -> str:
    """
    Make a completion request to Ollama API (for legacy GPT_request compatibility).

    ARGS:
        prompt: a str prompt
        model: Ollama model name
        temperature: sampling temperature
        max_tokens: maximum tokens to generate
        top_p: top-p sampling parameter
        stop: list of stop sequences
        base_url: Ollama API base URL
    RETURNS:
        a str of Ollama's response
    """
    if model is None:
        model = ollama_model_name
    if base_url is None:
        base_url = ollama_base_url

    temp_sleep()

    try:
        url = f"{base_url}/api/generate"
        payload = {
            "model": model,
            "prompt": prompt,
            "stream": False,  # Disable streaming to get single JSON response
            "options": {
                "temperature": temperature,
                "top_p": top_p,
                "num_predict": max_tokens,
            },
        }

        if stop:
            payload["options"]["stop"] = stop

        response = requests.post(url, json=payload, timeout=300)  # Tăng timeout lên 5 phút cho prompt dài
        response.raise_for_status()

        # Ollama /api/generate can return streaming format (multiple JSON lines)
        # or single JSON object. Handle both cases.
        text = response.text.strip()

        # Try to parse as single JSON first
        try:
            result = json.loads(text)
            if isinstance(result, dict) and "response" in result:
                return result["response"]
        except json.JSONDecodeError:
            # If single JSON fails, might be streaming format (multiple JSON lines)
            pass

        # Try parsing as streaming format (one JSON per line)
        full_response = ""
        lines = text.split("\n")
        for line in lines:
            line = line.strip()
            if not line:
                continue
            try:
                result = json.loads(line)
                if isinstance(result, dict):
                    # Extract response from each chunk
                    if "response" in result:
                        full_response += result["response"]
                    # Check if done
                    if result.get("done", False):
                        break
            except json.JSONDecodeError:
                # Skip invalid JSON lines
                continue

        if full_response:
            return full_response

        # If all parsing fails, try to extract from raw text
        # Look for "response" field in text
        try:
            # Try to find last complete JSON object
            last_brace = text.rfind("}")
            if last_brace != -1:
                last_json = text[: last_brace + 1]
                result = json.loads(last_json)
                if "response" in result:
                    return result["response"]
        except:
            pass

        # Last resort: return error
        print(f"Warning: Could not parse Ollama response. Raw text: {text[:200]}")
        return "Ollama ERROR: Could not parse response"

    except requests.exceptions.ConnectionError as e:
        print(f"Ollama Connection ERROR: Cannot connect to {base_url}")
        print(f"  Details: {str(e)}")
        print(f"  Check: Is Ollama running? Try: curl {base_url}/api/tags")
        return "Ollama ERROR"
    except requests.exceptions.Timeout as e:
        print(f"Ollama Timeout ERROR: Request took too long (>120s)")
        print(f"  Details: {str(e)}")
        return "Ollama ERROR"
    except requests.exceptions.HTTPError as e:
        print(f"Ollama HTTP ERROR: {e.response.status_code}")
        print(f"  Response: {e.response.text[:200]}")
        return "Ollama ERROR"
    except Exception as e:
        print(f"Ollama ERROR: {type(e).__name__}: {str(e)}")
        import traceback

        print(f"  Traceback: {traceback.format_exc()[:500]}")
        return "Ollama ERROR"


def ollama_get_embedding(
    text: str, model: str = None, base_url: str = None
) -> List[float]:
    """
    Get embedding from Ollama.

    Note: Ollama models need to support embeddings. Some models like nomic-embed-text
    are specifically designed for embeddings.

    ARGS:
        text: text to embed
        model: Ollama embedding model name
        base_url: Ollama API base URL
    RETURNS:
        a list of floats representing the embedding
    """
    if model is None:
        model = ollama_embedding_model_name
    if base_url is None:
        base_url = ollama_base_url

    text = text.replace("\n", " ")
    if not text:
        text = "this is blank"

    try:
        url = f"{base_url}/api/embeddings"
        payload = {"model": model, "prompt": text}

        response = requests.post(url, json=payload, timeout=300)  # Tăng timeout lên 5 phút cho prompt dài
        response.raise_for_status()

        result = response.json()
        return result["embedding"]

    except requests.exceptions.ConnectionError as e:
        print(f"Ollama Embedding Connection ERROR: Cannot connect to {base_url}")
        print(f"  Details: {str(e)}")
        return [0.0] * 768  # Default embedding dimension
    except requests.exceptions.Timeout as e:
        print(f"Ollama Embedding Timeout ERROR: Request took too long")
        return [0.0] * 768
    except Exception as e:
        print(f"Ollama Embedding ERROR: {type(e).__name__}: {str(e)}")
        return [0.0] * 768  # Default embedding dimension


def check_ollama_connection(base_url: str = None) -> bool:
    """
    Check if Ollama server is running and accessible.

    ARGS:
        base_url: Ollama API base URL
    RETURNS:
        True if connection is successful, False otherwise
    """
    if base_url is None:
        base_url = ollama_base_url

    try:
        url = f"{base_url}/api/tags"
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        return True
    except:
        return False
