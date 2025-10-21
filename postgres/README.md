# Dockerização do PostgreSQL para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o banco de dados **PostgreSQL**, configurado para ser usado com o ambiente TOTVS Protheus.

Este é um dos componentes da arquitetura dockerizada do Protheus, servindo como o backend de banco de dados.

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
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |
