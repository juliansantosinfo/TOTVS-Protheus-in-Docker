#!/bin/bash

######################################################################
# SCRIPT:      setup-build.sh
# DESCRIÇÃO:   Instala dependências para container TOTVS DbAccess no 
#              Oracle Linux 8-slim, com microdnf.
# AUTOR:       Julian de Almeida Santos
# DATA:        2025-10-18
#
# OBJETIVOS:
# - Atualizar pacotes do sistema
# - Instalar dependências básicas (unixODBC, wget, etc.)
# - Copiar arquivos de configuração ODBC
# - Configurar permissões de execução para scripts de entrypoint e setup
#
######################################################################

set -e  # Encerra o script em caso de erro

#---------------------------------------------------------------------

## 🚀 INÍCIO DA INSTALAÇÃO DE DEPENDÊNCIAS

    echo ""
    echo "======================================================"
    echo "🚀 INÍCIO DA INSTALAÇÃO DE DEPENDÊNCIAS BASE E ODBC"
    echo "======================================================"

    echo "⚙️ Iniciando instalação de dependências..."

#---------------------------------------------------------------------

## 🚀 ATUALIZAÇÃO DE PACOTES

    echo ""
    echo "------------------------------------------------------"
    echo "🔄 ATUALIZANDO PACOTES DO SISTEMA"
    echo "------------------------------------------------------"
    
    echo "⚙️ Executando microdnf update..."
    microdnf update -y
    
    if [ $? -eq 0 ]; then
        echo "✅ Pacotes atualizados com sucesso."
    else
        echo "❌ ERRO ao atualizar pacotes."
        exit 1
    fi

#---------------------------------------------------------------------

## 🚀 INSTALAÇÃO DE DEPENDÊNCIAS BÁSICAS E ODBC

    echo ""
    echo "------------------------------------------------------"
    echo "📦 INSTALAÇÃO DE DEPENDÊNCIAS"
    echo "------------------------------------------------------"
    
    DEPENDENCIAS="gzip iputils nano wget unixODBC unixODBC-devel"
    echo "⚙️ Instalando dependências: **$DEPENDENCIAS**..."
    
    microdnf install -y $DEPENDENCIAS
    
    if [ $? -eq 0 ]; then
        echo "✅ Dependências instaladas com sucesso."
    else
        echo "❌ ERRO ao instalar dependências. O script será encerrado."
        exit 1
    fi

#---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DE ARQUIVOS ODBC

    echo ""
    echo "------------------------------------------------------"
    echo "📝 CONFIGURAÇÃO DE ARQUIVOS ODBC"
    echo "------------------------------------------------------"
    
    # --- Copiando arquivos de configuracao para unixODBC
    echo "⚙️ Copiando odbc.ini para diretório padrão (/etc/)..."
    cp /totvs/resources/settings/odbc.ini /etc/odbc.ini
    echo "✅ /etc/odbc.ini copiado."

    echo "⚙️ Copiando odbcinst.ini para diretório padrão (/etc/)..."
    cp /totvs/resources/settings/odbcinst.ini /etc/odbcinst.ini
    echo "✅ /etc/odbcinst.ini copiado."

#---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DE DRIVES ODBC PARA MSSQL

    echo ""
    echo "------------------------------------------------------"
    echo "📝 FIGURAÇÃO DE DRIVES ODBC PARA MSSQL"
    echo "------------------------------------------------------"
    
    if [[ ! -f /totvs/resources/mssql/mssql-setup.sh ]]; then
        echo "❌ Erro: Script de setup do MSSQL não encontrado em /totvs/resources/mssql/mssql-setup.sh"
        exit 1
    fi

    chmod +x /totvs/resources/mssql/mssql-setup.sh

    if [[ ! -f /opt/microsoft/msodbcsql18/lib64/libmsodbcsql-18.3.so.3.1 ]]; then
        echo "⚙️ Biblioteca MSSQL ODBC não encontrada. Executando setup..."
        /totvs/resources/mssql/mssql-setup.sh
        if [ $? -ne 0 ]; then
            echo "❌ Erro ao configurar MSSQL."
            exit 1
        fi
    else
        echo "✅ Biblioteca de Drive MSSQL ODBC já existe. Setup ignorado."
    fi

    if [ $? -ne 0 ]; then
        echo "❌ Erro ao configurar MSSQL."
        exit 1
    fi

    echo "✅ MSSQL Drive ODBC configurado com sucesso."

#---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DE DRIVES ODBC PARA MSSQL

    echo ""
    echo "------------------------------------------------------"
    echo "📝 FIGURAÇÃO DE DRIVES ODBC PARA POSTGRESQL"
    echo "------------------------------------------------------"

    if [[ ! -f /totvs/resources/postgresql/postgresql-setup.sh ]]; then
        echo "❌ Erro: Script de setup do PostgreSQL não encontrado em /totvs/resources/postgresql/postgresql-setup.sh"
        exit 1
    fi

    chmod +x /totvs/resources/postgresql/postgresql-setup.sh

    if [[ ! -f /usr/pgsql-15/lib/psqlodbcw.so ]]; then
        echo "⚙️ Biblioteca PostgreSQL ODBC não encontrada. Executando setup..."
        /totvs/resources/postgresql/postgresql-setup.sh 
        
        if [ $? -ne 0 ]; then
            echo "❌ Erro ao configurar PostgreSQL."
            exit 1
        fi
    else
        echo "✅ Biblioteca PostgreSQL ODBC já existe. Setup ignorado."
    fi

    echo "✅ PostgreSQL Drive ODBC configurado com sucesso."

#---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DE PERMISSÕES DE EXECUÇÃO

    echo ""
    echo "------------------------------------------------------"
    echo "⚙️ CONFIGURAÇÃO DE PERMISSÕES DE EXECUÇÃO"
    echo "------------------------------------------------------"
    
    echo "⚙️ Aplicando permissões (+x) para scripts..."
    
    chmod +x /entrypoint.sh
    echo "✅ Permissão aplicada a /entrypoint.sh"

    chmod +x /totvs/resources/mssql/mssql-setup.sh
    echo "✅ Permissão aplicada a /totvs/resources/mssql/mssql-setup.sh"
    
    chmod +x /totvs/resources/postgresql/postgresql-setup.sh
    echo "✅ Permissão aplicada a /totvs/resources/postgresql/postgresql-setup.sh"

#---------------------------------------------------------------------

## 🚀 FINALIZAÇÃO

    echo ""
    echo "======================================================"
    echo "✅ INSTALAÇÃO DE DEPENDÊNCIAS CONCLUÍDA COM SUCESSO!"
    echo "======================================================"
    echo