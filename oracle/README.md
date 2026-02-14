# Dockerização do Oracle Database para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o banco de dados **Oracle Database** (versão SE2), configurado para ser usado com o ambiente TOTVS Protheus.

Este é um dos componentes da arquitetura dockerizada do Protheus, servindo como o backend de banco de dados.

### Outros Componentes Necessários

*   **appserver**: O servidor de aplicação Protheus.
*   **dbaccess**: O serviço de acesso ao banco de dados.
*   **licenseserver**: O serviço de gerenciamento de licenças.

## Início Rápido

**Importante:** Este contêiner precisa estar na mesma rede Docker que os outros serviços (`dbaccess`, `licenseserver`, `appserver`) para que a comunicação funcione.

1.  **Baixe a imagem (se disponível no Docker Hub):**
    ```bash
    docker pull juliansantosinfo/totvs_oracle:latest
    ```

2.  **Crie a rede Docker (caso ainda não exista):**
    ```bash
    docker network create totvs
    ```

3.  **Execute o contêiner:**
    ```bash
    docker run -d 
      --name totvs_oracle 
      --network totvs 
      -p 1521:1521 
      -e "ORACLE_PASSWORD=ProtheusDatabasePassword1"
      juliansantosinfo/totvs_oracle:latest
    ```

## Build Local

Caso queira construir a imagem localmente:

1.  A partir da raiz do projeto, acesse este diretório:
    ```bash
    cd oracle
    ```

2.  Execute o script de build:
    ```bash
    ./build.sh
    ```

## Variáveis de Ambiente

| Variável de Ambiente | Descrição | Conteúdo Padrão |
|---|---|---|
| `ORACLE_PASSWORD` | Senha para os usuários `SYS`, `SYSTEM`. | `ProtheusDatabasePassword1` |
| `RESTORE_BACKUP` | Define se o backup inicial deve ser restaurado (`Y`/`N`). | `Y` |
| `DEBUG_SCRIPT` | Ativa o modo de depuração dos scripts (`true`/`false`). | `false` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |
