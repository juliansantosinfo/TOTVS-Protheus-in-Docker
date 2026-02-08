#!/bin/bash
# ==============================================================================
# SCRIPT: lint-dockerfile.sh
# DESCRIÇÃO: Executa Hadolint em todos os Dockerfiles do projeto.
# ==============================================================================

if ! command -v hadolint &> /dev/null; then
    echo "⚠️  Hadolint não encontrado. Pule este passo ou instale: https://github.com/hadolint/hadolint"
    exit 0
fi

echo "🔍 Executando Hadolint..."

# Encontra arquivos chamados 'dockerfile' (case insensitive)
FILES=$(find . -iname "dockerfile" -not -path "./.git/*")

if [ -z "$FILES" ]; then
    echo "✅ Nenhum Dockerfile encontrado."
    exit 0
fi

echo "$FILES" | xargs hadolint

if [ $? -eq 0 ]; then
    echo "✅ Hadolint passou."
    exit 0
else
    echo "❌ Hadolint encontrou problemas."
    exit 1
fi
