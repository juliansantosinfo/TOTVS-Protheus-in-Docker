#!/bin/bash
#
# ==============================================================================
# SCRIPT: setup.sh
# DESCRIÇÃO: Script unificado para automatizar o download, montagem e extração 
#            dos pacotes do projeto TOTVS-Protheus-in-Docker a partir do GitHub.
#            Suporta módulos: appserver, dbaccess, licenseserver, mssql, postgres,
#            oracle e smartview.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-16
# USO: ./scripts/build/setup.sh [modulo]
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
set -euo pipefail

# Caminho para o versions.env (assumindo execução da raiz ou de scripts/validation/)
if [ -f "versions.env" ]; then
    source "versions.env"
elif [ -f "../../versions.env" ]; then
    source "../../versions.env"
    # Ajusta o path se estiver rodando de dentro de scripts/validation/
    cd ../..
else
    echo "🚨 Erro: Arquivo 'versions.env' não encontrado."
    exit 1
fi

# --- CONFIGURAÇÕES GERAIS ---
GH_OWNER="juliansantosinfo"
GH_REPO="TOTVS-Protheus-in-Docker-Resources"
GH_BRANCH="main"
GH_RELEASE="${RESOURCE_RELEASE:-}"

# --- FUNÇÃO: Exibir ajuda ---
mostrar_ajuda() {
    echo "Uso: $0 [modulo]"
    echo ""
    echo "Modulos disponíveis:"
    echo "  appserver      - Baixa os arquivos do AppServer"
    echo "  dbaccess       - Baixa e extrai os arquivos do DBAccess"
    echo "  licenseserver  - Baixa e extrai os arquivos do License Server"
    echo "  mssql          - Baixa os arquivos do MSSQL"
    echo "  postgres       - Baixa os arquivos do PostgreSQL"
    echo "  oracle         - Baixa os arquivos do Oracle"
    echo "  smartview      - Baixa os arquivos do SmartView"
    echo ""
    echo "Se nenhum módulo for informado, todos serão processados."
    echo ""
}

# --- FUNÇÃO: Processar módulo ---
processar_modulo() {
    local MODULO="$1"
    local GH_PATH DOWNLOAD_DIR DEST_DIR FILES API_URL

    case "$MODULO" in
        appserver)
            GH_PATH="${GH_RELEASE}/appserver"
            DOWNLOAD_DIR="/tmp/${GH_RELEASE}/appserver"
            DEST_DIR="appserver/totvs"
            FILES=("protheus.tar.gz" "protheus_data.tar.gz")
            ;;
        dbaccess)
            GH_PATH="${GH_RELEASE}/dbaccess"
            DOWNLOAD_DIR="/tmp/${GH_RELEASE}/dbaccess"
            DEST_DIR="dbaccess/totvs"
            FILES=("dbaccess.tar.gz")
            ;;
        licenseserver)
            GH_PATH="${GH_RELEASE}/licenseserver"
            DOWNLOAD_DIR="/tmp/${GH_RELEASE}/licenseserver"
            DEST_DIR="licenseserver/totvs"
            FILES=("licenseserver.tar.gz")
            ;;
        mssql)
            GH_PATH="${GH_RELEASE}/mssql"
            DOWNLOAD_DIR="/tmp/${GH_RELEASE}/mssql"
            DEST_DIR="mssql/resources"
            FILES=("data.tar.gz")
            ;;
        postgres)
            GH_PATH="${GH_RELEASE}/postgres"
            DOWNLOAD_DIR="/tmp/${GH_RELEASE}/postgres"
            DEST_DIR="postgres/resources"
            FILES=("data.tar.gz")
            ;;
        oracle)
            GH_PATH="${GH_RELEASE}/oracle"
            DOWNLOAD_DIR="/tmp/${GH_RELEASE}/oracle"
            DEST_DIR="oracle/resources"
            FILES=("data.tar.gz")
            ;;
        smartview)
            GH_PATH="smartview/3.9.0.4558336"
            DOWNLOAD_DIR="/tmp/smartview"
            DEST_DIR="smartview/totvs"
            FILES=("smartview.tar.gz")
            ;;
        *)
            echo "❌ Módulo inválido: $MODULO"
            return 1
            ;;
    esac

    API_URL="https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/contents/${GH_PATH}?ref=${GH_BRANCH}"

    echo "=========================================="
    echo "🔧 Iniciando setup do módulo: ${MODULO}"
    echo "Repositório: ${GH_OWNER}/${GH_REPO}"
    echo "Pasta: ${GH_PATH}"
    echo "Branch: ${GH_BRANCH}"
    echo "=========================================="
    echo ""

    mkdir -p "${DOWNLOAD_DIR}" "${DEST_DIR}"

    # --- DOWNLOAD DOS ARQUIVOS ---

    echo "🔍 Consultando recursos locais em no diretório temporário..."
    echo "Diretório Temporário: ${DOWNLOAD_DIR}"
    
    if ! ls "${DOWNLOAD_DIR}/*" >/dev/null 2>&1; then
    
        echo "🔍 Consultando API do GitHub..."
        echo "URL: ${API_URL}"
    
        curl -s "${API_URL}" | jq -r '.[] | select(.type=="file") | .download_url' | while read -r file_url; do
            if [ -n "$file_url" ]; then
                file_name=$(basename "${file_url}")
                echo "⬇️  Baixando arquivo: ${file_name}"
                curl -sL "${file_url}" -o "${DOWNLOAD_DIR}/${file_name}"
                [[ $? -eq 0 ]] && echo "✅ Download concluído: ${file_name}" || echo "❌ Erro ao baixar ${file_name}"
            fi
        done
    else
        echo "⏭️ Ignorando download, arquivos disponíveus localmente."
    fi

    # --- JUNTA PARTES DIVIDIDAS ---
    echo ""
    echo "🧩 Verificando partes divididas..."
    for file in "${FILES[@]}"; do
        if [[ "$file" == "protheus_data.tar.gz" && "$GH_RELEASE" != "release2310" ]]; then
            echo "⏭️ Ignorando arquivo ${file}"
            continue
        fi
        if [[ -f "${DOWNLOAD_DIR}/$file" ]]; then
            echo "⏭️ Ignorando arquivo ${file}"
            continue
        fi
        if ls "${DOWNLOAD_DIR}/${file}"* >/dev/null 2>&1; then
            echo "🔗 Montando ${file} a partir das partes..."
            cat "${DOWNLOAD_DIR}/${file}"* > "${DOWNLOAD_DIR}/${file}"
        else
            echo "⚠️ Nenhuma parte encontrada para ${file}"
        fi
    done

    # --- EXTRAÇÃO OU CÓPIA ---
    if [[ "$MODULO" =~ ^(dbaccess|licenseserver)$ ]]; then
        echo ""
        echo "📦 Iniciando extração dos arquivos..."
        for file in "${FILES[@]}"; do
            if [ -f "${DOWNLOAD_DIR}/${file}" ]; then
                echo "📂 Extraindo ${file} para ${DEST_DIR}"
                tar -xzf "${DOWNLOAD_DIR}/${file}" -C "${DEST_DIR}/"
            else
                echo "⚠️ Arquivo ${file} não encontrado para extração."
            fi
        done
    else
        echo ""
        echo "📂 Copiando arquivos para ${DEST_DIR}"
        for file in "${FILES[@]}"; do
            if [ -f "${DOWNLOAD_DIR}/${file}" ]; then
                cp "${DOWNLOAD_DIR}/${file}" "${DEST_DIR}/"
                echo "✅ Copiado: ${file}"
            else
                echo "⚠️ Arquivo não encontrado: ${file}"
            fi
        done
    fi

    echo ""
    echo "------------------------------------------"
    echo "✅ Processo concluído para o módulo: ${MODULO}"
    echo "Arquivos baixados em: ${DOWNLOAD_DIR}"
    echo "Arquivos finais em: ${DEST_DIR}"
    echo "------------------------------------------"
    echo ""
}

# Função auxiliar para remover arquivos e diretórios com verificação
remove_item() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "🧹 Removendo: $path"
    rm -rf "$path"
  else
    echo "ℹ️  Ignorado (não existe): $path"
  fi
}

# Executa o script clean.sh localizado no mesmo diretório que este script
# read -p "Deseja limpar os resources existentes antes de executar o setup (s/N)? " execute_clean
# echo ""

# if [[ "$execute_clean" =~ ^[Ss]$ ]]; then
#     "$(dirname "$0")/clean.sh"
# fi

# --- EXECUÇÃO PRINCIPAL ---
if [[ -n "$1" ]]; then
    MODULOS=("$1")
else
    echo "⚙️ Nenhum módulo informado — todos serão processados."
    MODULOS=("appserver" "dbaccess" "licenseserver" "mssql" "postgres" "oracle" "smartview")
fi

for mod in "${MODULOS[@]}"; do
    processar_modulo "$mod"
done

echo "=========================================="
echo "🏁 Todos os módulos foram processados com sucesso!"
echo "=========================================="
echo ""
