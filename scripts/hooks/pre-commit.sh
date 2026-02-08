#!/bin/bash
# ==============================================================================
# SCRIPT: scripts/hooks/pre-commit.sh
# DESCRIÇÃO: Orquestrador de validações disparado pelo Git Pre-commit Hook.
# ==============================================================================

echo "🚀 Iniciando validações de pré-commit..."

# 1. Validação de Versões
./scripts/validation/versions.sh
if [ $? -ne 0 ]; then exit 1; fi

# 2. Validação de Scripts Shell (ShellCheck)
./scripts/validation/lint-shell.sh
if [ $? -ne 0 ]; then exit 1; fi

# 3. Escaneamento de Segredos
./scripts/validation/secrets.sh
if [ $? -ne 0 ]; then exit 1; fi

# 4. Validação de .env.example
./scripts/validation/env.sh
if [ $? -ne 0 ]; then exit 1; fi

# 5. Linting de Dockerfiles (Hadolint)
./scripts/validation/lint-dockerfile.sh
if [ $? -ne 0 ]; then exit 1; fi

echo "✅ Todas as validações passaram!"
exit 0
