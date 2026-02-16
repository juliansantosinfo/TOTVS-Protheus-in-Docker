#!/bin/bash
#
# ==============================================================================
# SCRIPT: healthcheck.sh
# DESCRIÇÃO: Valida a saúde do serviço PostgreSQL dentro do container.
# AUTOR: Julian de Almeida Santos
# DATA: 2026-02-16
# USO: ./healthcheck.sh
# ==============================================================================

# Ativa modo de depuração se a variável DEBUG_SCRIPT estiver como true/1/yes
if [[ "${DEBUG_SCRIPT:-}" =~ ^(true|1|yes|y)$ ]]; then
    set -x
fi

# Garante que o script será encerrado em caso de erro
set -e

# Executa o utilitário oficial do PostgreSQL para verificar o status
# -U: Usuário (postgres por padrão ou variável de ambiente)
# -d: Banco de dados
if pg_isready -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-protheus}" > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi
