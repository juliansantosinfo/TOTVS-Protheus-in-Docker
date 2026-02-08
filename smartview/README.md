# Dockerização do SmartView para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o **SmartView** da TOTVS.

O SmartView é o servidor de Business Intelligence (BI) e Analytics do Protheus, responsável por processar consultas analíticas, gerar relatórios e fornecer visualizações de dados.

### Outros Componentes Necessários

*   **Banco de Dados**: `mssql` ou `postgres`.
*   **dbaccess**: O serviço de acesso ao banco de dados.
*   **licenseserver**: O serviço de gerenciamento de licenças.

## Início Rápido

**Importante:** Este contêiner precisa estar na mesma rede Docker que os serviços de `dbaccess` e `licenseserver` para funcionar.

1.  **Baixe a imagem (se disponível no Docker Hub):**
    ```bash
    docker pull juliansantosinfo/totvs_smartview:latest
    ```

2.  **Crie a rede Docker (caso ainda não exista):**
    ```bash
    docker network create totvs
    ```

3.  **Execute o contêiner:**
    ```bash
    docker run -d \
      --name totvs_smartview \
      --network totvs \
      -p 7017:7017 \
      -p 7019:7019 \
      juliansantosinfo/totvs_smartview:latest
    ```

## Build Local

Caso queira construir a imagem localmente:

1.  A partir da raiz do projeto, acesse este diretório:
    ```bash
    cd smartview
    ```

2.  Execute o script de build:
    ```bash
    ./build.sh
    ```

## Variáveis de Ambiente

| Variável | Descrição | Padrão |
|---|---|---|
| `EXTRACT_RESOURCES` | Extrai `smartview.tar.gz` na inicialização (`true`/`false`). | `true` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |
