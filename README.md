# Dockerização do ERP TOTVS Protheus

## Overview

Este repositório contém a implementação da aplicação do ERP TOTVS Protheus utilizando containers Docker.

O sistema de ERP Protheus é uma solução de software complexa que requer configurações e dependências específicas para funcionar. Este projeto visa simplificar a instalação, configuração e execução do Protheus ao containerizar-o utilizando Docker.

## Componentes

Este repositório contém três principais componentes:

1. **appserver**: O servidor de aplicação principal do sistema ERP Protheus.
2. **apprest**: O servidor de aplicação REST do sistema ERP Protheus.
3. **dbaccess**: Um serviço que fornece acesso ao banco de dados.
4. **licenseserver**: Um serviço que gerencia licenças para o sistema ERP Protheus.

## Aviso Legal e Instruções de Uso

Este repositório é um projeto independente e não possui qualquer afiliação com a TOTVS S/A. O código e as imagens aqui disponibilizados são destinados **exclusivamente para fins de desenvolvimento e testes**. **Não utilize este projeto em ambiente de produção.**

Ao utilizar este repositório, você concorda com os termos da licença MIT.

## Requisitos de Sistema: Ambiente de Desenvolvimento

Certifique-se de ter os seguintes pré-requisitos instalados em seu sistema:

**Windows:**

1. **WSL2:** Ative o Subsistema Windows para Linux (WSL2) seguindo este guia: [https://learn.microsoft.com/pt-br/windows/wsl/install](https://learn.microsoft.com/pt-br/windows/wsl/install)
2. **Docker Desktop:** Instale o Docker Desktop para Windows: [https://docs.docker.com/desktop/windows/install](https://docs.docker.com/desktop/windows/install). Como alternativa, configure manualmente o Docker em sua distribuição Linux dentro do WSL2.

**Linux:**

1. **Docker e Docker Compose:** Instale e configure as versões mais recentes do Docker e do Docker Compose. Consulte a documentação oficial do Docker para obter instruções específicas para sua distribuição Linux.

**Mac:**

1. **Docker Desktop:** Instale o Docker Desktop para macOS: [https://docs.docker.com/desktop/mac/install/](https://docs.docker.com/desktop/mac/install/)

## Início Rápido

Para começar com este projeto, siga os passos abaixo:

1. Clone este repositório e acesse o diretório do projeto:

    ```bash
    git clone https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker.git
    cd TOTVS-Protheus-in-Docker
    ```

2. Inicie os containers:

    ```bash
    docker compose -p totvs up
    ```

    Após a inicialização, acesse a aplicação em seu navegador através do endereço: <http://localhost:12345> (Smartclient Web).

    **Release 12.1.2410**
      - **Usuário:** admin
      - **Senha:** admin

    **Release 12.1.2510**
      - **Usuário:** admin
      - **Senha:** Docker@123

    **Informações adicionais sobre como iniciar o serviço `apprest` manualmente podem ser encontradas na documentação.**

## Build

Caso queira contruir as imagens localmente.

1. Clone este repositório e acesse o diretório do projeto:

    ```bash
    git clone https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker.git
    cd TOTVS-Protheus-in-Docker
    ```

2. acesse o diretorio **apprest** e execute o script `build.sh`

    ```bash
    cd apprest
    ./build.sh
    ```

3. acesse o diretorio **appserver** e execute o script `build.sh`

    ```bash
    cd appserver
    ./build.sh
    ```

4. acesse o diretorio **dbaccess** e execute o script `build.sh`

    ```bash
    cd appserver
    ./build.sh
    ```

5. acesse o diretorio **licenseserver** e execute o script `build.sh`

    ```bash
    cd appserver
    ./build.sh
    ```

6. Retorne ao diretório raiz do projeto, onde esta localizado o arquivo docker-compose.yaml

    ```bash
    cd ..
    ```

7. Inicie os containers:

    ```bash
    docker compose -p totvs up
    ```

### Configuração

A configuração para cada componente está armazenada em arquivos separados:

* `apprest/Dockerfile`: Contém as instruções para construir a imagem do apprest.
* `appserver/Dockerfile`: Contém as instruções para construir a imagem do appserver.
* `dbaccess/Dockerfile`: Contém as instruções para construir a imagem do dbaccess.
* `licenseserver/Dockerfile`: Contém as instruções para construir a imagem do licenseserver.

O arquivo `docker-compose.yml` orquestra os containers e define as variáveis de ambiente, portas e volumes necessários por componente.

## Execução dos Containers via Docker

Este guia detalha como executar os containers manualmente utilizando a linha de comando.

### Pré-requisitos

* Docker instalado e em execução.
* Conhecimento básico de comandos Docker.

### Passo 1: Criar a Rede Docker

Primeiramente, crie uma rede Docker para permitir a comunicação entre os containers:

```bash
docker network create totvs
```

### Passo 2: Iniciar os Containers

Agora, vamos iniciar cada container individualmente, conectando-os à rede "totvs":

**2.1. Microsoft SQL Server (mssql):**

```bash
docker run -d \
  --name totvs_mssql \
  --network totvs \
  -p 1433:1433 \
  -e "ACCEPT_EULA=Y" \
  -e "SA_PASSWORD=MicrosoftSQL2019" \
  juliansantosinfo/totvs_mssql:latest
```

**2.2. TOTVS License Server (licenseserver):**

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

**2.3. TOTVS DBAccess (dbaccess):**

```bash
docker run -d \
  --name totvs_dbaccess \
  --network totvs \
  -p 7890:7890 \
  -p 7891:7891 \
  -e "DATABASE_PASSWORD=MicrosoftSQL2019" \
  juliansantosinfo/totvs_dbaccess:latest
```

**2.4. TOTVS Application Server (appserver):**

```bash
docker run -d \
  --name totvs_appserver \
  --network totvs \
  -p 1234:1234 \
  -p 12345:12345 \
  --ulimit nofile=65536:65536 \
  juliansantosinfo/totvs_appserver:latest
```

**2.5. TOTVS Application REST (apprest):**

```bash
docker run -d \
  --name totvs_apprest \
  --network totvs \
  -p 1235:1235 \
  -p 12355:12355 \
  -p 8080:8080 \
  --ulimit nofile=65536:65536 \
  juliansantosinfo/totvs_apprest:latest
```

### Observações

* As portas expostas em cada container podem ser modificadas conforme necessário.
* As senhas definidas nos comandos acima são exemplos e devem ser alteradas para garantir a segurança do ambiente.
* As variáveis de ambiente estão disponiveis em uma sessão a parte nesta documentação.

### Próximos Passos

Após iniciar todos os containers, você pode acessar as aplicações TOTVS através das portas configuradas. Consulte a documentação oficial da TOTVS para obter mais informações sobre a utilização dos produtos.

## Perguntas Frequentes

**Pergunta:** Ao iniciar os containers `appserver` e `apprest`, a mensagem `[ERROR][SERVER] OPERATIONAL LIMITS ARE INSUFFICIENT, CHECK THE INSTALLATION PROCEDURES AS WELL AS 'ULIMIT' CONFIGURATION` é exibida. Como corrigir?

**Resposta:** Este erro pode ocorrer quando o número máximo de arquivos abertos simultaneamente está configurado com um valor excessivamente alto no sistema **host** (por exemplo, `9223372036854775807`). Isso pode causar inconsistências, fazendo com que o Docker ou os contêineres interpretem esse valor como inválido (como `-1`), resultando em falhas na inicialização dos serviços.

Para corrigir o problema, recomenda-se ajustar o parâmetro `/proc/sys/fs/file-max` para um valor mais adequado, como `65535`, que já é suficiente para a maioria dos ambientes.

Siga os passos abaixo ou veja o [Vídeo](https://learn.microsoft.com/pt-br/windows/wsl/install):

1. **Acesse a conta root:**

   ```bash
   sudo su
   ```

2. **Verifique o limite atual de arquivos abertos:**

   ```bash
   cat /proc/sys/fs/file-max
   ```

3. **Se o valor for muito alto (por exemplo, `9223372036854775807`), ajuste para `65535`:**

   ```bash
   echo 65535 > /proc/sys/fs/file-max
   ```

4. **Para tornar essa alteração persistente após reinicializações, adicione a seguinte linha ao arquivo `/etc/sysctl.conf`:**

   ```bash
   fs.file-max = 65535
   ```

   Edite o arquivo com:

   ```bash
   sudo nano /etc/sysctl.conf
   ```

   Adicione a linha ao final do arquivo.

5. **Aplique imediatamente a configuração sem precisar reiniciar:**

   ```bash
   sudo sysctl -p
   ```

**Observação:** Esta solução ajusta o limite de arquivos abertos no nível do sistema operacional host. Certifique-se de avaliar o impacto no seu ambiente antes de aplicar a alteração. Para cargas específicas que demandem valores mais altos, revise as necessidades reais do sistema antes de definir um novo limite.

### Variáveis de Ambiente

#### `licenseserver`

| Variável de Ambiente | Conteúdo Padrão | Descrição |
|---|---|---|
| `LICENSE_TCP_PORT` | `2234` | Define a porta TCP para comunicação com o servidor de licenças. |
| `LICENSE_CONSOLEFILE` | `/totvs/licenseserver/bin/appserver/licenseserver.log` | Define o caminho para o arquivo de log do servidor de licenças. |
| `LICENSE_PORT` | `5555` | Define a porta principal do servidor de licenças. |
| `LICENSE_WEBAPP_PORT` | `8020` | Define a porta para a interface de monitoramento web do servidor de licenças. |

#### `dbaccess`

| Variável de Ambiente | Conteúdo Padrão | Descrição |
|---|---|---|
| `DATABASE_PASSWORD` | `MicrosoftSQL2019` | Senha para acesso ao banco de dados (Mesma definida no container de banco de dados do MSSQL). |
| `DBACCESS_LICENSE_SERVER` | `totvs_licenseserver` | Define o nome do host do servidor de licenças. |
| `DBACCESS_LICENSE_PORT` | `5555` | Define a porta do servidor de licenças. |
| `DBACCESS_CONSOLEFILE` | `/totvs/dbaccess/multi/dbconsole.log` | Define o caminho para o arquivo de log do dbaccess. |

#### `appserver`

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

#### apprest

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
| `APPSERVER_REST_PORT` | `8080` | Define a porta para serviço REST do AppServer. |
| `APPSERVER_WEB_MANAGER` | `8088` | Define a porta para a interface web de gerenciamento do AppServer. |

### Licença

Este projeto está licenciado sob a Licença MIT. Consulte o arquivo `LICENSE` para detalhes.

### Contribuindo

Se você gostaria de contribuir para este projeto, por favor, forque-o e envie uma solicitação de pull com suas alterações.
