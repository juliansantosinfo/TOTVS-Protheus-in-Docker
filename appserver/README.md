# Dockerização do AppServer para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o **AppServer** Protheus.

Esta imagem é versátil e pode operar em dois modos distintos, configurados através da variável de ambiente `APPSERVER_MODE`:
*   **`application`** (padrão): Executa o servidor de aplicação principal, para acesso via Smartclient.
*   **`rest`**: Executa o servidor configurado para atender requisições da API REST.

### Outros Componentes Necessários

*   **Banco de Dados**: `mssql` ou `postgres`.
*   **dbaccess**: O serviço de acesso ao banco de dados.
*   **licenseserver**: O serviço de gerenciamento de licenças.

## Início Rápido

**Importante:** Este contêiner precisa estar na mesma rede Docker que os serviços de `dbaccess` e `licenseserver` para funcionar.

1.  **Baixe a imagem (se disponível no Docker Hub):**
    ```bash
    docker pull juliansantosinfo/totvs_appserver:latest
    ```

2.  **Crie a rede Docker (caso ainda não exista):**
    ```bash
    docker network create totvs
    ```

3.  **Execute o contêiner:**

    *   **Modo Aplicação (Smartclient):**
        ```bash
        docker run -d \
          --name totvs_appserver \
          --network totvs \
          -p 25001:25001 \
          -p 25002:25002 \
          -e "APPSERVER_MODE=application" \
          juliansantosinfo/totvs_appserver:latest
        ```

    *   **Modo REST (API):**
        ```bash
        docker run -d \
          --name totvs_apprest \
          --network totvs \
          -p 25180:25180 \
          -e "APPSERVER_MODE=rest" \
          juliansantosinfo/totvs_appserver:latest
        ```

## Build Local

Caso queira construir a imagem localmente:

1.  A partir da raiz do projeto, acesse este diretório:
    ```bash
    cd appserver
    ```

2.  Execute o script de build:
    ```bash
    ./build.sh
    ```

## Variáveis de Ambiente

| Variável | Descrição | Padrão |
|---|---|---|
| `APPSERVER_MODE` | Define o modo de operação: `application` ou `rest`. | `application` |
| `APPSERVER_DBACCESS_DATABASE` | Tipo do banco de dados. | `POSTGRES` ou `MSSQL` |
| `APPSERVER_DBACCESS_SERVER` | Host do serviço DBAccess. | `totvs_dbaccess` |
| `APPSERVER_DBACCESS_PORT` | Porta do serviço DBAccess. | `7890` |
| `APPSERVER_DBACCESS_ALIAS` | Alias da conexão com o banco. | `protheus` |
| `APPSERVER_LICENSE_SERVER` | Host do License Server. | `totvs_licenseserver` |
| `APPSERVER_LICENSE_PORT` | Porta do License Server. | `5555` |
| `APPSERVER_PORT` | Porta principal do AppServer. | `25001` |
| `APPSERVER_WEB_PORT` | Porta da interface web (Smartclient). | `25002` |
| `APPSERVER_REST_PORT` | Porta do serviço REST (usado no modo `rest`). | `25180` |
| `APPSERVER_WEB_MANAGER` | Porta da interface de gerenciamento. | `25088` |
| `DEBUG_SCRIPT` | Ativa o modo de depuração dos scripts (`true`/`false`). | `false` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |