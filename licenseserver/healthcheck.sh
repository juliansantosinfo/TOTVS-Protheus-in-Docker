#!/bin/bash
#
# ==============================================================================
# SCRIPT: healthcheck.sh
# DESCRIÇÃO: Valida a saúde do serviço TOTVS License Server.
# AUTOR: Julian de Almeida Santos
# DATA: 2026-02-16
# USO: ./healthcheck.sh
# ==============================================================================

# Ativa modo de depuração se a variável DEBUG_SCRIPT estiver como true/1/yes
if [[ "${DEBUG_SCRIPT:-}" =~ ^(true|1|yes|y)$ ]]; then
    set -x
fi

# Define a porta a ser validada (padrão 5555)
CHECK_PORT="${LICENSE_PORT:-5555}"

# Tenta abrir uma conexão TCP na porta selecionada
# Utiliza o bash /dev/tcp para validação leve
if timeout 1 bash -c "echo > /dev/tcp/localhost/${CHECK_PORT}" > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi
