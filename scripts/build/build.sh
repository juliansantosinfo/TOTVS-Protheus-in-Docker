#!/bin/bash
#
# ==============================================================================
# SCRIPT: build.sh (Master)
# DESCRIÇÃO: Script mestre para automatizar o build de múltiplas imagens Docker
#            do ecossistema TOTVS Protheus.
# AUTOR: Julian de Almeida Santos
# DATA: 2024-03-08
# USO: ./scripts/build/build.sh [apps...] [OPTIONS]
#
# EXEMPLOS:
#   ./scripts/build/build.sh appserver dbaccess
#   ./scripts/build/build.sh --no-cache
#   ./scripts/build/build.sh appserver --progress=plain
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
        echo -e "ℹ️ \033[1;34m$1\033[0m"
    }

    print_progress() {
        echo -e "🚀 \033[1;35m$1\033[0m"
    }

    print_banner() {
        echo -e "\033[1;36m==========================================================\033[0m"
        echo -e "\033[1;36m🎯 $1\033[0m"
        echo -e "\033[1;36m==========================================================\033[0m"
    }

    check_versions() {
        if [ -f "versions.env" ]; then
            # shellcheck source=versions.env
            source "versions.env"
        else
            print_error "Arquivo 'versions.env' não encontrado na raiz do projeto."
            exit 1
        fi
    }

# ----------------------------------------------------
#   SEÇÃO 2: PARSE DE ARGUMENTOS
# ----------------------------------------------------

    VALID_APPS=("appserver" "dbaccess" "licenseserver" "mssql" "postgres" "oracle" "smartview")
    APPS_TO_BUILD=()
    BUILD_OPTIONS=()

    # Itera sobre os argumentos para separar apps de opções
    for arg in "$@"; do
        is_app=false
        for app in "${VALID_APPS[@]}"; do
            if [[ "$arg" == "$app" ]]; then
                APPS_TO_BUILD+=("$arg")
                is_app=true
                break
            fi
        done
        
        if [[ "$is_app" == "false" ]]; then
            BUILD_OPTIONS+=("$arg")
        fi
    done

    # Se nenhum app foi informado, utiliza todos
    if [[ ${#APPS_TO_BUILD[@]} -eq 0 ]]; then
        print_info "Nenhum app especificado. Construindo todos os submodulos..."
        APPS_TO_BUILD=("${VALID_APPS[@]}")
    fi

# ----------------------------------------------------
#   SEÇÃO 3: FLUXO DE EXECUÇÃO
# ----------------------------------------------------

    check_versions

    print_banner "INICIANDO PROCESSO DE BUILD MASTER"
    print_info "Apps selecionados: ${APPS_TO_BUILD[*]}"
    [[ ${#BUILD_OPTIONS[@]} -gt 0 ]] && print_info "Opções extras: ${BUILD_OPTIONS[*]}"
    echo ""

    FAILED_APPS=()
    ORIGINAL_DIR=$(pwd)

    for APP in "${APPS_TO_BUILD[@]}"; do
        print_progress "Construindo submodulo: $APP"
        
        if [[ ! -d "$APP" ]]; then
            print_error "Diretório '$APP' não encontrado."
            FAILED_APPS+=("$APP")
            continue
        fi

        if [[ ! -f "$APP/build.sh" ]]; then
            print_error "Script de build não encontrado em '$APP/'."
            FAILED_APPS+=("$APP")
            continue
        fi

        # Entra no diretório do app para manter o contexto
        cd "$APP"
        
        print_info "Executando build em context: ./$APP"
        
        # Executa o build do submodulo passando as opções extras
        if ! ./build.sh "${BUILD_OPTIONS[@]+"${BUILD_OPTIONS[@]}"}"; then
            print_error "Falha no build do submodulo '$APP'."
            FAILED_APPS+=("$APP")
        else
            print_success "Build do submodulo '$APP' concluído com sucesso!"
        fi

        # Retorna ao diretório raiz
        cd "$ORIGINAL_DIR"
        echo "-----------------------------------"
    done

# ----------------------------------------------------
#   SEÇÃO 4: FINALIZAÇÃO
# ----------------------------------------------------

    if [[ ${#FAILED_APPS[@]} -eq 0 ]]; then
        print_banner "PROCESSO DE BUILD CONCLUÍDO COM SUCESSO"
        exit 0
    else
        print_banner "FALHA EM UM OU MAIS BUILDS"
        print_error "Os seguintes apps falharam: ${FAILED_APPS[*]}"
        exit 1
    fi
