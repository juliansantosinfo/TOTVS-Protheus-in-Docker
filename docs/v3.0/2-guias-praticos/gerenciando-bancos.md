# Guia Prático: Gerenciamento de Bancos de Dados

O ecossistema TOTVS Protheus in Docker oferece suporte desacoplado e nativo a três dos principais SGBDs corporativos do mercado: **PostgreSQL**, **Microsoft SQL Server** e **Oracle Database**.

---

## 🐘 1. PostgreSQL (`totvs_postgres`)

O PostgreSQL é a opção padrão e recomendada para ambientes locais de desenvolvimento devido à sua leveza, rápida inicialização e baixo consumo de memória RAM.

### 1.1. Codificação e Acentuação Protheus
O ERP Protheus requer codificação Latin-1 para compatibilidade estrita com campos de dicionário (`SX3`) e dados históricos:
* **Parâmetro de Inicialização:** `--locale=pt_BR.ISO-8859-1 -E LATIN1`
* **Volume de Persistência:** `totvs_postgres_data`

### 1.2. Parâmetros de Conexão Externa (DBeaver / pgAdmin)
* **Host:** `localhost` (ou IP da máquina hospedeira)
* **Porta:** `5432`
* **Banco de Dados:** `protheus`
* **Usuário:** `postgres`
* **Senha:** Valor de `DATABASE_PASSWORD` no seu `.env` (Padrão: `ProtheusDatabasePassword1`)

### 1.3. Backup e Restore Manual
```bash
# Gerar dump do banco protheus
docker exec -t totvs_postgres pg_dump -U postgres protheus > backup_protheus.sql

# Restaurar dump
cat backup_protheus.sql | docker exec -i totvs_postgres psql -U postgres protheus
```

---

## 🏢 2. Microsoft SQL Server (`totvs_mssql`)

Utiliza a imagem corporativa Microsoft SQL Server 2019 em Linux, configurada com o collation clássico do Protheus (`SQL_Latin1_General_CP1_CI_AS`).

### 2.1. Auto-Restauração de Backup (.bak)
O script de entrypoint do container verifica na primeira inicialização se o diretório de dados está vazio. Se a variável `RESTORE_BACKUP=Y` estiver ativa, ele restaura automaticamente o banco limpo contendo o dicionário e tabelas estruturais.

### 2.2. Parâmetros de Conexão (SSMS / Azure Data Studio)
* **Servidor:** `localhost,1433`
* **Autenticação:** Autenticação do SQL Server
* **Usuário:** `sa`
* **Senha:** Valor de `DATABASE_PASSWORD` no `.env`

---

## 🏛️ 3. Oracle Database (`totvs_oracle`)

Ideal para homologação e paridade com clientes corporativos de grande porte que operam Protheus sobre Oracle Enterprise.

### 3.1. Requisitos e Character Set
* **Oracle SID:** `XE`
* **Character Set:** `WE8MSWIN1252`
* **Porta TNS Listener:** `1521`
* **Usuários Administrativos:** `SYS`, `SYSTEM` e `PDBADMIN` (senha padronizada via `DATABASE_PASSWORD`).

### 3.2. Conexão Externa (PL/SQL Developer / SQL Developer / DBeaver)
* **Host:** `localhost`
* **Porta:** `1521`
* **Service Name:** `XE`
* **Usuário:** `system`
* **Senha:** Valor de `DATABASE_PASSWORD` no `.env`

---

## 🧹 4. Como Reiniciar uma Base do Zero (Reset de Dados)

Se o banco de dados for corrompido durante testes de migration ou você desejar voltar ao estado virgem de instalação:

```bash
# 1. Parar containers e remover volumes
docker compose -f docker-compose-postgresql.yaml down -v

# 2. Subir novamente garantindo que RESTORE_BACKUP=Y esteja no .env
docker compose -f docker-compose-postgresql.yaml up -d
```
> ⚠️ **Aviso:** O comando `down -v` apaga permanentemente todos os registros, notas e dados de teste armazenados nos volumes do banco de dados.
