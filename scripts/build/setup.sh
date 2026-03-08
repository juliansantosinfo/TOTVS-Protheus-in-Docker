#!/bin/bash
#
# ==============================================================================
# SCRIPT: setup.sh (Master)
# DESCRIÇÃO: Script mestre para automatizar o setup e descompactação de 
#            recursos nos submodulos do ecossistema TOTVS Protheus.
# AUTOR: Julian de Almeida Santos
# DATA: 2024-03-08
# USO: ./scripts/build/setup.sh [apps...]
#
# EXEMPLOS:
#   ./scripts/build/setup.sh appserver dbaccess
#   ./scripts/build/setup.sh
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
set -euo pipefail

# ----------------------------------------------------
#   SEÇÃO 1: DEFINIÇÃO DE FUNÇÕES AUXILIARES
# ----------------------------------------------------

    print_success() {
        echo -e "✅ \033[1;32m$1\033[0m"
    }

    print_error() {
        echo -e "🚨 \033[1;31mErro: $1\033[0m" >&2
    }

    print_info() {
        echo -e "ℹ️  \033[1;34m$1\033[0m"
    }

    print_progress() {
        echo -e "🚀 \033[1;35m$1\033[0m"
    }

    print_banner() {
        echo -e "\033[1;36m==========================================================\033[0m"
        echo -e "\033[1;36m🎯 $1\033[0m"
        echo -e "\033[1;36m==========================================================\033[0m"
    }

# ----------------------------------------------------
#   SEÇÃO 2: PARSE DE ARGUMENTOS
# ----------------------------------------------------

    VALID_APPS=("appserver" "dbaccess" "licenseserver" "mssql" "postgres" "oracle" "smartview")
    APPS_TO_SETUP=()

    # Itera sobre os argumentos para processar os apps
    for arg in "$@"; do
        is_app=false
        for app in "${VALID_APPS[@]}"; do
            if [[ "$arg" == "$app" ]]; then
                APPS_TO_SETUP+=("$arg")
                is_app=true
                break
            fi
        done
        
        if [[ "$is_app" == "false" ]]; then
            echo -e "⚠️  Aviso: O argumento '$arg' não é um nome de aplicação válido e será ignorado."
        fi
    done

    # Se nenhum app foi informado, utiliza todos
    if [[ ${#APPS_TO_SETUP[@]} -eq 0 ]]; then
        print_info "Nenhum app especificado. Iniciando setup de todos os submodulos..."
        APPS_TO_SETUP=("${VALID_APPS[@]}")
    fi

# ----------------------------------------------------
#   SEÇÃO 3: FLUXO DE EXECUÇÃO
# ----------------------------------------------------

    print_banner "INICIANDO PROCESSO DE SETUP MASTER"
    print_info "Apps selecionados: ${APPS_TO_SETUP[*]}"
    echo ""

    FAILED_APPS=()
    ORIGINAL_DIR=$(pwd)

    for APP in "${APPS_TO_SETUP[@]}"; do
        print_progress "Iniciando setup do submodulo: $APP"
        
        if [[ ! -d "services/$APP" ]]; then
            print_error "Diretório 'services/$APP' não encontrado."
            FAILED_APPS+=("$APP")
            continue
        fi

        # Alguns submodulos podem usar unpack.sh ou setup.sh (interno)
        SETUP_SCRIPT=""
        if [[ -f "services/$APP/unpack.sh" ]]; then
            SETUP_SCRIPT="./unpack.sh"
        elif [[ -f "services/$APP/setup-build.sh" ]]; then
            SETUP_SCRIPT="./setup-build.sh"
        fi

        if [[ -z "$SETUP_SCRIPT" ]]; then
            print_info "Nenhum script de setup encontrado em 'services/$APP/'. Pulando..."
            continue
        fi

        # Entra no diretório do app para manter o contexto
        cd "services/$APP"
        
        print_info "Executando $SETUP_SCRIPT em context: ./services/$APP"
        
        # Executa o setup do submodulo
        if ! bash "$SETUP_SCRIPT" "all"; then
            print_error "Falha no setup do submodulo '$APP'."
            FAILED_APPS+=("$APP")
        else
            print_success "Setup do submodulo '$APP' concluído com sucesso!"
        fi

        # Retorna ao diretório raiz
        cd "$ORIGINAL_DIR"
        echo "-----------------------------------"
    done

# ----------------------------------------------------
#   SEÇÃO 4: FINALIZAÇÃO
# ----------------------------------------------------

    if [[ ${#FAILED_APPS[@]} -eq 0 ]]; then
        print_banner "PROCESSO DE SETUP CONCLUÍDO COM SUCESSO"
        exit 0
    else
        print_banner "FALHA EM UM OU MAIS PROCESSOS DE SETUP"
        print_error "Os seguintes apps falharam: ${FAILED_APPS[*]}"
        exit 1
    fi
