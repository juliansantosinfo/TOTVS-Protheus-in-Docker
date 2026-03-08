# 5. Desenvolvimento, Customização e Manutenção do Projeto

## 5.1. Estrutura de Diretórios e Código Fonte
Para manter este projeto, é crucial entender a organização das pastas.

*   `services/appserver/`, `services/dbaccess/`, `services/licenseserver/`, etc.: Cada diretório raiz representa um microserviço. Dentro dele sempre haverá:
    *   `dockerfile`: A receita de bolo para criar a imagem.
    *   `build.sh`: Script wrapper para facilitar o `docker build`.
    *   `entrypoint.sh`: Script executado **dentro** do container ao iniciar. É aqui que a mágica da configuração dinâmica acontece.
    *   `resources/`: Pasta destinada a arquivos estáticos (ini, configs) copiados para a imagem.
    *   `totvs/`: Pasta (geralmente ignorada no git) onde o `setup.sh` deposita os binários pesados.

## 5.2. Personalizando Dockerfiles
Se você precisar instalar dependências de SO adicionais (ex: bibliotecas Python para SmartClient, fontes para relatórios, drivers de impressora):

1.  Edite o `dockerfile` do serviço correspondente.
2.  Localize a seção de instalação de pacotes. O projeto utiliza a abstração `$PKG_MGR` para lidar tanto com `dnf` quanto com `microdnf` em bases Red Hat UBI ou Oracle Linux.
3.  Adicione os pacotes desejados seguindo a sintaxe: `$PKG_MGR install -y <pacote>`.
4.  Rebuilde a imagem: `./services/appserver/build.sh`.

## 5.3. Entendendo os Entrypoints (Scripts de Inicialização)
A inteligência de adaptabilidade do ambiente reside nos arquivos `entrypoint.sh`.

**Validação e Padrões Inteligentes (DBAccess):**
O projeto adota uma filosofia de "Fail Fast" com padrões sensatos:
*   **Variáveis Obrigatórias:** `DATABASE_PROFILE`, `DATABASE_SERVER` e `DATABASE_PASSWORD`. Se não informadas, o container aborta a inicialização com erro explícito.
*   **Defaults por Perfil:** Se `DATABASE_PORT` ou `DATABASE_USERNAME` não forem informados, o script detecta o perfil (MSSQL, Postgres ou Oracle) e aplica os valores padrão de mercado para cada tecnologia.
*   **Resiliência:** Utiliza checks TCP via `/dev/tcp` para garantir conectividade antes de configurar arquivos `.ini`.

**Exemplo: Como o DBAccess sabe o IP do banco?**
No `services/dbaccess/entrypoint.sh`, existe uma lógica que lê a variável de ambiente `DATABASE_SERVER` (definida no docker-compose) e usa o comando `sed` (Stream Editor) para substituir um placeholder no arquivo `odbc.ini`.

```bash
# Trecho ilustrativo do script
sed -i "s/Servername_Host/$DATABASE_SERVER/g" /etc/odbc.ini
```
Se você criar uma nova variável de configuração, lembre-se de mapeá-la no `docker-compose.yaml` e implementar a lógica de substituição no `entrypoint.sh` correspondente.

## 5.4. Pipeline de CI/CD (GitHub Actions)
Este projeto está equipado com automação via GitHub Actions para garantir que as imagens no Docker Hub estejam sempre sincronizadas com o código do repositório.

### Fluxo de Trabalho (`.github/workflows/deploy.yml`)
1.  **Gatilho:** Commit na branch `main` ou `master`.
2.  **Matriz:** Dispara jobs paralelos para cada serviço (appserver, dbaccess, etc.).
3.  **Setup:** Baixa os binários do repositório de recursos.
4.  **Build:** Constrói a imagem Docker.
5.  **Tag:** Extrai a versão definida no script `build.sh`.
6.  **Push:** Envia para o Docker Hub (`juliansantosinfo/...`).

### Como atualizar a versão do projeto?
Para lançar uma nova versão (ex: mudar de 12.1.2510 para 12.1.2610):
1.  Edite o arquivo `versions.env` na raiz. Este arquivo é a **única fonte de verdade** para versões, nomes de imagens e tags de release.
2.  Execute o script de sincronização: `./scripts/validation/versions.sh --fix` para atualizar os labels em todos os Dockerfiles automaticamente.
3.  Atualize os binários no repositório de recursos externos.
4.  Faça o commit. O CI/CD cuidará do resto.

## 5.5. Melhores Práticas de Segurança Implementadas
*   **Usuário não-root:** Sempre que possível, os serviços rodam com usuário `totvs` (UID 1000) e não `root`, para evitar escalada de privilégios em caso de invasão.
*   **Segredos:** Senhas não são hardcoded nas imagens. São passadas via variáveis de ambiente.
    *   *Melhoria Futura:* Implementar Docker Secrets para não expor senhas nem nas variáveis de ambiente visíveis via `docker inspect`.
*   **Imagens Mínimas:** Uso de bases empresariais (**Enterprise Linux**) para reduzir superfície de ataque, tamanho e garantir suporte corporativo. No AppServer, foram removidos interpretadores adicionais como Python para maior endurecimento (hardening) da imagem.

## 5.6. Estendendo o Projeto
Deseja adicionar o **TOTVS TSS** (Nota Fiscal Eletrônica)?
1.  Crie uma pasta `tss/`.
2.  Crie um `Dockerfile` similar ao do `appserver` (pois o TSS também é um AppServer especializado).
3.  Crie um `docker-compose.override.yaml` ou adicione ao `docker-compose.yaml` principal.
4.  Configure a comunicação do AppServer principal com o TSS via parâmetros no `appserver.ini`.

## 5.7. Scripts de Automação e Utilidade
O diretório `scripts/` está organizado de forma hierárquica para facilitar a manutenção e a garantia de qualidade.

### 📁 scripts/build/ (Ciclo de Vida)
*   **`setup.sh`**: Baixa e organiza os binários oficiais. É o primeiro script a ser executado.
*   **`build.sh`**: Script mestre que orquestra a construção de todas as imagens Docker.
*   **`push.sh`**: Envia as imagens para o Docker Hub com tags de versão e `latest`.
*   **`clean.sh`**: Remove arquivos temporários e binários baixados.

### 📁 scripts/hooks/ (Git Automation)
*   **`install.sh`**: Instala e configura os Git Hooks no repositório local.
*   **`pre-commit.sh`**: Orquestrador que executa todas as validações de qualidade antes de um commit.
*   **`commit-msg.sh`**: Valida o padrão das mensagens de commit.

### 📁 scripts/validation/ (Qualidade e Linting)
Estes scripts garantem que o código siga os padrões estabelecidos:
*   **`versions.sh`**: Sincroniza versões entre `Dockerfiles` e `versions.env`.
*   **`env.sh`**: Valida a paridade entre `.env` e `.env.example`.
*   **`lint-shell.sh`**: Analisa scripts Bash com `shellcheck`.
*   **`lint-dockerfile.sh`**: Analisa Dockerfiles com `hadolint`.
## 5.8. Integridade de Imagens e Validação de Hashes
Para garantir que as imagens sejam construídas a partir de arquivos íntegros e não corrompidos, o projeto está implementando validações de hash SHA1.

*   **Oracle Database:** O diretório `services/oracle/` contém um arquivo `.hashes.sha1`. Durante o `build.sh`, o script valida se os arquivos locais (como scripts SQL e entrypoints) correspondem aos hashes registrados.
*   **Como atualizar os hashes:** Se você alterar propositalmente um arquivo e desejar atualizar o registro de integridade, execute:
    ```bash
    find . -type f ! -name ".hashes.sha1" -exec sha1sum {} + > .hashes.sha1
    ```
    *(Execute este comando de dentro da pasta do módulo correspondente)*.
