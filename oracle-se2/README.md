# Dockerização do Oracle Database para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o banco de dados **Oracle Database** (versão SE2).

**Importante:** As imagens Oracle SE2 não podem ser redistribuídas. Você deve construir a imagem localmente após baixar os binários oficiais da Oracle.

### Outros Componentes Necessários

*   **appserver**: O servidor de aplicação Protheus.
*   **dbaccess**: O serviço de acesso ao banco de dados.
*   **licenseserver**: O serviço de gerenciamento de licenças.

## Pré-requisitos

### Download dos Binários Oracle

Antes de construir a imagem, você precisa baixar os binários do Oracle Database:

1.  Acesse o site oficial da Oracle: [Oracle Database Downloads](https://www.oracle.com/database/technologies/oracle-database-software-downloads.html)

2.  Faça login com sua conta Oracle (ou crie uma conta gratuita)

3.  Baixe a versão desejada:
    *   **Oracle Database 19c (19.3.0)**: `LINUX.X64_193000_db_home.zip`
    *   **Oracle Database 21c (21.3.0)**: `LINUX.X64_213000_db_home.zip`

4.  Coloque o arquivo `.zip` baixado no diretório da versão correspondente:
    ```bash
    # Para Oracle 19c
    mv LINUX.X64_193000_db_home.zip ./19.3.0/

    # Para Oracle 21c
    mv LINUX.X64_213000_db_home.zip ./21.3.0/
    ```

## Build da Imagem

**Importante:** Este contêiner precisa estar na mesma rede Docker que os outros serviços (`dbaccess`, `licenseserver`, `appserver`) para que a comunicação funcione.

1.  **Construa a imagem localmente:**
    ```bash
    # Para Oracle 19c SE2
    ./build.sh -v 19.3.0 -t juliansantosinfo/totvs_oracle -s

    # Para Oracle 21c SE2
    ./build.sh -v 21.3.0 -t juliansantosinfo/totvs_oracle -s
    ```

2.  **Crie a rede Docker (caso ainda não exista):**
    ```bash
    docker network create totvs
    ```

3.  **Execute o contêiner:**
    ```bash
    docker run -d \
      --name totvs_oracle \
      --network totvs \
      -p 1521:1521 \
      -e ORACLE_SID=ORCL \
      -e ORACLE_PWD=ProtheusDatabasePassword1 \
      juliansantosinfo/totvs_oracle
    ```

## Variáveis de Ambiente

| Variável de Ambiente | Descrição | Conteúdo Padrão |
|---|---|---|
| `ORACLE_SID` | Nome do serviço Oracle. | `ORCL` |
| `ORACLE_PWD` | Senha do banco de dados Oracle. | ` ` |

## Notas

*   Os scripts de build são baseados nos [Dockerfiles oficiais da Oracle](https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance)
*   O processo de build pode levar bastante tempo (30-60 minutos dependendo do hardware)
*   Certifique-se de ter espaço em disco suficiente (mínimo 15GB livres)
