#!/bin/bash
# ==============================================================================
# SCRIPT: scan-secrets.sh
# DESCRIÇÃO: Verifica se há possíveis segredos expostos nos arquivos estagiados.
# ==============================================================================

echo "🔍 Verificando segredos em arquivos estagiados..."

# Lista arquivos estagiados, excluindo arquivos deletados
FILES=$(git diff --cached --name-only --diff-filter=ACMR)

if [ -z "$FILES" ]; then
    exit 0
fi

# Palavras-chave para buscar
KEYWORDS="PASSWORD|SECRET|KEY|TOKEN|CREDENTIAL"

# Arquivos permitidos (whitelist)
WHITELIST=".env.example|versions.env|scripts/scan-secrets.sh"

EXIT_CODE=0

for file in $FILES; do
    # Pula arquivos da whitelist
    if [[ "$file" =~ $WHITELIST ]]; then
        continue
    fi
    
    # Busca por atribuições diretas de segredos (Ex: PASSWORD=123)
    # Ignora linhas de comentário (#)
    if grep -E "^[^#]*($KEYWORDS)\s*=\s*[^\s]+" "$file" > /dev/null; then
        echo "❌ POTENCIAL SEGREDO ENCONTRADO EM: $file"
        grep -E "^[^#]*($KEYWORDS)\s*=\s*[^\s]+" "$file"
        EXIT_CODE=1
    fi
done

if [ $EXIT_CODE -ne 0 ]; then
    echo "⛔ Commit bloqueado! Remova os segredos ou use git commit --no-verify se for falso positivo."
    exit 1
else
    echo "✅ Nenhum segredo óbvio encontrado."
    exit 0
fi
