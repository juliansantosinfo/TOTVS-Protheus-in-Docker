#!/bin/bash
#
# ==============================================================================
# SCRIPT: versions.sh
# DESCRIÇÃO: Valida se as versões definidas no Dockerfile correspondem às versões
#            centralizadas no arquivo versions.env.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-12
# USO: ./scripts/validation/versions.sh [--fix]
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
set -euo pipefail

# ----------------------------------------------------
#   SEÇÃO 1: DEFINICAO DE FUNCOES AUXILIARES
# ----------------------------------------------------

    print_success() {
        echo "✅ $1"
    }

    print_error() {
        echo "❌ $1" >&2
    }

    print_warning() {
        echo "⚠️ $1"
    }

    print_info() {
        echo "🔍 $1"
    }

    print_plain() {
        echo "$1"
    }

    validate_label() {
        local label_name=$1
        local expected_value=$2
        local service=$3
        local actual_value

        DOCKERFILE="./${service}/Dockerfile"
        EXIT_CODE=0

        if [ ! -f "$DOCKERFILE" ]; then
            print_warning "Dockerfile não encontrado. Pulando validação."
            exit 0
        fi
        
        actual_value=$(grep -iE "LABEL ${label_name}=" "$DOCKERFILE" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")
        
        if [ "$actual_value" != "$expected_value" ]; then
            if [ "$AUTO_FIX" = true ]; then
                print_info "Corrigindo ${label_name}: $actual_value -> $expected_value"
                sed -i "s/LABEL ${label_name}=\"${actual_value}\"/LABEL ${label_name}=\"${expected_value}\"/" "$DOCKERFILE"
                
                # Verifica se deu certo
                local new_value
                new_value=$(grep -iE "LABEL ${label_name}=" "$DOCKERFILE" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")
                if [ "$new_value" == "$expected_value" ]; then
                    print_success "${service} ${label_name} corrigido com sucesso."
                else
                    print_error "Falha ao corrigir ${label_name}."
                    EXIT_CODE=1
                fi
            else
                print_error "${label_name}: Dockerfile ($actual_value) difere de versions.env ($expected_value)"
                EXIT_CODE=1
            fi
        else
            print_success "${service} ${label_name}: $expected_value"
        fi
    }

# ----------------------------------------------------
#   SEÇÃO 2: PARSE DE ARGUMENTOS
# ----------------------------------------------------

    AUTO_FIX=false

    if [[ "${1:-}" == "--fix" ]]; then
        AUTO_FIX=true
    fi

# ----------------------------------------------------
#   SEÇÃO 3: CARREGAMENTO DE CONFIGURAÇÕES
# ----------------------------------------------------

    if [ -f "versions.env" ]; then
        source "versions.env"
    elif [ -f "../../versions.env" ]; then
        source "../../versions.env"
        cd ../..
    else
        print_error "Arquivo 'versions.env' não encontrado."
        exit 1
    fi

# ----------------------------------------------------
#   SEÇÃO 4: VALIDAÇÃO DE VERSÕES
# ----------------------------------------------------

    print_info "Iniciando validação de versões..."
    print_plain "-----------------------------------"

    # Valida cada label
    validate_label "release" "${APPSERVER_VERSION}" "appserver"
    validate_label "build" "${APPSERVER_BUILD_VERSION}" "appserver"
    validate_label "dbapi" "${APPSERVER_DBAPI_VERSION}" "appserver"
    validate_label "webapp" "${APPSERVER_WEBAPP_VERSION}" "appserver"
    validate_label "version" "${DBACCESS_VERSION}" "dbaccess"
    validate_label "version" "${LICENSESERVER_VERSION}" "licenseserver"
    validate_label "version" "${MSSQL_VERSION}" "mssql"
    validate_label "version" "${ORACLE_VERSION}" "oracle"
    validate_label "version" "${POSTGRES_VERSION}" "postgres"
    validate_label "version" "${SMARTVIEW_VERSION}" "smartview"
    
    print_plain "-----------------------------------"
    
    if [ $EXIT_CODE -ne 0 ]; then
        if [ "$AUTO_FIX" = false ]; then
            print_info "Dica: Execute './scripts/validation/versions.sh --fix' para corrigir automaticamente."
        fi
        exit 1
    fi
    
    print_success "Validação concluída."
