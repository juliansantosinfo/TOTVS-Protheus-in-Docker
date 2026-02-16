#!/bin/bash
#
# ==============================================================================
# SCRIPT: entrypoint.sh
# DESCRIÇÃO: Ponto de entrada do container DBAccess. Realiza a configuração do
#              Banco de Dados e a inicialização do serviço TOTVS DBAccess.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-18
# USO: ./entrypoint.sh
# ==============================================================================

# Ativa modo de depuração se a variável DEBUG_SCRIPT estiver como true/1/yes
if [[ "${DEBUG_SCRIPT:-}" =~ ^(true|1|yes|y)$ ]]; then
    set -x
fi

# Variáveis de path para os scripts de configuração
SETUP_DATABASE_SCRIPT="/setup-database.sh"
SETUP_DBACCESS_SCRIPT="/setup-dbaccess.sh"

#---------------------------------------------------------------------

## 🚀 VALIDAÇÃO DE VARIÁVEIS OBRIGATÓRIAS

    echo "🔍 Validando variáveis mínimas para inicialização..."
    MANDATORY_VARS=("DATABASE_PROFILE" "DATABASE_SERVER" "DATABASE_PASSWORD")
    
    MISSING_VARS=0
    for var in "${MANDATORY_VARS[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "❌ ERRO: A variável de ambiente $var NÃO está definida."
            MISSING_VARS=$((MISSING_VARS + 1))
        fi
    done

    if [[ $MISSING_VARS -gt 0 ]]; then
        echo "🛑 Falha na inicialização: Variáveis obrigatórias ausentes."
        exit 1
    fi

#---------------------------------------------------------------------

## 🚀 FUNÇÕES AUXILIARES

    # Função para tratamento de erro e log de execução de scripts
    execute_script() {
        local script_path=$1
        local script_name=$(basename "$script_path")

        echo "⚙️ Executando script: **$script_name**..."
        
        if [[ ! -x "$script_path" ]]; then
            echo "❌ ERRO: O script **$script_name** não foi encontrado ou não tem permissão de execução."
            exit 1
        fi
        
        # Executa o script. O uso de 'source' ou '.' é essencial para manter 
        # as variáveis de ambiente exportadas por setup-database.sh
        . "$script_path"
        
        if [ $? -eq 0 ]; then
            echo "✅ Script **$script_name** executado com sucesso."
        else
            echo "❌ ERRO: O script **$script_name** falhou durante a execução. O processo será encerrado."
            exit 1
        fi
    }

#---------------------------------------------------------------------

## 🚀 INÍCIO DO PROCESSAMENTO

    echo ""
    echo "======================================================"
    echo "🚀 INÍCIO DO PROCESSO DE CONFIGURAÇÃO E STARTUP (ENTRYPOINT)"
    echo "======================================================"

    # Garante que os scripts tenham permissão de execução
    chmod +x "$SETUP_DATABASE_SCRIPT" "$SETUP_DBACCESS_SCRIPT"

#---------------------------------------------------------------------

## 🚀 FASE 1: CONFIGURAÇÃO DO BANCO DE DADOS (SETUP-DATABASE.SH)

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 FASE 1: CONFIGURAÇÃO DO BANCO DE DADOS"
    echo "------------------------------------------------------"
    
    execute_script "$SETUP_DATABASE_SCRIPT"

#---------------------------------------------------------------------

## 🚀 FASE 2: CONFIGURAÇÃO E INICIALIZAÇÃO DO DBACCESS (SETUP-DBACCESS.SH)

    echo ""
    echo "------------------------------------------------------"
    echo "🚀 FASE 2: CONFIGURAÇÃO E INICIALIZAÇÃO DO DBACCESS"
    echo "------------------------------------------------------"
    
    # O script setup-dbaccess.sh contém a lógica de inicialização (comando 'exec')
    # que encerrará este entrypoint e manterá o DBAccess como PID 1.
    execute_script "$SETUP_DBACCESS_SCRIPT"

    # Esta linha só será alcançada em caso de falha na execução do setup-dbaccess.sh
    echo "❌ ERRO FATAL: O processo de inicialização não foi concluído. Verifique os logs anteriores."
    exit 1