# 5. Desenvolvimento, Customização e Manutenção (v2.0)

A arquitetura da v2.0 é desenhada para times de **Cloud Native / DevOps** garantindo *Continuous Integration*.

## 5.1. A "Única Fonte de Verdade" (`versions.env`)
Seja você um desenvolvedor testando um patch local, ou o runner do GitHub Actions construindo a release oficial, o `versions.env` dita:
1. As versões das imagens Base e do banco de dados (ex: `POSTGRES_VERSION=15`).
2. A nomenclatura corporativa nos Registries (ex: `DOCKER_USER=juliansantosinfo`).
3. O versionamento real da esteira TOTVS (ex: `12.1.2510`).

> Sem o arquivo central `.env`, as branches secundárias quebra-cabeçam builds em loop. Quando você desejar *incrementar a versão do seu repositório*, a única alteração necessária será aqui no Github/VSCode.

### O Cão-de-Guarda das Versões
Rodou o commit sem conferir as tags dos arquivos `Dockerfile` dentro dos Submódulos?
**O Validador corrige as tags Docker automaticamente:**
`./scripts/validation/versions.sh --fix` 
*(Comando de rotina antes de `git commit`). Ele acessa todos os Dockerfiles dos submódulos e garante que o Label version=* coincida estritamente com o `.env`*.

## 5.2. Pipeline CI/CD: A "Esteira de Automação"
O projeto foi reimplementado no GitHub Actions garantindo validações profundas (*Lint*, *Syntax*, *Integration*, *Delivery*).
O arquivo maestro `.github/workflows/deploy.yml` descreve toda a rotina, executada ao "commitar" na branch principal:

1. **Job `lint-and-validation`**: Efetua Code-Review automatizado. Usa `Hadolint` (Docker), `ShellCheck` (Bash) e varre a consistência dos seus compose-files em YAML para garantir que ninguém incluiu vírgulas acidentais onde deveriam haver tabulações. 
2. **Job `smoke_test`**: O GitHub "baixa o `.tar` e protheus_data" de demonstração do setup original. Tenta injetar os serviços PostgreSQL, MSSQL e compila orquestralmente. Se qualquer container fizer Crash (Log Failed Exit Code 1) a release morre na praia. Protegendo a master branch e evitando Push Sujo de código ruim.
3. **Job `build-and-push`**: Se tudo "Der Verde" na esteira, uma conexão HTTPS encriptada faz Upload inteligente das *Oci Images* com Tag da Release (ex. `12.1.2510`) + a TAG *`latest`* (Se foi mesclado na branch default `master`).

### 5.2.1 Workflow_Dispatch Manual
No GitHub Web, não dependa apenas do *Push*. Você tem botões de Dispatch (Gatilhos Manuais) para engatilhar rodadas seletivas isoladas na infra (Baixar/Buildar apenas `appserver`, etc).

## 5.3. Controle de Microservices: Repositório de Submódulos
Você modificou um Dockerfile na raiz do `TOTVS-Protheus-in-Docker/appserver/` e "commitou" na raiz principal? **Você Errou.**
Submódulos Git são um portal para "Outro Repositório".
1. Você desce a pasta: `cd appserver`
2. Você altera e envia lá primeiro: `git commit -m "feat..." && git push origin master`
3. Você sobe a pasta `cd ..` 
4. Você atualiza a "Referência Criptográfica de Hashes daquele pacote na raíz do ecossistema mestre": `git add appserver && git commit -m "chore: Atualizando pacote de appserver para Hash XYZ"`.

Este design permite a separação de times. A equipe de Banco Cuida do Oracle Submodule. A equipe ADVPL versiona os AppServers. Fricção = Zero.

## 5.4. Scripts Master Explicados 

### `scripts/build/push.sh`
Orquestrador logado para entregar as dependências em *Repositórios Remotos*. Utiliza metadados do `versions.env` corporativo.

Para publicar manualmente (sem aguardar seu CI Pipeline):
`./scripts/build/push.sh appserver dbaccess`
(Requer autenticação primária `docker login`).

### `scripts/hooks/install.sh`
Rode este comando na sua máquina 1x após fazer Git Clone! Ele implanta bloqueadores na sua pasta `.git/hooks`.
Você fará um commit e digitará `git commit -m "aaaaa"`. O projeto te barrará e mandará usar `Conventional Commits` (`feat: ...`, `fix: ...`, `chore: ...`). E ele não deixa comittar senhas soltas.
