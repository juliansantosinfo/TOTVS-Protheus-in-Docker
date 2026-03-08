#!/bin/bash
#
# ==============================================================================
# SCRIPT: clean.sh (Master)
# DESCRIÇÃO: Script mestre para automatizar a limpeza de arquivos não versionados
#            nos submodulos do ecossistema TOTVS Protheus.
# AUTOR: Julian de Almeida Santos
# DATA: 2024-03-08
# USO: ./scripts/build/clean.sh [apps...]
#
# EXEMPLOS:
#   ./scripts/build/clean.sh appserver dbaccess
#   ./scripts/build/clean.sh
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
        echo -e "🧹 \033[1;34m$1\033[0m"
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
    APPS_TO_CLEAN=()

    # Itera sobre os argumentos para processar os apps
    for arg in "$@"; do
        is_app=false
        for app in "${VALID_APPS[@]}"; do
            if [[ "$arg" == "$app" ]]; then
                APPS_TO_CLEAN+=("$arg")
                is_app=true
                break
            fi
        done
        
        if [[ "$is_app" == "false" ]]; then
            echo -e "⚠️  Aviso: O argumento '$arg' não é um nome de aplicação válido e será ignorado."
        fi
    done

    # Se nenhum app foi informado, utiliza todos
    if [[ ${#APPS_TO_CLEAN[@]} -eq 0 ]]; then
        print_info "Nenhum app especificado. Limpando todos os submodulos..."
        APPS_TO_CLEAN=("${VALID_APPS[@]}")
    fi

# ----------------------------------------------------
#   SEÇÃO 3: FLUXO DE EXECUÇÃO
# ----------------------------------------------------

    print_banner "INICIANDO PROCESSO DE LIMPEZA MASTER"
    print_info "Apps selecionados: ${APPS_TO_CLEAN[*]}"
    echo ""

    FAILED_APPS=()
    ORIGINAL_DIR=$(pwd)

    for APP in "${APPS_TO_CLEAN[@]}"; do
        print_progress "Limpando submodulo: $APP"
        
        if [[ ! -d "$APP" ]]; then
            print_error "Diretório '$APP' não encontrado."
            FAILED_APPS+=("$APP")
            continue
        fi

        if [[ ! -f "$APP/clean.sh" ]]; then
            print_error "Script de limpeza não encontrado em '$APP/'."
            FAILED_APPS+=("$APP")
            continue
        fi

        # Entra no diretório do app para manter o contexto
        cd "$APP"
        
        print_info "Executando clean em context: ./$APP"
        
        # Executa o clean do submodulo
        if ! ./clean.sh; then
            print_error "Falha na limpeza do submodulo '$APP'."
            FAILED_APPS+=("$APP")
        else
            print_success "Limpeza do submodulo '$APP' concluída com sucesso!"
        fi

        # Retorna ao diretório raiz
        cd "$ORIGINAL_DIR"
        echo "-----------------------------------"
    done

# ----------------------------------------------------
#   SEÇÃO 4: FINALIZAÇÃO
# ----------------------------------------------------

    if [[ ${#FAILED_APPS[@]} -eq 0 ]]; then
        print_banner "PROCESSO DE LIMPEZA CONCLUÍDO COM SUCESSO"
        exit 0
    else
        print_banner "FALHA EM UM OU MAIS PROCESSOS DE LIMPEZA"
        print_error "Os seguintes apps falharam: ${FAILED_APPS[*]}"
        exit 1
    fi
