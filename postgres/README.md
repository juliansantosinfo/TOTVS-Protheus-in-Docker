# Dockerização do PostgreSQL para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o banco de dados **PostgreSQL**, configurado e otimizado para o ERP TOTVS Protheus.

A imagem utiliza uma estratégia de **pré-carregamento de dados**, onde o banco de dados já vem com a estrutura de dicionários do Protheus inicializada através de snapshots do diretório `PGDATA`. Isso elimina a necessidade de rodar assistentes de criação de tabelas que podem levar horas.

### Recursos Necessários
Para que a imagem funcione corretamente, o arquivo `data.tar.gz` deve estar presente em `postgres/resources/`. Você pode baixá-lo automaticamente via script de setup:
```bash
./scripts/build/setup.sh postgres
```


### Outros Componentes Necessários

*   **appserver**: O servidor de aplicação Protheus.
*   **dbaccess**: O serviço de acesso ao banco de dados.
*   **licenseserver**: O serviço de gerenciamento de licenças.

## Início Rápido

**Importante:** Este contêiner precisa estar na mesma rede Docker que os outros serviços (`dbaccess`, `licenseserver`, `appserver`) para que a comunicação funcione.

1.  **Baixe a imagem (se disponível no Docker Hub):**
    ```bash
    docker pull juliansantosinfo/totvs_postgres:latest
    ```

2.  **Crie a rede Docker (caso ainda não exista):**
    ```bash
    docker network create totvs
    ```

3.  **Execute o contêiner:**
    ```bash
    docker run -d \
      --name totvs_postgres \
      --network totvs \
      -p 5432:5432 \
      -e "POSTGRES_USER=postgres" \
      -e "POSTGRES_PASSWORD=ProtheusDatabasePassword1" \
      juliansantosinfo/totvs_postgres:latest
    ```

## Build Local

Caso queira construir a imagem localmente:

1.  A partir da raiz do projeto, acesse este diretório:
    ```bash
    cd postgres
    ```

2.  Execute o script de build:
    ```bash
    ./build.sh
    ```

## Variáveis de Ambiente

| Variável de Ambiente | Descrição | Conteúdo Padrão |
|---|---|---|
| `POSTGRES_USER` | Define o nome do superusuário do banco de dados. | `postgres` |
| `POSTGRES_PASSWORD` | Define a senha para o superusuário. | `ProtheusDatabasePassword1` |
| `POSTGRES_DB` | Nome do banco de dados a ser criado na inicialização. | `protheus` |
| `RESTORE_BACKUP` | Define se o backup inicial deve ser restaurado (`Y`/`N`). | `Y` |
| `DEBUG_SCRIPT` | Ativa o modo de depuração dos scripts (`true`/`false`). | `false` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |
