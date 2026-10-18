# Referência: Catálogo de Scripts e Utilitários CLI

Este documento cataloga todos os scripts executáveis da pasta `scripts/` e da raiz do projeto, descrevendo sua finalidade, parâmetros, comportamento e exemplos de uso.

---

## 🛠️ 1. Scripts de Compilação e Ciclo de Vida (`scripts/build/`)

### 1.1. `setup.sh`
* **Finalidade:** Orquestrador mestre para descompactação e preparação de pacotes. Valida e extrai os binários e recursos TOTVS previamente depositados em `services/<app>/packages/` para as estruturas operacionais internas (`totvs/`).
* **Sintaxe:**
  ```bash
  ./scripts/build/setup.sh [servico1 servico2 ...]
  ```
* **Comportamento:**
  * Se executado sem argumentos: processa os pacotes de todos os serviços aplicáveis (`appserver`, `dbaccess`, `licenseserver`, `smartview`).
  * Itera sobre os submódulos acionando os scripts locais de descompactação (`unpack.sh` ou `setup-build.sh`).
  * Valida se as versões dos pacotes correspondem às versões estritas declaradas em `versions.env` (ex.: `APPSERVER_BUILD_VERSION`).
  * Extrai e distribui os arquivos nos destinos operacionais internos (`totvs/protheus/bin/`, `totvs/protheus/apo/`, `totvs/protheus_data/`, etc.).
* **Exemplos:**
  ```bash
  ./scripts/build/setup.sh                     # Prepara e descompacta recursos de todos os serviços
  ./scripts/build/setup.sh appserver dbaccess  # Prepara apenas para appserver e dbaccess
  ```

---

### 1.2. `build.sh`
* **Finalidade:** Orquestrador mestre para construção das imagens Docker locais respeitando os metadados de versão.
* **Sintaxe:**
  ```bash
  ./scripts/build/build.sh [servicos...] [flags_extras_docker]
  ```
* **Comportamento:**
  * Executa os builds seletivamente ou em lote.
  * Repassa parâmetros extras diretamente para o `docker build` (como `--no-cache`).
* **Exemplos:**
  ```bash
  ./scripts/build/build.sh                          # Constrói todas as imagens
  ./scripts/build/build.sh appserver                # Constrói apenas totvs_appserver
  ./scripts/build/build.sh dbaccess --no-cache      # Constrói sem cache
  ```

---

### 1.3. `clean.sh`
* **Finalidade:** Exclui artefatos descompactados pelo `setup.sh` e arquivos temporários não rastreados pelo Git, garantindo um ambiente limpo ("Zero Git State").
* **Atenção:** Executa `git clean -fdx` nos diretórios do serviço, o que remove tanto os arquivos descompactados em `totvs/` quanto os pacotes originais depositados em `packages/`. Recomenda-se manter cópia de backup externa dos arquivos de instalação.
* **Sintaxe:**
  ```bash
  ./scripts/build/clean.sh [servicos...]
  ```
* **Exemplos:**
  ```bash
  ./scripts/build/clean.sh            # Limpa todos os submódulos
  ./scripts/build/clean.sh appserver  # Limpa apenas services/appserver
  ```

---

### 1.4. `push.sh`
* **Finalidade:** Realiza o envio (`docker push`) das imagens construídas localmente para o registro configurado (`DOCKER_USER` em `versions.env`).
* **Sintaxe:**
  ```bash
  ./scripts/build/push.sh [servicos...]
  ```
* **Pré-requisito:** Sessão autenticada via `docker login`.

---

## 🔍 2. Scripts de Validação e Qualidade (`scripts/validation/`)

### 2.1. `status.sh` (Diagnóstico Inteligente / Cockpit do Mantenedor)
* **Finalidade:** Exibe um raio-X unificado do estado atual do projeto para facilitar a retomada de manutenção. Inspeciona:
  1. **Root & Ambiente:** Branch ativa da raiz, working tree, presença do `.env`, status dos Git Hooks locais e estado do Docker Engine / containers ativos.
  2. **Matriz dos 7 Submódulos (`services/*`):** Alinhamento de branch por serviço vs esperado na release, status Git (`Limpo`, `Dirty` ou `Ahead`), paridade de versões (`Dockerfile` + `versions.env` interno + `docker-compose*.yaml`), estado de extração dos pacotes (`Extraído`, `Falta setup`, `Sem pacotes` ou `N/A`) e presença da imagem Docker local.
  3. **Guia de Próximos Passos:** Lista numerada e ordenada com os comandos exatos para corrigir pendências encontradas.
* **Sintaxe:**
  ```bash
  ./scripts/validation/status.sh [--fix]
  ```
* **Opções:**
  * Sem argumentos: Modo 100% leitura (seguro e rápido).
  * `--fix`: Aplica correções automáticas seguras (instala Git Hooks ausentes, cria `.env` a partir de `.env.example` se ausente e executa `versions.sh --fix`).

---

### 2.2. `versions.sh`
* **Finalidade:** O "cão de guarda" de integridade de versões. Compara a fonte única da verdade (`versions.env` na raiz) com três camadas:
  1. Os metadados `LABEL` presentes em cada `services/*/Dockerfile`.
  2. As variáveis e tags de `IMAGE_BASE` nos arquivos internos `services/*/versions.env`.
  3. As tags de imagem (`image: <user>/<app>:<tag>`) nos 4 arquivos `docker-compose*.yaml`.
* **Sintaxe:**
  ```bash
  ./scripts/validation/versions.sh [--fix]
  ```
* **Opções:**
  * Sem argumentos: Verifica se há inconsistências nas 3 camadas e retorna código `1` se houver divergência.
  * `--fix`: Corrige e sincroniza automaticamente os `Dockerfiles`, os `services/*/versions.env` e os arquivos `docker-compose*.yaml`.

---

### 2.3. `branch-checkout.sh`
* **Finalidade:** Alterna a branch do repositório root e de todos os 7 submódulos simultaneamente para a versão de release selecionada.
* **Sintaxe:**
  ```bash
  ./scripts/validation/branch-checkout.sh <versao> [--skip-root]
  ```
* **Versões Suportadas:** `12.1.2310`, `12.1.2410`, `12.1.2510`, `12.1.2610`, `main` / `master`.
* **Exemplo:**
  ```bash
  ./scripts/validation/branch-checkout.sh 12.1.2610
  ```

---

### 2.4. Linters Estáticos
| Script | Ferramenta Subjacente | Finalidade |
|---|---|---|
| `./scripts/validation/lint-compose.sh` | `docker compose config` | Valida sintaxe YAML e interpolação de variáveis em todos os compose files. |
| `./scripts/validation/lint-dockerfile.sh` | `Hadolint` | Análise estática de boas práticas de segurança e otimização nos Dockerfiles. |
| `./scripts/validation/lint-shell.sh` | `ShellCheck` | Varre todos os scripts `.sh` à procura de bugs, variáveis não declaradas ou má sintaxe. |
| `./scripts/validation/secrets.sh` | Varredura Regex de Segredos | Impede commit acidental de senhas reais, chaves privadas ou tokens no Git. |
| `./scripts/validation/env.sh` | Diff de Chaves | Assegura que `.env.example` contenha todas as variáveis esperadas pelos serviços. |

---

## 🧪 3. Scripts de Teste (`scripts/test/`)

### 3.1. `test-compose.sh`
* **Finalidade:** Valida sintaxe e opcionalmente executa um **Smoke Test** completo (subida real dos containers, espera de healthcheck por até 480s e destruição controlada do ambiente).
* **Sintaxe:**
  ```bash
  ./scripts/test/test-compose.sh [--full] [-f <arquivo.yaml>]
  ```
* **Opções:**
  * Sem argumentos: Executa validação de sintaxe de todos os compose files.
  * `--full`: Sobe os containers com `--profile full`, aguarda todos ficarem saudáveis e desfaz o ambiente.
  * `-f <arquivo>`: Foca o teste apenas no arquivo compose especificado.
* **Exemplos:**
  ```bash
  ./scripts/test/test-compose.sh -f docker-compose-postgresql.yaml --full
  ```

---

## 🪝 4. Gestão de Git Hooks (`scripts/hooks/`)

### 4.1. `install.sh`
* **Finalidade:** Instala os hooks do repositório dentro do diretório local `.git/hooks/`.
* **Hooks Ativados:**
  * `pre-commit`: Executa automaticamente antes de qualquer commit:
    * Validador de versões (`versions.sh`).
    * Varredor de segredos (`secrets.sh`).
    * ShellCheck nos scripts modificados.
    * Validação de sintaxe dos Compose files.
  * `commit-msg`: Força aderência estrita à especificação **Conventional Commits** (`feat:`, `fix:`, `chore:`, `docs:`, `ci:`).
  * `post-checkout`: Detecta quando o desenvolvedor troca de branch no root e invoca automaticamente o `branch-checkout.sh` para alinhar os submódulos.

---

## 🚀 5. Assistente CLI na Raiz (`run.sh`)

* **Finalidade:** Menu interativo de inicialização amigável.
* **Sintaxe:**
  ```bash
  ./run.sh
  ```
* **Benefícios:** Não exige memorização de comandos complexos; guia o usuário na escolha do banco (Postgres, SQL Server ou Oracle) e no perfil de execução (`default`, `full`, `with-rest`, `with-smartview`).

---

## 🧭 6. Atalhos de Manutenção (`Makefile` e `.vscode/tasks.json`)

Para eliminar a necessidade de memorizar caminhos de scripts após períodos sem atuar no projeto, a raiz dispõe de um **`Makefile`** (cujo alvo padrão ao digitar apenas `make` é o diagnóstico `status.sh`) e integração nativa com as **Tasks do VS Code** (`Ctrl+Shift+P` -> `Tasks: Run Task`):

| Comando `make` | Script Equivalente | Descrição |
|---|---|---|
| `make` ou `make status` | `./scripts/validation/status.sh` | Exibe o painel de Diagnóstico Inteligente e recomendações. |
| `make fix` | `./scripts/validation/status.sh --fix` | Corrige automaticamente versões, Git Hooks e `.env`. |
| `make help` | — | Lista todos os alvos disponíveis no terminal com exemplos. |
| `make versions` | `./scripts/validation/versions.sh` | Valida paridade entre `versions.env`, Dockerfiles, Compose e submódulos. |
| `make setup [APP=...]` | `./scripts/build/setup.sh [APP]` | Descompacta pacotes de todos os serviços ou de um serviço específico. |
| `make build [APP=...]` | `./scripts/build/build.sh [APP]` | Compila todas as imagens Docker ou apenas os serviços informados. |
| `make push [APP=...]` | `./scripts/build/push.sh [APP]` | Envia imagens construídas para o Docker Hub. |
| `make clean [APP=...]` | `./scripts/build/clean.sh [APP]` | Remove arquivos extraídos e temporários dos submódulos. |
| `make checkout V=<versao>` | `./scripts/validation/branch-checkout.sh <V>` | Alterna a release no root e nos 7 submódulos simultaneamente. |
| `make submodules` | `git submodule foreach ...` | Lista branch atual e status curto de cada submódulo em `services/`. |
| `make validate` | `./scripts/hooks/pre-commit.sh` | Executa toda a bateria de validações e linters de pré-commit. |
| `make test` | `./scripts/test/test-compose.sh` | Valida a sintaxe de todos os arquivos Docker Compose. |
| `make run` | `./run.sh` | Abre o assistente interativo para subir a stack. |
