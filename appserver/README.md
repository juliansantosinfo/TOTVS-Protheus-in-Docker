# Dockerização do AppServer para ERP TOTVS Protheus

## Overview

Este repositório contém a implementação da aplicação AppServer para ERP TOTVS Protheus utilizando contêineres Docker.

O sistema de ERP Protheus é uma solução de software complexa que requer configurações e dependências específicas para funcionar. Este projeto visa simplificar a instalação, configuração e execução do Protheus ao containerizar o AppServer utilizando Docker.

### Componentes

Este repositório contém um dos quatro principais componentes:

* **appserver**: O servidor de aplicação principal do sistema ERP Protheus.

Outros contêineres necessários

* **mssql**: Serviço de banco de dados para persistencia dos dados do sistema.
* **licenseserver**: Um serviço que gerencia licenças para o sistema ERP Protheus.
* **dbaccess**: Um serviço que fornece acesso ao banco de dados.
Protheus.

### Início Rápido

Para começar com este projeto, siga os passos abaixo.

**Importante:** Este container precisa estar na mesma rede que os serviços MSSQL, DBAccess e LicenseServer para funcionar corretamente.

1. Baixe a imagem:

    ```bash
    docker pull juliansantosinfo/totvs_appserver:latest
    ```

2. Criar rede exclusiva para os containeres do projeto, caso inda não exista:

    ```bash
    docker network create totvs
    ```

3. Executar o container.

    ```bash
    docker run -d --name totvs_appserver --network totvs -p 1234:1234 -p 12345:12345 -p 8088:8088 juliansantosinfo/totvs_appserver:latest
    ```

4. Login.

    Para efetuar login utilize o usuário `admin` se senha `Docker@123`.

### Build local

Caso queira construir as imagens localmente

1. Clone o repositório GIT do projeto:

    ```bash
    git clone https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker.git
    ```

2. acesse o diretório appserver`

    ```bash
    cd appserver
    ```

3. Execute o script `build.sh

    ```bash
    ./build.sh
    ```

### Variáveis de Ambiente

| Variável de Ambiente | Conteúdo Padrão | Descrição |
|---|---|---|
| `APPSERVER_RPO_CUSTOM` | `/totvs/protheus/apo/custom.rpo` | Define o caminho para o arquivo de RPO customizado do AppServer. |
| `APPSERVER_DBACCESS_DATABASE` | `MSSQL` | Define o tipo de banco de dados utilizado (ex: MSSQL, Oracle). |
| `APPSERVER_DBACCESS_SERVER` | `totvs_dbaccess` | Define o nome do host do serviço DBAccess. |
| `APPSERVER_DBACCESS_PORT` | `7890` | Define a porta do serviço DBAccess. |
| `APPSERVER_DBACCESS_ALIAS` | `protheus` | Define o alias para a conexão com o banco de dados. |
| `APPSERVER_CONSOLEFILE` | `/totvs/protheus/bin/appserver/appserver.log` | Define o caminho para o arquivo de log do AppServer. |
| `APPSERVER_MULTIPROTOCOLPORTSECURE` | `0` | Define a porta segura para o protocolo múltiplo (0 desativa a porta segura). |
| `APPSERVER_MULTIPROTOCOLPORT` | `1` | Define a porta para o protocolo múltiplo. |
| `APPSERVER_LICENSE_SERVER` | `totvs_licenseserver` | Define o nome do host do servidor de licenças. |
| `APPSERVER_LICENSE_PORT` | `5555` | Define a porta do servidor de licenças. |
| `APPSERVER_PORT` | `1234` | Define a porta principal do AppServer. |
| `APPSERVER_WEB_PORT` | `12345` | Define a porta para a interface web do AppServer. |
| `APPSERVER_WEB_MANAGER` | `8088` | Define a porta para a interface web de gerenciamento do AppServer. |
