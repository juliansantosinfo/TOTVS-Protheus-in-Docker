#!/bin/bash

######################################################################
# SCRIPT:      setup-database.sh
# DESCRIÇÃO:   Configura o banco de dados, ambiente e as bibliotecas de 
#              driver ODBC/JDBC com base no perfil de banco de dados (DATABASE_PROFILE).
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

DATABASE_DEFAULT_NAME=""
DATABASE_DEFAULT_ALIAS=""
DATABASE_DEFAULT_PASSWORD="ProtheusDatabasePassword1"

#---------------------------------------------------------------------

## 🚀 FUNÇOES AUXILIARES

    # Define a função de impressao do nome e conteudo da variáveis de ambiente
    check_env_vars() {
        local var_name=$1
        if [[ -z "${!var_name}" ]]; then
            echo "❌ ERRO: A variável de ambiente **${var_name}** não está definida ou está vazia."
            exit 1
        else
            # Exibe o nome e o valor (ou apenas um check, se preferir ocultar segredos)
            echo "🔎 **${var_name}**: ${!var_name} ✅"
        fi
    }
    
#---------------------------------------------------------------------

## 🚀 INÍCIO DA VERIFICAÇÃO DE VARIÁVEIS DE AMBIENTE

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DA VERIFICAÇÃO DE VÁRIAVEIS DE AMBIENTE"
    echo "------------------------------------------------------"

    echo "🔎 Verificando váriaveis de ambiente..."

    check_env_vars "DATABASE_PROFILE"
    check_env_vars "DATABASE_ALIAS"
    check_env_vars "DATABASE_SERVER"
    check_env_vars "DATABASE_PORT"
    check_env_vars "DATABASE_NAME"
    check_env_vars "DATABASE_USERNAME"
    check_env_vars "DATABASE_PASSWORD"
    
    echo "✅ Todas as variáveis de ambiente requeridas verificadas com sucesso."

#---------------------------------------------------------------------

## 🚀 INÍCIO DA CONFIGURAÇÃO DO BANCO DE DADOS

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DA CONFIGURAÇÃO DO BANCO DE DADOS"
    echo "------------------------------------------------------"

    echo "✅ DATABASE_PROFILE detectado: **${DATABASE_PROFILE}**"
    echo "⚙️ Iniciando a configuração do banco de dados..."

    case "${DATABASE_PROFILE}" in
        MSSQL)
            echo "⚙️ Configurando MSSQL..."
            export DATABASE_DEFAULT_NAME="master"
            export DATABASE_DRIVER=MSSQL18
            export DATABASE_CLIENT_LIBRARY_MSSQL=/usr/lib64/libodbc.so
            export SQL_COMMAND_PASSWORD_UPDATE="ALTER ROLE $DATABASE_USERNAME WITH PASSWORD = '${DATABASE_PASSWORD}';"
            export SCRIPT_BASE="/totvs/resources/mssql/mssql-create_database.sql"
            echo "✅ MSSQL configurado com sucesso."
            ;;
            
        POSTGRES)
            echo "⚙️ Configurando POSTGRES..."
            export DATABASE_DEFAULT_ALIAS="POSTGRES"
            export DATABASE_DEFAULT_NAME="postgres"
            export DATABASE_DRIVER=PostgreSQL
            export DATABASE_CLIENT_LIBRARY_POSTGRES=/usr/lib64/libodbc.so
            export SQL_COMMAND_PASSWORD_UPDATE="ALTER LOGIN [$DATABASE_USERNAME] WITH PASSWORD = '${DATABASE_PASSWORD}';"
            export SCRIPT_BASE="/totvs/resources/postgresql/postgresql-create_database.sql"
            echo "✅ PostgreSQL configurado com sucesso."
            ;;
            
        *)
            echo "❌ Erro: Profile de banco de dados inválido (**${DATABASE_PROFILE}**) ou não suportado (apenas MSSQL ou POSTGRES)."
            exit 1
            ;;
    esac

    echo "✅ Fim da configuração do banco de dados."

#---------------------------------------------------------------------

## 🚀 INÍCIO DA CONFIGURAÇÃO DO ODBC

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DA CONFIGURAÇÃO DO ODBC"
    echo "------------------------------------------------------"
    echo "🔎 Verificando a presença do gerenciador de drivers ODBC (libodbc.so)..."

    if [[ ! -f /usr/lib64/libodbc.so ]]; then
        echo "❌ ERRO: A biblioteca ODBC esperada em **/usr/lib64/libodbc.so** não foi encontrada."
        echo "Certifique-se de que o pacote do gerenciador de drivers ODBC (unixODBC) esteja instalado."
        exit 1
    else
        echo "✅ Biblioteca ODBC **/usr/lib64/libodbc.so** verificada com sucesso."
    fi

    echo "⚙️ Configurando ODBC..."

    if [[ ! -f /etc/odbc.ini ]]; then
        echo "❌ Erro: Arquivo /etc/odbc.ini não encontrado."
        exit 1
    else
        export ODBC_PATH="/etc/odbc.ini"
    fi

    check_env_vars "DATABASE_DRIVER"

    sed -i "s,DATABASE_ALIAS,${DATABASE_ALIAS},g" "$ODBC_PATH"
    sed -i "s,DATABASE_DRIVER,${DATABASE_DRIVER},g" "$ODBC_PATH"
    sed -i "s,DATABASE_SERVER,${DATABASE_SERVER},g" "$ODBC_PATH"
    sed -i "s,DATABASE_PORT,${DATABASE_PORT},g" "$ODBC_PATH"
    sed -i "s,DATABASE_NAME,${DATABASE_NAME},g" "$ODBC_PATH"
    sed -i "s,DATABASE_USERNAME,${DATABASE_USERNAME},g" "$ODBC_PATH"
    sed -i "s,DATABASE_PASSWORD,${DATABASE_PASSWORD},g" "$ODBC_PATH"

    echo "✅ Fim da configuração do ODBC."

#---------------------------------------------------------------------

## 🚀 INÍCIO DO TESTE DE CONEXAO COM BANCO DE DADOS

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DO TESTE DE CONEXAO COM BANCO DE DADOS"
    echo "------------------------------------------------------"
    echo "🔎 Verificando a conexão com Banco de Dados ${DATABASE_PROFILE}..."
    echo "🔎 ALIAS...: $DATABASE_ALIAS"
    echo "🔎 Username: $DATABASE_USERNAME"
    echo "🔎 PASSWORD: $DATABASE_PASSWORD"

    check_env_vars "DATABASE_DEFAULT_NAME"
    check_env_vars "DATABASE_DEFAULT_ALIAS"
    check_env_vars "SQL_COMMAND_PASSWORD_UPDATE"

    echo "quit;" | isql -v "$DATABASE_DEFAULT_ALIAS" "$DATABASE_USERNAME" "$DATABASE_PASSWORD"

    if [ ! $? = 0 ]; then

        echo "❌ ERRO: A senha ('$DATABASE_PASSWORD') para o DB ${DATABASE_PROFILE} parece estar incorreta ou o alias é inválido."
        echo "⚠️ Tentando conexão com senha default."
        echo "quit;" | isql -b "$DATABASE_DEFAULT_ALIAS" "$DATABASE_USERNAME" "$DATABASE_DEFAULT_PASSWORD"

        if [ $? = 0 ]; then

            echo "✅ Conexão com Banco de Dados ${DATABASE_PROFILE} foi estabelecida."
            echo "🔥 Executando script para atualização de senha"

            echo "$SQL_COMMAND_PASSWORD_UPDATE" | isql -b "$DATABASE_DEFAULT_ALIAS" "$DATABASE_USERNAME" "$DATABASE_DEFAULT_PASSWORD" > /dev/null 2>&1

            if [ $? -eq 0 ]; then

                echo "🚀 SUCESSO: A senha do usuário '$DATABASE_USERNAME' foi alterada."
                echo "🔎 Verificando a conexão com a nova senha para confirmar..."
                echo "quit;" | isql -b "$DATABASE_DEFAULT_ALIAS" "$DATABASE_USERNAME" "$DATABASE_PASSWORD" > /dev/null 2>&1

                if [ $? -eq 0 ]; then
                    echo "✅ Conexão com Banco de Dados ${DATABASE_PROFILE} foi estabelecida."
                else
                    echo "❌ ERRO: A alteração de senha parece ter ocorrido, mas a nova conexão de verificação FALHOU."
                    echo "   O login '$DATABASE_USERNAME' pode estar em um estado inconsistente. Verifique manualmente."
                    exit 1
                fi

            else

                echo "❌ ERRO: Não foi possível alterar a senha do usuário '$DATABASE_USERNAME'."
                echo "   Causa provável: Permissões insuficientes ou política de senha do SQL Server não atendida."
                exit 1

            fi
        else
            echo "❌ ERRO: Não foi possível se conectar com a senha default '$DATABASE_DEFAULT_PASSWORD'."
            exit 1
        fi
    else
        echo "✅ Conexão com Banco de Dados ${DATABASE_PROFILE} foi estabelecida."
    fi

#---------------------------------------------------------------------

## 🚀 INÍCIO DA EXECUÇÃO DE SCRIPTS BASE

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DA EXECUÇÃO DE SCRIPTS INICIAIS"
    echo "------------------------------------------------------"
    echo "🚀 Executando scripts iniciais..."

    check_env_vars "SCRIPT_BASE"

    sed -i "s,DATABASE_NAME,${DATABASE_NAME},g" "$SCRIPT_BASE"
    sed -i "s,DATABASE_USERNAME,${DATABASE_USERNAME},g" "$SCRIPT_BASE"

    cat "$SCRIPT_BASE"
    
    isql -b "$DATABASE_DEFAULT_ALIAS" "$DATABASE_USERNAME" "$DATABASE_PASSWORD" < "$SCRIPT_BASE" > /dev/null 2>&1

    if [[ ! $? = 0 ]]; then
        echo "❌ ERRO: Não foi possivel executar os script iniciais."
        exit 1
    else
        echo "✅ Scripts executados com sucesso!"
    fi