# 3. Instalação e Configuração (v2.0)

A instalação da versão 2.0 foi radicalmente simplificada pela adoção de scripts mestres de orquestração integrados com Git Submodules.

## 3.1. Pré-requisitos do Sistema
*   **Docker Engine:** Versão 20.10+ (ou Docker Desktop para Windows/Mac).
*   **Docker Compose:** Versão 2.0+ (plugin nativo `docker compose`).
*   **Git:** Essencial para gerenciar o ecossistema multi-repositórios.

>(**Windows User:** Projeções de I/O em WSL2 recomendam **fortemente** gerenciar projetos docker fora da partição compartilhada do sistema operativo original `(/mnt/c)` para impedir perda de performance severa).

## 3.2. Obtendo o Projeto (Atenção aos Submódulos)
Devido à transição para uma arquitetura modular, o clone **deve** solicitar a inicialização e atualização recursiva de todos os repositórios filhos atrelados.

```bash
# Clone o repositório principal trazendo todos os microserviços (submódulos)
git clone --recursive https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker.git
cd TOTVS-Protheus-in-Docker
```

> **O que fazer se esqueci o `--recursive`?**
> Basta inicializá-los manualmente:
> `git submodule update --init --recursive`

## 3.3. Configuração Inicial do Ambiente 

### 3.3.1. Variáveis de Proteção (.env)
A base para o deploy são os arquivos de configuração local e de definições de versão.
1.  Copie os templates base de desenvolvimento:
    ```bash
    cp .env.example .env
    ```
2.  Edite seu `.env`, prestando especial atenção a `DATABASE_PASSWORD` (senha do sa/postgres) e a opção `EXTRACT_RESOURCES=true` (descompacta bases limpas gerando o estado inicial do DB). As credenciais no compose obedecem sua configuração na largada.

*(**Nota da v2.0:** O arquivo de declaração de instâncias `versions.env` NÃO requer edição manual, ele pauta o ritmo do ecossistema todo e a versão base a ser empregada em todas as builds no repositório. Mova versões dele, apenas se for gerenciar um upgrade release).*

### 3.3.2. Motor de Download Orquestrado (`setup.sh`)
Ao invés de entrar em pasta por pasta de submódulo executando scripts nativos, o repositório principal introduz ferramentas universais na pasta `scripts/`. Este script faz a requisição de download para os binários estáticos pesados que não pesam seu `.git` .
```bash
# Executa a cópia oficial para todos os submodulos ativos:
./scripts/build/setup.sh
```
> O comando inteligente fará:
> *   Requisição do `protheus.tar` base para AppServer e REST.
> *   Carga preliminar de SmartView e LicensE.
> *   Dumps de volume cru prontos (Database `data.tar.gz`) acelerando dezenas de horas caso tivessem que criar SX* e tabelas no log via DBAccess.

## 3.4. Construção Modular (Build Master)
Cansado de `cd dockerApp... docker build`? A nova orquestração elimina processos monótonos.
O orquestrador master unifica builds garantindo aderência rigorosa com labels de `versions.env`.

```bash
# Gerando a malha completa: Buildar Todos os submódulos da arquitetura
./scripts/build/build.sh
```

**Construções Seletivas:** A flexibilidade permite requisições pontuais. 
```bash
# Quero buildar apenas o Middleware e o Relatório
./scripts/build/build.sh dbaccess smartview
```
Seu terminal listará em cores a confirmação de sucesso de imagens construídas e validadas dentro de *namespaces* corporativos (ex. `juliansantosinfo/totvs_appserver:12.1.2510`).

## 3.5. Inicialização (Deploy)
Os perfis Compose estão amadurecidos na base repositória principal.

### Rota Padrão via Terminal
Suba um stack corporativo robusto focado em PostgreSQL + Full Profile (Inclui portas SmartView e AppRest):

```bash
docker compose -f docker-compose-postgresql.yaml --profile full up -d
```
*(As variações `-mssql.yaml` e `-oracle.yaml` garantem paridade total de ambiente)*.

> **Scripts de Suporte Opcionais**
> Caso queira suporte interativo inicial via shell, `./run.sh` continua sendo o seu console CLI principal que roteia sua escolha de profile guiado por menus numéricos.

Verifique log das imagens orquestradas: `docker compose ps`
Aguarde alguns minutos durante a 1º largada, a etapa "Server Ready" ou porta `:1235` (WebAPP Admin) marcarão seu sucesso.
