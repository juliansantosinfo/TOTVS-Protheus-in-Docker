#!/bin/bash
#
# ==============================================================================
# SCRIPT: healthcheck.sh
# DESCRIÇÃO: Valida a saúde do serviço DBAccess testando a conectividade ODBC.
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

# Utiliza o isql para testar a conexão com o alias configurado
# -b: Batch mode (não interativo)
if echo "quit;" | isql -b "${DATABASE_ALIAS:-protheus}" "${DATABASE_USERNAME}" "${DATABASE_PASSWORD}" > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi
