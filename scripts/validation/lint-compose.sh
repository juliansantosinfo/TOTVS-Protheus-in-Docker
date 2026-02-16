#!/bin/bash
#
# ==============================================================================
# SCRIPT: lint-compose.sh
# DESCRIÇÃO: Valida a sintaxe de todos os arquivos Docker Compose encontrados
#            na raiz do projeto utilizando 'docker compose config'.
# AUTOR: Julian de Almeida Santos
# DATA: 2026-02-16
# USO: ./scripts/validation/lint-compose.sh
# ==============================================================================

# Ativa modo de depuração se a variável DEBUG_SCRIPT estiver como true/1/yes
if [[ "${DEBUG_SCRIPT:-}" =~ ^(true|1|yes|y)$ ]]; then
    set -x
fi

set -euo pipefail

echo "🔍 Validando sintaxe dos arquivos Docker Compose..."

# Garante que estamos na raiz do projeto (ajuste se necessário dependendo de onde o script é chamado)
# Se o script for chamado de dentro de scripts/validation, sobe dois níveis
if [[ $(basename "$PWD") == "validation" ]]; then
    cd ../..
fi

# Encontra arquivos docker-compose*.yml ou *.yaml na raiz
# Usamos ls para facilitar a iteração mas com tratamento para diretórios vazios
COMPOSE_FILES=$(ls docker-compose*.yaml docker-compose*.yml 2>/dev/null || true)

if [ -z "$COMPOSE_FILES" ]; then
    echo "✅ Nenhum arquivo Docker Compose encontrado para validar."
    exit 0
fi

EXIT_CODE=0

for file in $COMPOSE_FILES; do
    echo -n "   - $file... "
    # O comando 'config' valida sintaxe e interpolação de variáveis
    if docker compose -f "$file" config > /dev/null 2>&1; then
        echo "✅"
    else
        echo "❌"
        echo "🛑 Erro de sintaxe detectado em: $file"
        EXIT_CODE=1
    fi
done

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Todos os arquivos Docker Compose são válidos."
    exit 0
else
    echo "❌ Falha na validação de sintaxe."
    exit 1
fi
