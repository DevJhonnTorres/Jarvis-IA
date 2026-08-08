"""
DeepSeek v4 API Integration
Integrates DeepSeek v4 with Hermes Telegram Bot
"""

import os
from typing import Optional
from openai import OpenAI

class DeepSeekClient:
    def __init__(self, api_key: Optional[str] = None):
        """Initialize DeepSeek client"""
        self.api_key = api_key or os.getenv("DEEPSEK_API_KEY")

        if not self.api_key:
            raise ValueError("DEEPSEK_API_KEY not found in environment variables")

        # DeepSeek API is OpenAI compatible
        self.client = OpenAI(
            api_key=self.api_key,
            base_url="https://api.deepseek.com"
        )
        self.model = "deepseek-chat"

    async def query(self, message: str, system_prompt: Optional[str] = None) -> str:
        """
        Query DeepSeek with a message

        Args:
            message: User message to send to DeepSeek
            system_prompt: Optional system prompt for context

        Returns:
            Response from DeepSeek
        """
        try:
            system = system_prompt or "You are a helpful AI assistant. Respond in Spanish when the user writes in Spanish."

            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system},
                    {"role": "user", "content": message}
                ],
                temperature=0.7,
                max_tokens=2000,
                top_p=0.95,
            )

            return response.choices[0].message.content

        except Exception as e:
            return f"❌ Error contacting DeepSeek: {str(e)}"

    def query_sync(self, message: str, system_prompt: Optional[str] = None) -> str:
        """Synchronous version of query (for non-async code)"""
        try:
            system = system_prompt or "You are a helpful AI assistant. Respond in Spanish when the user writes in Spanish."

            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system},
                    {"role": "user", "content": message}
                ],
                temperature=0.7,
                max_tokens=2000,
                top_p=0.95,
            )

            return response.choices[0].message.content

        except Exception as e:
            return f"❌ Error contacting DeepSeek: {str(e)}"

# Initialize globally
try:
    deepsek_client = DeepSeekClient()
    DEEPSEK_AVAILABLE = True
except Exception as e:
    print(f"⚠️ DeepSeek not available: {e}")
    deepsek_client = None
    DEEPSEK_AVAILABLE = False
