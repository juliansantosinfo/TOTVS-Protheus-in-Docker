#!/bin/bash
#
# ==============================================================================
# SCRIPT: status.sh
# DESCRIÇÃO: Diagnóstico Inteligente (Cockpit do Mantenedor) para o projeto
#            TOTVS-Protheus-in-Docker. Exibe um raio-X unificado de branches,
#            submódulos, consistência de versões, pacotes/recursos, Git Hooks
#            e imagens Docker locais, sugerindo (ou aplicando com --fix) os
#            próximos passos de manutenção.
# AUTOR: Julian de Almeida Santos
# DATA: 2026-10-17
# USO: ./scripts/validation/status.sh [--fix]
# ==============================================================================

set -euo pipefail

# ----------------------------------------------------
#   SEÇÃO 1: CORES E VARIÁVEIS GLOBAIS
# ----------------------------------------------------

    BOLD='\033[1m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    CYAN='\033[0;36m'
    BLUE='\033[0;34m'
    GRAY='\033[0;90m'
    NC='\033[0m'

    AUTO_FIX=false
    if [[ "${1:-}" == "--fix" ]]; then
        AUTO_FIX=true
    elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        echo "Uso: ./scripts/validation/status.sh [--fix]"
        echo ""
        echo "Opções:"
        echo "  --fix     Corrige automaticamente hooks, .env, versões e branches de submódulos"
        echo "  -h,--help Exibe esta ajuda"
        exit 0
    fi

    if [ ! -f "versions.env" ] && [ -f "../../versions.env" ]; then
        cd ../..
    fi

    if [ ! -f "versions.env" ]; then
        echo -e "${RED}❌ Erro: Execute este script a partir da raiz do projeto TOTVS-Protheus-in-Docker.${NC}" >&2
        exit 1
    fi

    # shellcheck source=versions.env
    source "versions.env"

    SERVICES=("appserver" "dbaccess" "licenseserver" "smartview" "postgres" "mssql" "oracle")
    RECOMMENDATIONS=()
    WARNINGS_COUNT=0
    ERRORS_COUNT=0

# ----------------------------------------------------
#   SEÇÃO 2: FUNÇÕES AUXILIARES DE INSPEÇÃO
# ----------------------------------------------------

    add_recommendation() {
        local msg="$1"
        local item
        for item in "${RECOMMENDATIONS[@]+"${RECOMMENDATIONS[@]}"}"; do
            if [[ "$item" == "$msg" ]]; then
                return 0
            fi
        done
        RECOMMENDATIONS+=("$msg")
    }

    get_expected_branch() {
        local service="$1"
        local root_version="$2"

        case "$root_version" in
            "12.1.2310")
                case "$service" in
                    appserver)     echo "12.1.2310"      ;;
                    dbaccess)      echo "v23.1.1.7"      ;;
                    postgres)      echo "v15"            ;;
                    mssql)         echo "v2019"          ;;
                    oracle)        echo "v21.3.0"        ;;
                    licenseserver) echo "v3.6.1"         ;;
                    smartview)     echo "v3.9.0.4558336" ;;
                esac ;;
            "12.1.2410")
                case "$service" in
                    appserver)     echo "12.1.2410"      ;;
                    dbaccess)      echo "v24.1.1.0"      ;;
                    postgres)      echo "v15"            ;;
                    mssql)         echo "v2019"          ;;
                    oracle)        echo "v21.3.0"        ;;
                    licenseserver) echo "v3.7.0"         ;;
                    smartview)     echo "v3.9.0.4558336" ;;
                esac ;;
            "12.1.2510")
                case "$service" in
                    appserver)     echo "12.1.2510"      ;;
                    dbaccess)      echo "v24.1.1.0"      ;;
                    postgres)      echo "v15"            ;;
                    mssql)         echo "v2019"          ;;
                    oracle)        echo "v21.3.0"        ;;
                    licenseserver) echo "v3.7.0"         ;;
                    smartview)     echo "v3.9.0.4558336" ;;
                esac ;;
            "12.1.2610")
                case "$service" in
                    appserver)     echo "12.1.2610"      ;;
                    dbaccess)      echo "v26.1.0.0"      ;;
                    postgres)      echo "v15"            ;;
                    mssql)         echo "v2019"          ;;
                    oracle)        echo "v21.3.0"        ;;
                    licenseserver) echo "v3.7.2"         ;;
                    smartview)     echo "v3.9.0.4558336" ;;
                esac ;;
            "main"|"master")
                echo "main" ;;
            *)
                get_expected_branch "$service" "${APPSERVER_RELEASE}" ;;
        esac
    }

    get_service_version() {
        local service="$1"
        case "$service" in
            appserver)     echo "${APPSERVER_VERSION}"     ;;
            dbaccess)      echo "${DBACCESS_VERSION}"      ;;
            licenseserver) echo "${LICENSESERVER_VERSION}" ;;
            smartview)     echo "${SMARTVIEW_VERSION}"     ;;
            postgres)      echo "${POSTGRES_VERSION}"      ;;
            mssql)         echo "${MSSQL_VERSION}"         ;;
            oracle)        echo "${ORACLE_VERSION}"        ;;
        esac
    }

    get_service_image_name() {
        local service="$1"
        case "$service" in
            appserver)     echo "${APPSERVER_IMAGE_NAME}"     ;;
            dbaccess)      echo "${DBACCESS_IMAGE_NAME}"      ;;
            licenseserver) echo "${LICENSESERVER_IMAGE_NAME}" ;;
            smartview)     echo "${SMARTVIEW_IMAGE_NAME}"     ;;
            postgres)      echo "${POSTGRES_IMAGE_NAME}"      ;;
            mssql)         echo "${MSSQL_IMAGE_NAME}"         ;;
            oracle)        echo "${ORACLE_IMAGE_NAME}"        ;;
        esac
    }

    check_service_versions_sync() {
        local service="$1"
        local dockerfile="services/${service}/Dockerfile"
        local sub_env="services/${service}/versions.env"
        local exp_ver
        exp_ver=$(get_service_version "$service")
        local img_name
        img_name=$(get_service_image_name "$service")

        if [ ! -f "$dockerfile" ] || [ ! -f "$sub_env" ]; then
            echo "missing"
            return
        fi

        # 1. Valida Dockerfile
        if [ "$service" == "appserver" ]; then
            local r b d w
            r=$(grep -iE "^LABEL release=" "$dockerfile" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")
            b=$(grep -iE "^LABEL build=" "$dockerfile" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")
            d=$(grep -iE "^LABEL dbapi=" "$dockerfile" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")
            w=$(grep -iE "^LABEL webapp=" "$dockerfile" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")
            if [[ "$r" != "$APPSERVER_VERSION" || "$b" != "$APPSERVER_BUILD_VERSION" || "$d" != "$APPSERVER_DBAPI_VERSION" || "$w" != "$APPSERVER_WEBAPP_VERSION" ]]; then
                echo "mismatch"
                return
            fi
        else
            local v
            v=$(grep -iE "^LABEL version=" "$dockerfile" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")
            if [[ "$v" != "$exp_ver" ]]; then
                echo "mismatch"
                return
            fi
        fi

        # 2. Valida versions.env interno do submódulo
        local sub_user
        sub_user=$(grep -E "^DOCKER_USER=" "$sub_env" | head -n 1 | cut -d'=' -f2- | tr -d '"' | tr -d "[:space:]")
        if [[ "$sub_user" != "$DOCKER_USER" ]]; then
            echo "mismatch"
            return
        fi

        # 3. Valida docker-compose*.yaml
        local expected_img="${DOCKER_USER}/${img_name}:${exp_ver}"
        local cf
        for cf in docker-compose.yaml docker-compose-mssql.yaml docker-compose-postgresql.yaml docker-compose-oracle.yaml; do
            if [ -f "$cf" ] && grep -qE "image:[[:space:]]*[^[:space:]]*/${img_name}:" "$cf"; then
                if grep -E "image:[[:space:]]*[^[:space:]]*/${img_name}:" "$cf" | grep -qvE "image:[[:space:]]*${expected_img}([[:space:]]|$)"; then
                    echo "mismatch"
                    return
                fi
            fi
        done

        echo "ok"
    }

    check_service_packages() {
        local service="$1"
        local pkg_dir="services/${service}/packages"
        local has_raw_pkgs=false

        if [ -d "$pkg_dir" ]; then
            local raw_count
            raw_count=$(find "$pkg_dir" -maxdepth 1 -type f \( -iname "*.tar.gz" -o -iname "*.zip" -o -iname "*.rpo" \) 2>/dev/null | wc -l)
            if [ "$raw_count" -gt 0 ]; then
                has_raw_pkgs=true
            fi
        fi

        case "$service" in
            appserver)
                if [ -f "services/appserver/totvs/protheus/bin/appserver/appsrvlinux" ] && \
                   [ -f "services/appserver/totvs/protheus/bin/appserver/webapp.so" ] && \
                   compgen -G "services/appserver/totvs/protheus/apo/ttt*120.rpo" >/dev/null; then
                    echo "extracted"
                elif [ "$has_raw_pkgs" = true ]; then
                    echo "needs_setup"
                else
                    echo "no_packages"
                fi
                ;;
            dbaccess)
                if [ -f "services/dbaccess/totvs/dbaccess/multi/dbaccess64" ]; then
                    echo "extracted"
                elif [ "$has_raw_pkgs" = true ]; then
                    echo "needs_setup"
                else
                    echo "no_packages"
                fi
                ;;
            licenseserver)
                if [ -f "services/licenseserver/totvs/installer.jar" ]; then
                    echo "extracted"
                elif [ "$has_raw_pkgs" = true ]; then
                    echo "needs_setup"
                else
                    echo "no_packages"
                fi
                ;;
            smartview)
                if [ -f "services/smartview/totvs/smartview/TReports.Agent" ]; then
                    echo "extracted"
                elif [ "$has_raw_pkgs" = true ]; then
                    echo "needs_setup"
                else
                    echo "no_packages"
                fi
                ;;
            postgres|mssql|oracle)
                echo "na"
                ;;
        esac
    }

# ----------------------------------------------------
#   SEÇÃO 3: AUTO-FIX OPCIONAL (--fix)
# ----------------------------------------------------

    if [ "$AUTO_FIX" = true ]; then
        echo -e "${CYAN}${BOLD}🔧 Executando Auto-Fix do Diagnóstico Inteligente...${NC}"
        echo "------------------------------------------------------------------------"

        # 1. Instalar Git Hooks se faltarem
        if [ ! -x ".git/hooks/pre-commit" ] || [ ! -x ".git/hooks/commit-msg" ] || [ ! -x ".git/hooks/post-checkout" ]; then
            ./scripts/hooks/install.sh
        fi

        # 2. Criar .env se não existir
        if [ ! -f ".env" ] && [ -f ".env.example" ]; then
            cp .env.example .env
            echo -e "✅ Arquivo '.env' criado a partir de '.env.example'."
        fi

        # 3. Sincronizar versões (Dockerfiles + Compose + versions.env internos)
        ./scripts/validation/versions.sh --fix

        echo "------------------------------------------------------------------------"
        echo ""
    fi

# ----------------------------------------------------
#   SEÇÃO 4: DIAGNÓSTICO DO ROOT E AMBIENTE
# ----------------------------------------------------

    echo -e "${CYAN}${BOLD}=======================================================================================${NC}"
    echo -e "${CYAN}${BOLD}🩺 DIAGNÓSTICO DO PROJETO — TOTVS Protheus in Docker (Cockpit do Mantenedor)${NC}"
    echo -e "${CYAN}${BOLD}=======================================================================================${NC}"

    ROOT_BRANCH=$(git branch --show-current || echo "DETACHED")
    if [ -z "$ROOT_BRANCH" ]; then
        ROOT_BRANCH="DETACHED"
    fi

    ROOT_DIRTY_COUNT=$(git status --porcelain | wc -l)
    ROOT_SUBMODULE_MODIFIED=$(git status --porcelain | grep -cE "^.M services/|^M  services/" || true)

    # Verifica Git Hooks
    HOOKS_OK=true
    for hook in pre-commit commit-msg post-checkout; do
        if [ ! -x ".git/hooks/$hook" ]; then
            HOOKS_OK=false
        fi
    done

    # Verifica .env
    ENV_STATUS="${GREEN}✅ Presente (.env)${NC}"
    if [ ! -f ".env" ]; then
        ENV_STATUS="${YELLOW}⚠️  Ausente (.env não criado)${NC}"
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
        add_recommendation "Criar arquivo .env local: cp .env.example .env (ou rode: make fix)"
    fi

    HOOKS_STATUS="${GREEN}✅ Ativos (pre-commit, commit-msg, post-checkout)${NC}"
    if [ "$HOOKS_OK" = false ]; then
        HOOKS_STATUS="${YELLOW}⚠️  Incompletos em .git/hooks/${NC}"
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
        add_recommendation "Instalar Git Hooks locais: ./scripts/hooks/install.sh (ou rode: make fix)"
    fi

    ROOT_GIT_STATUS="${GREEN}✅ Limpo${NC}"
    if [ "$ROOT_DIRTY_COUNT" -gt 0 ]; then
        ROOT_GIT_STATUS="${YELLOW}⚠️  ${ROOT_DIRTY_COUNT} alteração(ões) pendente(s)${NC}"
        if [ "$ROOT_SUBMODULE_MODIFIED" -gt 0 ]; then
            ROOT_GIT_STATUS="${ROOT_GIT_STATUS} ${BLUE}(${ROOT_SUBMODULE_MODIFIED} ponteiro(s) de submódulo)${NC}"
        fi
    fi

    # Verifica Docker Daemon e Containers ativos
    DOCKER_RUNNING=false
    DOCKER_IMAGES_LIST=""
    RUNNING_CONTAINERS=0
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        DOCKER_RUNNING=true
        DOCKER_IMAGES_LIST=$(docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || true)
        RUNNING_CONTAINERS=$(docker ps --filter "name=totvs_" --format "{{.Names}}" 2>/dev/null | wc -l)
    fi

    if [ "$DOCKER_RUNNING" = true ]; then
        if [ "$RUNNING_CONTAINERS" -gt 0 ]; then
            DOCKER_STATUS="${GREEN}✅ Ativo (${RUNNING_CONTAINERS} container(s) totvs_* em execução)${NC}"
        else
            DOCKER_STATUS="${GREEN}✅ Ativo (nenhum container totvs_* rodando)${NC}"
        fi
    else
        DOCKER_STATUS="${RED}❌ Docker Daemon indisponível ou sem permissão${NC}"
        ERRORS_COUNT=$((ERRORS_COUNT + 1))
    fi

    echo -e " 📌 ${BOLD}Release Alvo (versions.env):${NC} ${CYAN}${APPSERVER_RELEASE}${NC} (${RESOURCE_RELEASE}) | Docker Hub: ${BOLD}${DOCKER_USER}${NC}"
    echo -e " 🌿 ${BOLD}Repositório Root:${NC}            Branch ${BOLD}${ROOT_BRANCH}${NC} | Working Tree: ${ROOT_GIT_STATUS}"
    echo -e " 🪝 ${BOLD}Git Hooks:${NC}                   ${HOOKS_STATUS}"
    echo -e " ⚙️  ${BOLD}Configuração (.env):${NC}         ${ENV_STATUS}"
    echo -e " 🐳 ${BOLD}Docker Engine:${NC}               ${DOCKER_STATUS}"
    echo ""

# ----------------------------------------------------
#   SEÇÃO 5: MATRIZ UNIFICADA DOS 7 SERVIÇOS
# ----------------------------------------------------

    echo -e "${BOLD}📦 MATRIZ DE ESTADO DOS SUBMÓDULOS (services/*)${NC}"
    echo "------------------------------------------------------------------------------------------"
    printf " %-14s | %-20s | %-15s | %-16s | %-16s | %-12s\n" \
        "SERVIÇO" "BRANCH GIT" "STATUS GIT" "VERSÕES" "PACOTES/SETUP" "IMAGEM LOCAL"
    echo "------------------------------------------------------------------------------------------"

    NEEDS_VERSION_FIX=false
    NEEDS_BRANCH_SYNC=false
    SERVICES_NEEDING_SETUP=()
    SERVICES_NEEDING_IMAGEBASE=()
    DIRTY_SUBMODULES=()
    AHEAD_SUBMODULES=()

    for svc in "${SERVICES[@]}"; do
        svc_dir="services/${svc}"
        exp_branch=$(get_expected_branch "$svc" "$ROOT_BRANCH")
        exp_ver=$(get_service_version "$svc")
        img_name=$(get_service_image_name "$svc")
        full_img="${DOCKER_USER}/${img_name}:${exp_ver}"

        if [ ! -d "$svc_dir/.git" ] && [ ! -f "$svc_dir/.git" ]; then
            printf " %-14s | %-20s | %-15s | %-16s | %-16s | %-12s\n" \
                "$svc" "❌ Não inicializado" "-" "-" "-" "-"
            ERRORS_COUNT=$((ERRORS_COUNT + 1))
            add_recommendation "Inicializar submódulos Git: git submodule update --init --recursive"
            continue
        fi

        # 1. Branch do submódulo
        cur_branch=$(git -C "$svc_dir" branch --show-current 2>/dev/null || true)
        if [ -z "$cur_branch" ]; then
            branch_col="❌ DETACHED"
            ERRORS_COUNT=$((ERRORS_COUNT + 1))
            NEEDS_BRANCH_SYNC=true
        elif [ "$cur_branch" != "$exp_branch" ]; then
            branch_col="⚠️ ${cur_branch} (!=${exp_branch})"
            WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
            NEEDS_BRANCH_SYNC=true
        else
            branch_col="✅ ${cur_branch}"
        fi

        # 2. Status Git do submódulo (Dirty / Ahead)
        dirty_cnt=$(git -C "$svc_dir" status --porcelain 2>/dev/null | wc -l)
        ahead_cnt=0
        if [ -n "$cur_branch" ]; then
            ahead_cnt=$(git -C "$svc_dir" rev-list --count "origin/${cur_branch}..HEAD" 2>/dev/null || echo "0")
        fi

        if [ "$dirty_cnt" -gt 0 ]; then
            git_col="⚠️ Dirty (${dirty_cnt})"
            WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
            DIRTY_SUBMODULES+=("$svc")
        elif [ "$ahead_cnt" -gt 0 ]; then
            git_col="⬆️ Ahead (${ahead_cnt})"
            WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
            AHEAD_SUBMODULES+=("$svc")
        else
            git_col="✅ Limpo"
        fi

        # 3. Sincronia de Versões
        ver_state=$(check_service_versions_sync "$svc")
        if [ "$ver_state" == "ok" ]; then
            ver_col="✅ ${exp_ver}"
        else
            ver_col="❌ Divergente"
            ERRORS_COUNT=$((ERRORS_COUNT + 1))
            NEEDS_VERSION_FIX=true
        fi

        # 4. Pacotes / Setup
        pkg_state=$(check_service_packages "$svc")
        case "$pkg_state" in
            extracted)
                pkg_col="✅ Extraído"
                ;;
            needs_setup)
                pkg_col="⚠️ Falta setup"
                WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
                SERVICES_NEEDING_SETUP+=("$svc")
                ;;
            no_packages)
                pkg_col="⚪ Sem pacotes"
                ;;
            na)
                pkg_col="➖ N/A (SQL)"
                ;;
        esac

        # 5. Imagem Docker Local
        if [ "$DOCKER_RUNNING" = true ]; then
            if echo "$DOCKER_IMAGES_LIST" | grep -qx "$full_img"; then
                img_col="✅ Pronta"
                # Verifica se a tag IMAGE_BASE correspondente já foi gerada localmente
                sub_env="services/${svc}/versions.env"
                if [ -f "$sub_env" ]; then
                    exp_base=$(grep -E "^IMAGE_BASE=" "$sub_env" | head -n1 | cut -d"=" -f2- | tr -d "\"" | tr -d "'")
                    if [ -n "$exp_base" ] && ! echo "$DOCKER_IMAGES_LIST" | grep -qx "$exp_base"; then
                        SERVICES_NEEDING_IMAGEBASE+=("$svc")
                    fi
                fi
            else
                img_col="⚪ Ausente"
            fi
        else
            img_col="❓ Off"
        fi

        printf " %-14s | %-21s | %-16s | %-17s | %-17s | %-12s\n" \
            "$svc" "$branch_col" "$git_col" "$ver_col" "$pkg_col" "$img_col"
    done

    echo "------------------------------------------------------------------------------------------"

# ----------------------------------------------------
#   SEÇÃO 6: CONSTRUÇÃO DAS RECOMENDAÇÕES ORDENADAS
# ----------------------------------------------------

    if [ "$NEEDS_BRANCH_SYNC" = true ]; then
        target_b="$ROOT_BRANCH"
        [[ "$target_b" == "DETACHED" ]] && target_b="${APPSERVER_RELEASE}"
        add_recommendation "Alinhar branches dos submódulos: ./scripts/validation/branch-checkout.sh ${target_b} (ou: make checkout V=${target_b})"
    fi

    if [ "$NEEDS_VERSION_FIX" = true ]; then
        add_recommendation "Sincronizar versions.env com Dockerfiles e Compose: ./scripts/validation/versions.sh --fix (ou: make fix)"
    fi

    if [ ${#SERVICES_NEEDING_SETUP[@]} -gt 0 ]; then
        add_recommendation "Extrair pacotes depositados em packages/: ./scripts/build/setup.sh ${SERVICES_NEEDING_SETUP[*]} (ou: make setup)"
    fi

    if [ ${#SERVICES_NEEDING_IMAGEBASE[@]} -gt 0 ]; then
        add_recommendation "Imagem(ns) base privada(s) pendente(s) de tag/push (${SERVICES_NEEDING_IMAGEBASE[*]}): Execute 'make imagebase APP=\"${SERVICES_NEEDING_IMAGEBASE[*]}\"' antes de subir alterações para o GitHub."
    fi

    if [ ${#DIRTY_SUBMODULES[@]} -gt 0 ]; then
        add_recommendation "Submódulo(s) com arquivos modificados (${DIRTY_SUBMODULES[*]}): Faça commit/push DENTRO de services/<app> antes de commitar na raiz."
    fi

    if [ ${#AHEAD_SUBMODULES[@]} -gt 0 ]; then
        add_recommendation "Submódulo(s) com commits locais não enviados (${AHEAD_SUBMODULES[*]}): Execute 'git -C services/<app> push' antes de commitar o ponteiro no root."
    fi

    if [ "$ROOT_SUBMODULE_MODIFIED" -gt 0 ] && [ ${#DIRTY_SUBMODULES[@]} -eq 0 ] && [ ${#AHEAD_SUBMODULES[@]} -eq 0 ]; then
        add_recommendation "Ponteiros de submódulos atualizados na raiz: Execute 'git add services/ && git commit -m \"chore: atualizar ponteiros de submodulos\"'."
    fi

# ----------------------------------------------------
#   SEÇÃO 7: EXIBIÇÃO DO GUIA DE PRÓXIMOS PASSOS
# ----------------------------------------------------

    echo ""
    if [ ${#RECOMMENDATIONS[@]} -eq 0 ]; then
        echo -e "${GREEN}${BOLD}🎉 Tudo 100% sincronizado! Nenhuma pendência estrutural detectada.${NC}"
        echo -e "${GRAY}💡 Atalhos rápidos: 'make help' (ver comandos) | 'make build' (compilar imagens) | 'make validate' (rodar linters) | './run.sh' (subir stack)${NC}"
    else
        echo -e "${YELLOW}${BOLD}🧭 PRÓXIMOS PASSOS RECOMENDADOS (na ordem de execução):${NC}"
        step=1
        for rec in "${RECOMMENDATIONS[@]}"; do
            echo -e "   ${BOLD}${step}.${NC} ${rec}"
            step=$((step + 1))
        done
        echo ""
        echo -e "${GRAY}💡 Dica: Rode './scripts/validation/status.sh --fix' (ou 'make fix') para corrigir automaticamente versões, hooks e .env.${NC}"
    fi
    echo -e "${CYAN}${BOLD}=======================================================================================${NC}"
