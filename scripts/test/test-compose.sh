#!/bin/bash
#
# ==============================================================================
# SCRIPT: test-compose.sh
# DESCRIÇÃO: Automatiza a validação de sintaxe e testes de inicialização (smoke test)
#            de todos os arquivos docker-compose do projeto.
# AUTOR: Julian de Almeida Santos
# DATA: 2026-02-16
# USO: ./scripts/validation/test-compose.sh [--full]
#      --full: Realiza o teste de 'up/down' além da validação de sintaxe.
# ==============================================================================

set -euo pipefail

# --- Configurações ---
COMPOSE_FILES=(
    "docker-compose.yaml"
    "docker-compose-postgresql.yaml"
    "docker-compose-mssql.yaml"
    "docker-compose-oracle.yaml"
)
TEST_PROJECT_NAME="totvs-smoke-test"
FULL_TEST=false

if [[ "${1:-}" == "--full" ]]; then
    FULL_TEST=true
fi

# --- Preparação ---
if [ ! -f .env ]; then
    echo "⚠️  Arquivo .env não encontrado. Utilizando .env.example para os testes..."
    cp .env.example .env
fi

# --- Funções ---

run_smoke_test() {
    local file=$1
    echo "🚀 Iniciando Smoke Test (UP/DOWN) para: $file"
    
    # Tenta subir a stack com profile full para testar tudo
    if ! docker compose -p "$TEST_PROJECT_NAME" -f "$file" --profile full up -d; then
        echo "❌ FALHA: Erro ao executar 'docker compose up'"
        return 1
    fi

    echo "⏳ Aguardando serviços ficarem saudáveis (timeout 240s)..."
    local timeout=240
    local count=0
    local all_healthy=false

    while [ $count -lt $timeout ]; do
        # Verifica se há containers não saudáveis (excluindo os que não tem healthcheck)
        local unhealthy
        unhealthy=$(docker compose -p "$TEST_PROJECT_NAME" ps --format json | jq -r 'select(.Health != "healthy" and .Health != "") | .Name')
        
        if [ -z "$unhealthy" ]; then
            all_healthy=true
            break
        fi
        
        sleep 5
        count=$((count + 5))
        echo "   ... aguardando ($count/s)"
    done

    if [ "$all_healthy" = true ]; then
        echo "✅ SUCESSO: Todos os serviços estão saudáveis."
        local status=0
    else
        echo "❌ FALHA: Timeout atingido. Alguns serviços não ficaram saudáveis."
        docker compose -p "$TEST_PROJECT_NAME" ps
        local status=1
    fi

    echo "🧹 Limpando ambiente de teste..."
    docker compose -p "$TEST_PROJECT_NAME" -f "$file" --profile full kill > /dev/null 2>&1
    docker compose -p "$TEST_PROJECT_NAME" -f "$file" --profile full down -v > /dev/null 2>&1
    return $status
}

# --- Execução ---

echo "=========================================================="
echo "🧪 INICIANDO VALIDAÇÃO DE DOCKER COMPOSE"
echo "=========================================================="

# 1. Validação de Sintaxe (Modular)
if ! ./scripts/validation/lint-compose.sh; then
    echo "🛑 Abortando testes de runtime devido a erros de sintaxe."
    exit 1
fi

# 2. Testes de Inicialização (se solicitado)
if [ "$FULL_TEST" = true ]; then
    echo ""
    echo "--- Etapa: Smoke Tests de Inicialização ---"
    
    FAILED_FILES=()

    for file in "${COMPOSE_FILES[@]}"; do
        if [ ! -f "$file" ]; then
            echo "⚠️  Arquivo não encontrado: $file (Pulando)"
            continue
        fi

        if ! run_smoke_test "$file"; then
            FAILED_FILES+=("$file (Runtime)")
        fi
    done

    echo ""
    echo "=========================================================="
    echo "📊 RESUMO DO TESTE DE RUNTIME"
    echo "=========================================================="

    if [ ${#FAILED_FILES[@]} -eq 0 ]; then
        echo "🎉 SUCESSO: Todas as stacks iniciaram corretamente!"
        exit 0
    else
        echo "🛑 FALHA: As seguintes stacks apresentaram problemas:"
        for failed in "${FAILED_FILES[@]}"; do
            echo "   - $failed"
        done
        exit 1
    fi
fi

exit 0
