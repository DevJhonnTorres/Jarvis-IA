"""
DeepSeek API Usage Logger
Monitorea en tiempo real cuándo y cómo se usa tu API
"""

import os
import json
import time
from datetime import datetime
from typing import Optional
from openai import OpenAI

class DeepSeekClientWithLogging:
    def __init__(self, api_key: Optional[str] = None, log_file: str = "deepsek_usage.log"):
        """Initialize DeepSeek client with logging"""
        self.api_key = api_key or os.getenv("DEEPSEK_API_KEY")

        if not self.api_key:
            raise ValueError("DEEPSEK_API_KEY not found in environment variables")

        self.client = OpenAI(
            api_key=self.api_key,
            base_url="https://api.deepseek.com"
        )
        self.model = "deepseek-v4-flash"
        self.log_file = log_file
        self.call_count = 0
        self.total_tokens = 0

    def log(self, message: str, level: str = "INFO"):
        """Log messages with timestamp"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_line = f"[{timestamp}] [{level}] {message}"

        print(log_line)

        with open(self.log_file, "a") as f:
            f.write(log_line + "\n")

    def query_sync(self, message: str, system_prompt: Optional[str] = None) -> str:
        """Query DeepSeek with detailed logging"""
        self.call_count += 1

        self.log(f"", "INFO")
        self.log(f"{'='*70}", "INFO")
        self.log(f"🔴 LLAMADA #{self.call_count} A DEEPSEK API", "INFO")
        self.log(f"{'='*70}", "INFO")

        timestamp = datetime.now().isoformat()
        self.log(f"⏰ Timestamp: {timestamp}", "INFO")

        system = system_prompt or "You are a helpful AI assistant. Respond in Spanish when the user writes in Spanish."

        self.log(f"📨 Mensaje del usuario: {message[:100]}{'...' if len(message) > 100 else ''}", "INFO")
        self.log(f"📝 Longitud del mensaje: {len(message)} caracteres", "INFO")
        self.log(f"🤖 Modelo: {self.model}", "INFO")
        self.log(f"🔑 API Key (primeros 15 caracteres): {self.api_key[:15]}...", "INFO")
        self.log(f"🌐 Endpoint: https://api.deepseek.com/chat/completions", "INFO")

        try:
            start_time = time.time()
            self.log(f"⏳ Enviando solicitud a DeepSeek...", "INFO")

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

            elapsed_time = time.time() - start_time

            # Extract response details
            response_text = response.choices[0].message.content
            input_tokens = response.usage.prompt_tokens
            output_tokens = response.usage.completion_tokens
            total_tokens = response.usage.total_tokens

            self.total_tokens += total_tokens

            self.log(f"✅ Respuesta recibida exitosamente", "SUCCESS")
            self.log(f"⏱️  Tiempo de respuesta: {elapsed_time:.2f} segundos", "INFO")
            self.log(f"", "INFO")
            self.log(f"📊 ESTADÍSTICAS DE TOKENS:", "INFO")
            self.log(f"   - Tokens enviados (input): {input_tokens}", "INFO")
            self.log(f"   - Tokens recibidos (output): {output_tokens}", "INFO")
            self.log(f"   - Total en esta llamada: {total_tokens}", "INFO")
            self.log(f"   - Total acumulado: {self.total_tokens}", "INFO")
            self.log(f"", "INFO")
            self.log(f"💬 Respuesta (primeros 150 caracteres):", "INFO")
            self.log(f"   {response_text[:150]}{'...' if len(response_text) > 150 else ''}", "INFO")
            self.log(f"", "INFO")
            self.log(f"📈 RESUMEN:", "INFO")
            self.log(f"   - Llamadas totales: {self.call_count}", "INFO")
            self.log(f"   - Tokens totales consumidos: {self.total_tokens}", "INFO")
            if self.call_count > 0:
                avg_tokens = self.total_tokens / self.call_count
                self.log(f"   - Promedio de tokens/llamada: {avg_tokens:.0f}", "INFO")
            self.log(f"{'='*70}", "INFO")
            self.log(f"", "INFO")

            return response_text

        except Exception as e:
            self.log(f"❌ ERROR en DeepSeek API", "ERROR")
            self.log(f"   Tipo de error: {type(e).__name__}", "ERROR")
            self.log(f"   Mensaje: {str(e)}", "ERROR")
            self.log(f"{'='*70}", "ERROR")
            return f"❌ Error contacting DeepSeek: {str(e)}"

# Función auxiliar para ver el log en tiempo real
def monitor_logs(filename: str = "deepsek_usage.log", tail_lines: int = 50):
    """Monitor log file in real time"""
    import subprocess

    try:
        subprocess.run(["tail", "-f", filename])
    except KeyboardInterrupt:
        print("\n📌 Monitoring stopped")

if __name__ == "__main__":
    # Ejemplo de uso
    try:
        client = DeepSeekClientWithLogging()

        # Test message
        response = client.query_sync("¿Hola, cómo estás?")
        print("\n\n🎯 Respuesta final:")
        print(response)

    except Exception as e:
        print(f"❌ Error: {e}")
