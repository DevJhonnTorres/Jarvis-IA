"""
Keep Alive Flask Server
Mantiene el bot activo 24/7 en Replit
Sin este, Replit duerme el bot después de 1 hora
"""

from flask import Flask
from threading import Thread
import time

app = Flask(__name__)

@app.route('/')
def home():
    return "🤖 Hermes Bot is alive!", 200

@app.route('/health')
def health():
    return {"status": "ok", "uptime": time.time()}, 200

def run():
    """Ejecuta el servidor Flask en background"""
    app.run(host='0.0.0.0', port=8080, debug=False)

def keep_alive():
    """Inicia el servidor Flask en un thread separado"""
    server_thread = Thread(target=run)
    server_thread.daemon = True
    server_thread.start()
    print("✅ Keep-alive server started on port 8080")
