#!/bin/bash
# ==============================================================
# Script: postgresql-setup.sh
# Descrição: Instala o driver ODBC e PSQL para o PostgreSQL 15 no Oracle Linux 8-slim, com microdnf.
# Autor: Julian de Almeida Santos
# ==============================================================
# Este script executa os seguintes passos:
#   1. Atualiza pacotes do sistema
#   2. Baixa e instala o repositório oficial do PostgreSQL 15 (PGDG)
#   3. Desabilita o PostgreSQL nativo do Oracle Linux
#   4. Instala o PostgreSQL 15 driver ODBC correspondente
#   5. Limpa o cache e arquivos temporários
# ==============================================================

set -e  # Encerra o script em caso de erro

echo "🚀 Iniciando instalação do driver ODBC e PSQL para o PostgreSQL 15..."

# --- Atualiza pacotes do sistema ---
echo "🔄 Atualizando pacotes..."
microdnf update -y

# --- Baixa o repositório oficial do PostgreSQL ---
if [[ ! -f /totvs/resources/postgresql/pgdg-redhat-repo-latest.noarch.rpm ]]; then
    echo "🌐 Baixando repositório oficial do PostgreSQL 15..."
    wget -O /totvs/resources/postgresql/pgdg-redhat-repo-latest.noarch.rpm https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
fi

# --- Instala o repositório PGDG ---
echo "📁 Instalando repositório PGDG..."
rpm -ivh /totvs/resources/postgresql/pgdg-redhat-repo-latest.noarch.rpm

# --- Desabilita o módulo PostgreSQL nativo ---
echo "⚙️  Desabilitando módulo PostgreSQL nativo..."
microdnf module disable -y postgresql || true

# --- Instala o PostgreSQL 15 driver ODBC ---
echo "🧩 Instalando PostgreSQL 15 e driver ODBC..."
microdnf install -y postgresql15-odbc

# --- Limpa cache e remove arquivos temporários ---
echo "🧹 Limpando cache..."
microdnf clean all
rm -f pgdg-redhat-repo-latest.noarch.rpm

# --- Finalização ---
echo "✅ Instalação concluída com sucesso!"
