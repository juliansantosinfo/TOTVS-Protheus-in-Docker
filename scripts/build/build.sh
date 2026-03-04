#!/bin/bash
#
# ==============================================================================
# SCRIPT: build.sh
# DESCRIÇÃO: Script mestre para automatizar o processo de build de múltiplas
#            aplicações Docker (appserver, dbaccess, etc.) a partir da raiz do projeto.
#            Se nenhuma aplicação for especificada, todas serão construídas.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-12
# USO: ./scripts/build/build.sh [<app1> [app2] [...]] [plain | auto | tty]
#
# Exemplo 1: ./scripts/build/build.sh # Constrói TODAS as aplicações
# Exemplo 2: ./scripts/build/build.sh appserver dbaccess
# Exemplo 3: ./scripts/build/build.sh licenseserver plain
#
# Argumentos obrigatórios (se fornecidos): Nomes das aplicações (appserver, dbaccess, licenseserver, mssql, postgres, oracle, smartview).
# Argumentos opcionais (devem vir por último):
#   - Modo de Progress (Argumento 1): 'plain', 'auto', ou 'tty' (Opcional, padrão no script filho).
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
set -euo pipefail

# --- Variáveis de Configuração ---
# Lista de aplicações válidas no seu projeto.
readonly VALID_APPS=("appserver" "dbaccess" "licenseserver" "mssql" "postgres" "oracle" "smartview")

# --- Carregar Versões Centralizadas ---
if [ -f "versions.env" ]; then
    source "versions.env"
else
    echo "🚨 Erro: Arquivo 'versions.env' não encontrado. O script deve ser executado na raiz do projeto."
    exit 1
fi

# Armazena os nomes das aplicações que serão construídas.
APPS_TO_BUILD=()
# Variáveis para repassar os argumentos opcionais.
PROMPT_ARG=""

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
        "--progress=plain" | "--progress=auto" | "--progress=tty" | "--no-cache" | "--no-extract")
            PROMPT_ARG=" $arg"
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
echo "Parâmetros repassados: $PROMPT_ARG"
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
    echo "➡️ Chamando script: ${SCRIPT_PATH}${PROMPT_ARG}"

    # Usa 'bash' explicitamente e verifica o status de saída.
    if ! bash "${SCRIPT_PATH}${PROMPT_ARG}"; then
        echo "❌ FALHA: O script de build para '$APP_NAME' falhou." >&2
        MASTER_SUCCESS=false
    else
        echo "✅ SUCESSO: Build para '$APP_NAME' concluído."
    fi

    echo ">>> FIM DO BUILD PARA $APP_NAME <<<"
    echo ""

done

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