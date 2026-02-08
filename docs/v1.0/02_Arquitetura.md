# 2. Arquitetura do Sistema

## 2.1. Conceito de Microserviços Aplicado ao Protheus
Tradicionalmente, uma instalação Protheus envolve um servidor Windows ou Linux pesado rodando múltiplos serviços (DBAccess, AppServer, License Server) e um banco de dados, muitas vezes na mesma máquina.

Neste projeto, explodimos esse monólito em containers discretos, cada um com uma Responsabilidade Única (SRP).

### Diagrama Conceitual
```mermaid
---
config:
  layout: elk
---
flowchart TB
 subgraph subGraph0["Docker Network"]
        AppServer["Container: AppServer<br>Modo: Application"]
        AppRest["Container: AppServer<br>Modo: REST"]
        SmartView["Container: SmartView<br>Relatórios"]
        DBAccess["Container: DBAccess<br>Middleware"]
        License["Container: LicenseServer"]
        Database[("Container: Banco de Dados<br>PostgreSQL ou MSSQL")]
  end
    Client["SmartClient / Browser"] -- Porta 25001/25002 --> AppServer
    ExtSystem["Sistemas Externos"] -- Porta 25180 --> AppRest
    AppServer -- TCP --> DBAccess & License
    AppRest -- TCP --> DBAccess & License
    SmartView -- REST --> AppRest
    DBAccess -- ODBC --> Database
```

## 2.2. Detalhamento dos Componentes

### 2.2.1. Serviço de Banco de Dados (Database Layer)
O alicerce do sistema. O projeto suporta nativamente dois "sabores" de banco de dados, definidos através de arquivos Compose distintos.

*   **Opção A: PostgreSQL (Recomendado)**
    *   **Imagem Base:** `postgres:15`
    *   **Função:** Armazenar os dados do ERP (tabelas, dicionários SXs).
    *   **Particularidades:** O Dockerfile customizado configura o `locale` (pt_BR) e encoding (LATIN1) essenciais para o correto funcionamento do Protheus com acentuação.
    *   **Persistência:** Utiliza volumes Docker para garantir que os dados sobrevivam ao reinício do container.

*   **Opção B: Microsoft SQL Server (MSSQL)**
    *   **Imagem Base:** `mcr.microsoft.com/mssql/server:2019-latest`
    *   **Função:** Alternativa robusta e tradicional para ambientes que espelham produção Windows.
    *   **Particularidades:** Exige aceitação de EULA. O script de inicialização é capaz de restaurar backups `.bak` automaticamente.

### 2.2.2. Middleware de Banco de Dados (DBAccess)
*   **Imagem:** `totvs_dbaccess`
*   **Função:** Atua como tradutor entre o AppServer (código ADVPL) e o Banco de Dados (SQL).
*   **Configuração Dinâmica:**
    *   No boot, o script `entrypoint.sh` detecta qual banco está sendo usado (Postgres ou MSSQL) através de variáveis de ambiente.
    *   Ele configura automaticamente os drivers ODBC (`odbc.ini`) e o arquivo de configuração do serviço (`dbaccess.ini`).
    *   Isso permite que a **mesma imagem Docker** sirva para conectar em qualquer banco suportado.

### 2.2.3. Servidor de Licenças (License Server)
*   **Imagem:** `totvs_licenseserver`
*   **Função:** Controla as sessões de usuário e permissões de módulos.
*   **Operação:** Emula um servidor de licenças local ou conecta-se a um servidor corporativo virtual (caso configurado). Para ambientes de desenvolvimento, geralmente opera em modo de demonstração ou com licenças de desenvolvedor.

### 2.2.4. Servidor de Aplicação (AppServer)
Este é o coração do processamento. O projeto utiliza uma abordagem inteligente onde uma única imagem Docker (`totvs_appserver`) pode assumir papéis diferentes baseada na variável `APPSERVER_MODE`.

*   **Papel 1: Application Server (Standard)**
    *   **Modo:** `application`
    *   **Portas:** 25001 (TCP SmartClient), 25002 (Web SmartClient).
    *   **Uso:** É onde os usuários se conectam para operar o sistema. Executa as interfaces de tela, rotinas de cadastro, processos, etc.
    
*   **Papel 2: REST Server**
    *   **Modo:** `rest`
    *   **Portas:** 25180 (HTTP REST).
    *   **Uso:** Dedicado a servir APIs para integrações e para o SmartView. Separar este serviço garante que cargas pesadas de API não travem a interface do usuário.

*   **Papel 3: SQLite Server (Local Database)**
    *   **Modo:** `sqlite`
    *   **Portas:** 12346
    *   **Uso:** Utilizado para servir arquivos locais. Utiliza o sqlite no modelo client/server semelhante ao c-tree server.
    

### 2.2.5. SmartView (TReports)
*   **Imagem:** `totvs_smartview`
*   **Função:** Servidor de relatórios modernos da TOTVS.
*   **Integração:** Conecta-se exclusivamente ao AppServer em modo REST para extrair dados e definições de relatórios.

## 2.3. Rede e Comunicação
Todos os containers são colocados em uma rede virtual Docker privada (`totvs`).
*   **Comunicação Interna:** Os containers conversam entre si usando seus nomes de serviço como DNS (ex: o AppServer conecta no `dbaccess` usando o hostname `dbaccess`, não IP).
*   **Exposição Externa:** Apenas as portas necessárias para o usuário (ex: 25002 para Web, 1433 para SQL Management Studio) são mapeadas para o `localhost` da máquina hospedeira.

## 2.4. Volumes e Persistência de Dados
O Docker é efêmero por natureza (arquivos somem se o container for deletado). Para evitar perda de dados, utilizamos Volumes Docker:

*   **`postgres_data` / `mssql_data`:** Garante que o banco de dados não seja apagado.
*   **`protheus_data`:** Armazena o `protheus_data` para que atualizações persistam ou possam ser gerenciadas externamente.
*   **`appserver_apo`**: Persiste o Repositório de Objetos (RPO).
*   **`appserver_data`**: Persiste a pasta do binário do servidor de aplicação.
*   **`apprest_apo`**: Persiste o RPO específico para o serviço REST.
*   **`apprest_data`**: Persiste a pasta do binário do serviço REST.
*   **`smartview_data`**: Persiste as configurações e metadados do servidor de relatórios SmartView.
