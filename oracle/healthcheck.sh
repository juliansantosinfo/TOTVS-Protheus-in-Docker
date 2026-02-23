#!/bin/bash
#
# ==============================================================================
# SCRIPT: healthcheck.sh
# DESCRIÇÃO: Valida a saúde do serviço AppServer/Rest Protheus.
# AUTOR: Julian de Almeida Santos
# DATA: 2026-02-16
# USO: ./healthcheck.sh
# ==============================================================================

# Ativa modo de depuração se a variável DEBUG_SCRIPT estiver como true/1/yes
if [[ "${DEBUG_SCRIPT:-}" =~ ^(true|1|yes|y)$ ]]; then
    set -x
fi

# Tenta abrir uma conexão TCP na porta selecionada
# Utiliza o bash /dev/tcp para validação leve sem dependências extras
if timeout 1 bash -c "echo > /dev/tcp/localhost/1521" > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi
