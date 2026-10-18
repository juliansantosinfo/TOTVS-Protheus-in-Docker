# Tutorial: Usando os Assistentes Visuais e CLI

O projeto oferece ferramentas auxiliares para simplificar a configuração de ambientes sem a necessidade de decorar comandos de terminal ou editar arquivos YAML manualmente.

---

## 📟 1. Assistente Interativo de Terminal (`./run.sh`)

O arquivo `run.sh` na raiz do projeto é um script Bash projetado para conduzir o usuário passo a passo através de menus interativos.

### Como Executar
No terminal, a partir da raiz do repositório:
```bash
./run.sh
```

### Fluxo Guiado pelo Assistente
1. **Escolha do Banco de Dados:**
   * `1) PostgreSQL (Recomendado)`
   * `2) Microsoft SQL Server`
   * `3) Oracle Database`
2. **Escolha do Perfil de Execução:**
   * `Stack Básica`: Inicia apenas Banco de Dados, License Server, DBAccess e AppServer.
   * `Stack Completa (Full)`: Inclui AppRest (APIs) e SmartView (Relatórios).
   * `Stack com REST`: Inclui apenas a API REST.
   * `Stack com SmartView`: Inclui apenas o motor de relatórios.
3. **Inicialização Automatizada:**
   O script monta a linha de comando correspondente (ex.: `docker compose -f docker-compose-postgresql.yaml --profile full up -d`) e inicia a stack com validação de status.

---

## 🌐 2. Geradores Web Online

Para desenvolvedores ou analistas que preferem criar arquivos customizados via interface visual, existem duas ferramentas oficiais integradas ao ecossistema:

### 2.1. TOTVS Protheus Compose Generator
* **Acesso:** [TOTVS Protheus Compose Generator](https://juliansantosinfo.github.io/TOTVS-Protheus-Compose-Generator/)
* **Objetivo:** Permite customizar parâmetros de banco de dados, portas expostas, volumes e perfis de forma interativa.
* **Saída:** Gera e permite download direto de:
  * `docker-compose.yml` customizado.
  * `.env` pré-configurado com as credenciais selecionadas.
* **Como utilizar o pacote baixado:**
  Basta colocar os arquivos em um diretório vazio e executar:
  ```bash
  docker compose up -d
  ```

### 2.2. TOTVS Protheus Dockerfile Generator
* **Acesso:** [TOTVS Protheus Dockerfile Generator](https://juliansantosinfo.github.io/TOTVS-Protheus-Dockerfile-Generator/)
* **Objetivo:** Geração de `Dockerfiles` sob medida para componentes individuais do ecossistema (AppServer, DBAccess, LicenseServer).
* **Casos de uso:** Criação de imagens customizadas com camadas extras corporativas (drivers adicionais, pacotes de monitoramento, agentes de APM como New Relic ou Datadog).

---

## ⚖️ 3. Quando usar cada ferramenta?

| Cenário de Uso | Ferramenta Recomendada | Vantagem Principal |
|---|---|---|
| **Desenvolvimento Local Rápido** | `./run.sh` | Sem necessidade de decorar sintaxe de compose ou nomes de profiles. |
| **Ambientes Customizados / Homologação** | [Compose Generator](https://juliansantosinfo.github.io/TOTVS-Protheus-Compose-Generator/) | Ajuste fino de portas e configurações de forma visual e segura. |
| **Esteiras CI/CD e Servidores Headless** | `docker compose -f ... up -d` | Execução não interativa e determinística em scripts e automações. |
| **Imagens Especializadas** | [Dockerfile Generator](https://juliansantosinfo.github.io/TOTVS-Protheus-Dockerfile-Generator/) | Flexibilidade para adicionar pacotes e drivers sem alterar os submódulos oficiais. |

---

## 🎯 Próximos Passos
* Para entender a fundo os perfis do Docker Compose, veja [Deploy com Perfis do Compose](../2-guias-praticos/deploy-perfis-compose.md).
* Para conferir todas as portas expostas, veja [Matriz de Portas e Redes](../4-referencia/matriz-portas-e-redes.md).
