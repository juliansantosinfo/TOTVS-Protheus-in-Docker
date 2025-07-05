# Dockerização do LicenseServer para ERP TOTVS Protheus

## Overview

Este repositório contém a implementação da aplicação LicenseServer para ERP TOTVS Protheus utilizando contêineres Docker.

O sistema de ERP Protheus é uma solução de software complexa que requer configurações e dependências específicas para funcionar. Este projeto visa simplificar a instalação, configuração e execução do Protheus ao containerizar o LicenseServer utilizando Docker.

### Componentes

Este repositório contém um dos quatro principais componentes:

* **licenseserver**: Um serviço que gerencia licenças para o sistema ERP Protheus.

Outros contêineres necessários

* **mssql**: Serviço de banco de dados para persistencia dos dados do sistema.
* **dbaccess**: Um serviço que fornece acesso ao banco de dados.
* **appserver**: O servidor de aplicação principal do sistema ERP Protheus.
* **apprest**: O servidor de aplicação REST do sistema ERP Protheus.

### Início Rápido

Para começar com este projeto, siga os passos abaixo.

**Importante:** Este container precisa estar na mesma rede que os serviços MSSQL, DBAccess e AppServer para funcionar corretamente.

1. Baixe a imagem:

    ```bash
    docker pull juliansantosinfo/totvs_licenseserver:latest
    ```

2. Criar rede exclusiva para os containeres do projeto, caso inda não exista:

    ```bash
    docker network create totvs
    ```

3. Executar o container.

    ```bash
    docker run -d --name totvs_dbaccess --network totvs -p 5555:5555 -p 2234:2234 -p 8020:8020 --ulimit juliansantosinfo/totvs_licenseserver:latest
    ```

### Build local

Caso queira construir as imagens localmente

1. Clone o repositório GIT do projeto:

    ```bash
    git clone https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker.git
    ```

2. acesse o diretório licenseserver:

    ```bash
    cd licenseserver
    ```

3. Execute o script `build.sh

    ```bash
    ./build.sh
    ```

### Variáveis de Ambiente

| Variável de Ambiente | Conteúdo Padrão | Descrição |
|---|---|---|
| `LICENSE_TCP_PORT` | `2234` | Define a porta TCP para comunicação com o servidor de licenças. |
| `LICENSE_CONSOLEFILE` | `/totvs/licenseserver/bin/appserver/licenseserver.log` | Define o caminho para o arquivo de log do servidor de licenças. |
| `LICENSE_PORT` | `5555` | Define a porta principal do servidor de licenças. |
| `LICENSE_WEBAPP_PORT` | `8020` | Define a porta para a interface de monitoramento web do servidor de licenças. |
