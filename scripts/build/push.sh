#!/bin/bash
#
# ==============================================================================
# SCRIPT: push.sh
# DESCRIÇÃO: Script mestre para enviar todas as imagens Docker para o Docker Hub.
#            Chama o script push.sh individual de cada serviço.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-12
# USO: ./push.sh [OPTIONS]
#
# OPÇÕES:
#   --no-latest                 Não faz push da tag 'latest'
#   --tag=<TAG>                 Define uma tag customizada para push
#   -h, --help                  Exibe esta mensagem de ajuda
#
# EXEMPLOS:
#   ./push.sh
#   ./push.sh --no-latest
#   ./push.sh --tag=custom-tag
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
# -e: Sai imediatamente se um comando falhar.
# -u: Trata variáveis não definidas como erro.
# -o pipefail: Garante que um pipeline (ex: cat | tar) falhe se qualquer comando falhar.
set -euo pipefail

# ----------------------------------------------------
#   SEÇÃO 1: DEFINICAO DE FUNCOES AUXILIARES
# ----------------------------------------------------

    # --- Funções de Impressão ---
    print_success() {
        local message="$1"
        echo "✅ $message"
    }

    print_error() {
        local message="$1"
        echo "🚨 Erro: $message" >&2
    }

    print_warning() {
        local message="$1"
        echo "⚠️ Aviso: $message"
    }

    print_info() {
        local message="$1"
        echo "ℹ️ $message"
    }

    print_docker() {
        local message="$1"
        echo "🐳 $message"
    }

    show_help() {
        cat << EOF
USO: ./push.sh [OPTIONS]

OPÇÕES:
  --no-latest                 Não faz push da tag 'latest'
  --tag=<TAG>                 Define uma tag customizada para push
  -h, --help                  Exibe esta mensagem de ajuda

EXEMPLOS:
  ./push.sh
  ./push.sh --no-latest
  ./push.sh --tag=custom-tag

EOF
        exit 0
    }

    check_versions() {
        if [ -f "versions.env" ]; then
            # shellcheck source=versions.env
            source "versions.env"
            print_info "Versões carregadas do 'versions.env'"
        else
            print_error "Arquivo 'versions.env' não encontrado."
            exit 1
        fi
    }

# ----------------------------------------------------
#   SEÇÃO 2: PARSE DE ARGUMENTOS
# ----------------------------------------------------

    PUSH_LATEST="true"
    CUSTOM_TAG=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-latest)
                PUSH_LATEST="false"
                shift
                ;;
            --tag=*)
                CUSTOM_TAG="${1#*=}"
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                print_error "Opção desconhecida: $1"
                show_help
                ;;
        esac
    done

# ----------------------------------------------------
#   SEÇÃO 3: DEFINIÇÕES VARIAVEIS
# ----------------------------------------------------

    readonly VALID_APPS=("appserver" "dbaccess" "licenseserver" "mssql" "postgres" "oracle" "smartview")
    APPS_TO_PUSH=("${VALID_APPS[@]}")

    echo "=========================================================="
    echo "🚀 STARTING PUSH"
    echo "=========================================================="

    MASTER_SUCCESS=true

    for APP_NAME in "${APPS_TO_PUSH[@]}"; do
        echo ""
        echo ">>> 📤 PUSHING SERVICE: $APP_NAME <<<"
        
        SCRIPT_PATH="./${APP_NAME}/push.sh"

        if [ ! -f "$SCRIPT_PATH" ]; then
            echo "🚨 ERROR: Push script not found: $SCRIPT_PATH" >&2
            MASTER_SUCCESS=false
            continue
        fi

        # Execute the push script
        if ! bash "$SCRIPT_PATH"; then
            echo "❌ FAILURE: Push for '$APP_NAME' failed." >&2
            MASTER_SUCCESS=false
        else
            echo "✅ SUCCESS: Push for '$APP_NAME' completed."
        fi
    done

    if [ "$MASTER_SUCCESS" = true ]; then
        echo ""
        echo "🎉 ALL PUSHES COMPLETED SUCCESSFULLY!"
        exit 0
    else
        echo ""
        echo "🛑 SOME PUSHES FAILED." >&2
        exit 1
    fi
