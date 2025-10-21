# Dockerização do License Server para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o **License Server** da TOTVS.

Este serviço é um componente essencial da arquitetura, responsável pelo gerenciamento e distribuição de licenças para os serviços de aplicação do Protheus.

### Outros Componentes Necessários

*   **Banco de Dados**: `mssql` ou `postgres`.
*   **dbaccess**: O serviço de acesso ao banco de dados.
*   **appserver**: O servidor de aplicação Protheus.

## Início Rápido

**Importante:** Este contêiner precisa estar na mesma rede Docker que os outros serviços para que a comunicação funcione.

1.  **Baixe a imagem (se disponível no Docker Hub):**
    ```bash
    docker pull juliansantosinfo/totvs_licenseserver:latest
    ```

2.  **Crie a rede Docker (caso ainda não exista):**
    ```bash
    docker network create totvs
    ```

3.  **Execute o contêiner:**
    ```bash
    docker run -d \
      --name totvs_licenseserver \
      --network totvs \
      -p 5555:5555 \
      -p 2234:2234 \
      -p 8020:8020 \
      --ulimit nofile=65536:65536 \
      juliansantosinfo/totvs_licenseserver:latest
    ```

## Build Local

Caso queira construir a imagem localmente:

1.  A partir da raiz do projeto, acesse este diretório:
    ```bash
    cd licenseserver
    ```

2.  Execute o script de build:
    ```bash
    ./build.sh
    ```

## Variáveis de Ambiente

| Variável | Descrição | Padrão |
|---|---|---|
| `LICENSE_TCP_PORT` | Porta TCP de comunicação. | `2234` |
| `LICENSE_PORT` | Porta principal do serviço. | `5555` |
| `LICENSE_WEBAPP_PORT`| Porta da interface web de monitoramento. | `8020` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |
