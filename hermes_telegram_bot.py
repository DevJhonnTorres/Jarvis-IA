#!/usr/bin/env python3
"""
Hermes Agent Telegram Bot
Connects Hermes Agent with Telegram for 24/7 communication
Works on Replit with keep-alive server
"""

import os
import sys
import asyncio
from typing import Optional
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from keep_alive import keep_alive
from deepsek_integration import deepsek_client, DEEPSEK_AVAILABLE


class HermesBot:
    def __init__(self, token: str):
        self.token = token
        self.app = Application.builder().token(token).build()
        self.setup_handlers()

    def setup_handlers(self):
        """Configure bot command and message handlers"""
        self.app.add_handler(CommandHandler("start", self.start))
        self.app.add_handler(CommandHandler("help", self.help_command))
        self.app.add_handler(CommandHandler("status", self.status))
        self.app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, self.handle_message))
        self.app.add_handler(MessageHandler(filters.Document.ALL, self.handle_document))

    async def start(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /start command"""
        welcome_msg = (
            "🤖 *Hermes + DeepSeek v4 Bot*\n\n"
            "Bienvenido. Soy tu asistente de IA con DeepSeek v4.\n"
            "Escribe cualquier mensaje y te ayudaré.\n\n"
            "💡 Puedo:\n"
            "• Responder preguntas\n"
            "• Analizar texto\n"
            "• Ayudarte con código\n"
            "• Y mucho más\n\n"
            "Comandos:\n"
            "/help - Mostrar ayuda\n"
            "/status - Estado de DeepSeek"
        )
        await update.message.reply_text(welcome_msg, parse_mode="Markdown")

    async def help_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /help command"""
        help_msg = (
            "📚 *Ayuda - Hermes Agent*\n\n"
            "Puedes enviar:\n"
            "• 💬 Mensajes de texto\n"
            "• 📄 Archivos (documentos, código, logs)\n\n"
            "Hermes puede:\n"
            "• Responder preguntas\n"
            "• Analizar archivos\n"
            "• Leer código\n"
            "• Procesar documentos\n"
            "• Y mucho más\n\n"
            "Comandos:\n"
            "/start - Iniciar bot\n"
            "/status - Ver estado\n"
            "/help - Esta ayuda"
        )
        await update.message.reply_text(help_msg, parse_mode="Markdown")

    async def status(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Check AI service status"""
        if DEEPSEK_AVAILABLE:
            status_msg = "✅ DeepSeek v4 API está activo\n\n🤖 Modelo: deepseek-chat\n🔌 Conexión: Establecida"
        else:
            status_msg = "❌ DeepSeek API no está disponible"

        await update.message.reply_text(status_msg)

    async def handle_document(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle document uploads"""
        import os

        document = update.message.document
        await update.message.reply_text("📥 Descargando archivo...")

        try:
            # Download file
            file = await context.bot.get_file(document.file_id)
            file_path = f"/tmp/{document.file_name}"
            await file.download_to_drive(file_path)

            # Read file content
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()

            # Truncate if too long
            if len(content) > 5000:
                content = content[:5000] + "\n\n[... archivo truncado ...]"

            # Send to DeepSeek
            await update.message.reply_text("🔄 Analizando archivo con DeepSeek...")
            prompt = f"Analiza este archivo:\n\n{content}\n\n¿Qué contiene? ¿Hay algo que instalar o ejecutar?"

            # Call DeepSeek directly (synchronous)
            if DEEPSEK_AVAILABLE:
                response = deepsek_client.query_sync(prompt)
            else:
                response = "❌ DeepSeek no disponible"

            # Send response
            if len(response) > 4096:
                for i in range(0, len(response), 4096):
                    await update.message.reply_text(response[i:i+4096])
            else:
                await update.message.reply_text(response)

            # Cleanup
            if os.path.exists(file_path):
                os.remove(file_path)

        except Exception as e:
            error_msg = f"❌ Error procesando archivo:\n{str(e)}"
            await update.message.reply_text(error_msg)
            print(f"Error en handle_document: {e}")

    async def handle_message(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Process user messages and send to DeepSeek"""
        user_message = update.message.text

        # Show typing indicator
        await update.message.chat.send_action("typing")

        try:
            if DEEPSEK_AVAILABLE:
                # Send message to DeepSeek
                response = await self.query_deepsek(user_message)
            else:
                response = "❌ DeepSeek API no está disponible. Verifica tu API key."

            # Split long messages
            if len(response) > 4096:
                for i in range(0, len(response), 4096):
                    await update.message.reply_text(response[i:i+4096])
            else:
                await update.message.reply_text(response)

        except Exception as e:
            error_msg = f"❌ Error: {str(e)}\n\nIntenta de nuevo o usa /help"
            await update.message.reply_text(error_msg)

    async def query_deepsek(self, message: str) -> str:
        """Query DeepSeek v4 API"""
        try:
            if not DEEPSEK_AVAILABLE:
                return "❌ DeepSeek API no está disponible. Verifica tu API key."

            # Use DeepSeek client synchronously
            response = deepsek_client.query_sync(message)
            return response

        except Exception as e:
            return f"❌ Error: {str(e)}\n\nIntenta de nuevo."

    def run(self):
        """Start the bot"""
        print("🚀 Iniciando Hermes Telegram Bot...")
        self.app.run_polling(allowed_updates=Update.ALL_TYPES)


def main():
    """Main entry point"""
    # Iniciar keep-alive server para Replit (mantiene el bot activo 24/7)
    keep_alive()

    token = os.getenv("TELEGRAM_BOT_TOKEN")

    if not token:
        print("❌ Error: TELEGRAM_BOT_TOKEN no está configurado")
        print("\nConfigura la variable de entorno:")
        print("  export TELEGRAM_BOT_TOKEN='tu_token_aqui'")
        sys.exit(1)

    print("🚀 Iniciando Hermes Telegram Bot...")
    bot = HermesBot(token)
    bot.run()


if __name__ == "__main__":
    main()
