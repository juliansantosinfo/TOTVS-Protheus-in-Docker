# Tutorial: Início Rápido (Zero ao Protheus no Ar)

Este tutorial conduz você do zero até um ambiente funcional do ERP TOTVS Protheus rodando em containers Docker em menos de 10 minutos.

---

## 📋 1. Pré-requisitos

Certifique-se de que sua máquina possui:
1. **Docker Engine 20.10+** e **Docker Compose v2+** (comando nativo `docker compose`).
2. **Git** configurado.
3. **Mínimo de Recursos Recomendados:**
   * 8 GB de memória RAM livre (16 GB recomendado para stack completa).
   * 30 GB de espaço em disco.
4. **Ajuste Mandatório no Host Linux / WSL2 (Limite de Arquivos):**
   O AppServer do Protheus exige um limite adequado de descritores de arquivo. Execute no terminal da máquina host:
   ```bash
   sudo sysctl -w fs.file-max=65535
   ```
   > ⚠️ **Aviso para Usuários Windows / WSL2:**  
   > Sempre clone e execute o projeto dentro do sistema de arquivos Linux do WSL2 (ex.: `/home/seu-usuario/...`). **Nunca** rode na partição compartilhada `/mnt/c/...`, pois a lentidão de I/O degradará severamente a inicialização do Protheus.

---

## 📥 2. Clonando o Repositório com Submódulos

O projeto utiliza Git Submodules para organizar os microserviços. Para clonar a estrutura completa:

```bash
# Clone trazendo recursivamente todos os serviços
git clone --recursive https://github.com/juliansantosinfo/TOTVS-Protheus-in-Docker.git
cd TOTVS-Protheus-in-Docker
```

> 💡 **Esqueceu o `--recursive`?**  
> Se você fez um `git clone` convencional e as pastas dentro de `services/` estiverem vazias, execute:
> ```bash
> git submodule update --init --recursive
> ```

---

## 🔒 3. Configurando o Ambiente e Git Hooks

### 3.1. Instalar Git Hooks Locais
Execute o script instalador de hooks para habilitar as proteções automáticas de commit, linters e validações de versões:
```bash
./scripts/hooks/install.sh
```

### 3.2. Criar seu Arquivo de Ambiente (.env)
Copie o template de exemplo:
```bash
cp .env.example .env
```

Abra o arquivo `.env` gerado. Para o primeiro teste rápido, as configurações padrão já estão pré-ajustadas.
As variáveis mais importantes a conhecer:
* `DATABASE_PASSWORD`: Senha administrativa padrão do banco de dados (ex: `ProtheusDatabasePassword1`).
* `EXTRACT_RESOURCES=true`: Garante que os recursos iniciais (dicionários e tabelas limpas) sejam extraídos na primeira inicialização.

---

## 🚀 4. Iniciando a Stack de Containers

Escolha o banco de dados de sua preferência. Recomendamos o **PostgreSQL** para desenvolvimento por sua inicialização rápida e baixo consumo de recursos:

### Opção A: PostgreSQL (Recomendado)
```bash
docker compose -f docker-compose-postgresql.yaml up -d
```

### Opção B: Microsoft SQL Server
```bash
docker compose -f docker-compose-mssql.yaml up -d
```

### Opção C: Oracle Database
```bash
docker compose -f docker-compose-oracle.yaml up -d
```

---

## 🔍 5. Acompanhando a Inicialização

Na primeira partida, os containers realizarão a descompactação inicial e configuração do schema. Acompanhe os logs do servidor de aplicação:

```bash
# Acompanhar logs em tempo real
docker compose -f docker-compose-postgresql.yaml logs -f appserver
```

Quando você visualizar no log a mensagem informando que os serviços estão prontos (ou que o listener HTTP da porta `1235` subiu), o ambiente estará disponível.

---

## 🌐 6. Acessando o Protheus

Abra o navegador de sua preferência e acesse o **SmartClient Web**:
* **URL:** [http://localhost:1235](http://localhost:1235)
* **Usuário:** `admin`
* **Senha:** ` ` *(Um único espaço em branco)*
* **Ambiente (Environment):** `ENVIRONMENT`

### Acesso ao Console do DBAccess
Para checar a integridade da conexão ODBC e monitorar threads do banco:
* **URL:** [http://localhost:7890](http://localhost:7890)

---

## 🛑 7. Pausando e Reiniciando o Ambiente

* **Para pausar sem perder dados:**
  ```bash
  docker compose -f docker-compose-postgresql.yaml stop
  ```
* **Para retomar:**
  ```bash
  docker compose -f docker-compose-postgresql.yaml start
  ```
* **Para parar e remover os containers mantendo os volumes persistidos:**
  ```bash
  docker compose -f docker-compose-postgresql.yaml down
  ```

---

## 🎯 Próximos Passos
* Deseja subir serviços adicionais como APIs REST e SmartView? Consulte o guia [Deploy com Perfis do Compose](../2-guias-praticos/deploy-perfis-compose.md).
* Precisa atualizar fontes ou compilar um `custom.rpo`? Acesse [Atualização de RPO e Fontes AdvPL/TLPP](../2-guias-praticos/atualizando-rpo-fontes.md).
