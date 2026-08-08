"""
Hermes Agent Local Integration
Uses installed Hermes Agent to process messages
"""

import subprocess
import os
from typing import Optional

class HermesLocalClient:
    def __init__(self):
        """Initialize Hermes local client"""
        self.hermes_path = self._find_hermes()
        if not self.hermes_path:
            raise ValueError("Hermes not found in PATH")

    def _find_hermes(self) -> Optional[str]:
        """Find Hermes in system PATH"""
        try:
            result = subprocess.run(
                ["which", "hermes"],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                return result.stdout.strip()
        except Exception as e:
            print(f"Error finding Hermes: {e}")
        return None

    def query_sync(self, message: str) -> str:
        """
        Query Hermes Agent synchronously

        Args:
            message: User message to send to Hermes

        Returns:
            Response from Hermes
        """
        try:
            # Call Hermes with the message
            result = subprocess.run(
                ["hermes", "chat", message],
                capture_output=True,
                text=True,
                timeout=30,
                env={**os.environ}
            )

            if result.returncode == 0:
                response = result.stdout.strip()
                if response:
                    return response
                else:
                    return "✅ Hermes procesó el mensaje pero no devolvió texto"
            else:
                error_msg = result.stderr.strip() if result.stderr else "Error desconocido"
                return f"❌ Error de Hermes: {error_msg}"

        except subprocess.TimeoutExpired:
            return "⏱️ Hermes tardó demasiado en responder. Intenta con un mensaje más corto."
        except FileNotFoundError:
            return "❌ Hermes no está instalado o no se encuentra en PATH"
        except Exception as e:
            return f"❌ Error al llamar a Hermes: {str(e)}"

    async def query(self, message: str) -> str:
        """Async wrapper for query_sync"""
        return self.query_sync(message)

# Initialize globally
try:
    hermes_client = HermesLocalClient()
    HERMES_AVAILABLE = True
    print("✅ Hermes Agent detectado y listo")
except Exception as e:
    print(f"⚠️ Hermes no disponible: {e}")
    hermes_client = None
    HERMES_AVAILABLE = False
