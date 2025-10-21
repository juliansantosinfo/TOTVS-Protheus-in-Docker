#!/usr/bin/env bash
# ==============================================================================
# SCRIPT: run.sh
# DESCRIÇÃO: Script interativo para simplificar a inicialização do ambiente
#            TOTVS-Protheus-in-Docker. Guia o usuário na escolha do banco
#            de dados e do perfil de execução.
#
# AUTOR: Gemini
# DATA: 2025-10-20
# USO: ./run.sh
# ==============================================================================

# --- Configuração de Robustez ---
set -euo pipefail

# --- Funções ---

# Função para exibir cabeçalhos de seção
print_header() {
    echo
    echo "--- $1 ---"
}

# --- Fluxo Principal ---

echo "###################################################"
echo "🚀 Bem-vindo ao Assistente de Inicialização do Protheus Docker"
echo "###################################################"

# 1. Escolha do Banco de Dados
print_header "1. Escolha do Banco de Dados"
echo "Qual banco de dados você gostaria de usar?"
select db_choice in "PostgreSQL (Recomendado)" "Microsoft SQL Server"; do
    case $db_choice in
        "PostgreSQL (Recomendado)")
            COMPOSE_FILE="docker-compose-postgresql.yaml"
            break
            ;;
        "Microsoft SQL Server")
            COMPOSE_FILE="docker-compose-mssql.yaml"
            break
            ;;
        *)
            echo "Opção inválida. Por favor, digite 1 ou 2."
            ;;
    esac
done

# 2. Escolha do Perfil (API REST)
print_header "2. Iniciar Serviços da API REST?"
echo "Você deseja incluir os serviços da API REST (perfil 'full')?"
select profile_choice in "Sim" "Não"; do
    case $profile_choice in
        "Sim")
            PROFILE_ARG="--profile full"
            break
            ;;
        "Não")
            PROFILE_ARG=""
            break
            ;;
        *)
            echo "Opção inválida. Por favor, digite 1 ou 2."
            ;;
    esac
done

# 3. Verificação do arquivo .env
print_header "3. Verificação de Configuração"
if [ ! -f .env ]; then
    echo "⚠️  Aviso: O arquivo '.env' não foi encontrado."
    echo "Copiando '.env.example' para '.env'. Por favor, revise as senhas se necessário."
    cp .env.example .env
else
    echo "✅ Arquivo '.env' encontrado."
fi


# 4. Confirmação e Execução
print_header "4. Confirmação e Execução"
# Constrói o comando final
final_command="docker compose -f ${COMPOSE_FILE} -p totvs ${PROFILE_ARG} up -d"

echo "O seguinte comando será executado:"
echo
echo "   $final_command"
echo

read -p "Deseja continuar? (s/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "🛑 Operação cancelada pelo usuário."
    exit 0
fi

# Executa o comando
echo
echo "🚀 Executando o comando... Por favor, aguarde."
if eval "$final_command"; then
    echo
    echo "🎉 Ambiente iniciado com sucesso!"
    echo "Você pode monitorar os logs com o comando: docker compose -p totvs logs -f"
else
    echo
    echo "❌ Falha ao iniciar o ambiente. Verifique os logs acima." >&2
    exit 1
fi
