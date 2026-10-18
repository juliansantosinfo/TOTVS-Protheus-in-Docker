# Tutorial: Primeiro Build Local de Imagens

Neste tutorial, você aprenderá como construir localmente todas as imagens Docker do ecossistema TOTVS Protheus, personalizando componentes e garantindo consistência com o arquivo mestre de versões.

---

## 🎯 Por que construir imagens localmente?

Embora as imagens pré-construídas estejam disponíveis no Docker Hub (`juliansantosinfo/*`), o build local é essencial quando você precisa:
1. Customizar scripts de entrypoint ou pacotes do sistema operacional.
2. Homologar novas releases do AppServer, DBAccess ou SmartView antes da publicação oficial.
3. Operar em ambientes corporativos isolados (sem acesso direto ao Docker Hub).
4. Gerar builds com `--no-cache` para testes de integração contínua (CI).

---

## 📦 1. Obtenção de Pacotes e Descompactação (`setup.sh`)

Os binários e pacotes proprietários da TOTVS (AppServer, DBAccess, License Server, SmartView, RPOs e dicionários base) não são versionados no Git por motivos de licenciamento e tamanho. O desenvolvedor deve obter esses pacotes e organizá-los antes da compilação.

### 1.1. Obtenção e Distribuição nos Diretórios `packages/`

Baixe os pacotes oficiais diretamente do Portal do Cliente TOTVS (Central de Downloads) e deposite os arquivos compactados nos diretórios `packages/` de cada serviço correspondente:

| Serviço | Diretório de Destino | Padrão do Arquivo Esperado | Descrição |
|---|---|---|---|
| **AppServer** | `services/appserver/packages/` | `*-P12_APPSERVER_BUILD-*_LINUX_X64.TAR.GZ` | Binário do AppServer Linux |
| **AppServer** | `services/appserver/packages/` | `*-P12_SMARTCLIENT_WEBAPP_*_LINUX_X64.TAR.GZ` | Biblioteca SmartClient WebApp (`webapp.so`) |
| **AppServer** | `services/appserver/packages/` | `*-REPOSITORIO_DE_OBJETOS_BRASIL_*_TTTM120.RPO` | RPO Padrão da Release |
| **AppServer** | `services/appserver/packages/` | `*-BRA-HELPS_COMPL_*.ZIP` | Arquivos de Ajuda de Campos/Telas |
| **AppServer** | `services/appserver/packages/` | `*-BRA-DICIONARIOS_COMPL_*.ZIP` | Dicionários SXs e Estruturas |
| **AppServer** | `services/appserver/packages/` | `*-BRA-MENUS_*.ZIP` | Menus do Sistema (`.xnu`) |
| **DBAccess** | `services/dbaccess/packages/` | `*-TOTVS_DBACCESS_BUILD_*_LINUX_X64.TAR.GZ` | Binário do DBAccess Linux x64 |
| **License Server** | `services/licenseserver/packages/` | `*-TOTVSLICENSE_*_LINUX.TAR.GZ` | Binário do License Server Linux |
| **SmartView** | `services/smartview/packages/` | `*-linux-x64.zip` | Pacote do SmartView / TReports |

### 1.2. Executando o Setup Mestre (`setup.sh`)

Com os pacotes depositados em suas respectivas pastas `packages/`, execute o script `setup.sh`. Ele valida as versões contra o arquivo `versions.env`, descompacta e distribui os arquivos para a estrutura interna (`totvs/`) de cada componente:

```bash
# Preparar e descompactar dependências de todos os serviços
./scripts/build/setup.sh
```

#### Execução Seletiva por Serviço

Caso deseje preparar apenas serviços específicos:

```bash
./scripts/build/setup.sh appserver dbaccess
```

> 🔍 **O que o `setup.sh` realiza por debaixo dos panos?**
>
> * Itera sobre os submódulos selecionados acionando seus scripts locais de descompactação (`unpack.sh` ou `setup-build.sh`).
> * Valida se a versão dos pacotes corresponde exatamente à versão declarada em `versions.env` (ex.: `APPSERVER_BUILD_VERSION`).
> * Descompacta e organiza os artefatos nos destinos internos (`totvs/protheus/bin/`, `totvs/protheus/apo/`, `totvs/protheus_data/`, etc.).

---

## ⚖️ 2. Garantindo a Consistência de Versões (`versions.sh`)

Antes de iniciar a compilação, garanta que os `Dockerfiles` dos submódulos estejam estritamente alinhados com o arquivo `versions.env`:

```bash
# Valida e sincroniza os LABELS de versão em todos os Dockerfiles
./scripts/validation/versions.sh --fix
```

Se qualquer tag estiver divergente, o utilitário corrigirá os arquivos automaticamente.

---

## 🔨 3. Executando o Build Mestre (`build.sh`)

O script `scripts/build/build.sh` atua como maestro, iterando sobre os submódulos e executando o `docker build` com as tags e argumentos corretos.

### 3.1. Build Completo de Todos os Serviços

```bash
./scripts/build/build.sh
```

Durante a execução, o terminal exibirá logs coloridos indicando o status de cada componente:
* `totvs_appserver` (Modo Application e REST)
* `totvs_dbaccess`
* `totvs_licenseserver`
* `totvs_postgres`
* `totvs_mssql`
* `totvs_oracle`
* `totvs_smartview`

### 3.2. Build Seletivo

Você pode especificar um ou mais serviços como argumento:

```bash
# Compilar apenas o AppServer e o DBAccess
./scripts/build/build.sh appserver dbaccess
```

### 3.3. Forçando Build sem Cache

Para garantir uma compilação limpa do zero, repasse a flag `--no-cache`:

```bash
./scripts/build/build.sh appserver --no-cache
```

---

## 🧹 4. Limpeza de Temporários e Cache (`clean.sh`)

Após a compilação, para liberar espaço em disco e retornar os diretórios ao estado "Zero Git State" (ideal antes de fazer commits):

```bash
# Remove artefatos descompactados e pacotes não versionados
./scripts/build/clean.sh
```

Ou para limpar apenas um serviço:

```bash
./scripts/build/clean.sh dbaccess
```

> [!WARNING]
> **Atenção ao diretório `packages/`:**
> O script `clean.sh` executa `git clean -fdx` nos diretórios do serviço, o que **exclui tanto os arquivos descompactados em `totvs/` quanto os pacotes originais colocados em `packages/`**.
> Certifique-se de manter uma cópia dos instaladores e arquivos `.zip` / `.tar.gz` baixados da TOTVS em um diretório fora da árvore do repositório Git!

---

## 🧪 5. Validando as Imagens Construídas

Verifique se as imagens foram registradas localmente com suas respectivas tags:

```bash
docker images | grep -E "totvs|juliansantosinfo"
```

Em seguida, execute o script de validação de subida de containers:

```bash
# Executa validação de sintaxe e smoke test
./scripts/test/test-compose.sh -f docker-compose-postgresql.yaml
```

---

## 🎯 Próximos Passos

* Para enviar suas imagens compiladas a um registro privado ou Docker Hub, consulte o guia de [Scripts e Utilitários CLI](../4-referencia/catalogo-scripts-cli.md).
* Para entender como contribuir com melhorias nos submódulos, veja [Desenvolvimento em Submódulos](../2-guias-praticos/desenvolvimento-submodulos.md).
