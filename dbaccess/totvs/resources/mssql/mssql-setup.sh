#!/bin/bash
# ==============================================================
# Script: mssql-setup.sh
# Descrição: Instala o driver ODBC e sqlcmd para o MSSQL 2019 no Oracle Linux 8-slim, com microdnf.
# Autor: Julian de Almeida Santos
# ==============================================================
# Este script executa os seguintes passos:
#   1. Instalando drive ODBC e SQLCMD para MSSQL 2019 via arquivo mssql-odbc.tar.gz
# ==============================================================

set -e  # Encerra o script em caso de erro

echo "🚀 Iniciando instalação do driver ODBC e sqlcmd para o MSSQL 2019..."

# --- Extrai drive ODBC e SQLCMD para MSSQL 2019 no diretorio de intacao padrao.
echo "📦 Instalando drive ODBC e SQLCMD para MSSQL 2019 via arquivo mssql-odbc.tar.gz"
tar  -xzf /totvs/resources/mssql/mssql-odbc.tar.gz -C /

# --- Finalização ---
echo "✅ Instalação concluída com sucesso!"
echo
