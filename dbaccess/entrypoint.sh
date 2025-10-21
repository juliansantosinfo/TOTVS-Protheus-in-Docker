#!/bin/bash

######################################################################
# SCRIPT:      entrypoint.sh
# DESCRIÇÃO:   Ponto de entrada principal. Executa a configuração do
#              Banco de Dados e, em seguida, a configuração e 
#              inicialização do serviço TOTVS DBAccess.
# AUTOR:       Julian de Almeida Santos
# DATA:        2025-10-18
#
######################################################################

# Variáveis de path para os scripts de configuração
SETUP_DATABASE_SCRIPT="/setup-database.sh"
SETUP_DBACCESS_SCRIPT="/setup-dbaccess.sh"

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