# Diretrizes de Gestão de Versões

O versionamento de todas as imagens, binários e artefatos TOTVS Protheus é estritamente centralizado.

## 1. Fonte Única da Verdade (`versions.env`)
- O arquivo `versions.env` na raiz do projeto é a **única fonte da verdade** para:
  - Versão da Release TOTVS (`RESOURCE_RELEASE`, `APPSERVER_RELEASE`).
  - Tags das imagens Docker (`*_VERSION`, `*_IMAGE_NAME`).
  - Usuário Docker Hub (`DOCKER_USER`).
  - Versões específicas de componentes (`APPSERVER_BUILD_VERSION`, `APPSERVER_WEBAPP_VERSION`, `APPSERVER_DBAPI_VERSION`, `DBACCESS_VERSION`, `LICENSESERVER_VERSION`, etc.).

## 2. Sincronização Obrigatória com Dockerfiles
- Qualquer alteração manual ou automática em `versions.env` DEVE ser sucedida pela execução:
  ```bash
  ./scripts/validation/versions.sh --fix
  ```
- Este comando propaga e corrige os valores dos metadados `LABEL release=...`, `LABEL build=...`, `LABEL dbapi=...`, `LABEL webapp=...` e `LABEL version=...` nos `Dockerfile`s em `services/`.
- O Git Pre-commit Hook bloqueará qualquer commit se houver divergência entre `versions.env` e os `Dockerfile`s.

## 3. Sincronização dos Arquivos Docker Compose
- Ao criar ou migrar para uma nova versão de serviço (ex: AppServer `12.1.2610`, DbAccess `26.1.0.0`, License Server `3.7.2`), certifique-se de atualizar as referências nos arquivos Compose:
  - `docker-compose.yaml`
  - `docker-compose-mssql.yaml`
  - `docker-compose-postgresql.yaml`
  - `docker-compose-oracle.yaml`
- As tags devem refletir exatamente as variáveis definidas em `versions.env`.

## 4. Atualização de Mapeamentos de Branches
- Ao introduzir uma nova release anual/semestral do Protheus (ex: `12.1.2610`):
  - Inclua a nova release no `case` de [`scripts/hooks/post-checkout.sh`](../../scripts/hooks/post-checkout.sh).
  - Adicione a tabela de mapeamento de submódulos correspondente na função `obter_branch_do_servico` de [`scripts/validation/branch-checkout.sh`](../../scripts/validation/branch-checkout.sh).
