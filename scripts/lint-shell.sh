#!/bin/bash
# ==============================================================================
# SCRIPT: lint-shell.sh
# DESCRIÇÃO: Executa ShellCheck em todos os arquivos .sh do projeto.
# ==============================================================================

if ! command -v shellcheck &> /dev/null; then
    echo "⚠️  ShellCheck não encontrado. Pule este passo ou instale: 'sudo apt install shellcheck'"
    exit 0
fi

echo "🔍 Executando ShellCheck..."

# Encontra arquivos .sh, ignorando a pasta .git
FILES=$(find . -name "*.sh" -not -path "./.git/*" -not -path "./node_modules/*")

if [ -z "$FILES" ]; then
    echo "✅ Nenhum script shell encontrado."
    exit 0
fi

# Executa o shellcheck. Se falhar, o script sai com erro.
echo "$FILES" | xargs shellcheck --severity=error

if [ $? -eq 0 ]; then
    echo "✅ ShellCheck passou."
    exit 0
else
    echo "❌ ShellCheck encontrou erros."
    exit 1
fi
