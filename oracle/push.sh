#!/bin/bash
#
# ==============================================================================
# SCRIPT: push.sh
# DESCRIÇÃO: Envia a imagem Docker do Oracle Database TOTVS para o Docker Hub.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-12
# USO: ./push.sh
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
# -e: Sai imediatamente se um comando falhar.
# -u: Trata variáveis não definidas como erro.
# -o pipefail: Garante que um pipeline (ex: cat | tar) falhe se qualquer comando falhar.
set -euo pipefail

# 1. Navegar para o diretório do script para garantir caminhos relativos corretos
cd "$(dirname "$0")"

# 2. Carregar Configuração Centralizada (esperado no diretório pai)
if [ -f "../versions.env" ]; then
    source "../versions.env"
else
    echo "🚨 Erro: Arquivo '../versions.env' não encontrado."
    exit 1
fi

# 3. Determinar variáveis específicas deste serviço
IMAGE_TAG="${ORACLE_VERSION}"
IMAGE_NAME="${ORACLE_IMAGE_NAME}"

if [ -z "$IMAGE_TAG" ] || [ -z "$IMAGE_NAME" ] || [ -z "$DOCKER_USER" ]; then
    echo "🚨 Erro: Configurações incompletas em versions.env"
    exit 1
fi

FULL_TAG="${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
LATEST_TAG="${DOCKER_USER}/${IMAGE_NAME}:latest"

echo "--------------------------------------------------"
echo "Pushing image: $FULL_TAG"
echo "--------------------------------------------------"
docker push "$FULL_TAG"

# 4. Push da tag 'latest' apenas se PUSH_LATEST for true
# No GitHub Actions, definiremos isso com base na branch.
# Localmente, o padrão é true para facilitar.
if [ "${PUSH_LATEST:-true}" = "true" ]; then
    echo "--------------------------------------------------"
    echo "Tagging and pushing: $LATEST_TAG"
    echo "--------------------------------------------------"
    docker tag "$FULL_TAG" "$LATEST_TAG"
    docker push "$LATEST_TAG"
    echo "✅ Successfully pushed $FULL_TAG and $LATEST_TAG"
else
    echo "⏭️ Skipping 'latest' tag push (PUSH_LATEST is false)"
    echo "✅ Successfully pushed $FULL_TAG"
fi
