#!/usr/bin/env python3
"""
Hermes Agent Telegram Bot
Connects Hermes Agent with Telegram for 24/7 communication
"""

import os
import sys
import asyncio
from typing import Optional
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

# Hermes Agent integration
try:
    import subprocess
    HERMES_AVAILABLE = True
except ImportError:
    HERMES_AVAILABLE = False
    print("Warning: Hermes not found in PATH")


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

    async def start(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /start command"""
        welcome_msg = (
            "🤖 *Hermes Agent Bot*\n\n"
            "Bienvenido. Soy Hermes, tu asistente de IA.\n"
            "Escribe cualquier mensaje y te ayudaré.\n\n"
            "Comandos:\n"
            "/help - Mostrar ayuda\n"
            "/status - Estado de Hermes"
        )
        await update.message.reply_text(welcome_msg, parse_mode="Markdown")

    async def help_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /help command"""
        help_msg = (
            "📚 *Ayuda - Hermes Agent*\n\n"
            "Puedes enviar cualquier mensaje y Hermes responderá.\n"
            "Hermes puede:\n"
            "• Responder preguntas\n"
            "• Analizar texto\n"
            "• Buscar información\n"
            "• Y mucho más\n\n"
            "Comandos disponibles:\n"
            "/start - Iniciar bot\n"
            "/status - Ver estado\n"
            "/help - Esta ayuda"
        )
        await update.message.reply_text(help_msg, parse_mode="Markdown")

    async def status(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Check Hermes status"""
        if HERMES_AVAILABLE:
            try:
                result = subprocess.run(
                    ["hermes", "--version"],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                status_msg = f"✅ Hermes está activo\n\n{result.stdout}"
            except Exception as e:
                status_msg = f"⚠️ Error: {str(e)}"
        else:
            status_msg = "❌ Hermes no está disponible"

        await update.message.reply_text(status_msg)

    async def handle_message(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Process user messages and send to Hermes"""
        user_message = update.message.text

        # Show typing indicator
        await update.message.chat.send_action("typing")

        try:
            if HERMES_AVAILABLE:
                # Send message to Hermes (this is a placeholder - actual integration depends on Hermes API)
                response = await self.query_hermes(user_message)
            else:
                response = "❌ Hermes no está disponible. Por favor instálalo primero: hermes --version"

            # Split long messages
            if len(response) > 4096:
                for i in range(0, len(response), 4096):
                    await update.message.reply_text(response[i:i+4096])
            else:
                await update.message.reply_text(response)

        except Exception as e:
            error_msg = f"❌ Error: {str(e)}\n\nIntenta de nuevo o usa /help"
            await update.message.reply_text(error_msg)

    async def query_hermes(self, message: str) -> str:
        """Query Hermes Agent (placeholder - needs Hermes API integration)"""
        try:
            # This is a placeholder for Hermes integration
            # You'll need to implement the actual Hermes API call here
            result = subprocess.run(
                ["hermes", "chat", message],
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0:
                return result.stdout.strip() or "Respuesta vacía de Hermes"
            else:
                return f"Error de Hermes: {result.stderr}"

        except subprocess.TimeoutExpired:
            return "⏱️ Hermes tardó demasiado en responder. Intenta con un mensaje más corto."
        except Exception as e:
            return f"Error al contactar Hermes: {str(e)}"

    def run(self):
        """Start the bot"""
        print("🚀 Iniciando Hermes Telegram Bot...")
        self.app.run_polling(allowed_updates=Update.ALL_TYPES)


def main():
    """Main entry point"""
    token = os.getenv("TELEGRAM_BOT_TOKEN")

    if not token:
        print("❌ Error: TELEGRAM_BOT_TOKEN no está configurado")
        print("\nConfigura la variable de entorno:")
        print("  export TELEGRAM_BOT_TOKEN='tu_token_aqui'")
        sys.exit(1)

    bot = HermesBot(token)
    bot.run()


if __name__ == "__main__":
    main()
