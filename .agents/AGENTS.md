# TOTVS Protheus in Docker - Agent Guidelines

Este documento define as diretrizes, arquitetura, padrões e procedimentos para agentes atuando no repositório **TOTVS-Protheus-in-Docker**.

---

## 1. Visão Geral da Arquitetura

O projeto provê uma infraestrutura modularizada em containers Docker para execução do ERP TOTVS Protheus, orquestrado via Docker Compose com múltiplos bancos de dados e serviços auxiliares:

- **`appserver`**: Servidor de aplicação TOTVS Protheus (modos `application`, `rest`, `sqlite`).
- **`dbaccess`**: Middleware de abstração e comunicação com o banco de dados.
- **`licenseserver`**: Servidor de licenciamento TOTVS.
- **`smartview`**: Plataforma de BI, relatórios e analytics (TReports).
- **Bancos de Dados Suportados**:
  - Microsoft SQL Server (`docker-compose-mssql.yaml` / `docker-compose.yaml`)
  - PostgreSQL (`docker-compose-postgresql.yaml`)
  - Oracle Database (`docker-compose-oracle.yaml`)

Todos os serviços de aplicação residem em **submódulos Git** sob o diretório `services/`.

---

## 2. Regras Fundamentais (Invioláveis)

### 2.1. Fonte Única da Verdade para Versões (`versions.env`)
- O arquivo `versions.env` na raiz do projeto é a **única fonte da verdade** para tags de imagens, versões de binários e usuário Docker (`DOCKER_USER`).
- **Regra de Ouro**: Ao alterar qualquer versão ou tag em `versions.env`, execute imediatamente:
  ```bash
  ./scripts/validation/versions.sh --fix
  ```
  Isso garante que os `Dockerfile`s em `services/` tenham seus `LABEL` sincronizados.
- Sempre que houver nova versão ou release, atualize também os arquivos `docker-compose*.yaml` e os scripts de transição de branches (`branch-checkout.sh` e `post-checkout.sh`).

### 2.2. Fluxo de Git Submodules
- Os diretórios em `services/` são submódulos Git apontando para repositórios individuais da organização.
- Se uma alteração afetar o conteúdo de um serviço (por exemplo, `Dockerfile`, scripts de entrypoint, ou `unpack.sh` em `services/appserver`), o commit deve ser feito **primeiro no submódulo** e posteriormente no repositório root (atualizando o commit pointer).
- Utilize a skill `submodule-sync` ao alternar branches ou preparar sincronizações em lote.

### 2.3. Padrão de Commits (Conventional Commits)
- Commits devem seguir estritamente o padrão [Conventional Commits](https://www.conventionalcommits.org/):
  - `feat`: Novas funcionalidades no ambiente ou orquestração.
  - `fix`: Correção de bugs em scripts, compose ou Dockerfiles.
  - `chore`: Atualização de versões (`versions.env`), dependências e submódulos.
  - `docs`: Documentação em `docs/` ou arquivos markdown.
  - `ci`: Alterações nos workflows do GitHub Actions (`.github/workflows/`).
- O hook `scripts/validation/commit-msg.sh` rejeita mensagens fora desse padrão.
- **Nunca use `--no-verify`** a menos que expressamente autorizado para contornar falsos positivos de segredos em arquivos de exemplo.

### 2.4. Git Hooks Ativos
- Os hooks locais estão instalados em `.git/hooks/` a partir de `scripts/hooks/`:
  - `pre-commit`: Executa validação de versões, ShellCheck, segredos, `.env.example`, Hadolint e sintaxe de compose.
  - `commit-msg`: Valida formato Conventional Commits.
  - `post-checkout`: Sincroniza submódulos de acordo com a branch selecionada.

---

## 3. Estrutura de Scripts e Automação

Sempre utilize os scripts existentes na pasta `scripts/` antes de criar comandos manuais:

| Script | Finalidade |
|---|---|
| `./scripts/build/setup.sh [apps...]` | Descompacta dependências e pacotes TOTVS em `services/*/packages/`. |
| `./scripts/build/build.sh [apps...] [flags]` | Constrói imagens Docker localmente com argumentos opcionais (`--no-cache`, etc.). |
| `./scripts/build/push.sh [apps...]` | Envia as imagens construídas para o Docker Hub. |
| `./scripts/build/clean.sh` | Limpa recursos baixados, temporários e caches de build. |
| `./scripts/validation/versions.sh [--fix]` | Valida e corrige inconsistências entre `versions.env` e `Dockerfile`s. |
| `./scripts/validation/lint-compose.sh` | Valida sintaxe e interpolação dos arquivos `docker-compose*.yaml`. |
| `./scripts/validation/lint-dockerfile.sh` | Executa análise estática com Hadolint nos Dockerfiles. |
| `./scripts/validation/lint-shell.sh` | Executa verificação de scripts com ShellCheck. |
| `./scripts/validation/secrets.sh` | Valida staged files contra vazamento acidental de chaves/senhas reais. |
| `./scripts/validation/branch-checkout.sh <versao>` | Alinha a branch do root e de todos os submódulos para a versão desejada. |
| `./scripts/test/test-compose.sh [-f file] [--full]` | Executa validação e smoke test de subida de containers. |
| `./run.sh` | Menu interativo de inicialização rápida do ambiente Protheus Docker. |

---

## 4. Customizações no Diretório `.agents/`

Consulte e utilize os recursos disponibilizados neste diretório:

### Regras (`.agents/rules/`)
- `rules/versions.md`: Regras estritas de integridade de versão e compose.
- `rules/commits-and-hooks.md`: Validações de pré-commit e convenção de mensagens.
- `rules/submodules.md`: Ciclo de vida e regras para manipulação de submódulos.
- `rules/docker-best-practices.md`: Padrões de imagem Docker, ulimits e redes.

### Skills (`.agents/skills/`)
- **`version-sync`**: Procedimento passo a passo para bump de release e sincronização de versões.
- **`docker-build-test`**: Procedimento para build de imagens e execução de smoke tests.
- **`submodule-sync`**: Procedimento de alinhamento e atualização de submódulos Git.
- **`resource-unpack`**: Gestão e descompactação de pacotes de binários TOTVS (RPO, WebApp, Help, Menus).
