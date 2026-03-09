#!/bin/bash
# ==============================================================================
# SCRIPT: scripts/hooks/post-checkout.sh
# DESCRIÇÃO: Sincroniza submódulos com a branch correta após o checkout.
# ==============================================================================

# Parâmetros do hook: <old_head> <new_head> <is_branch_checkout>
OLD_HEAD=$1
NEW_HEAD=$2
IS_BRANCH_CHECKOUT=$3

# Só processa se for um checkout de branch (flag 1)
if [ "$IS_BRANCH_CHECKOUT" -ne 1 ]; then
    exit 0
fi

# Descobre o nome da branch atual
BRANCH_NAME=$(git branch --show-current)

# Se não encontrou nome de branch, não temos como mapear
if [ -z "$BRANCH_NAME" ]; then
    exit 0
fi

# Verifica se a branch é uma das suportadas para restauração automática
case "$BRANCH_NAME" in
    12.1.2310|12.1.2410|12.1.2510|main|master)
        echo "Hook post-checkout: Sincronizando submódulos para '$BRANCH_NAME'..."
        
        # Chama o script de restauração com a flag --skip-root
        if ! ./scripts/validation/branch-checkout.sh "$BRANCH_NAME" --skip-root; then
            echo "Falha na sincronização automática de submódulos para '$BRANCH_NAME'."
            echo "Verifique manualmente as branches em 'services/'."
            exit 1
        fi
        
        echo "Submódulos sincronizados com sucesso."
        ;;
    *)
        # Outras branches não disparam a restauração automática
        ;;
esac

exit 0