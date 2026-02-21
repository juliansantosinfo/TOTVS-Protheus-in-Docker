#!/bin/bash
# ==============================================================
# Script: oracle-setup.sh
# Descrição: Instala o Oracle Instant Client e driver ODBC.
# Autor: Julian de Almeida Santos
# ==============================================================

set -e

PKG_MGR=$(command -v dnf || command -v microdnf)

echo "🚀 Iniciando instalação do Oracle Instant Client e driver ODBC..."

# --- Instala o Instant Client (Basic, ODBC, SQL*Plus) ---
echo "🧩 Instalando Oracle Instant Client (Basic, ODBC, SQL*Plus)..."

if command -v dnf > /dev/null 2>&1; then
    # --- Instala o repositório do Oracle Instant Client ---
    echo "🔄 Instalando repositório do Oracle Instant Client..."
    curl -o oracle-instantclient-basic-21.21.0.0.0-1.el8.x86_64.rpm  https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient21/x86_64/getPackage/oracle-instantclient-basic-21.21.0.0.0-1.el8.x86_64.rpm
    curl -o oracle-instantclient-sqlplus-21.21.0.0.0-1.el8.x86_64.rpm  https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient21/x86_64/getPackage/oracle-instantclient-sqlplus-21.21.0.0.0-1.el8.x86_64.rpm
    curl -o oracle-instantclient-devel-21.21.0.0.0-1.el8.x86_64.rpm  https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient21/x86_64/getPackage/oracle-instantclient-devel-21.21.0.0.0-1.el8.x86_64.rpm

    # --- Instala o repositório do Oracle Instant Client ---
    echo "🔄 Instalando dependencias do Oracle Instant Client..."
    $PKG_MGR localinstall -y oracle-instantclient-basic-21.21.0.0.0-1.el8.x86_64.rpm 
    $PKG_MGR localinstall -y oracle-instantclient-sqlplus-21.21.0.0.0-1.el8.x86_64.rpm 
    $PKG_MGR localinstall -y oracle-instantclient-devel-21.21.0.0.0-1.el8.x86_64.rpm

    rm -rf oracle-instantclient-basic-21.21.0.0.0-1.el8.x86_64.rpm 
    rm -rf oracle-instantclient-sqlplus-21.21.0.0.0-1.el8.x86_64.rpm 
    rm -rf oracle-instantclient-devel-21.21.0.0.0-1.el8.x86_64.rpm
else
    # --- Instala o repositório do Oracle Instant Client ---
    echo "🔄 Instalando repositório do Oracle Instant Client..."
    $PKG_MGR install -y \
        oracle-instantclient-release-el8

    # --- Instala o repositório do Oracle Instant Client ---
    echo "🔄 Instalando dependencias do Oracle Instant Client..."
    $PKG_MGR install -y \
        libaio \
        oracle-instantclient-basic \
        oracle-instantclient-odbc \
        oracle-instantclient-sqlplus
fi

# --- Finalização ---
echo "✅ Instalação concluída com sucesso!"
echo
