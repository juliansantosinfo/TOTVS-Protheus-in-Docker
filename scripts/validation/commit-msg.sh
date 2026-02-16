#!/bin/bash
#
# ==============================================================================
# SCRIPT: commit-msg.sh
# DESCRIÇÃO: Valida se a mensagem do commit segue o padrão Conventional Commits.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-12
# USO: ./scripts/validation/commit-msg.sh <arquivo_da_mensagem>
# ==============================================================================

COMMIT_MSG_FILE=$1
MSG_CONTENT=$(cat "$COMMIT_MSG_FILE")

# Regex para Conventional Commits
# Tipos: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# Formato: tipo(escopo opcional): descrição
PATTERN="^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .+$"

if [[ ! "$MSG_CONTENT" =~ $PATTERN ]]; then
    echo "❌ Erro: Mensagem de commit inválida."
    echo "------------------------------------------------------------------"
    echo "Sua mensagem: $MSG_CONTENT"
    echo "------------------------------------------------------------------"
    echo "A mensagem deve seguir o padrão Conventional Commits:"
    echo "  <tipo>(<escopo>): <descrição>"
    echo ""
    echo "Exemplos válidos:"
    echo "  feat: adicionar novo endpoint"
    echo "  fix(appserver): corrigir variável de ambiente"
    echo "  docs: atualizar README"
    echo "  ci: ajustar workflow do github"
    echo ""
    echo "Tipos permitidos: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
    exit 1
fi

echo "✅ Mensagem de commit válida."
exit 0
