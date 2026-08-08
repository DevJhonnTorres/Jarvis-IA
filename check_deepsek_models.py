#!/usr/bin/env python3
"""
Check available DeepSeek models
"""

import os
from openai import OpenAI

api_key = os.getenv("DEEPSEK_API_KEY") or "sk-877a3664c3f04201b17ee6adb6d7b161"

client = OpenAI(
    api_key=api_key,
    base_url="https://api.deepseek.com"
)

try:
    print("🔍 Fetching available DeepSeek models...")
    models = client.models.list()

    print("\n✅ Available Models:\n")
    for model in models.data:
        print(f"  - {model.id}")

    print("\n" + "="*60)
    print("Recommended models:")
    print("  deepseek-chat      (Standard, balanced)")
    print("  deepseek-coder     (Code generation)")
    print("  deepseek-reasoner  (Complex reasoning)")
    print("="*60)

except Exception as e:
    print(f"❌ Error: {e}")
    print("\nCommon DeepSeek models:")
    print("  - deepseek-chat")
    print("  - deepseek-coder")
    print("  - deepseek-reasoner")
    print("  - deepseek-v4")
