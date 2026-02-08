# Dockerização do ERP TOTVS Protheus

## Overview

Este repositório contém a implementação da aplicação do ERP TOTVS Protheus utilizando uma arquitetura de microserviços em containers Docker.

O sistema de ERP Protheus é uma solução de software complexa que requer configurações e dependências específicas. Este projeto visa simplificar drasticamente a instalação, configuração e execução do Protheus para **ambientes de desenvolvimento e teste**.

## 🚀 Gerador de Docker Compose (Recomendado)

Para facilitar a configuração do seu ambiente Protheus em Docker, utilize o **[TOTVS Protheus Compose Generator](https://juliansantosinfo.github.io/TOTVS-Protheus-Compose-Generator/)**. 

Esta ferramenta web permite que você selecione de forma visual e intuitiva as versões do Protheus (12.1.2310, 12.1.2410, 12.1.2510), o banco de dados (PostgreSQL ou MSSQL) e outros serviços opcionais (como o servidor REST). Ao final, ela gera automaticamente os arquivos `docker-compose.yml` e `.env` customizados para sua necessidade.

*   **Acesse agora:** [https://juliansantosinfo.github.io/TOTVS-Protheus-Compose-Generator/](https://juliansantosinfo.github.io/TOTVS-Protheus-Compose-Generator/)
*   **Repositório do Gerador:** [juliansantosinfo/TOTVS-Protheus-Compose-Generator](https://github.com/juliansantosinfo/TOTVS-Protheus-Compose-Generator)

* [**Release 12.1.2310**](https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker/tree/12.1.2310)
* [**Release 12.1.2410**](https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker/tree/12.1.2410)
* [**Release 12.1.2510**](https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker/tree/12.1.2510)

## Componentes

A arquitetura do projeto é dividida nos seguintes serviços:

1.  **`appserver`**: O servidor de aplicação Protheus. Esta é uma imagem versátil que pode operar em dois modos, definidos pela variável de ambiente `APPSERVER_MODE`:
    *   `application` (padrão): Executa o servidor de aplicação principal, permitindo acesso via Smartclient.
    *   `rest`: Executa o servidor para atender requisições da API REST.
2.  **`dbaccess`**: O serviço intermediário que gerencia e fornece o acesso ao banco de dados.
3.  **`licenseserver`**: O serviço de gerenciamento de licenças da TOTVS.
4.  **Banco de Dados**: Você pode escolher entre duas opções de banco de dados:
    *   **`mssql`**: Microsoft SQL Server.
    *   **`postgres`**: PostgreSQL.

## Aviso Legal e Instruções de Uso

Este repositório é um projeto independente e não possui qualquer afiliação com a TOTVS S/A. O código e as imagens aqui disponibilizados são destinados **exclusivamente para fins de desenvolvimento e testes**. **Não utilize este projeto em ambiente de produção.**

Ao utilizar este repositório, você concorda com os termos da licença MIT.

## Requisitos de Sistema

Certifique-se de ter os seguintes pré-requisitos instalados em seu sistema:

*   **Windows:**
    1.  **WSL2:** Ative o Subsistema Windows para Linux. [Guia de Instalação](https://learn.microsoft.com/pt-br/windows/wsl/install).
    2.  **Docker Desktop:** Instale o Docker Desktop para Windows. [Guia de Instalação](https://docs.docker.com/desktop/windows/install).
*   **Linux:**
    1.  **Docker e Docker Compose:** Instale as versões mais recentes. Consulte a documentação oficial para sua distribuição.
*   **Mac:**
    1.  **Docker Desktop:** Instale o Docker Desktop para macOS. [Guia de Instalação](https://docs.docker.com/desktop/mac/install/).

## Início Rápido

Você pode configurar o ambiente de duas formas: utilizando o gerador web (mais fácil) ou manualmente seguindo os passos abaixo.

### Opção 1: Usando o Gerador (Recomendado)

1. Acesse o [**TOTVS Protheus Compose Generator**](https://juliansantosinfo.github.io/TOTVS-Protheus-Compose-Generator/).
2. Selecione as opções desejadas.
3. Baixe os arquivos `docker-compose.yml` e `.env`.
4. Em um terminal, na pasta onde baixou os arquivos, execute:
   ```bash
   docker compose up -d
   ```

### Opção 2: Configuração Manual

1.  Clone este repositório:
    ```bash
    git clone https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker.git
    cd TOTVS-Protheus-in-Docker
    ```

2.  Configure as variáveis de ambiente. Copie o arquivo de exemplo `.env.example` para `.env` e ajuste as variáveis conforme necessário, como a senha do banco de dados.
    ```bash
    cp .env.example .env
    ```

3.  Inicie os contêineres usando Docker Compose. Escolha o comando de acordo com o banco de dados desejado:

    *   **Para usar PostgreSQL (Recomendado):**
        ```bash
        docker compose -f docker-compose-postgresql.yaml -p totvs up -d
        ```

    *   **Para usar Microsoft SQL Server:**
        ```bash
        docker compose -f docker-compose-mssql.yaml -p totvs up -d
        ```
    
    O perfil `full` inclui o serviço `apprest` (servidor REST). Para iniciá-lo junto com os outros serviços:
    ```bash
    # Exemplo com PostgreSQL
    docker compose -f docker-compose-postgresql.yaml --profile full -p totvs up -d
    ```


4.  Acesse a aplicação:
    *   **Smartclient Web:** Abra seu navegador e acesse <http://localhost:25002>
    *   **Credenciais (Release 12.1.2510):**
        *   **Usuário:** `admin`
        *   **Senha:** `Docker@123`

## Build Local das Imagens

Se preferir construir as imagens Docker localmente em vez de usar as do Docker Hub:

1.  Clone o repositório, caso ainda não o tenha feito.
2.  Execute o script `build.sh` dentro do diretório de cada componente:
    ```bash
    # Construir a imagem do AppServer (que serve para 'application' e 'rest')
    cd appserver/
    ./build.sh
    cd ..

    # Construir a imagem do DBAccess
    cd dbaccess/
    ./build.sh
    cd ..

    # Construir a imagem do License Server
    cd licenseserver/
    ./build.sh
    cd ..

    # Construir a imagem do MS SQL (se for usar)
    cd mssql/
    ./build.sh
    cd ..

    # Construir a imagem do PostgreSQL (se for usar)
    cd postgres/
    ./build.sh
    cd ..
    ```
3.  Após construir as imagens, suba os contêineres com os comandos do "Início Rápido".

## Configuração

A configuração dos serviços é feita principalmente por meio de **variáveis de ambiente**. Os arquivos `docker-compose-*.yaml` contêm as configurações padrão.

Os `Dockerfiles` para cada componente estão em seus respectivos diretórios (`appserver/dockerfile`, `dbaccess/dockerfile`, etc.).

## Execução Manual dos Containers

Para executar cada contêiner individualmente (sem Docker Compose), siga os passos:

1.  **Crie a Rede Docker:**
    ```bash
    docker network create totvs
    ```

2.  **Inicie os Contêineres:**
    *   **Banco de Dados (Exemplo com MSSQL):**
        ```bash
        docker run -d --name totvs_mssql --network totvs -p 1433:1433 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=ProtheusDatabasePassword1" juliansantosinfo/totvs_mssql:latest
        ```
    *   **License Server:**
        ```bash
        docker run -d --name totvs_licenseserver --network totvs -p 5555:5555 -p 2234:2234 -p 8020:8020 juliansantosinfo/totvs_licenseserver:latest
        ```
    *   **DBAccess:**
        ```bash
        docker run -d --name totvs_dbaccess --network totvs -p 7890:7890 -e "DATABASE_SERVER=totvs_mssql" -e "DATABASE_PASSWORD=ProtheusDatabasePassword1" juliansantosinfo/totvs_dbaccess:latest
        ```
    *   **AppServer (Modo Aplicação):**
        ```bash
        docker run -d --name totvs_appserver --network totvs -p 25001:25001 -p 25002:25002 -e "APPSERVER_MODE=application" juliansantosinfo/totvs_appserver:latest
        ```
    *   **AppServer (Modo REST):**
        ```bash
        docker run -d --name totvs_apprest --network totvs -p 25180:25180 -e "APPSERVER_MODE=rest" juliansantosinfo/totvs_appserver:latest
        ```

## Perguntas Frequentes (FAQ)

**P:** Ao iniciar os containers, recebo o erro `[ERROR][SERVER] OPERATIONAL LIMITS ARE INSUFFICIENT, CHECK THE INSTALLATION PROCEDURES AS WELL AS 'ULIMIT' CONFIGURATION`. Como corrigir?

**R:** Este erro ocorre quando o limite de arquivos abertos no sistema host é muito alto, causando uma interpretação incorreta pelo contêiner. Para corrigir, ajuste o limite no seu sistema host (especialmente em ambientes WSL2/Linux):

1.  Verifique o limite atual: `cat /proc/sys/fs/file-max`
2.  Se o valor for excessivamente alto, ajuste-o temporariamente: `sudo sysctl -w fs.file-max=65535`
3.  Para tornar a alteração permanente, adicione `fs.file-max = 65535` ao arquivo `/etc/sysctl.conf` e execute `sudo sysctl -p`.

## Variáveis de Ambiente

Abaixo estão as principais variáveis para configurar os serviços.

#### Banco de Dados: `mssql`

| Variável | Descrição | Padrão |
|---|---|---|
| `SA_PASSWORD` | Senha para o usuário `sa` (usar `DATABASE_PASSWORD` do `.env`). | `ProtheusDatabasePassword1` |
| `ACCEPT_EULA` | Confirma a aceitação da licença de uso do SQL Server. | `Y` |
| `RESTORE_BACKUP` | Define se o backup inicial deve ser restaurado (`Y`/`N`). | `Y` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |

#### Banco de Dados: `postgres`

| Variável | Descrição | Padrão |
|---|---|---|
| `POSTGRES_USER` | Nome do superusuário do banco de dados. | `postgres` |
| `POSTGRES_PASSWORD`| Senha para o superusuário (usar `DATABASE_PASSWORD` do `.env`). | `ProtheusDatabasePassword1` |
| `POSTGRES_DB` | Nome do banco de dados a ser criado na inicialização. | `protheus` |
| `POSTGRES_INITDB_ARGS`| Argumentos extras para o `initdb`, como `locale`. | `--locale=pt_BR.ISO-8859-1 -E LATIN1` |
| `RESTORE_BACKUP` | Define se o backup inicial deve ser restaurado (`Y`/`N`). | `Y` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |

#### `licenseserver`

| Variável | Descrição | Padrão |
|---|---|---|
| `LICENSE_TCP_PORT` | Porta TCP de comunicação. | `2234` |
| `LICENSE_PORT` | Porta principal do serviço. | `5555` |
| `LICENSE_WEBAPP_PORT`| Porta da interface web de monitoramento. | `8020` |
| `LICENSE_CONSOLEFILE`| Caminho do arquivo de log do serviço. | `/totvs/licenseserver/bin/appserver/licenseserver.log` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |

#### `dbaccess`

| Variável | Descrição | Padrão |
|---|---|---|
| `DATABASE_PROFILE` | Tipo do banco de dados (`POSTGRES` ou `MSSQL`). | `MSSQL` |
| `DATABASE_SERVER` | Host do servidor de banco de dados. | `totvs_mssql` |
| `DATABASE_PORT` | Porta do servidor de banco de dados. | `1433` |
| `DATABASE_ALIAS` | Alias da base de dados no DBAccess. | `protheus` |
| `DATABASE_NAME` | Nome da base de dados. | `protheus` |
| `DATABASE_USERNAME` | Usuário de acesso ao banco. | `sa` |
| `DATABASE_PASSWORD` | Senha de acesso ao banco (usar `DATABASE_PASSWORD` do `.env`). | `ProtheusDatabasePassword1` |
| `DBACCESS_LICENSE_SERVER`| Host do License Server. | `totvs_licenseserver` |
| `DBACCESS_LICENSE_PORT`| Porta do License Server. | `5555` |
| `DBACCESS_CONSOLEFILE`| Caminho do arquivo de log do serviço. | `/totvs/dbaccess/multi/dbconsole.log` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |

#### `appserver` / `apprest`

| Variável | Descrição | Padrão |
|---|---|---|
| `APPSERVER_MODE` | Modo de operação: `application` ou `rest`. | `application` |
| `EXTRACT_RESOURCES`| Extrai `protheus.tar.gz` na inicialização (`true`/`false`). | `true` |
| `APPSERVER_DBACCESS_DATABASE` | Tipo do banco de dados (`POSTGRES` ou `MSSQL`). | `MSSQL` |
| `APPSERVER_DBACCESS_SERVER` | Host do serviço DBAccess. | `totvs_dbaccess` |
| `APPSERVER_DBACCESS_PORT` | Porta do serviço DBAccess. | `7890` |
| `APPSERVER_DBACCESS_ALIAS` | Alias da conexão com o banco. | `protheus` |
| `APPSERVER_LICENSE_SERVER` | Host do License Server. | `totvs_licenseserver` |
| `APPSERVER_LICENSE_PORT` | Porta do License Server. | `5555` |
| `APPSERVER_PORT` | Porta principal do AppServer (modo `application`). | `25001` |
| `APPSERVER_WEB_PORT` | Porta da interface web/Smartclient (modo `application`). | `25002` |
| `APPSERVER_REST_PORT` | Porta do serviço REST (modo `rest`). | `25180` |
| `APPSERVER_WEB_MANAGER` | Porta da interface de gerenciamento. | `25088` |
| `APPSERVER_CONSOLEFILE`| Caminho do arquivo de log do serviço. | `/totvs/protheus/bin/appserver/appserver.log` |
| `APPSERVER_RPO_CUSTOM` | Caminho para o RPO customizado. | `/totvs/protheus/apo/custom.rpo` |
| `APPSERVER_ENVIRONMENT_LOCALFILES`| Tipo de banco para arquivos locais (`SQLite`). | `SQLITE` |
| `APPSERVER_SQLITE_SERVER`| Host do serviço de banco de dados local. | `totvs_appsqlite` |
| `APPSERVER_SQLITE_PORT`| Porta do serviço de banco de dados local. | `12346` |
| `APPSERVER_SQLITE_INSTANCES`| Configuração de instâncias do `SQLite`. | `1,10,1,1` |
| `APPSERVER_MULTIPROTOCOLPORTSECURE`| Porta segura para múltiplos protocolos (0 para desativar). | `0` |
| `APPSERVER_MULTIPROTOCOLPORT`| Porta para múltiplos protocolos. | `1` |
| `TZ` | Fuso horário do contêiner. | `America/Sao_Paulo` |

### Licença

Este projeto está licenciado sob a Licença MIT. Consulte o arquivo `LICENSE.txt` para detalhes.

### Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para forcar o projeto e enviar um Pull Request com suas melhorias.
