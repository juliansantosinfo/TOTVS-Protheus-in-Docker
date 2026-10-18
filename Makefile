# ==============================================================================
# Makefile — Cockpit de Manutenção (TOTVS Protheus in Docker)
# ==============================================================================
# Uso rápido:
#   make              -> Executa o Diagnóstico Inteligente (status.sh)
#   make help         -> Lista todos os comandos disponíveis
#   make fix          -> Corrige versões, hooks e .env automaticamente
#   make setup        -> Descompacta pacotes em services/*/packages/
#   make build        -> Constrói todas as imagens (ou APP=appserver)
#   make imagebase    -> Tagueia e envia imagem base privada (ou APP=appserver)
#   make validate     -> Executa todos os linters e validações de pré-commit
#   make checkout V=12.1.2610 -> Alinha branch do root e dos 7 submódulos
# ==============================================================================

.DEFAULT_GOAL := status
.PHONY: status doctor help fix versions hooks setup build push imagebase base-push clean checkout submodules validate test run

APP ?=
V ?=

status: ## Exibe o painel de Diagnóstico Inteligente do projeto (padrão)
	@./scripts/validation/status.sh

doctor: status ## Alias para 'make status'

fix: ## Corrige automaticamente versões (Dockerfiles/Compose/Submódulos), Git Hooks e .env
	@./scripts/validation/status.sh --fix

versions: ## Valida consistência do versions.env com Dockerfiles, Compose e Submódulos
	@./scripts/validation/versions.sh

hooks: ## Instala/atualiza os Git Hooks locais (.git/hooks/)
	@./scripts/hooks/install.sh

setup: ## Extrai pacotes em services/*/packages/ (use APP=<servico> para filtrar)
	@./scripts/build/setup.sh $(APP)

build: ## Compila imagens Docker localmente (use APP=<servico> para filtrar)
	@./scripts/build/build.sh $(APP)

push: ## Envia imagens para o Docker Hub (use APP=<servico> para filtrar)
	@./scripts/build/push.sh $(APP)

imagebase: ## Tagueia e envia imagem base privada ao Docker Hub (use APP=<servico>)
	@./scripts/build/imagebase.sh $(APP)

base-push: imagebase ## Alias para 'make imagebase'

clean: ## Limpa artefatos extraídos e temporários (use APP=<servico> para filtrar)
	@./scripts/build/clean.sh $(APP)

checkout: ## Alterna release no root e nos 7 submódulos (ex: make checkout V=12.1.2610)
	@if [ -z "$(V)" ]; then \
		echo "❌ Informe a versão desejada. Exemplo: make checkout V=12.1.2610"; \
		exit 1; \
	fi
	@./scripts/validation/branch-checkout.sh $(V)

submodules: ## Exibe branch e status Git detalhado de cada submódulo em services/
	@git submodule foreach 'echo "=== $$name ($$(git branch --show-current)) ===" && git status -s'

validate: ## Executa toda a suíte de validação e linters (pré-commit completo)
	@./scripts/hooks/pre-commit.sh

test: ## Valida sintaxe e interpolação de todos os arquivos Docker Compose
	@./scripts/test/test-compose.sh

run: ## Inicia o assistente interativo para subir a stack Docker Compose
	@./run.sh

help: ## Exibe este guia rápido de comandos de manutenção
	@echo "======================================================================================="
	@echo "🛠️  COMANDOS DE MANUTENÇÃO — TOTVS Protheus in Docker"
	@echo "======================================================================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[1;36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Exemplos com parâmetros:"
	@echo "  make setup APP=appserver          # Extrai pacotes apenas do appserver"
	@echo "  make build APP=\"appserver dbaccess\" # Compila apenas appserver e dbaccess"
	@echo "  make imagebase APP=appserver      # Tagueia e envia imagem base privada"
	@echo "  make checkout V=12.1.2610         # Sincroniza root e submódulos na 12.1.2610"
	@echo "======================================================================================="
