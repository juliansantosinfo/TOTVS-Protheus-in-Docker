#!/bin/bash
# ==============================================================================
# SCRIPT: scripts/hooks/install.sh
# DESCRIÇÃO: Instala os Git Hooks no repositório local.
# ==============================================================================

PRE_COMMIT_HOOK=".git/hooks/pre-commit"
COMMIT_MSG_HOOK=".git/hooks/commit-msg"
POST_CHECKOUT_HOOK=".git/hooks/post-checkout"

# Garante permissão de execução nos scripts de hook
chmod +x scripts/hooks/pre-commit.sh
chmod +x scripts/hooks/commit-msg.sh
chmod +x scripts/hooks/post-checkout.sh

echo "🔧 Configurando Git Hooks..."

# --- 1. Hook Commit-Msg ---
echo "Instalando commit-msg em $COMMIT_MSG_HOOK..."
cat <<EOF > "$COMMIT_MSG_HOOK"
#!/bin/bash
./scripts/hooks/commit-msg.sh "\$1"
EOF
chmod +x "$COMMIT_MSG_HOOK"

# --- 2. Hook Pre-Commit ---
echo "Instalando pre-commit em $PRE_COMMIT_HOOK..."
cat <<EOF > "$PRE_COMMIT_HOOK"
#!/bin/bash
./scripts/hooks/pre-commit.sh
EOF
chmod +x "$PRE_COMMIT_HOOK"

# --- 3. Hook Post-Checkout ---
echo "Instalando post-checkout em $POST_CHECKOUT_HOOK..."
cat <<EOF > "$POST_CHECKOUT_HOOK"
#!/bin/bash
./scripts/hooks/post-checkout.sh "\$1" "\$2" "\$3"
EOF
chmod +x "$POST_CHECKOUT_HOOK"

echo "✅ Git Hooks instalados com sucesso!"