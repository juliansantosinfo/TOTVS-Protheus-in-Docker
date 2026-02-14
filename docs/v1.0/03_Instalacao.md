# 3. Instalação e Configuração

## 3.1. Pré-requisitos do Sistema
Antes de iniciar, certifique-se de que o ambiente hospedeiro atende aos requisitos mínimos.

### Software Necessário
1.  **Docker Engine:** Versão 20.10 ou superior.
2.  **Docker Compose:** Versão 2.0 ou superior (plugin `docker compose` v2).
3.  **Git:** Para clonar o repositório.

#### Notas Específicas por Sistema Operacional
*   **Linux:** É o ambiente nativo e mais performático. Recomendado: Ubuntu 22.04/24.04, Fedora, ou Oracle Linux.
*   **Windows:** Obrigatório o uso de **WSL 2** (Windows Subsystem for Linux). O Docker Desktop deve estar configurado para usar o backend WSL 2, não Hyper-V legado, para garantir performance de I/O de disco aceitável.
*   **macOS:** Suportado via Docker Desktop for Mac (Apple Silicon M1/M2/M3 é suportado, mas as imagens devem ser compatíveis com arquitetura ARM64 ou usar emulação Rosetta 2 - *Nota: O MSSQL oficial pode ter limitações em ARM, prefira Postgres ou Azure SQL Edge*).

## 3.2. Obtendo o Projeto
```bash
# Clone o repositório principal
git clone https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker.git
cd TOTVS-Protheus-in-Docker
```

## 3.3. Configuração Inicial (Setup)

### 3.3.1. Variáveis de Ambiente (.env)
O projeto utiliza um arquivo `.env` para centralizar configurações sensíveis e comuns.
1.  Copie o modelo:
    ```bash
    cp .env.example .env
    ```
2.  Edite o arquivo `.env`. As variáveis mais críticas são:
    *   `DATABASE_PASSWORD`: Defina uma senha forte. Esta senha será injetada tanto na criação do banco quanto na configuração dos serviços que o acessam.
    *   `DATABASE_ALIAS`: Nome da instância/alias do banco de dados (ex: `protheus`).
    

### 3.3.2. Download de Recursos (Binários e RPO)
O projeto não inclui os binários no git para manter o repositório leve.
Você deve fornecer os arquivos ou usar o script de setup que baixa "snapshots" de um ambiente pré-configurado.

O script `scripts/build/setup.sh` é responsável por preparar a "cozinha" antes do build.
```bash
./scripts/build/setup.sh
```
*O que ele faz?*
Ao contrário de instaladores tradicionais, este script baixa **sistemas de arquivos completos e pré-instalados**:
*   **AppServer:** Baixa binários (`protheus.tar.gz`) e a estrutura de dados inicial (`protheus_data.tar.gz`) separadamente.
*   **Bancos de Dados:** Baixa os arquivos de dados físicos (`data.tar.gz`) contendo um banco Protheus vazio mas já inicializado (dicionários criados).
*   **SmartView/DBAccess:** Baixa as aplicações prontas para execução.

Isso garante que, ao subir os containers, o sistema já esteja pronto para uso imediato, sem necessidade de rodar wizards de instalação.

## 3.4. Construção das Imagens (Build)
Embora as imagens possam estar disponíveis no Docker Hub, é altamente recomendável saber como construí-las localmente para customizações.

Utilize o script mestre de build na raiz:
```bash
# Para construir todas as imagens
./scripts/build.sh

# Para construir apenas uma específica (ex: appserver)
./appserver/build.sh
```
Este processo pode levar vários minutos na primeira vez, pois envolve o download de imagens base (Oracle Linux, Postgres) e a instalação de pacotes.

## 3.5. Inicialização do Ambiente (Deploy)

### Método 1: Wizard Interativo (Recomendado para Iniciantes)
O projeto inclui um script `run.sh` que guia o usuário:
```bash
./run.sh
```
Ele perguntará:
1.  Qual banco de dados usar (Postgres, MSSQL ou Oracle).
2.  Se deseja ativar o perfil completo (com REST e SmartView).
E então executará o comando Docker Compose correto.

### Método 2: Manual (Linha de Comando)
Para usuários avançados que desejam controle total ou automação.

**Para PostgreSQL:**
```bash
docker compose -f docker-compose-postgresql.yaml -p totvs up -d
```

**Para SQL Server:**
```bash
docker compose -f docker-compose-mssql.yaml -p totvs up -d
```

**Para Oracle:**
```bash
docker compose -f docker-compose-oracle.yaml -p totvs up -d
```

**Adicionando serviços extras (AppRest + SmartView):**
Adicione a flag `--profile full`:
```bash
docker compose -f docker-compose-postgresql.yaml --profile full -p totvs up -d
```

## 3.6. Verificação Pós-Instalação
Após rodar o comando `up -d`, aguarde alguns minutos para que os serviços subam (especialmente o banco de dados e a primeira carga do AppServer).

Verifique o status:
```bash
docker compose -p totvs ps
```
Todos os estados devem estar como `Up` ou `Healthy`.

Acesse a interface Web do Protheus (Webapp) para validar:
*   URL: `http://localhost:23002`
*   Login Padrão: `admin` / `admin` (ou conforme configurado no seu banco de dados restaurado).
