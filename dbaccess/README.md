# Dockerização do DBAccess para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o **DBAccess** da TOTVS.

Este serviço atua como um intermediário de comunicação entre os servidores de aplicação (`appserver`) e o banco de dados, gerenciando as conexões.

### Outros Componentes Necessários

*   **Banco de Dados**: `mssql`, `postgres` ou `oracle`.
*   **licenseserver**: O serviço de gerenciamento de licenças.
*   **appserver**: O servidor de aplicação Protheus.

## Início Rápido

**Importante:** Este contêiner precisa estar na mesma rede Docker que o banco de dados e o License Server para funcionar corretamente.

1.  **Baixe a imagem (se disponível no Docker Hub):**
    ```bash
    docker pull juliansantosinfo/totvs_dbaccess:latest
    ```

2.  **Crie a rede Docker (caso ainda não exista):**
    ```bash
    docker network create totvs
    ```

3.  **Execute o contêiner:**
    ```bash
    docker run -d \
      --name totvs_dbaccess \
      --network totvs \
      -p 7890:7890 \
      -p 7891:7891 \
      juliansantosinfo/totvs_dbaccess:latest
    ```
    *Observação: A configuração do banco de dados é feita via variáveis de ambiente.*

## Build Local

Caso queira construir a imagem localmente:

1.  A partir da raiz do projeto, acesse este diretório:
    ```bash
    cd dbaccess
    ```

2.  Execute o script de build:
    ```bash
    ./build.sh
    ```

## Variáveis de Ambiente

| Variável | Descrição | Padrão |
|---|---|---|
| `DATABASE_PROFILE` | Tipo do banco de dados. | `POSTGRES`, `MSSQL` ou `ORACLE` |
| `DATABASE_SERVER` | Host do servidor de banco de dados. | `totvs_postgres` / `totvs_mssql` / `totvs_oracle` |
| `DATABASE_PORT` | Porta do servidor de banco de dados. | `5432` / `1433` / `1521` |
| `DATABASE_ALIAS` | Alias da base de dados no DBAccess. | `protheus` |
| `DATABASE_NAME` | Nome da base de dados. | `protheus` |
| `DATABASE_USERNAME` | Usuário de acesso ao banco. | `postgres` / `sa` / `protheus` |
| `DATABASE_PASSWORD` | Senha de acesso ao banco. | `ProtheusDatabasePassword1` |
| `DATABASE_WAIT_RETRIES` | Número de tentativas de conexão com o banco. | `30` |
| `DATABASE_WAIT_INTERVAL` | Intervalo em segundos entre tentativas. | `2` |
| `DBACCESS_LICENSE_SERVER`| Host do License Server. | `totvs_licenseserver` |
| `DBACCESS_LICENSE_PORT`| Porta do License Server. | `5555` |
| `LICENSE_WAIT_RETRIES` | Número de tentativas de conexão com o License Server. | `30` |
| `LICENSE_WAIT_INTERVAL` | Intervalo em segundos entre tentativas. | `2` |
| `DEBUG_SCRIPT` | Ativa o modo de depuração dos scripts (`true`/`false`). | `false` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |
