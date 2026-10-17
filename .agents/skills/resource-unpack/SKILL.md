---
name: resource-unpack
description: Use when unpacking TOTVS Protheus binary packages, extracting RPOs, menus, help files, dictionaries, or preparing dependencies in services/*/packages/ for Docker builds.
---

# Extração de Binários e Recursos TOTVS

## Visão Geral
Gerencia a localização e o desempacotamento de binários TOTVS, arquivos RPO, menus, ajudas (helps) e dicionários de dados a partir dos pacotes em `services/*/packages/`, preparando a estrutura interna para o build das imagens Docker.

## Quando Usar
- Ao atualizar binários ou pacotes TOTVS baixados para uma nova release.
- Quando o script de build (`build.sh`) falhar com erro de arquivo não encontrado (ex: `Nenhum arquivo RPO encontrado`, `AppServer binário não encontrado`).
- Antes de iniciar a construção de imagens Docker em um novo ambiente ou após limpeza de cache (`clean.sh`).

**Quando NÃO usar:**
- Quando os arquivos já estiverem descompactados e você desejar apenas construir a imagem (utilize a skill `docker-build-test`).
- Quando a imagem estiver utilizando uma `IMAGE_BASE` customizada que já contenha os binários pré-instalados.

---

## Estrutura de Pacotes Suportada

Os pacotes devem ser depositados no diretório `packages/` do respectivo serviço:

### 1. `services/appserver/packages/`
- **Binário do AppServer**: `*-P12_APPSERVER_BUILD-*_LINUX_X64.TAR.GZ`
- **SmartClient WebApp**: `*-P12_SMARTCLIENT_WEBAPP_*_LINUX_X64.TAR.GZ`
- **Repositório de Objetos (RPO)**: `*-REPOSITORIO_DE_OBJETOS_BRASIL_*_TTTM120.RPO`
- **Helps**: `*-BRA-HELPS_COMPL_*.ZIP`
- **Dicionários**: `*-BRA-DICIONARIOS_COMPL_*.ZIP`
- **Menus**: `*-BRA-MENUS_*.ZIP`

### 2. `services/dbaccess/packages/`
- **Binário do DBAccess**: `*-TOTVS_DBACCESS_BUILD_*_LINUX_X64.TAR.GZ`

### 3. `services/licenseserver/packages/`
- **Binário do License Server**: `*-TOTVSLICENSE_*_LINUX.TAR.GZ`

### 4. `services/smartview/packages/`
- **Binário do SmartView**: `*-linux-x64.zip`

---

## Execução

### A. Setup Master (Recomendado)
Executa a descompactação para todos ou serviços específicos através do script master:
```bash
# Todos os serviços
./scripts/build/setup.sh

# Apenas serviços específicos
./scripts/build/setup.sh appserver dbaccess
```

### B. Execução Individual no Submódulo
Você também pode rodar o `unpack.sh` diretamente dentro do diretório do serviço:
```bash
cd services/appserver
./unpack.sh all          # Extrai tudo
# ou componentes específicos:
./unpack.sh appserver
./unpack.sh webapp
./unpack.sh rpo
./unpack.sh menus
./unpack.sh helps
./unpack.sh dictionaries
cd ../..
```

---

## Destinos de Extração (Validação)
Após a execução do setup, verifique se os destinos foram povoados:
- `services/appserver/totvs/protheus/bin/appserver/appsrvlinux`
- `services/appserver/totvs/protheus/bin/appserver/webapp.so`
- `services/appserver/totvs/protheus/apo/tttm120.rpo`
- `services/appserver/totvs/protheus_data/system/` (arquivos `.xnu`)
- `services/appserver/totvs/protheus_data/systemload/` (arquivos `.unq`, `hlp*.txt`, `sx*.txt`)
- `services/dbaccess/totvs/dbaccess/dbaccess64`
- `services/licenseserver/totvs/licenseserver/`

---

## Erros Comuns
- **Padrão de nomenclatura de arquivos**: Os scripts de descompactação usam globbing (ex: `*APPSERVER_BUILD*`). Arquivos renomeados incorretamente não serão encontrados.
- **Espaço em disco**: A extração completa da release (RPO + dicionários + binários) consome cerca de 5 a 10 GB de espaço em disco temporário.
