# Diretrizes de Docker e Compose

O ambiente TOTVS Protheus possui requisitos operacionais específicos para execução estável em containers Linux.

---

## 1. Padrões para Dockerfiles
- **Hadolint Compliance**: Todo Dockerfile deve passar na validação estática de [`./scripts/validation/lint-dockerfile.sh`](../../scripts/validation/lint-dockerfile.sh).
- **Labels Padronizadas**:
  - `release`: Release do Protheus (ex: `"12.1.2610"`).
  - `build`: Build do AppServer binário (ex: `"26.3.0.0"`).
  - `dbapi`: Versão do DbAPI integrado (ex: `"26.1.0.0"`).
  - `webapp`: Versão do SmartClient WebApp (ex: `"26.0.0"`).
  - `version`: Versão do serviço (DbAccess, LicenseServer, etc.).
  - `description`: Descrição concisa do serviço.
  - `maintainer`: Mantenedor do projeto.
- **Camadas e Cache**: Agrupe comandos `RUN` para minimizar camadas e limpe pacotes temporários (`yum clean all` ou `rm -rf /var/cache/yum`) na mesma camada.

---

## 2. Requisitos Operacionais de Runtime

### A. Ulimits (`nofile`)
O AppServer e o License Server abrem centenas de descritores de arquivos simultâneos.
- Sempre configure nos serviços do Compose:
  ```yaml
  ulimits:
    nofile:
      soft: 65536
      hard: 65536
  ```
- No host Linux, certifique-se de que `fs.file-max` suporte essa alocação (mínimo `65535`).

### B. Healthchecks e Dependências
- Todo container na stack principal possui um script `/healthcheck.sh` embutido.
- Utilize `depends_on` com `condition: service_healthy` para garantir que o banco e o license server estejam 100% operacionais antes de iniciar o DBAccess e o AppServer.

### C. Redes e Volumes
- **Rede Compartilhada**: Todos os serviços devem se comunicar pela rede bridge nomeada `totvs`.
- **Persistência de Dados**:
  - `totvs_protheus_data`: Dados do ERP (`system`, `systemload`, dicionários).
  - `totvs_appserver_apo`: Repositório de objetos RPO compilado (`tttm120.rpo`, `custom.rpo`).
  - Volumes específicos de banco: `totvs_postgres_data`, `totvs_mssql_data`.
  - BI / SmartView: `totvs_smartview_data`.

### D. Multi-Profiles do Compose
O projeto utiliza profiles do Compose:
- Default: Stack padrão com o banco escolhido, license server, dbaccess e appserver.
- `--profile full`: Inclui a API REST (`apprest`) e o BI (`smartview`).
- Perfis individuais: `with-rest`, `with-smartview`.
