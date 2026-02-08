#!/bin/bash
# Script para instalar os git hooks

PRE_COMMIT_HOOK=".git/hooks/pre-commit"
COMMIT_MSG_HOOK=".git/hooks/commit-msg"

echo "🔧 Configurando Git Hooks..."

# --- 1. Hook Pre-Commit ---
echo "Instalando pre-commit em $PRE_COMMIT_HOOK..."
cat <<EOF > "$PRE_COMMIT_HOOK"
#!/bin/bash
# Git Pre-commit Hook Orchestrator

echo "🚀 Running pre-commit hooks..."

# 1. Validação de Versões
./scripts/validate-versions.sh
if [ \$? -ne 0 ]; then exit 1; fi

# 2. Validação de Scripts Shell (ShellCheck)
./scripts/lint-shell.sh
if [ \$? -ne 0 ]; then exit 1; fi

# 3. Escaneamento de Segredos
./scripts/scan-secrets.sh
if [ \$? -ne 0 ]; then exit 1; fi

# 4. Validação de .env.example
./scripts/validate-env.sh
if [ \$? -ne 0 ]; then exit 1; fi

# 5. Linting de Dockerfiles (Hadolint)
./scripts/lint-dockerfile.sh
if [ \$? -ne 0 ]; then exit 1; fi

echo "✅ Todos os pre-commit hooks passaram!"
EOF
chmod +x "$PRE_COMMIT_HOOK"


# --- 2. Hook Commit-Msg ---
echo "Instalando commit-msg em $COMMIT_MSG_HOOK..."
cat <<EOF > "$COMMIT_MSG_HOOK"
#!/bin/bash
# Git Commit-Msg Hook

./scripts/validate-commit-msg.sh "\$1"
EOF
chmod +x "$COMMIT_MSG_HOOK"

echo "✅ Git Hooks instalados com sucesso!"
