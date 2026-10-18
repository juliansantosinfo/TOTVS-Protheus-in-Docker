---
name: version-sync
description: Use when updating service versions, bumping Protheus release versions, fixing version mismatch errors between versions.env and Dockerfiles, or synchronizing docker-compose image tags.
---

# Sincronização e Gestão de Versões

## Visão Geral
Gerencia a integridade das versões do ecossistema Protheus em Docker a partir do arquivo central [`versions.env`](../../../versions.env), garantindo que Dockerfiles, arquivos compose e scripts de branch reflitam a mesma numeração.

## Quando Usar
- Ao atualizar qualquer versão de binário ou release (ex: AppServer, DbAccess, License Server, SmartView).
- Ao migrar para uma nova release semestral/anual do Protheus (ex: `12.1.2510` -> `12.1.2610`).
- Quando `./scripts/validation/versions.sh` reportar erro de divergência (`❌ ... difere de versions.env`).
- Quando os arquivos `docker-compose*.yaml` precisarem de atualização nas tags das imagens.

**Quando NÃO usar:**
- Para builds sem alteração de versão (utilize a skill `docker-build-test`).
- Para apenas descompactar pacotes sem mexer nas tags (utilize a skill `resource-unpack`).

---

## Passo a Passo

### 1. Atualizar o Arquivo Central `versions.env`
Edite [`versions.env`](../../../versions.env) definindo as novas variáveis. Exemplo para upgrade da release `12.1.2610`:
```env
RESOURCE_RELEASE=release2610
APPSERVER_RELEASE=12.1.2610
APPSERVER_VERSION="${APPSERVER_RELEASE}"
APPSERVER_BUILD_VERSION=26.3.0.0
APPSERVER_WEBAPP_VERSION=26.0.0
APPSERVER_DBAPI_VERSION=26.1.0.0
DBACCESS_VERSION=26.1.0.0
LICENSESERVER_VERSION=3.7.2
```

### 2. Sincronizar Automaticamente Dockerfiles, Submódulos e Compose (`--fix`)
Execute o script de validação com o parâmetro `--fix` (ou `make fix`):
```bash
./scripts/validation/versions.sh --fix
```
O script atualizará automaticamente:
- As diretivas `LABEL` em todos os `services/*/Dockerfile`.
- As variáveis de versão e `IMAGE_BASE` em todos os `services/*/versions.env`.
- As tags de imagens (`image: <user>/<app>:<tag>`) em `docker-compose.yaml`, `docker-compose-mssql.yaml`, `docker-compose-postgresql.yaml` e `docker-compose-oracle.yaml`.

### 3. Atualizar Mapeamentos de Branches (Se nova Release)
Caso a alteração envolva uma nova release semestral do Protheus:
1. No arquivo [`scripts/hooks/post-checkout.sh`](../../../scripts/hooks/post-checkout.sh), inclua a branch no `case "$BRANCH_NAME"`.
2. No arquivo [`scripts/validation/branch-checkout.sh`](../../../scripts/validation/branch-checkout.sh), adicione o bloco da release na função `obter_branch_do_servico()`.
3. No arquivo [`scripts/validation/status.sh`](../../../scripts/validation/status.sh), adicione o bloco correspondente em `get_expected_branch()`.

### 4. Validação e Diagnóstico Final
Execute o diagnóstico e as validações para garantir que nenhum erro passe pelo hook de pre-commit:
```bash
# 1. Diagnóstico Inteligente geral do projeto
./scripts/validation/status.sh

# 2. Valida consistência entre versions.env, Dockerfiles, Submódulos e Compose
./scripts/validation/versions.sh

# 3. Valida sintaxe de todos os compose files
./scripts/validation/lint-compose.sh

# 4. Valida variáveis de ambiente
./scripts/validation/env.sh
```

---

## Erros Comuns
- **Esquecer o `--fix`**: Tentar comitar após editar `versions.env` fará o hook `pre-commit` falhar.
- **Alterações em `services/*/Dockerfile` ou `services/*/versions.env`**: Lembre-se que modificações dentro de `services/<app>/` pertencem ao submódulo e devem ser comitadas primeiro no submódulo antes do repositório root.
