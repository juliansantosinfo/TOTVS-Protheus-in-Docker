# Dockerização do SmartView para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o **SmartView** da TOTVS, projetado para rodar sobre distribuições **Enterprise Linux** (como **Red Hat UBI** ou **Oracle Linux**).

O SmartView é o servidor de Business Intelligence (BI) e Analytics do Protheus, responsável por processar consultas analíticas, gerar relatórios modernos e fornecer visualizações de dados (TReports).

### Diferenciais desta Imagem

*   **Compatibilidade Gráfica:** A imagem configura automaticamente o repositório **EPEL** para instalar `libgdiplus` e `fontconfig`, essenciais para a renderização de relatórios e exportações gráficas em ambientes Linux corporativos.
*   **Performance:** Base empresarial otimizada para execução de aplicações .NET Core.

### Outros Componentes Necessários

*   **Banco de Dados**: `mssql`, `postgres` ou `oracle`.
*   **dbaccess**: Middleware de acesso ao banco.
*   **licenseserver**: Gestão de licenças.
*   **AppRest**: O SmartView consome dados via API REST do Protheus.

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
    *Nota: O build instala automaticamente as dependências do EPEL e gera o cache de fontes via fc-cache.*

## Variáveis de Ambiente

| Variável | Descrição | Padrão |
|---|---|---|
| `EXTRACT_RESOURCES` | Extrai `smartview.tar.gz` na inicialização (`true`/`false`). | `true` |
| `DEBUG_SCRIPT` | Ativa o modo de depuração dos scripts (`true`/`false`). | `false` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |
