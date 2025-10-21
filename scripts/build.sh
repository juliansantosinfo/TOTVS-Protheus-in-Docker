#!/bin/bash
#
# ==============================================================================
# SCRIPT: master-build.sh
# DESCRIÇÃO: Script mestre para automatizar o processo de build de múltiplas
#            aplicações Docker (appserver, dbaccess, etc.) a partir da raiz do projeto.
#            Se nenhuma aplicação for especificada, todas serão construídas.
# AUTOR: Julian de Almeidad Santos
# DATA: 2025-10-12
# USO: ./master-build.sh [<app1> [app2] [...]] [plain | auto | tty]
#
# Exemplo 1: ./master-build.sh # Constrói TODAS as aplicações
# Exemplo 2: ./master-build.sh appserver dbaccess
# Exemplo 3: ./master-build.sh licenseserver plain
#
# Argumentos obrigatórios (se fornecidos): Nomes das aplicações (appserver, dbaccess, licenseserver, mssql, postgres).
# Argumentos opcionais (devem vir por último):
#   - Modo de Progress (Argumento 1): 'plain', 'auto', ou 'tty' (Opcional, padrão no script filho).
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
set -euo pipefail

# --- Variáveis de Configuração ---
# Lista de aplicações válidas no seu projeto.
readonly VALID_APPS=("appserver" "dbaccess" "licenseserver" "mssql" "postgres")
# Armazena os nomes das aplicações que serão construídas.
APPS_TO_BUILD=()
# Variáveis para repassar os argumentos opcionais (progress).
PROGRESS_ARG="auto"
PROMPT_ARG="auto"

# ----------------------------------------------------
#               FUNÇÃO DE VALIDAÇÃO
# ----------------------------------------------------

# Função auxiliar para verificar se um item está na lista de aplicações válidas.
is_valid_app() {
    local app_name="$1"
    for valid_app in "${VALID_APPS[@]}"; do
        if [ "$app_name" == "$valid_app" ]; then
            return 0 # 0 é sucesso (verdadeiro)
        fi
    done
    return 1 # 1 é falha (falso)
}

# ----------------------------------------------------
#               PROCESSAMENTO DE ARGUMENTOS
# ----------------------------------------------------

# Itera sobre todos os argumentos passados para separar as aplicações dos parâmetros.
for arg in "$@"; do
    case "$arg" in
        # Captura os argumentos opcionais de modo (progress)
        "plain" | "auto" | "tty")
            PROGRESS_ARG="$arg"
            ;;
        "no-prompt" | "noprompt")
            PROMPT_ARG="$arg"
            ;;
        # Se não for um argumento de modo conhecido, trata como nome de aplicação.
        *)
            if is_valid_app "$arg"; then
                APPS_TO_BUILD+=("$arg")
            # Se o argumento não for um app válido nem um parâmetro de modo, ele é ignorado.
            else
                echo "⚠️ Aviso: O argumento '$arg' não é um nome de aplicação ou parâmetro válido e será ignorado." >&2
            fi
            ;;
    esac
done

# --- NOVO BLOCO DE LÓGICA ---
# Se a lista de aplicações para construir estiver vazia, use TODAS as aplicações válidas.
if [ ${#APPS_TO_BUILD[@]} -eq 0 ]; then
    echo "ℹ️ Nenhuma aplicação especificada. Construindo TODAS as aplicações válidas."
    APPS_TO_BUILD=("${VALID_APPS[@]}")
fi

# ----------------------------------------------------
#               FLUXO PRINCIPAL: EXECUÇÃO DOS BUILDS
# ----------------------------------------------------

echo ""
echo "--- Etapa: Execução de Builds ---"

echo "=========================================================="
echo "🎯 INICIANDO BUILD MASTER: ${APPS_TO_BUILD[*]}"
echo "Parâmetros repassados: Progress='${PROGRESS_ARG:-padrão do script filho}'"
echo "=========================================================="

# Variável de controle para rastrear o sucesso de todos os builds.
MASTER_SUCCESS=true

# Loop sobre a lista de aplicações para construir.
for APP_NAME in "${APPS_TO_BUILD[@]}"; do
    
    echo ""
    echo ">>> 🏗️ INICIANDO BUILD PARA APLICAÇÃO: $APP_NAME <<<"
    
    # Monta o caminho completo do script específico.
    SCRIPT_PATH="./${APP_NAME}/build.sh"

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "🚨 ERRO: Script específico não encontrado: $SCRIPT_PATH" >&2
        MASTER_SUCCESS=false
        continue # Pula para a próxima aplicação no loop
    fi

    # Executa o script filho, repassando os argumentos de progress.
    echo "➡️ Chamando script: $SCRIPT_PATH ${PROGRESS_ARG} ${PROMPT_ARG}"
    
    # Usa 'bash' explicitamente e verifica o status de saída.
    if ! bash "$SCRIPT_PATH" "$PROGRESS_ARG" "${PROMPT_ARG}"; then
        echo "❌ FALHA: O script de build para '$APP_NAME' falhou." >&2
        MASTER_SUCCESS=false
    else
        echo "✅ SUCESSO: Build para '$APP_NAME' concluído."
    fi

    echo ">>> FIM DO BUILD PARA $APP_NAME <<<"
    echo ""

done

# ----------------------------------------------------
#               PUSH DE IMAGENS PARA DOCKERHUB
# ----------------------------------------------------

echo ""
echo "--- Etapa: Publicação no DockerHub ---"

# Lembrete de Login: Garante que o usuário esteja autenticado.
echo "⚠️ Certifique-se de estar logado no Docker Hub: (docker login)"
read -p "Deseja enviar TODAS as imagens criadas para o DockerHub? (s/n) " execute_push

if [[ "$execute_push" =~ ^[Ss]$ ]]; then

    echo ">>> 🔄 INICIANDO PUSH PARA DOCKERHUB: <<<"

    # Usando a estrutura <USUARIO>/<IMAGEM>:<TAG> para cada serviço.
    readonly DOCKER_TAG_APPSERVER="juliansantosinfo/totvs_appserver:12.1.2310"
    readonly DOCKER_TAG_DBACCESS="juliansantosinfo/totvs_dbaccess:23.1.1.4"
    readonly DOCKER_TAG_LICENSE="juliansantosinfo/totvs_licenseserver:3.6.1"
    readonly DOCKER_TAG_MSSQL="juliansantosinfo/totvs_mssql:12.1.2310"
    readonly DOCKER_TAG_POSTGRES="juliansantosinfo/totvs_postgres:12.1.2310"

    readonly IMAGES_TO_PUSH=(
        "$DOCKER_TAG_APPSERVER"
        "$DOCKER_TAG_DBACCESS"
        "$DOCKER_TAG_LICENSE"
        "$DOCKER_TAG_MSSQL"
        "$DOCKER_TAG_POSTGRES"
    )
    
    # Itera sobre o array de tags e envia uma por uma.
    for tag in "${IMAGES_TO_PUSH[@]}"; do
        echo "➡️ Enviando imagem: $tag"
        # O 'set -e' no início do script garantirá que ele pare se qualquer 'docker push' falhar.
        if docker push "$tag"; then
            echo "✅ Push de '$tag' concluído."
        else
            echo "❌ Falha ao enviar '$tag'. Continuar ou abortar?" >&2
            # Se você quiser que o script pare na falha, não precisa do 'if/else',
            # o 'set -e' já cuida disso. Mantive o 'if' para melhor feedback.
        fi
    done
    
    echo "🎉 Processo de Push finalizado."
    echo ">>> FIM DO PUSH PARA DOCKERHUB <<<"
    echo ""
else
    echo "⏭️ Push para DockerHub ignorado."
fi

# ----------------------------------------------------
#               FINALIZAÇÃO
# ----------------------------------------------------

if [ "$MASTER_SUCCESS" = true ]; then
    echo "=========================================================="
    echo "🎉 SUCESSO GERAL: Todos os builds solicitados foram concluídos!"
    echo "=========================================================="
    exit 0
else
    echo "=========================================================="
    echo "🛑 FALHA GERAL: Um ou mais builds falharam. Verifique os logs acima." >&2
    echo "=========================================================="
    exit 1
fi