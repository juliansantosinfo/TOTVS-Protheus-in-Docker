#!/bin/bash

######################################################################
# SCRIPT:      setup-dbaccess.sh
# DESCRIÇÃO:   Inicializa e configura o serviço TOTVS DBAccess.
# AUTOR:       Julian de Almeida Santos
# DATA:        2025-10-18
#
# VARIAVEIS DE AMBIENTE REQUERIDAS:
# - DATABASE_PROFILE....: Define o SGBD a ser configurado (MSSQL ou POSTGRES).
# - DATABASE_ALIAS      : Define Alias ODBC.
# - DATABASE_SERVER     : Define host para o Servidor de Banco de Dados.
# - DATABASE_PORT       : Define porta para o Servidor de Banco de Dados.
# - DATABASE_NAME       : Define nome do Banco de Dados.
# - DATABASE_USERNAME   : Define usuário para o Servidor de Banco de Dados.
# - DATABASE_PASSWORD   : Define senha para o Servidor de Banco de Dados.
#
######################################################################

title="TOTVS DBAccess 23.1.1.4"
prog="dbaccess64"
pathbin="/totvs/dbaccess/multi"
progbin="${pathbin}/${prog}"
inifile="${pathbin}/dbaccess.ini"
export LD_LIBRARY_PATH="${pathbin}:${LD_LIBRARY_PATH}"

#---------------------------------------------------------------------

## 🚀 FUNÇOES AUXILIARES

    # Define a função de tratamento de erro para variáveis de ambiente
    check_env_vars() {
        local var_name=$1
        if [[ -z "${!var_name}" ]]; then
            echo "❌ ERRO: A variável de ambiente **${var_name}** não está definida. O script será encerrado."
            exit 1
        fi
    }

#---------------------------------------------------------------------

## 🚀 INÍCIO DA VERIFICAÇÃO DE VARIÁVEIS DE AMBIENTE

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DA VERIFICAÇÃO DE VÁRIAVEIS DE AMBIENTE"
    echo "------------------------------------------------------"

    echo "🔎 Verificando váriaveis de ambiente requeridas..."

    check_env_vars "DATABASE_PROFILE"
    echo "🔎 DATABASE_PROFILE... ✅"

    check_env_vars "DATABASE_SERVER"
    echo "🔎 DATABASE_SERVER... ✅"

    check_env_vars "DATABASE_PORT"
    echo "🔎 DATABASE_PORT... ✅"

    check_env_vars "DATABASE_ALIAS"
    echo "🔎 DATABASE_ALIAS... ✅"

    check_env_vars "DATABASE_NAME"
    echo "🔎 DATABASE_NAME... ✅"

    check_env_vars "DATABASE_USERNAME"
    echo "🔎 DATABASE_USERNAME... ✅"

    check_env_vars "DATABASE_PASSWORD"
    echo "🔎 DATABASE_PASSWORD... ✅"

    echo "✅ Todas as variáveis de ambiente requeridas verificadas com sucesso."

#---------------------------------------------------------------------

## 🚀 INÍCIO DA CONFIGURAÇÃO DO DBACCESS.INI

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DA CONFIGURAÇÃO DO DBACCESS.INI"
    echo "------------------------------------------------------"
    echo "⚙️ Iniciando configuração do arquivo .ini..."

    if [[ ! -f "/totvs/resources/settings/dbaccess.ini" ]]; then
        echo "❌ ERRO: Arquivo de configuração **dbaccess.ini** não encontrado em /totvs/resources/settings. O script será encerrado."
        exit 1
    fi

    cp -f /totvs/resources/settings/dbaccess.ini "$inifile"
    echo "✅ Arquivo base copiado para **$inifile**."

    echo "⚙️ Aplicando substituições de variáveis..."
    sed -i "s,DBACCESS_LICENSE_SERVER,${DBACCESS_LICENSE_SERVER},g" "$inifile"
    sed -i "s,DBACCESS_LICENSE_PORT,${DBACCESS_LICENSE_PORT},g" "$inifile"
    sed -i "s,DBACCESS_CONSOLEFILE,${DBACCESS_CONSOLEFILE},g" "$inifile"
    sed -i "s,DATABASE_CLIENT_LIBRARY_MSSQL,${DATABASE_CLIENT_LIBRARY_MSSQL},g" "$inifile"
    sed -i "s,DATABASE_CLIENT_LIBRARY_POSTGRES,${DATABASE_CLIENT_LIBRARY_POSTGRES},g" "$inifile"
    sed -i "s,DATABASE_CLIENT_LIBRARY_ORACLE,${DATABASE_CLIENT_LIBRARY_ORACLE},g" "$inifile"
    
    echo "✅ Variáveis substituídas no $inifile."

#---------------------------------------------------------------------

## 🚀 INÍCIO DA CONFIGURAÇÃO DO DBACCESS

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DA CONFIGURAÇÃO DO DBACCESS"
    echo "------------------------------------------------------"

    if [[ ! -x "/totvs/dbaccess/tools/dbaccesscfg" ]]; then
        echo "❌ ERRO: Ferramenta **dbaccesscfg** não encontrada ou sem permissão de execução. O script será encerrado."
        exit 1
    fi

    echo "⚙️ Configurando alias do DBAccess usando dbaccesscfg..."
    cd /totvs/dbaccess/multi/

    case "${DATABASE_PROFILE}" in
        MSSQL)
            echo "⚙️ Executando dbaccesscfg para MSSQL..."
            /totvs/dbaccess/tools/dbaccesscfg -u "${DATABASE_USERNAME}" -p "${DATABASE_PASSWORD}" -d mssql -a "${DATABASE_ALIAS}"
            if [ $? -eq 0 ]; then
                echo "✅ Configuração MSSQL do DBAccess concluída para o alias **${DATABASE_ALIAS}**."
            else
                echo "❌ ERRO ao configurar MSSQL com dbaccesscfg. O script será encerrado."
                exit 1
            fi
            ;;
        POSTGRES)
            echo "⚙️ Executando dbaccesscfg para POSTGRES..."
            /totvs/dbaccess/tools/dbaccesscfg -u "${DATABASE_USERNAME}" -p "${DATABASE_PASSWORD}" -d postgres -a "${DATABASE_ALIAS}"
            if [ $? -eq 0 ]; then
                echo "✅ Configuração PostgreSQL do DBAccess concluída para o alias **${DATABASE_ALIAS}**."
            else
                echo "❌ ERRO ao configurar PostgreSQL com dbaccesscfg. O script será encerrado."
                exit 1
            fi
            ;;
        ORACLE)
            echo "⚙️ Executando dbaccesscfg para ORACLE..."
            /totvs/dbaccess/tools/dbaccesscfg -u "${DATABASE_USERNAME}" -p "${DATABASE_PASSWORD}" -d oracle -a "${DATABASE_ALIAS}"
            if [ $? -eq 0 ]; then
                echo "✅ Configuração ORACLE do DBAccess concluída para o alias **${DATABASE_ALIAS}**."
            else
                echo "❌ ERRO ao configurar ORACLE com dbaccesscfg. O script será encerrado."
                exit 1
            fi
            ;;
        *)
            echo "❌ ERRO: Profile de banco de dados inválido (**${DATABASE_PROFILE}**) ou não suportado (apenas MSSQL ou POSTGRES). O script será encerrado."
            exit 1
            ;;
    esac

    cd /totvs
    echo "✅ Fim da configuração do DBAccess."

#---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DE LIMITES (ULIMIT)

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DA CONFIGURAÇÃO DE LIMITES (ULIMIT)"
    echo "------------------------------------------------------"

    echo "⚙️ Aplicando limites de recursos (ulimit)..."

    ulimit -n 65536            # open files
    ulimit -s 1024             # stack size
    ulimit -c unlimited        # core file size
    ulimit -f unlimited        # file size
    ulimit -t unlimited        # cpu time
    ulimit -v unlimited        # virtual memory

    echo "✅ Limites aplicados com sucesso."

#---------------------------------------------------------------------

## 🚀 INÍCIO DA INICIALIZAÇÃO DO SERVIÇO

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DA INICIALIZAÇÃO DO SERVIÇO"
    echo "------------------------------------------------------"

    echo "🚀 Iniciando **${title}**..."
    # A linha 'exec' substitui o processo shell atual pelo DBAccess, mantendo o PID 1 no container.
    exec "${progbin}"