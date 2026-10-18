# Referência: Dicionário de Variáveis de Ambiente

Este documento especifica exaustivamente todas as variáveis de ambiente suportadas pelos containers do ecossistema TOTVS Protheus in Docker, centralizadas nos arquivos `.env` e `versions.env`.

---

## 🌐 1. Configurações Globais e Operacionais

| Variável | Tipo | Padrão | Descrição |
|---|---|---|---|
| `TZ` | String | `America/Sao_Paulo` | Fuso horário do sistema operacional para todos os containers. Garante sincronia de logs, timestamps de banco e rotinas contábeis/fiscais do ERP. |
| `DEBUG_SCRIPT` | Booleano | `false` | Se `true`, habilita o modo de depuração nos scripts shell de inicialização (`set -x`), imprimindo cada linha executada no console do Docker. |
| `EXTRACT_RESOURCES` | Booleano | `true` | Se `true`, descompacta os artefatos estáticos (`protheus.tar.gz`, `smartview.tar.gz`) para os volumes de persistência na primeira partida. Se `false`, pula a descompactação caso os volumes já estejam populados. |
| `RESTORE_BACKUP` | String (`Y`/`N`) | `Y` | Controla a restauração automática do banco de dados a partir dos arquivos de backup/snapshot na primeira inicialização se o volume de dados estiver vazio. |

---

## 🗄️ 2. Camada de Banco de Dados

### 2.1. Variáveis Compartilhadas / Comuns
| Variável | Tipo | Padrão | Descrição |
|---|---|---|---|
| `DATABASE_PASSWORD` | String | `ProtheusDatabasePassword1` | Senha administrativa principal do banco (usada pelo usuário `sa` no MSSQL, `postgres` no PostgreSQL e `SYS`/`SYSTEM` no Oracle). |
| `DATABASE_USERNAME` | String | *Auto por banco* | Usuário para conexão do DBAccess (`sa`, `postgres` ou `system`). |
| `DATABASE_ALIAS` | String | `protheus` | Alias de conexão configurado no DBAccess para identificar o banco Protheus. |
| `DATABASE_NAME` | String | `protheus` | Nome físico do catálogo de banco de dados a ser criado ou acessado. |
| `DATABASE_WAIT_RETRIES` | Inteiro | `30` | Quantidade máxima de tentativas que os serviços clientes aguardam a porta do banco abrir. |
| `DATABASE_WAIT_INTERVAL` | Inteiro (segundos) | `2` | Intervalo em segundos entre tentativas consecutivas de ping TCP na porta do banco. |

### 2.2. Específicas: PostgreSQL (`totvs_postgres`)
| Variável | Tipo | Padrão | Descrição |
|---|---|---|---|
| `POSTGRES_USER` | String | `postgres` | Nome do superusuário do PostgreSQL. |
| `POSTGRES_PASSWORD` | String | `${DATABASE_PASSWORD}` | Senha do superusuário. |
| `POSTGRES_DB` | String | `protheus` | Nome do banco inicial gerado pelo `initdb`. |
| `POSTGRES_INITDB_ARGS` | String | `--locale=pt_BR.ISO-8859-1 -E LATIN1` | Parâmetros de codificação mandatórios para a acentuação correta do ERP Protheus. |

### 2.3. Específicas: Microsoft SQL Server (`totvs_mssql`)
| Variável | Tipo | Padrão | Descrição |
|---|---|---|---|
| `SA_PASSWORD` | String | `${DATABASE_PASSWORD}` | Senha da conta do administrador de sistemas (`sa`). |
| `ACCEPT_EULA` | String (`Y`/`N`) | `Y` | Aceitação obrigatória do contrato de licença Microsoft para inicialização do container. |

### 2.4. Específicas: Oracle Database (`totvs_oracle`)
| Variável | Tipo | Padrão | Descrição |
|---|---|---|---|
| `ORACLE_PWD` | String | `${DATABASE_PASSWORD}` | Senha para as contas `SYS`, `SYSTEM` e `PDBADMIN`. |
| `ORACLE_SID` | String | `XE` | System Identifier (nome da instância do Oracle). |
| `ORACLE_CHARACTERSET` | String | `WE8MSWIN1252` | Conjunto de caracteres Windows-1252 para conformidade com o dicionário Protheus. |

---

## 🔑 3. TOTVS License Server (`totvs_licenseserver`)

| Variável | Tipo | Padrão | Descrição |
|---|---|---|---|
| `LICENSE_TCP_PORT` | Inteiro | `2234` | Porta interna TCP para comunicação de licenças. |
| `LICENSE_PORT` | Inteiro | `5555` | Porta principal do serviço de licenciamento. |
| `LICENSE_WEBAPP_PORT` | Inteiro | `8020` | Porta para a interface web de monitoramento e administração de licenças. |
| `LICENSE_CONSOLEFILE` | Caminho | `/totvs/licenseserver/bin/appserver/licenseserver.log` | Destino do arquivo de log gerado pelo License Server. |
| `LICENSE_WAIT_RETRIES` | Inteiro | `30` | Tentativas de espera de inicialização do License Server por serviços dependentes. |
| `LICENSE_WAIT_INTERVAL` | Inteiro | `2` | Intervalo em segundos entre tentativas de conexão ao License Server. |

---

## 🔄 4. TOTVS DBAccess (`totvs_dbaccess`)

| Variável | Tipo | Padrão | Descrição |
|---|---|---|---|
| `DATABASE_PROFILE` | String | `MSSQL` / `POSTGRES` / `ORACLE` | Define qual driver ODBC e template de configuração (`dbaccess.ini`) será ativado. |
| `DATABASE_SERVER` | String | `totvs_postgres` / `totvs_mssql` / `totvs_oracle` | Hostname ou nome do container do banco de dados na rede Docker. |
| `DATABASE_PORT` | Inteiro | `5432` / `1433` / `1521` | Porta do banco de dados correspondente ao perfil selecionado. |
| `DBACCESS_LICENSE_SERVER` | String | `totvs_licenseserver` | Host do container License Server para validação do DBAccess. |
| `DBACCESS_LICENSE_PORT` | Inteiro | `5555` | Porta do serviço de licenciamento. |
| `DBACCESS_CONSOLEFILE` | Caminho | `/totvs/dbaccess/multi/dbconsole.log` | Caminho completo do log de console do DBAccess. |

---

## ⚡ 5. TOTVS AppServer (`totvs_appserver`, `totvs_apprest`, `totvs_appsqlite`)

| Variável | Tipo | Padrão | Descrição |
|---|---|---|---|
| `APPSERVER_MODE` | String | `application` | Modo de execução do binário: `application` (SmartClient), `rest` (API WebServices) ou `sqlite` (LocalFiles). |
| `APPSERVER_PORT` | Inteiro | `1234` | Porta TCP para conexão de SmartClient Desktop convencional. |
| `APPSERVER_WEB_PORT` | Inteiro | `1235` | Porta HTTP para o SmartClient Web (execução via navegador). |
| `APPSERVER_REST_PORT` | Inteiro | `8080` | Porta HTTP/REST para consumo de endpoints e integrações (ativada quando `APPSERVER_MODE=rest`). |
| `APPSERVER_CONSOLEFILE` | Caminho | `/totvs/protheus/bin/appserver/appserver.log` | Arquivo físico onde são gravadas as mensagens de log e console. |
| `APPSERVER_RPO_CUSTOM` | Caminho | `/totvs/protheus/apo/custom.rpo` | Caminho do repositório de customizações para carga prioritária. |
| `APPSERVER_DBACCESS_DATABASE` | String | `${DATABASE_PROFILE}` | Tipo de banco para configuração no `appserver.ini`. |
| `APPSERVER_DBACCESS_SERVER` | String | `totvs_dbaccess` | Hostname do DBAccess na rede Docker. |
| `APPSERVER_DBACCESS_PORT` | Inteiro | `7890` | Porta de comunicação TCP do DBAccess. |
| `APPSERVER_DBACCESS_ALIAS` | String | `${DATABASE_ALIAS}` | Nome do alias de banco a ser requisitado pelo Protheus. |
| `APPSERVER_LICENSE_SERVER` | String | `totvs_licenseserver` | Host do License Server para concessão de tokens de usuário. |
| `APPSERVER_LICENSE_PORT` | Inteiro | `5555` | Porta do License Server. |
| `APPSERVER_MULTIPROTOCOLPORT` | Inteiro (0/1) | `1` | Habilita o suporte a múltiplos protocolos na mesma porta TCP. |
| `APPSERVER_MULTIPROTOCOLPORTSECURE`| Inteiro (0/1) | `0` | Habilita porta MPP com criptografia TLS/SSL nativa. |
| `DBACCESS_CHECK` | Booleano | `false` | Se `true`, valida ativamente a disponibilidade do DBAccess antes de subir o AppServer. |
| `LICENSESERVER_CHECK` | Booleano | `false` | Se `true`, valida ativamente a disponibilidade do LicenseServer antes de subir o AppServer. |

### 5.1. Variáveis de LocalFiles (SQLite)
| Variável | Tipo | Padrão | Descrição |
|---|---|---|---|
| `APPSERVER_ENVIRONMENT_LOCALFILES` | String | `SQLITE` | Define SQLite como motor de alta performance para arquivos de dicionário temporários. |
| `APPSERVER_SQLITE_SERVER` | String | `totvs_appsqlite` | Host do serviço dedicado SQLite em rede. |
| `APPSERVER_SQLITE_PORT` | Inteiro | `12346` | Porta do serviço SQLite LocalFiles. |
| `APPSERVER_SQLITE_INSTANCES` | String | `1,10,1,1` | Pool de instâncias para distribuição de leitura do SQLite. |

---

## 📊 6. TOTVS SmartView (`totvs_smartview`)

| Variável | Tipo | Padrão | Descrição |
|---|---|---|---|
| `EXTRACT_RESOURCES` | Booleano | `true` | Extrai os binários e modelos do SmartView na primeira subida. |
| `TZ` | String | `America/Sao_Paulo` | Fuso horário para execução dos agendamentos de relatórios. |
| `DEBUG_SCRIPT` | Booleano | `false` | Ativa depuração do entrypoint do SmartView. |

---

## 🏷️ 7. Variáveis Mestres de Release (`versions.env`)

O arquivo `versions.env` é a única fonte da verdade para o versionamento do projeto. **Não deve ser editado manualmente para configurações locais**, apenas durante o gerenciamento de upgrades:

```env
# Configurações Globais
DOCKER_USER=juliansantosinfo
RESOURCE_RELEASE=release2610

# AppServer
APPSERVER_RELEASE=12.1.2610
APPSERVER_VERSION="${APPSERVER_RELEASE}"
APPSERVER_IMAGE_NAME=totvs_appserver
APPSERVER_BUILD_VERSION=26.3.0.0
APPSERVER_WEBAPP_VERSION=26.0.0
APPSERVER_DBAPI_VERSION=26.1.0.0

# DBAccess
DBACCESS_VERSION=26.1.0.0
DBACCESS_IMAGE_NAME=totvs_dbaccess

# License Server
LICENSESERVER_VERSION=3.7.2
LICENSESERVER_IMAGE_NAME=totvs_licenseserver

# Bancos de Dados
MSSQL_VERSION=2019
MSSQL_IMAGE_NAME=totvs_mssql
ORACLE_VERSION=21.3.0
ORACLE_IMAGE_NAME=totvs_oracle
POSTGRES_VERSION=15
POSTGRES_IMAGE_NAME=totvs_postgres

# SmartView
SMARTVIEW_VERSION=3.9.0.4558336
SMARTVIEW_IMAGE_NAME=totvs_smartview
```
