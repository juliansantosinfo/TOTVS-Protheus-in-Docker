#!/bin/bash
#
# ==============================================================================
# SCRIPT: build.sh
# DESCRIÇÃO: Responsável por realizar o build da imagem Docker para o serviço 
#            TOTVS SmartView.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-02-05
# USO: ./build.sh [plain | auto | tty]
#      - Argumento 1 (progress): Controla o formato do output do Docker (padrão: auto).
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
# -e: Sai imediatamente se um comando falhar.
# -u: Trata variáveis não definidas como erro.
# -o pipefail: Garante que um pipeline (ex: cat | tar) falhe se qualquer comando falhar.
set -euo pipefail

readonly REQUIRED_DIR_NAME="smartview"
readonly TOTVS_DIR="./totvs"

# --- Carregar Versões Centralizadas ---
if [ -f "versions.env" ]; then
    source "versions.env"
elif [ -f "../versions.env" ]; then
    source "../versions.env"
else
    echo "🚨 Erro: Arquivo 'versions.env' não encontrado."
    exit 1
fi

readonly DOCKER_IMAGE_TAG="${SMARTVIEW_VERSION}"
readonly DOCKER_TAG="${DOCKER_USER}/${SMARTVIEW_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

DOCKER_PROGRESS_MODE="${1:-auto}"
DOCKER_PROGRESS_MODE=$(echo "$DOCKER_PROGRESS_MODE" | tr '[:upper:]' '[:lower:]')

CURRENT_DIR_NAME=$(basename "$PWD")

echo "🎯 Verificando o ambiente de execução..."

if [ "$CURRENT_DIR_NAME" == "$REQUIRED_DIR_NAME" ]; then
    echo "✅ Diretório validado: Executando em '$CURRENT_DIR_NAME'."
elif [ -d "$REQUIRED_DIR_NAME" ]; then
    echo "➡️ Diretório '$REQUIRED_DIR_NAME' encontrado. Acessando..."
    cd "$REQUIRED_DIR_NAME"
    echo "✅ Movido com sucesso. Diretório atual: $(basename "$PWD")"
else
    echo "🚨 ERRO DE AMBIENTE: Este script deve ser executado *dentro* do diretório **'$REQUIRED_DIR_NAME'** ou em um diretório que o **contenha**." >&2
    exit 1
fi

echo "🚀 Iniciando processo de build..."
echo "ℹ️ Docker Tag Completa: $DOCKER_TAG"
echo "ℹ️ Docker Progress Mode: $DOCKER_PROGRESS_MODE"
echo "🔍 Verificando o diretório '${TOTVS_DIR}'..."

while [ ! -f "./totvs/smartview.tar.gz" ]; do
    echo "⏳ Arquivo não encontrado. Executando setup..."
    
    current_directory=$(pwd)
    cd ../
    ./scripts/build/setup.sh smartview
    cd "$current_directory"
    
    sleep 2
done

if [ -f "./totvs/smartview.tar.gz" ]; then
    echo "✅ Arquivo 'smartview.tar.gz' localizado."
else
    echo "❌ Erro: Arquivo smartview.tar.gz não encontrado."
    exit 1
fi

echo "🐳 Iniciando Docker build..."
docker build --progress="$DOCKER_PROGRESS_MODE" -t "$DOCKER_TAG" .
echo "✅ Docker build finalizado com sucesso. Imagem: $DOCKER_TAG"

echo "✅ Processo de build finalizado com sucesso!"
