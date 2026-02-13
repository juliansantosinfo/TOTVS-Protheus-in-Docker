#!/bin/bash
# ==============================================================
# Script: oracle-setup.sh
# Descrição: Instala o Oracle Instant Client e driver ODBC para o Oracle no Oracle Linux 8-slim.
# Autor: Julian de Almeida Santos
# ==============================================================

set -e

echo "🚀 Iniciando instalação do Oracle Instant Client e driver ODBC..."

# --- Instala o repositório do Oracle Instant Client ---
echo "🔄 Instalando repositório do Oracle Instant Client..."
microdnf install -y oracle-instantclient-release-el8

# --- Instala o Instant Client (Basic, ODBC, SQL*Plus) ---
echo "🧩 Instalando Oracle Instant Client (Basic, ODBC, SQL*Plus)..."
microdnf install -y oracle-instantclient-basic \
                 oracle-instantclient-odbc \
                 oracle-instantclient-sqlplus

# --- Limpa cache ---
echo "🧹 Limpando cache..."
microdnf clean all

# --- Finalização ---
echo "✅ Instalação concluída com sucesso!"
echo
