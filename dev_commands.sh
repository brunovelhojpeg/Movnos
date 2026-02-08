#!/bin/bash

# ==================== COMANDOS PARA RODAR NO TERMINAL ====================

# 1. Limpar cache do Flutter
echo "🧹 Limpando cache..."
flutter clean

# 2. Instalar dependências
echo "📦 Instalando dependências..."
flutter pub get

# 3. Rodar no iOS (se estiver no Mac)
echo "📱 Para rodar no iOS:"
echo "flutter run -d ios"

# 4. Rodar no Android
echo "🤖 Para rodar no Android:"
echo "flutter run -d android"

# 5. Ver dispositivos disponíveis
echo "📱 Ver dispositivos:"
echo "flutter devices"

# ==========================================================================

# INSTRUÇÕES:
# 1. Copie os comandos abaixo um por um no terminal do VS Code
# 2. Execute na ordem indicada

echo ""
echo "✅ EXECUTE ESTES COMANDOS NO TERMINAL:"
echo ""
echo "flutter clean"
echo "flutter pub get"
echo "flutter devices"
echo "flutter run"
