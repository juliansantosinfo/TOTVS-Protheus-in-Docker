# Dockerização do MSSQL para ERP TOTVS Protheus

## Overview

Este repositório contém a implementação da aplicação MSSQL para ERP TOTVS Protheus utilizando contêineres Docker.

O sistema de ERP Protheus é uma solução de software complexa que requer configurações e dependências específicas para funcionar. Este projeto visa simplificar a instalação, configuração e execução do Protheus ao containerizar o MSSQL utilizando Docker.

### Componentes

Este repositório contém um dos quatro principais componentes:

* **mssql**: Serviço de banco de dados para persistencia dos dados do sistema.

Outros containeres necessários

* **appserver**: O servidor de aplicação principal do sistema ERP Protheus.
* **dbaccess**: Um serviço que fornece acesso ao banco de dados.
* **licenseserver**: Um serviço que gerencia licenças para o sistema ERP Protheus.
* **apprest**: O servidor de aplicação REST do sistema ERP Protheus.

### Início Rápido

Para começar com este projeto, siga os passos abaixo.

**Importante:** Este container precisa estar na mesma rede que os serviços DBAccess, LicenseServer e AppServer para funcionar corretamente.

1. Baixe a imagem:

    ```bash
    docker pull juliansantosinfo/totvs_mssql:latest
    ```

2. Criar rede exclusiva para os containeres do projeto, caso inda não exista:

    ```bash
    docker network create totvs
    ```

3. Executar o container.

    ```bash
    docker run -d --name totvs_mssql --network totvs -p 1434:1433 -e SA_PASSWORD="MicrosoftSQL2019" -e ACCEPT_EULA="Y" juliansantosinfo/totvs_mssql:latest
    ```

### Build local

Caso queira construir as imagens localmente

1. Clone o repositório GIT do projeto:

    ```bash
    git clone https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker.git
    ```

2. acesse o diretório mssql:

    ```bash
    cd mssql
    ```

3. Execute o script `build.sh:

    ```bash
    ./build.sh
    ```

### Variáveis de Ambiente

| Variável de Ambiente | Conteúdo Padrão | Descrição |
|---|---|---|
| `SA_PASSWORD` | `MicrosoftSQL2019` | Senha para acesso ao banco de dados (Mesma definida no container do dbaccess). |
| `ACCEPT_EULA` | `Y` | Defina a variável ACCEPT_EULA com qualquer valor para confirmar sua aceitação do Contrato de Licença do Usuário Final. Configuração exigida para a imagem do SQL Server. |
