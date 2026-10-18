#!/bin/bash
#
# ==============================================================================
# SCRIPT: versions.sh
# DESCRIÇÃO: Valida e sincroniza as versões definidas nos Dockerfiles,
#            arquivos docker-compose*.yaml e services/*/versions.env com base
#            na fonte única da verdade (versions.env na raiz).
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-12
# USO: ./scripts/validation/versions.sh [--fix]
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
set -euo pipefail

# ----------------------------------------------------
#   SEÇÃO 1: DEFINICAO DE FUNCOES AUXILIARES
# ----------------------------------------------------

    OVERALL_EXIT_CODE=0

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

        local dockerfile="./services/${service}/Dockerfile"

        if [ ! -f "$dockerfile" ]; then
            print_warning "Dockerfile não encontrado em ${dockerfile}. Pulando validação."
            return 0
        fi

        actual_value=$(grep -iE "^LABEL ${label_name}=" "$dockerfile" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")

        if [ "$actual_value" != "$expected_value" ]; then
            if [ "$AUTO_FIX" = true ]; then
                print_info "Corrigindo Dockerfile (${service}) ${label_name}: $actual_value -> $expected_value"
                sed -i "s|^LABEL ${label_name}=\"${actual_value}\"|LABEL ${label_name}=\"${expected_value}\"|" "$dockerfile"

                local new_value
                new_value=$(grep -iE "^LABEL ${label_name}=" "$dockerfile" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")
                if [ "$new_value" == "$expected_value" ]; then
                    print_success "${service}/Dockerfile (${label_name}) corrigido: $expected_value"
                else
                    print_error "Falha ao corrigir ${label_name} em ${dockerfile}."
                    OVERALL_EXIT_CODE=1
                fi
            else
                print_error "${service}/Dockerfile (${label_name}): '$actual_value' difere de versions.env ('$expected_value')"
                OVERALL_EXIT_CODE=1
            fi
        else
            print_success "${service}/Dockerfile (${label_name}): $expected_value"
        fi
    }

    validate_submodule_env_var() {
        local service=$1
        local var_name=$2
        local expected_value=$3
        local env_file="./services/${service}/versions.env"
        local actual_value

        if [ ! -f "$env_file" ]; then
            print_warning "Arquivo ${env_file} não encontrado. Pulando."
            return 0
        fi

        actual_value=$(grep -E "^${var_name}=" "$env_file" | head -n 1 | cut -d'=' -f2- | tr -d '"' | tr -d "[:space:]")

        if [ "$actual_value" != "$expected_value" ]; then
            if [ "$AUTO_FIX" = true ]; then
                print_info "Corrigindo ${env_file} (${var_name}): $actual_value -> $expected_value"
                sed -i "s|^${var_name}=.*|${var_name}=${expected_value}|" "$env_file"

                local new_value
                new_value=$(grep -E "^${var_name}=" "$env_file" | head -n 1 | cut -d'=' -f2- | tr -d '"' | tr -d "[:space:]")
                if [ "$new_value" == "$expected_value" ]; then
                    print_success "${service}/versions.env (${var_name}) corrigido: $expected_value"
                else
                    print_error "Falha ao corrigir ${var_name} em ${env_file}."
                    OVERALL_EXIT_CODE=1
                fi
            else
                print_error "${service}/versions.env (${var_name}): '$actual_value' difere do esperado ('$expected_value')"
                OVERALL_EXIT_CODE=1
            fi
        else
            print_success "${service}/versions.env (${var_name}): $expected_value"
        fi
    }

    validate_compose_image() {
        local compose_file=$1
        local image_name=$2
        local expected_version=$3
        local expected_full="${DOCKER_USER}/${image_name}:${expected_version}"

        if [ ! -f "$compose_file" ]; then
            return 0
        fi

        # Verifica se o arquivo compose referencia esta imagem
        if ! grep -qE "image:[[:space:]]*[^[:space:]]*/${image_name}:" "$compose_file"; then
            return 0
        fi

        local mismatched_lines
        mismatched_lines=$(grep -E "image:[[:space:]]*[^[:space:]]*/${image_name}:" "$compose_file" | grep -vE "image:[[:space:]]*${expected_full}([[:space:]]|$)" || true)

        if [ -n "$mismatched_lines" ]; then
            if [ "$AUTO_FIX" = true ]; then
                print_info "Corrigindo imagem ${image_name} em ${compose_file} -> ${expected_full}"
                sed -i -E "s|(image:[[:space:]]*)[^[:space:]]*/${image_name}:[^[:space:]]+|\1${expected_full}|g" "$compose_file"
                print_success "${compose_file} (${image_name}) corrigido: ${expected_full}"
            else
                local actual_img
                actual_img=$(echo "$mismatched_lines" | head -n 1 | awk '{print $2}')
                print_error "${compose_file}: imagem '${actual_img}' difere do esperado ('${expected_full}')"
                OVERALL_EXIT_CODE=1
            fi
        else
            print_success "${compose_file} (${image_name}): ${expected_full}"
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
        # shellcheck source=versions.env
        source "versions.env"
    elif [ -f "../../versions.env" ]; then
        # shellcheck source=../../versions.env
        source "../../versions.env"
        cd ../..
    else
        print_error "Arquivo 'versions.env' não encontrado."
        exit 1
    fi

# ----------------------------------------------------
#   SEÇÃO 4: VALIDAÇÃO DE DOCKERFILES
# ----------------------------------------------------

    print_info "1/3 Validando LABELs nos Dockerfiles (services/*/Dockerfile)..."
    print_plain "-----------------------------------"

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

# ----------------------------------------------------
#   SEÇÃO 5: VALIDAÇÃO DE VERSIONS.ENV DOS SUBMÓDULOS
# ----------------------------------------------------

    print_plain ""
    print_info "2/3 Validando versions.env internos dos submódulos (services/*/versions.env)..."
    print_plain "-----------------------------------"

    validate_submodule_env_var "appserver" "DOCKER_USER" "${DOCKER_USER}"
    validate_submodule_env_var "appserver" "IMAGE_BASE" "${DOCKER_USER}/imagebase:totvs-protheus-release_${APPSERVER_RELEASE}-build_${APPSERVER_BUILD_VERSION}-dbapi_${APPSERVER_DBAPI_VERSION}-webapp_${APPSERVER_WEBAPP_VERSION}"
    validate_submodule_env_var "appserver" "APPSERVER_RELEASE" "${APPSERVER_RELEASE}"
    validate_submodule_env_var "appserver" "APPSERVER_BUILD_VERSION" "${APPSERVER_BUILD_VERSION}"
    validate_submodule_env_var "appserver" "APPSERVER_WEBAPP_VERSION" "${APPSERVER_WEBAPP_VERSION}"
    validate_submodule_env_var "appserver" "APPSERVER_DBAPI_VERSION" "${APPSERVER_DBAPI_VERSION}"

    validate_submodule_env_var "dbaccess" "DOCKER_USER" "${DOCKER_USER}"
    validate_submodule_env_var "dbaccess" "IMAGE_BASE" "${DOCKER_USER}/imagebase:totvs-dbaccess-build_${DBACCESS_VERSION}"
    validate_submodule_env_var "dbaccess" "DBACCESS_VERSION" "${DBACCESS_VERSION}"

    validate_submodule_env_var "licenseserver" "DOCKER_USER" "${DOCKER_USER}"
    validate_submodule_env_var "licenseserver" "IMAGE_BASE" "${DOCKER_USER}/imagebase:totvs-licenseserver-build_${LICENSESERVER_VERSION}"
    validate_submodule_env_var "licenseserver" "LICENSESERVER_VERSION" "${LICENSESERVER_VERSION}"

    validate_submodule_env_var "mssql" "DOCKER_USER" "${DOCKER_USER}"
    validate_submodule_env_var "mssql" "IMAGE_BASE" "${DOCKER_USER}/imagebase:totvs-mssql-version_${MSSQL_VERSION}"
    validate_submodule_env_var "mssql" "MSSQL_VERSION" "${MSSQL_VERSION}"

    validate_submodule_env_var "oracle" "DOCKER_USER" "${DOCKER_USER}"
    validate_submodule_env_var "oracle" "IMAGE_BASE" "${DOCKER_USER}/imagebase:totvs-oracle-version_${ORACLE_VERSION}"
    validate_submodule_env_var "oracle" "ORACLE_VERSION" "${ORACLE_VERSION}"

    validate_submodule_env_var "postgres" "DOCKER_USER" "${DOCKER_USER}"
    validate_submodule_env_var "postgres" "IMAGE_BASE" "${DOCKER_USER}/imagebase:totvs-postgres-version_${POSTGRES_VERSION}"
    validate_submodule_env_var "postgres" "POSTGRES_VERSION" "${POSTGRES_VERSION}"

    validate_submodule_env_var "smartview" "DOCKER_USER" "${DOCKER_USER}"
    validate_submodule_env_var "smartview" "IMAGE_BASE" "${DOCKER_USER}/imagebase:totvs-smartview_${SMARTVIEW_VERSION}"
    validate_submodule_env_var "smartview" "SMARTVIEW_VERSION" "${SMARTVIEW_VERSION}"

# ----------------------------------------------------
#   SEÇÃO 6: VALIDAÇÃO DOS ARQUIVOS DOCKER COMPOSE
# ----------------------------------------------------

    print_plain ""
    print_info "3/3 Validando tags nos arquivos docker-compose*.yaml..."
    print_plain "-----------------------------------"

    COMPOSE_FILES=(
        "docker-compose.yaml"
        "docker-compose-mssql.yaml"
        "docker-compose-postgresql.yaml"
        "docker-compose-oracle.yaml"
    )

    for cf in "${COMPOSE_FILES[@]}"; do
        validate_compose_image "$cf" "${APPSERVER_IMAGE_NAME}" "${APPSERVER_VERSION}"
        validate_compose_image "$cf" "${DBACCESS_IMAGE_NAME}" "${DBACCESS_VERSION}"
        validate_compose_image "$cf" "${LICENSESERVER_IMAGE_NAME}" "${LICENSESERVER_VERSION}"
        validate_compose_image "$cf" "${SMARTVIEW_IMAGE_NAME}" "${SMARTVIEW_VERSION}"
        validate_compose_image "$cf" "${MSSQL_IMAGE_NAME}" "${MSSQL_VERSION}"
        validate_compose_image "$cf" "${POSTGRES_IMAGE_NAME}" "${POSTGRES_VERSION}"
        validate_compose_image "$cf" "${ORACLE_IMAGE_NAME}" "${ORACLE_VERSION}"
    done

    print_plain "-----------------------------------"

    if [ $OVERALL_EXIT_CODE -ne 0 ]; then
        if [ "$AUTO_FIX" = false ]; then
            print_info "Dica: Execute './scripts/validation/versions.sh --fix' para sincronizar tudo automaticamente."
        fi
        exit 1
    fi

    print_success "Validação de versões concluída com sucesso."
