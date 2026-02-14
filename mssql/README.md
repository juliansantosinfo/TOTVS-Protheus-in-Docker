# Dockerização do MS SQL Server para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o banco de dados **Microsoft SQL Server**, configurado para ser usado com o ambiente TOTVS Protheus.

Este é um dos componentes da arquitetura dockerizada do Protheus, servindo como o backend de banco de dados.

### Outros Componentes Necessários

*   **appserver**: O servidor de aplicação Protheus.
*   **dbaccess**: O serviço de acesso ao banco de dados.
*   **licenseserver**: O serviço de gerenciamento de licenças.

## Início Rápido

**Importante:** Este contêiner precisa estar na mesma rede Docker que os outros serviços (`dbaccess`, `licenseserver`, `appserver`) para que a comunicação funcione.

1.  **Baixe a imagem (se disponível no Docker Hub):**
    ```bash
    docker pull juliansantosinfo/totvs_mssql:latest
    ```

2.  **Crie a rede Docker (caso ainda não exista):**
    ```bash
    docker network create totvs
    ```

3.  **Execute o contêiner:**
    ```bash
    docker run -d \
      --name totvs_mssql \
      --network totvs \
      -p 1433:1433 \
      -e "ACCEPT_EULA=Y" \
      -e "SA_PASSWORD=ProtheusDatabasePassword1" \
      juliansantosinfo/totvs_mssql:latest
    ```

## Build Local

Caso queira construir a imagem localmente:

1.  A partir da raiz do projeto, acesse este diretório:
    ```bash
    cd mssql
    ```

2.  Execute o script de build:
    ```bash
    ./build.sh
    ```

## Variáveis de Ambiente

| Variável de Ambiente | Descrição | Conteúdo Padrão |
|---|---|---|
| `SA_PASSWORD` | Define a senha para o usuário `sa`. | `ProtheusDatabasePassword1` |
| `ACCEPT_EULA` | Confirma a aceitação da licença de uso do SQL Server. | `Y` |
| `RESTORE_BACKUP` | Define se o backup inicial deve ser restaurado (`Y`/`N`). | `Y` |
| `DEBUG_SCRIPT` | Ativa o modo de depuração dos scripts (`true`/`false`). | `false` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |
