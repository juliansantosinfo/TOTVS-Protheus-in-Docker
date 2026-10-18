# Guia Prático: Deploy com Perfis do Docker Compose

Os arquivos `docker-compose-*.yaml` utilizam o recurso nativo de **Profiles** do Docker Compose para permitir que você inicialize somente os serviços necessários para sua carga de trabalho, economizando memória e CPU.

---

## 🎯 1. Perfis Disponíveis

| Perfil | Serviços Inicializados | Caso de Uso |
|---|---|---|
| *(Padrão / Sem perfil)* | Banco de Dados, `licenseserver`, `dbaccess`, `appserver` (Modo Application) | Desenvolvimento comum via SmartClient Desktop ou Web (porta 1235). |
| `full` | Stack básica + `apprest` + `smartview` | Testes integrados de ponta a ponta, APIs REST e extração de relatórios. |
| `with-rest` | Stack básica + `apprest` | Desenvolvimento de integrações HTTP/REST, APIs TLPP ou WebServices. |
| `with-smartview` | Stack básica + `smartview` | Desenvolvimento e homologação exclusiva de relatórios e BI (TReports). |

---

## 💻 2. Exemplos Práticos de Inicialização

### 2.1. PostgreSQL (Recomendado)
* **Stack básica (baixo consumo de RAM):**
  ```bash
  docker compose -f docker-compose-postgresql.yaml up -d
  ```
* **Stack completa (com REST e SmartView):**
  ```bash
  docker compose -f docker-compose-postgresql.yaml --profile full up -d
  ```
* **Apenas com API REST:**
  ```bash
  docker compose -f docker-compose-postgresql.yaml --profile with-rest up -d
  ```

### 2.2. Microsoft SQL Server
* **Stack básica:**
  ```bash
  docker compose -f docker-compose-mssql.yaml up -d
  ```
* **Stack completa:**
  ```bash
  docker compose -f docker-compose-mssql.yaml --profile full up -d
  ```

### 2.3. Oracle Database
* **Stack básica:**
  ```bash
  docker compose -f docker-compose-oracle.yaml up -d
  ```
* **Stack completa:**
  ```bash
  docker compose -f docker-compose-oracle.yaml --profile full up -d
  ```

---

## 🔀 3. Combinando Múltiplos Perfis

Você pode declarar a flag `--profile` múltiplas vezes na mesma linha de comando para subir combinações específicas:

```bash
docker compose -f docker-compose-postgresql.yaml --profile with-rest --profile with-smartview up -d
```

---

## 🛑 4. Parando Serviços por Perfil

Para parar os serviços vinculados a um perfil sem afetar os dados persistidos:

```bash
docker compose -f docker-compose-postgresql.yaml --profile full down
```

> ⚠️ **Atenção:** Nunca adicione a flag `-v` a menos que queira deletar permanentemente os volumes de dados e tabelas do banco.
