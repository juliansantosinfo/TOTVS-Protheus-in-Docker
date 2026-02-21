# Dockerização do AppServer para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o **AppServer** Protheus.

A imagem é projetada para rodar sobre distribuições **Enterprise Linux** (como **Red Hat UBI** ou **Oracle Linux**), oferecendo segurança e estabilidade corporativa.

### Modos de Operação

Esta imagem é versátil e pode operar em três modos distintos, configurados através da variável de ambiente `APPSERVER_MODE`:
*   **`application`** (padrão): Servidor de aplicação principal (SmartClient Web/TCP).
*   **`rest`**: Servidor configurado para atender requisições da API REST.
*   **`sqlite`**: Servidor de arquivos locais (LocalFiles) para alta performance de I/O em banco de dados local.

**Otimização:** O servidor web de gerenciamento legado em Python/Flask foi removido para reduzir o tamanho da imagem e aumentar a segurança.

### Outros Componentes Necessários

*   **Banco de Dados**: `mssql`, `postgres` ou `oracle`.
*   **dbaccess**: Middleware de acesso ao banco.
*   **licenseserver**: Gestão de licenças.

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
          -p 1234:1234 \
          -p 12345:12345 \
          -e "APPSERVER_MODE=application" \
          juliansantosinfo/totvs_appserver:latest
        ```

    *   **Modo REST (API):**
        ```bash
        docker run -d \
          --name totvs_apprest \
          --network totvs \
          -p 8080:8080 \
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
    *Nota: O build utiliza o gerenciador de pacotes dinâmico ($PKG_MGR) para configurar dependências como gzip e procps.*

## Variáveis de Ambiente

| Variável | Descrição | Padrão |
|---|---|---|
| `APPSERVER_MODE` | Define o modo de operação: `application`, `rest` ou `sqlite`. | `application` |
| `APPSERVER_DBACCESS_DATABASE` | Tipo do banco de dados (POSTGRES, MSSQL, ORACLE). | `MSSQL` |
| `APPSERVER_DBACCESS_SERVER` | Host do serviço DBAccess. | `totvs_dbaccess` |
| `APPSERVER_DBACCESS_PORT` | Porta do serviço DBAccess. | `7890` |
| `APPSERVER_DBACCESS_ALIAS` | Alias da conexão com o banco. | `protheus` |
| `APPSERVER_LICENSE_SERVER` | Host do License Server. | `totvs_licenseserver` |
| `APPSERVER_LICENSE_PORT` | Porta do License Server. | `5555` |
| `APPSERVER_PORT` | Porta principal do AppServer (TCP). | `1234` |
| `APPSERVER_WEB_PORT` | Porta da interface web (Smartclient). | `12345` |
| `APPSERVER_REST_PORT` | Porta do serviço REST (usado no modo `rest`). | `8080` |
| `APPSERVER_ENVIRONMENT_LOCALFILES`| Tipo de banco para arquivos locais. | `SQLITE` |
| `LICENSE_WAIT_RETRIES` | Tentativas de conexão com o License Server. | `30` |
| `LICENSE_WAIT_INTERVAL` | Intervalo em segundos entre tentativas. | `2` |
| `DBACCESS_WAIT_RETRIES` | Tentativas de conexão com o DBAccess. | `30` |
| `DBACCESS_WAIT_INTERVAL` | Intervalo em segundos entre tentativas. | `2` |
| `DEBUG_SCRIPT` | Ativa o modo de depuração dos scripts (`true`/`false`). | `false` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |