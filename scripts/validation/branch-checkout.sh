#!/bin/bash

# ==============================================================================
# Script: branch-checkout.sh
#
# DESCRIÇÃO: Executa branch-checkout para definir a branch correta para o 
#            repositório root e todos os seus módulos.
#
# AUTOR: Julian de Almeida Santos
# DATA: 2026-03-08
#
# COMO USAR:
#   ./branch-checkout.sh 12.1.2310
#   ./branch-checkout.sh 12.1.2410
#   ./branch-checkout.sh 12.1.2510
#   ./branch-checkout.sh main
# ==============================================================================


# ========================
# TABELA DE VERSÕES
# ========================
# Cada versão do Root tem uma lista de serviços com suas branches correspondentes.
# Para adicionar uma versão nova, basta copiar um bloco e alterar os valores.

obter_branch_do_servico() {
    local SERVICO="$1"    # Ex: "appserver", "dbaccess"
    local VERSAO="$2"     # Ex: "12.1.2310", "main"

    case "$VERSAO" in

        "12.1.2310")
            case "$SERVICO" in
                appserver)     echo "12.1.2310"         ;;
                dbaccess)      echo "v23.1.1.7"         ;;
                postgres)      echo "v15"               ;;
                mssql)         echo "v2019"             ;;
                oracle)        echo "v21.3.0"           ;;
                licenseserver) echo "v3.6.1"            ;;
                smartview)     echo "v3.9.0.4558336"    ;;
            esac ;;

        "12.1.2410")
            case "$SERVICO" in
                appserver)     echo "12.1.2410"         ;;
                dbaccess)      echo "v24.1.1.0"         ;;
                postgres)      echo "v15"               ;;
                mssql)         echo "v2019"             ;;
                oracle)        echo "v21.3.0"           ;;
                licenseserver) echo "v3.7.0"            ;;
                smartview)     echo "v3.9.0.4558336"    ;;
            esac ;;

        "12.1.2510")
            case "$SERVICO" in
                appserver)     echo "12.1.2510"         ;;
                dbaccess)      echo "v24.1.1.0"         ;;
                postgres)      echo "v15"               ;;
                mssql)         echo "v2019"             ;;
                oracle)        echo "v21.3.0"           ;;
                licenseserver) echo "v3.7.0"            ;;
                smartview)     echo "v3.9.0.4558336"    ;;
            esac ;;

        "main"|"master")
            case "$SERVICO" in
                appserver)     echo "main" ;;
                dbaccess)      echo "main" ;;
                postgres)      echo "main" ;;
                mssql)         echo "main" ;;
                oracle)        echo "main" ;;
                licenseserver) echo "main" ;;
                smartview)     echo "main" ;;
            esac ;;

    esac
}


# ========================
# FUNÇÃO: TROCAR DE BRANCH
# ========================
# Recebe uma pasta e o nome da branch, e faz o checkout + pull.

trocar_branch() {
    local PASTA="$1"
    local BRANCH="$2"
    local NOME
    NOME=$(basename "$PASTA")

    echo "--- $NOME ---"

    # Entra na pasta
    cd "$PASTA" || { echo "Não foi possível acessar a pasta: $PASTA"; return; }

    # Verifica se a branch existe (no computador ou no servidor remoto)
    local BRANCH_EXISTE=false
    git rev-parse --verify "$BRANCH"          >/dev/null 2>&1 && BRANCH_EXISTE=true
    git rev-parse --verify "origin/$BRANCH"   >/dev/null 2>&1 && BRANCH_EXISTE=true

    if [ "$BRANCH_EXISTE" = true ]; then
        echo "Trocando para a branch: $BRANCH"
        git checkout "$BRANCH" --quiet

        echo "Baixando atualizações..."
        git pull origin "$BRANCH" --rebase --quiet

        echo "OK!"
        echo ""
    else
        echo "ERRO: A branch '$BRANCH' não existe neste repositório."
        echo ""
        exit 1
    fi

    # Volta para a pasta anterior
    cd - > /dev/null || return
}


# ========================
# INÍCIO DO SCRIPT
# ========================

# Garante que o usuário informou a versão desejada
if [ -z "${1:-}" ]; then
    echo "Erro: Informe a versão que deseja usar."
    echo ""
    echo "Uso:      $0 [versão]"
    echo "Exemplos: $0 12.1.2310"
    echo "          $0 12.1.2410"
    echo "          $0 12.1.2510"
    echo "          $0 main"
    exit 1
fi

VERSAO_DESEJADA="$1"
PASTA_RAIZ=$(pwd)

# Garante que o script está sendo executado na pasta certa
if [ ! -f ".gitmodules" ]; then
    echo "Erro: Execute este script na raiz do projeto Protheus-in-Docker."
    exit 1
fi

echo "Iniciando para a versão: $VERSAO_DESEJADA"
echo ""

# Passo 1: Troca a branch do projeto principal (Root)
# Pode pular o root passando --skip-root como segundo argumento
if [ "${2:-}" != "--skip-root" ]; then
    trocar_branch "$PASTA_RAIZ" "$VERSAO_DESEJADA"
fi

# Passo 2: Troca a branch de cada serviço dentro da pasta "services/"
if [ ! -d "services" ]; then
    echo "Erro: A pasta 'services/' não foi encontrada."
    exit 1
fi

for PASTA_SERVICO in services/*/; do
    NOME_SERVICO=$(basename "$PASTA_SERVICO")

    # Descobre qual branch esse serviço deve usar nessa versão
    BRANCH_SERVICO=$(obter_branch_do_servico "$NOME_SERVICO" "$VERSAO_DESEJADA")

    if [ -n "$BRANCH_SERVICO" ]; then
        trocar_branch "$PASTA_RAIZ/$PASTA_SERVICO" "$BRANCH_SERVICO"
    else
        echo "Aviso: Serviço '$NOME_SERVICO' não tem regra para a versão '$VERSAO_DESEJADA'. Pulando..."
        echo ""
    fi
done

echo "Concluído! Todos os repositórios foram atualizados para a versão $VERSAO_DESEJADA."