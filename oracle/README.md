# Dockerização do Oracle Database para ERP TOTVS Protheus

## Overview

Este diretório contém a implementação do container Docker para o banco de dados **Oracle Database**, especificamente otimizado para o ERP TOTVS Protheus. 

A imagem utiliza como base a versão **Oracle XE 21c**, garantindo um ambiente leve e funcional para desenvolvimento e testes. Diferente de instalações tradicionais, esta imagem utiliza uma estratégia de **pré-carregamento de dados**, onde o banco de dados já vem com a estrutura de dicionários do Protheus inicializada através de snapshots físicos.

### Outros Componentes Necessários

*   **appserver**: O servidor de aplicação Protheus.
*   **dbaccess**: O serviço de acesso ao banco de dados.
*   **licenseserver**: O serviço de gerenciamento de licenças.

### Componentes da Solução
*   **Base:** Oracle Express Edition (XE) 21c.
*   **Estratégia de Dados:** Restauração via `data.tar.gz` (contendo os arquivos do diretório `oradata`).
*   **Segurança:** Validação de integridade via hashes SHA1 durante o build.

## Pré-requisitos

### Recursos Necessários (Snapshot de Dados)
Para que a imagem funcione corretamente, você deve fornecer o arquivo `data.tar.gz` no diretório `oracle/resources/`. Este arquivo contém os arquivos físicos do banco de dados já configurados para o Protheus.

Você pode baixar automaticamente os recursos necessários utilizando o script de setup na raiz do projeto:
```bash
./scripts/build/setup.sh oracle
```

## Build da Imagem

O script de build automatiza a validação de integridade e a marcação da imagem com base nas versões definidas no arquivo `versions.env`.

1.  **Construa a imagem localmente:**
    ```bash
    ./oracle/build.sh
    ```
    *Nota: O script verificará se houve alterações nos arquivos locais (via hashes) e só processará o build se houver mudanças.*

## Execução e Início Rápido

Você pode rodar o banco de dados de forma isolada ou via Docker Compose (recomendado).

### Via Docker Run (Manual)
```bash
docker run -d \
  --name totvs_oracle \
  --network totvs \
  -p 1521:1521 \
  -e ORACLE_PWD=ProtheusDatabasePassword1 \
  -v totvs_oracle_data:/opt/oracle/oradata \
  juliansantosinfo/totvs_oracle:21.3.0
    ```

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
    docker run -d \
      --name totvs_oracle \ 
      --network totvs \
      -p 1521:1521 \
      -e "ORACLE_PWD=ProtheusDatabasePassword1" \
      juliansantosinfo/totvs_oracle:latest
    ```

### Via Docker Compose
Utilize o arquivo dedicado na raiz do projeto:
```bash
docker compose -f docker-compose-oracle.yaml -p totvs up -d
```

## Variáveis de Ambiente

| Variável | Descrição | Valor Padrão |
|---|---|---|
| `ORACLE_SID` | Identificador do Sistema (Instance Name). | `XE` |
| `ORACLE_PWD` | Senha para os usuários `SYS`, `SYSTEM` e `PDBADMIN`. | `ProtheusDatabasePassword1` |
| `ORACLE_CHARACTERSET` | Character set do banco de dados. | `WE8MSWIN1252` |
| `RESTORE_BACKUP` | Define se o backup em `data.tar.gz` deve ser restaurado. | `Y` |
| `DEBUG_SCRIPT` | Ativa o modo de depuração (`set -x`) nos scripts. | `false` |
| `TZ` | Fuso horário do sistema. | `America/Sao_Paulo` |

## Persistência de Dados
Os dados do banco residem no diretório `/opt/oracle/oradata` dentro do container. É altamente recomendável mapear este diretório para um volume Docker para garantir a persistência dos dados entre reinícios de container.

No Compose, o volume padrão é o `totvs_oracle_data`.

## Validação de Integridade
Este módulo utiliza um arquivo `.hashes.sha1` para monitorar alterações nos scripts de inicialização e Dockerfile. Se você fizer alterações manuais nos scripts, o `build.sh` detectará e atualizará os hashes automaticamente.
