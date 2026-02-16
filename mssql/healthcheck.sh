#!/bin/bash
#
# ==============================================================================
# SCRIPT: healthcheck.sh
# DESCRIÇÃO: Valida a saúde do serviço SQL Server dentro do container.
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

# O sqlcmd no MSSQL 2019 fica neste caminho no Ubuntu
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"

# Se o diretório for diferente (versões mais novas), tenta localizar
if [ ! -f "$SQLCMD" ]; then
    SQLCMD=$(which sqlcmd)
fi

# Executa uma query simples para validar a conexão
# -S: Server (localhost)
# -U: User (sa)
# -P: Password (variável de ambiente)
# -Q: Query
# -C: Trust Server Certificate
if "$SQLCMD" -S localhost -U sa -P "${SA_PASSWORD}" -C -Q "SELECT 1" > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi
