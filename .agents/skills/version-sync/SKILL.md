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

### 2. Sincronizar Dockerfiles Automaticamente
Execute o script de validação com o parâmetro `--fix`:
```bash
./scripts/validation/versions.sh --fix
```
O script atualizará automaticamente as diretivas `LABEL` nos Dockerfiles de `services/appserver/Dockerfile` e `services/dbaccess/Dockerfile`.

### 3. Atualizar Arquivos Docker Compose
Verifique e atualize as tags das imagens em todos os arquivos Compose afetados:
- `docker-compose.yaml`
- `docker-compose-mssql.yaml`
- `docker-compose-postgresql.yaml`
- `docker-compose-oracle.yaml`

Certifique-se de que os serviços `appserver`, `apprest`, `dbaccess`, `licenseserver` e `smartview` utilizem as novas tags.

### 4. Atualizar Mapeamentos de Branches (Se nova Release)
Caso a alteração envolva uma nova release semestral do Protheus:
1. No arquivo [`scripts/hooks/post-checkout.sh`](../../../scripts/hooks/post-checkout.sh), inclua a branch no `case "$BRANCH_NAME"`.
2. No arquivo [`scripts/validation/branch-checkout.sh`](../../../scripts/validation/branch-checkout.sh), adicione o bloco da release na função `obter_branch_do_servico()`.

### 5. Validação e Verificação Final
Execute as validações para garantir que nenhum erro passe pelo hook de pre-commit:
```bash
# 1. Valida consistência entre versions.env e Dockerfiles
./scripts/validation/versions.sh

# 2. Valida sintaxe de todos os compose files
./scripts/validation/lint-compose.sh

# 3. Valida variáveis de ambiente
./scripts/validation/env.sh
```

---

## Erros Comuns
- **Esquecer o `--fix`**: Tentar comitar após editar `versions.env` fará o hook `pre-commit` falhar.
- **Docker Compose dessincronizado**: O `versions.sh` valida apenas os `Dockerfile`s; os compose files precisam ser atualizados explicitamente.
- **Submódulo com `versions.env` interno**: Certifique-se de que o `versions.env` de `services/appserver/` e `services/dbaccess/` não possuam conflito com o root.
