#!/bin/bash
#
# ==============================================================================
# SCRIPT: imagebase.sh (Master)
# DESCRIÇÃO: Automatiza o tagueamento e envio de imagens base privadas (IMAGE_BASE)
#            para o Docker Hub, garantindo que as esteiras de CI/CD do GitHub
#            Actions tenham acesso aos binários pré-instalados dos serviços TOTVS.
# AUTOR: Julian de Almeida Santos
# DATA: 2026-10-17
# USO: ./scripts/build/imagebase.sh [apps...] [OPTIONS]
#
# OPÇÕES:
#   --no-push                   Apenas cria a tag localmente, sem enviar ao Docker Hub
#   --tag-only                  Alias para '--no-push'
#   --check                     Apenas verifica a consistência e existência das tags locais
#   -h, --help                  Exibe esta mensagem de ajuda
#
# EXEMPLOS:
#   ./scripts/build/imagebase.sh appserver
#   ./scripts/build/imagebase.sh appserver dbaccess
#   ./scripts/build/imagebase.sh --check
#   ./scripts/build/imagebase.sh appserver --no-push
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

    print_warning() {
        echo -e "⚠️ \033[1;33m$1\033[0m"
    }

    print_info() {
        echo -e "ℹ️ \033[1;34m$1\033[0m"
    }

    print_progress() {
        echo -e "🚀 \033[1;35m$1\033[0m"
    }

    print_docker() {
        echo -e "🐳 \033[1;36m$1\033[0m"
    }

    print_banner() {
        echo -e "\033[1;36m==========================================================\033[0m"
        echo -e "\033[1;36m🎯 $1\033[0m"
        echo -e "\033[1;36m==========================================================\033[0m"
    }

    show_help() {
        cat << 'HELPEOF'
USO: ./scripts/build/imagebase.sh [apps...] [OPTIONS]

OPÇÕES:
  --no-push                   Apenas cria a tag localmente, sem enviar ao Docker Hub
  --tag-only                  Alias para '--no-push'
  --check                     Apenas verifica a consistência e existência das tags locais
  -h, --help                  Exibe esta mensagem de ajuda

EXEMPLOS:
  ./scripts/build/imagebase.sh appserver
  ./scripts/build/imagebase.sh appserver dbaccess
  ./scripts/build/imagebase.sh
  ./scripts/build/imagebase.sh --check
  ./scripts/build/imagebase.sh appserver --no-push

HELPEOF
        exit 0
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

    get_service_local_image() {
        local app="$1"
        case "$app" in
            appserver)     echo "${DOCKER_USER}/${APPSERVER_IMAGE_NAME}:${APPSERVER_RELEASE}" ;;
            dbaccess)      echo "${DOCKER_USER}/${DBACCESS_IMAGE_NAME}:${DBACCESS_VERSION}" ;;
            licenseserver) echo "${DOCKER_USER}/${LICENSESERVER_IMAGE_NAME}:${LICENSESERVER_VERSION}" ;;
            mssql)         echo "${DOCKER_USER}/${MSSQL_IMAGE_NAME}:${MSSQL_VERSION}" ;;
            oracle)        echo "${DOCKER_USER}/${ORACLE_IMAGE_NAME}:${ORACLE_VERSION}" ;;
            postgres)      echo "${DOCKER_USER}/${POSTGRES_IMAGE_NAME}:${POSTGRES_VERSION}" ;;
            smartview)     echo "${DOCKER_USER}/${SMARTVIEW_IMAGE_NAME}:${SMARTVIEW_VERSION}" ;;
            *)             echo "" ;;
        esac
    }

    get_submodule_image_base() {
        local app="$1"
        local env_file="services/${app}/versions.env"
        if [ -f "$env_file" ]; then
            grep -E '^IMAGE_BASE=' "$env_file" | head -n1 | cut -d'=' -f2- | tr -d '"' | tr -d "'"
        fi
    }

# ----------------------------------------------------
#   SEÇÃO 2: PARSE DE ARGUMENTOS
# ----------------------------------------------------

    VALID_APPS=("appserver" "dbaccess" "licenseserver" "mssql" "postgres" "oracle" "smartview")
    APPS_SELECTED=()
    DO_PUSH=true
    CHECK_MODE=false

    for arg in "$@"; do
        is_app=false
        for app in "${VALID_APPS[@]}"; do
            if [[ "$arg" == "$app" ]]; then
                APPS_SELECTED+=("$arg")
                is_app=true
                break
            fi
        done
        
        if [[ "$is_app" == "false" ]]; then
            case "$arg" in
                --no-push|--tag-only)
                    DO_PUSH=false
                    ;;
                --check)
                    CHECK_MODE=true
                    ;;
                -h|--help)
                    show_help
                    ;;
                *)
                    print_error "Opção desconhecida: $arg"
                    show_help
                    ;;
            esac
        fi
    done

    # Se nenhum app foi informado, utiliza todos os válidos
    if [[ ${#APPS_SELECTED[@]} -eq 0 ]]; then
        APPS_SELECTED=("${VALID_APPS[@]}")
    fi

# ----------------------------------------------------
#   SEÇÃO 3: VALIDAÇÃO DO AMBIENTE
# ----------------------------------------------------

    check_versions

    if ! command -v docker &> /dev/null; then
        print_error "Docker não está instalado ou não está no PATH."
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker daemon não está em execução ou não há permissão de acesso."
        exit 1
    fi

# ----------------------------------------------------
#   SEÇÃO 4: MODO DE CHECAGEM (--check)
# ----------------------------------------------------

    if [ "$CHECK_MODE" = true ]; then
        print_banner "STATUS DAS IMAGENS BASE PRIVADAS (IMAGE_BASE)"
        printf " %-14s | %-12s | %-12s | %s\n" "SERVIÇO" "IMAGEM LOCAL" "TAG BASE" "IMAGE_BASE ESPERADA"
        echo "--------------------------------------------------------------------------------------------------------"

        for app in "${APPS_SELECTED[@]}"; do
            local_img=$(get_service_local_image "$app")
            base_img=$(get_submodule_image_base "$app")

            local_status="⚪ Ausente"
            if docker image inspect "$local_img" > /dev/null 2>&1; then
                local_status="✅ Pronta"
            fi

            base_status="⚪ Ausente"
            if [ -n "$base_img" ] && docker image inspect "$base_img" > /dev/null 2>&1; then
                base_status="✅ Tagueada"
            fi

            printf " %-14s | %-12s | %-12s | %s\n" "$app" "$local_status" "$base_status" "$base_img"
        done
        echo "--------------------------------------------------------------------------------------------------------"
        exit 0
    fi

# ----------------------------------------------------
#   SEÇÃO 5: EXECUÇÃO DO TAG E PUSH
# ----------------------------------------------------

    print_banner "GERENCIADOR DE IMAGENS BASE PRIVADAS (IMAGE_BASE)"
    print_info "Serviços selecionados: ${APPS_SELECTED[*]}"
    print_info "Ação: Tag $([ "$DO_PUSH" = true ] && echo "+ Push para Docker Hub" || echo "apenas local")"
    echo ""

    FAILED_APPS=()

    for app in "${APPS_SELECTED[@]}"; do
        print_progress "Processando serviço: $app"

        local_img=$(get_service_local_image "$app")
        base_img=$(get_submodule_image_base "$app")

        if [[ -z "$local_img" ]]; then
            print_error "Não foi possível determinar a imagem local para o serviço '$app'."
            FAILED_APPS+=("$app")
            continue
        fi

        if [[ -z "$base_img" ]]; then
            print_error "Variável IMAGE_BASE não encontrada em 'services/$app/versions.env'."
            FAILED_APPS+=("$app")
            continue
        fi

        # 1. Verifica se a imagem compilada localmente existe
        if ! docker image inspect "$local_img" > /dev/null 2>&1; then
            print_error "Imagem local '$local_img' não encontrada."
            print_info "💡 Dica: Compile primeiro a imagem local com 'make build APP=$app'."
            FAILED_APPS+=("$app")
            echo "-----------------------------------"
            continue
        fi

        # 2. Executa o docker tag
        print_docker "Tagueando imagem:"
        echo "   Origem:  $local_img"
        echo "   Destino: $base_img"

        if ! docker tag "$local_img" "$base_img"; then
            print_error "Falha ao criar a tag Docker para '$app'."
            FAILED_APPS+=("$app")
            echo "-----------------------------------"
            continue
        fi
        print_success "Tag criada com sucesso: $base_img"

        # 3. Executa o docker push (se habilitado)
        if [ "$DO_PUSH" = true ]; then
            print_docker "Enviando imagem base para o Docker Hub..."
            if ! docker push "$base_img"; then
                print_error "Falha ao enviar '$base_img' para o Docker Hub."
                FAILED_APPS+=("$app")
                echo "-----------------------------------"
                continue
            fi
            print_success "Push concluído com sucesso: $base_img"
        else
            print_warning "Push desabilitado (--no-push / --tag-only). Imagem base mantida apenas localmente."
        fi

        echo "-----------------------------------"
    done

# ----------------------------------------------------
#   SEÇÃO 6: FINALIZAÇÃO
# ----------------------------------------------------

    if [[ ${#FAILED_APPS[@]} -eq 0 ]]; then
        print_banner "PROCESSO DE IMAGEBASE CONCLUÍDO COM SUCESSO"
        exit 0
    else
        print_banner "FALHA EM UM OU MAIS SERVIÇOS"
        print_error "Os seguintes serviços falharam: ${FAILED_APPS[*]}"
        exit 1
    fi
