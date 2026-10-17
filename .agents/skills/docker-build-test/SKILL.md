---
name: docker-build-test
description: Use when building Protheus Docker images, running smoke tests on compose stacks, testing container runtime initialization, or verifying build health.
---

# Build de Imagens Docker e Smoke Tests

## Visão Geral
Padroniza o fluxo de construção das imagens Docker dos serviços TOTVS Protheus (`appserver`, `dbaccess`, `licenseserver`, etc.) e a execução de testes automatizados de inicialização (Smoke Tests).

## Quando Usar
- Ao gerar novas imagens locais após atualização de pacotes ou modificação de Dockerfiles/scripts de entrypoint.
- Ao executar smoke tests para validar se os containers sobem e alcançam estado `healthy`.
- Ao preparar uma release para envio ao Docker Hub (`push.sh`).

**Quando NÃO usar:**
- Para apenas alinhar números de versão em arquivos de texto (utilize a skill `version-sync`).
- Para descompactar pacotes sem disparar o build (utilize a skill `resource-unpack`).

---

## Tabela de Referência Rápida

| Objetivo | Comando |
|---|---|
| Build de todos os serviços | `./scripts/build/build.sh` |
| Build de serviço específico | `./scripts/build/build.sh appserver` (ou `dbaccess`, `licenseserver`, etc.) |
| Build sem cache | `./scripts/build/build.sh appserver --no-cache` |
| Build com logs detalhados | `./scripts/build/build.sh appserver --progress=plain` |
| Validar sintaxe dos Composes | `./scripts/validation/lint-compose.sh` |
| Smoke test em stack específica | `./scripts/test/test-compose.sh -f docker-compose-postgresql.yaml` |
| Smoke test completo (todas as stacks) | `./scripts/test/test-compose.sh --full` |
| Limpar imagens e caches locais | `./scripts/build/clean.sh` |

---

## Procedimento Passo a Passo

### 1. Pré-Requisitos e Recursos
Antes de iniciar o build, garanta que os binários necessários estejam extraídos nos submódulos:
```bash
./scripts/build/setup.sh [apps...]
```
Certifique-se de que o Docker Daemon está ativo e com permissões adequadas:
```bash
docker info > /dev/null
```

### 2. Executar o Build
Execute o script master de build indicando os serviços desejados:
```bash
# Exemplo: Build apenas de AppServer e DbAccess
./scripts/build/build.sh appserver dbaccess
```
O script master:
- Carrega as variáveis de [`versions.env`](../../../versions.env).
- Entra no diretório `services/<app>`.
- Executa o script `build.sh` interno com os argumentos passados.
- Tagueia a imagem no formato `${DOCKER_USER}/${IMAGE_NAME}:${VERSION}`.

### 3. Validar e Testar a Stack (Smoke Test)
Após o build, valide a integridade executando o smoke test:
```bash
# Valida sintaxe + sobe containers até ficarem 'healthy' + derruba com limpeza
./scripts/test/test-compose.sh -f docker-compose-postgresql.yaml
```

Critérios de sucesso do Smoke Test:
- Todos os containers alcançam status `healthy` dentro do timeout (padrão: 480 segundos).
- Logs não apresentam falhas de conexão de licença ou DBAccess.
- O ambiente é derrubado e os volumes limpos sem deixar resíduos órfãos.

---

## Troubleshooting Comum
- **Erro `OPERATIONAL LIMITS` no AppServer**:
  Verifique os limites no host com `ulimit -n`. Caso inferior a 65536, aplique `ulimit -n 65536` ou configure `/etc/security/limits.conf`.
- **Falha de Timeout no DbAccess**:
  Verifique se o banco de dados especificado já estava inicializado e se o License Server está respondendo na porta `5555`.
