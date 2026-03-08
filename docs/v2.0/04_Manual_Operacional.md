# 4. Manual Operacional (v2.0)

A v2.0 abandona a necessidade de operar microsserviços individualmente de pasta em pasta, promovendo a raiz do projeto principal a **Painel de Controle Central**.

## 4.1. Orquestradores Diários
A operação foi otimizada via novos master-scripts em shell `(scripts/*)`, dotados de feedback visual colorido e processamento modular (Você define o nome do contêiner opcional, ou processa tudo).

### Fluxos Típicos
| Master Script | Ação Orquestrada | Comando (Todos) | Comando Específico (AppServer apenas) |
|---|---|---|---|
| **Build** | Constrói infraestrutura Docker garantindo Labels via API | `./scripts/build/build.sh` | `./scripts/build/build.sh appserver` |
| **Limpeza (Clean)**| Restauração drástica. Remove os binários `*.tar` não versionados, apagando downloads efêmeros do `setup.sh`. Mantém o ambiente "Zero Git State" ideal antes de Commits. | `./scripts/build/clean.sh` | `./scripts/build/clean.sh dbaccess` |

> *Aviso: A manutenção isolada de scripts em pastas internas (ex `services/appserver/build.sh`) ainda é factível na v2.0 caso precise focar exclusivamente no repositório dequele serviço (o submódulo), mas gerenciar na raiz é recomendado.*

## 4.2. Fluxos Tradicionais de Docker Compose

*(A matriz clássica de mapeamento permanece inalterada em relação aos comportamentos internos nativos).*

*   **Pausar execução noturna:** `docker compose -p totvs stop`
*   **Destruição limpa (Apaga contêineres e portmaps, mas preserva volumes e banco de dados já criados):** `docker compose -p totvs down`

### Mapeamento Consolidado de Portas (TCP/IP)
O roteamento exposto aos `locahost` via Docker Desktop e WSL obedece a tabela:
| Serviço Docker | Porta Interna | Exposição Host | O que Roda Aqui |
|---|---|---|---|
| **totvs_appserver** | 1235 / 1234 | 1235 / 1234 | Interface HTML Remota / Conexão TCP Desktop |
| **totvs_apprest** | 8080 | 8080 | APIs e Integrações WSDL REST |
| **totvs_dbaccess** | 7890 | 7890 | Console de Monitoramento TopConnect |
| **totvs_licenseserver** | 5555 | 5555 | Protocolo Virtual de Licençiamento |
| *(Seu SQL Local)* | 5432 / 1433 / 1521 | Variável | Sockets nativos (PGAdmin, SSMS, PL/SQL) |

## 4.3. Monitoramento Centralizado e Profiling
Os scripts de verificação valem ouro no desenvolvimento diário:
`./scripts/validation/versions.sh` 
Crucial na governança de releases. Garanta que você e seu time não estejam buildando acidentalmente AppServer v12.1.25 enquanto o resto roda 2210.

`docker compose logs -f appserver` (Para acompanhar loops, crash limits, ou threads da web).

## 4.4. Atualização de Dados a Frio vs Bind Mounts
1. **Atalhos (Copiar e Colar `RPOs`)**: Em dev local contínuo, não faça Rebuild `(build.sh)` por causa de um fonte compilado! Continue transferindo binários via docker command local:
   `docker cp ./tttp120.rpo totvs_appserver_1:/totvs/protheus/apo/tttp120.rpo && docker restart totvs_appserver_1`

2. **A Grande Renovação (`setup.sh`)**: Você quer atualizar toda a arquitetura base do AppServer + Nova Release TOTVS? Rode `./scripts/build/clean.sh`, depois `./scripts/build/setup.sh` (para puxar a cópia nova master de infra local) e, por fim um `.build.sh`.

### Limpeza Destrutiva de Estado
> Caso o Docker Desktop indique corrupção severa da Image layer, ou o `postgres_data` crashe por corrupção fatal:
*   `docker compose -p totvs down -v` (O argumento `-v` erradica seus dados persistentes de Database e Dicionários para sempre. Tenha Backups).
