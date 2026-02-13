#!/bin/bash

# ==============================================================================
# AI Code Review - Pre-Push Hook (DevOps/Infrastructure Edition)
# Adapts the Gemini review process for Docker, Shell, Python, and YAML files.
# ==============================================================================

# 1. Determine the range of commits to check
# pre-push receives lines on stdin: <local_ref> <local_sha> <remote_ref> <remote_sha>
read local_ref local_sha remote_ref remote_sha

# If we're pushing a new branch (remote_sha is 000...), compare against origin/main
# Adjust 'origin/master' or 'origin/main' based on your default branch
if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
    RANGE="origin/master...HEAD"
else
    RANGE="$remote_sha...$local_sha"
fi

# 2. Identify files and generate diff
# Focus on Infrastructure: Shell, Docker, Python, YAML
FILES=$(git diff --name-only "$RANGE" -- '*.sh' '*Dockerfile*' '*.dockerfile' '*.py' '*.yaml' '*.yml')

if [ -z "$FILES" ]; then
    exit 0
fi

# Limit diff size to avoid token limits (approx check)
DIFF=$(git diff "$RANGE" -- '*.sh' '*Dockerfile*' '*.dockerfile' '*.py' '*.yaml' '*.yml')
CHAR_COUNT=${#DIFF}

if [ "$CHAR_COUNT" -gt 25000 ]; then
    echo "⚠️  Diff too large for AI review ($CHAR_COUNT chars). Skipping AI check."
    exit 0
fi

echo "--- Iniciando AI Code Review (DevOps/Infra) ---"
echo "Files to review:"
echo "$FILES"

# 3. Construct the Prompt
PROMPT="Aja como um Engenheiro DevOps Sênior e Especialista em Segurança.
Analise o diff abaixo (arquivos de Infraestrutura: Docker, Shell, CI/CD) e verifique:

1. **Segurança:** 
   - Exposição de credenciais/segredos.
   - Uso de usuário 'root' desnecessário em Dockerfiles.
   - Permissões de arquivos inseguras.
2. **Docker Best Practices:** 
   - Otimização de camadas (layer caching).
   - Uso de multi-stage builds.
   - Tags de imagem fixas (evitar 'latest' em prod).
3. **Shell Scripting:** 
   - Validação de erros (set -e, pipefail).
   - Quoting correto de variáveis.
   - Comandos perigosos (rm -rf sem checks).
4. **Python/Geral:** 
   - Tratamento de exceções e clareza.

Lembre-se de informar o arquivo e a linha do problema.

Ao final da sua análise, você DEVE escrever EXATAMENTE uma das tags abaixo na última linha:
[APROVADO] - Se o código seguir boas práticas e for seguro.
[REPROVADO] - Se houver erros graves de segurança, lógica ou performance.

DIFF:
$DIFF"

# 4. Call Gemini CLI
# Verify if 'gemini' command exists
if ! command -v gemini &> /dev/null; then
    echo "⚠️  Command 'gemini' not found. Skipping AI review."
    exit 0
fi

RESPONSE=$(gemini -p "$PROMPT")

echo "--- Sugestões do Gemini ---"
echo "$RESPONSE"
echo "---------------------------"

# 5. Generate Report and Open in Editor
REPORT_FILE="/tmp/ai_review_$(date +%s).md"

{
    echo "# AI Code Review - DevOps"
    echo "Date: $(date)"
    echo "Commit Range: $RANGE"
    echo "---"
    echo "$RESPONSE"
} > "$REPORT_FILE"

# Open in VS Code if available, otherwise cat
if command -v code &> /dev/null; then
    code "$REPORT_FILE"
else
    echo "Report saved to: $REPORT_FILE"
fi

# 6. Validate Approval
if echo "$RESPONSE" | grep -q "\[REPROVADO\]"; then
    echo "❌ PUSH BLOQUEADO: O Gemini identificou problemas críticos na infraestrutura."
    echo "Consulte o relatório em: $REPORT_FILE"
    exit 1
fi

if echo "$RESPONSE" | grep -q "\[APROVADO\]"; then
    echo "✅ PUSH AUTORIZADO: Infraestrutura validada."
    exit 0
else
    echo "⚠️  AVISO: O Gemini não retornou uma conclusão clara. Revise manualmente."
    # Interactive check often fails in non-interactive git hooks, so we default to warning but allow
    # If strictly interactive is needed, use < /dev/tty
    if [ -t 0 ]; then
        read -p "Deseja prosseguir mesmo assim? (y/n) " -n 1 -r < /dev/tty
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && exit 0 || exit 1
    else
        echo "Non-interactive mode detected. Proceeding with caution."
        exit 0
    fi
fi
