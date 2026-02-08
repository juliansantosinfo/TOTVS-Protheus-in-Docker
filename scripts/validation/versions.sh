#!/bin/bash
# ==============================================================================
# SCRIPT: validate-versions.sh
# DESCRIÇÃO: Valida se a versão definida nos Dockerfiles corresponde à versão
#            centralizada no arquivo versions.env.
#            Pode corrigir automaticamente com a flag --fix.
# USO: ./scripts/validate-versions.sh [--fix]
# ==============================================================================

set -u

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

AUTO_FIX=false
if [[ "${1:-}" == "--fix" ]]; then
    AUTO_FIX=true
fi

EXIT_CODE=0

# Função de Validação
validate_service() {
    local service=$1
    local version_var=$2
    local dockerfile="./$service/dockerfile"
    local expected_version="${!version_var}"

    if [ ! -f "$dockerfile" ]; then
        echo "⚠️  Aviso: Dockerfile não encontrado para $service. Pulando."
        return
    fi

    # Extrai a versão atual (procura por LABEL release= ou LABEL version=)
    # 1. grep: busca a linha
    # 2. head: garante apenas a primeira ocorrência
    # 3. cut: pega o valor depois do =
    # 4. tr: remove aspas e espaços
    local actual_version=$(grep -iE "LABEL (release|version)=" "$dockerfile" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")
    
    # Identifica qual label está sendo usada para o possível fix
    local label_type=$(grep -iE -o "LABEL (release|version)=" "$dockerfile" | head -n 1 | cut -d' ' -f2 | cut -d'=' -f1)

    if [ "$actual_version" != "$expected_version" ]; then
        if [ "$AUTO_FIX" = true ]; then
            echo "🔧 Corrigindo $service: $actual_version -> $expected_version"
            
            # Substitui a versão no arquivo usando sed
            # Usa regex para garantir que pegamos a linha certa (release ou version)
            sed -i "s/LABEL $label_type="$actual_version"/LABEL $label_type="$expected_version"/" "$dockerfile"
            
            # Verifica se deu certo
            local new_version=$(grep -iE "LABEL (release|version)=" "$dockerfile" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "[:space:]")
            if [ "$new_version" == "$expected_version" ]; then
                echo "✅ $service corrigido com sucesso."
            else
                echo "❌ Falha ao corrigir $service."
                EXIT_CODE=1
            fi
        else
            echo "❌ ERRO ($service): Versão no Dockerfile ($actual_version) difere de versions.env ($expected_version)"
            EXIT_CODE=1
        fi
    else
        echo "✅ OK ($service): Versão correta ($expected_version)"
    fi
}

echo "🔍 Iniciando validação de versões..."
echo "-----------------------------------"

validate_service "appserver" "APPSERVER_VERSION"
validate_service "dbaccess" "DBACCESS_VERSION"
validate_service "licenseserver" "LICENSESERVER_VERSION"
validate_service "mssql" "MSSQL_VERSION"
validate_service "postgres" "POSTGRES_VERSION"
validate_service "smartview" "SMARTVIEW_VERSION"

echo "-----------------------------------"
if [ $EXIT_CODE -ne 0 ]; then
    echo "🛑 Validação falhou! Algumas versões estão inconsistentes."
    if [ "$AUTO_FIX" = false ]; then
        echo "💡 Dica: Execute './scripts/validate-versions.sh --fix' para corrigir automaticamente."
    fi
    exit 1
else
    echo "🎉 Todas as versões estão sincronizadas."
    exit 0
fi
