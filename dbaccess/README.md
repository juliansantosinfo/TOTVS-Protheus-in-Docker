# Dockerização do DBAccess para ERP TOTVS Protheus

## Overview

Este repositório contém a implementação da aplicação DBAccess para ERP TOTVS Protheus utilizando contêineres Docker.

O sistema de ERP Protheus é uma solução de software complexa que requer configurações e dependências específicas para funcionar. Este projeto visa simplificar a instalação, configuração e execução do Protheus ao containerizar o DbAccess utilizando Docker.

### Componentes

Este repositório contém um dos quatro principais componentes:

* **dbaccess**: Um serviço que fornece acesso ao banco de dados.

Outros containeres necessários

* **appserver**: O servidor de aplicação principal do sistema ERP Protheus.

Outros contêineres necessários

* **mssql**: Serviço de banco de dados para persistencia dos dados do sistema.
* **licenseserver**: Um serviço que gerencia licenças para o sistema ERP Protheus.
* **apprest**: O servidor de aplicação REST do sistema ERP Protheus.

### Início Rápido

Para começar com este projeto, siga os passos abaixo.

**Importante:** Este container precisa estar na mesma rede que os serviços MSSQL, LicenseServer para funcionar corretamente.

1. Baixe a imagem:

    ```bash
    docker pull juliansantosinfo/totvs_dbaccess:latest
    ```

2. Criar rede exclusiva para os containeres do projeto, caso inda não exista:

    ```bash
    docker network create totvs
    ```

3. Executar o container.

    ```bash
    docker run -d --name totvs_dbaccess --network totvs -p 7890:7890 -p 7891:7891 juliansantosinfo/totvs_dbaccess:latest
    ```

### Build local

Caso queira construir as imagens localmente

1. Clone o repositório GIT do projeto:

    ```bash
    git clone https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker.git
    ```

2. acesse o diretório dbaccess:

    ```bash
    cd dbaccess
    ```

3. Execute o script `build.sh:

    ```bash
    ./build.sh
    ```

### Variáveis de Ambiente

| Variável de Ambiente | Conteúdo Padrão | Descrição |
|---|---|---|
| `DATABASE_PASSWORD` | `MicrosoftSQL2019` | Senha para acesso ao banco de dados (Mesma definida no container de banco de dados do MSSQL). |
| `DBACCESS_LICENSE_SERVER` | `totvs_licenseserver` | Define o nome do host do servidor de licenças. |
| `DBACCESS_LICENSE_PORT` | `5555` | Define a porta do servidor de licenças. |
| `DBACCESS_CONSOLEFILE` | `/totvs/dbaccess/multi/dbconsole.log` | Define o caminho para o arquivo de log do dbaccess. |
