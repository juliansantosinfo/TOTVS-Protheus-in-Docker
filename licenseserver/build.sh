#!/bin/bash
#
# ==============================================================================
# SCRIPT: build.sh (Versão Final e Completa)
# DESCRIÇÃO: Responsável por realizar o build da imagem Docker para o serviço DBAccess
#            TOTVS e restaurar ou atualizar dependências da aplicação.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-12
# USO: ./build.sh [plain | auto | tty]
#      - Argumento 1 (progress): Controla o formato do output do Docker (padrão: auto).
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
# -e: Sai imediatamente se um comando falhar.
# -u: Trata variáveis não definidas como erro.
# -o pipefail: Garante que um pipeline (ex: cat | tar) falhe se qualquer comando falhar.
set -euo pipefail

# --- Variáveis de Configuração Global ---
readonly REQUIRED_DIR_NAME="licenseserver"
readonly TOTVS_DIR="./totvs"

# --- Componentes da Docker Tag (Separados para fácil manutenção) ---
readonly DOCKER_USER="juliansantosinfo"
readonly DOCKER_IMAGE_NAME="totvs_licenseserver"
readonly DOCKER_IMAGE_TAG="3.6.1"
readonly DOCKER_TAG="${DOCKER_USER}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

# Argumento 1: Modo de Progresso do Docker Build (padrão: auto)
# Se não for fornecido, usa 'auto'. Se for fornecido, usa o valor, convertido para minúsculas.
DOCKER_PROGRESS_MODE="${1:-auto}"
DOCKER_PROGRESS_MODE=$(echo "$DOCKER_PROGRESS_MODE" | tr '[:upper:]' '[:lower:]')

# ----------------------------------------------------
#               SEÇÃO 0: VALIDAÇÃO E ACESSO AO DIRETÓRIO
# ----------------------------------------------------

# Obtém o nome do diretório atual.
CURRENT_DIR_NAME=$(basename "$PWD")

echo "🎯 Verificando o ambiente de execução..."

# 1. Verifica se já estamos no diretório correto.
if [ "$CURRENT_DIR_NAME" == "$REQUIRED_DIR_NAME" ]; then
    echo "✅ Diretório validado: Executando em '$CURRENT_DIR_NAME'."

# 2. Verifica se o subdiretório 'appserver' existe no local atual.
elif [ -d "$REQUIRED_DIR_NAME" ]; then
    echo "➡️ Diretório '$REQUIRED_DIR_NAME' encontrado. Acessando..."
    # Acessa o diretório. O 'set -e' garantirá que o script pare se o 'cd' falhar.
    cd "$REQUIRED_DIR_NAME"
    echo "✅ Movido com sucesso. Diretório atual: $(basename "$PWD")"

# 3. Caso contrário, é um erro.
else
    echo "🚨 ERRO DE AMBIENTE: Este script deve ser executado *dentro* do diretório **'$REQUIRED_DIR_NAME'** ou em um diretório que o **contenha**." >&2
    echo "    Diretório atual: '$CURRENT_DIR_NAME'" >&2
    echo "    Por favor, corrija sua localização e tente novamente." >&2
    exit 1 # Sai com código de erro.
fi

# ----------------------------------------------------
#               SEÇÃO 1: PREPARAÇÃO DOS RECURSOS
# ----------------------------------------------------

echo "🚀 Iniciando processo de build..."
echo "ℹ️ Docker Tag Completa: $DOCKER_TAG"
echo "ℹ️ Docker Progress Mode: $DOCKER_PROGRESS_MODE"
echo "🔍 Verificando o diretório '${TOTVS_DIR}'..."

# Verifica se os recursos existem.
while [ ! -d "./totvs/licenseserver" ]; do
    echo "⏳ Diretório não encontrado. Executando setup..."
    
    # Executa o setup.sh a partir do diretório onde ele está localizado
    current_directory=$(pwd)
    cd ../
    ./scripts/setup.sh licenseserver
    cd "$current_directory"

    # Pequena pausa para evitar loop excessivo
    sleep 2
done

if [  -d "./totvs/licenseserver" ]; then
    echo "✅ Diretório 'licenseserver' localizado."
else
    echo "❌ Erro: Diretório 'licenseserver' não encontrado."
    exit 1
fi

# ----------------------------------------------------
#               SEÇÃO 2: EXECUÇÃO DO DOCKER BUILD
# ----------------------------------------------------

echo "🐳 Iniciando Docker build..."
# Executa o comando docker build, usando as flags para um build limpo e output legível.
# Usa a variável $DOCKER_TAG reconstruída.
docker build --progress="$DOCKER_PROGRESS_MODE" -t "$DOCKER_TAG" .
echo "✅ Docker build finalizado com sucesso. Imagem: $DOCKER_TAG"

echo "✅ Processo de build finalizado com sucesso!"