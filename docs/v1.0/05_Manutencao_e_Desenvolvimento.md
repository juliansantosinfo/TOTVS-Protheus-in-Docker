# 5. Desenvolvimento, Customização e Manutenção do Projeto

## 5.1. Estrutura de Diretórios e Código Fonte
Para manter este projeto, é crucial entender a organização das pastas.

*   `appserver/`, `dbaccess/`, `licenseserver/`, etc.: Cada diretório raiz representa um microserviço. Dentro dele sempre haverá:
    *   `dockerfile`: A receita de bolo para criar a imagem.
    *   `build.sh`: Script wrapper para facilitar o `docker build`.
    *   `entrypoint.sh`: Script executado **dentro** do container ao iniciar. É aqui que a mágica da configuração dinâmica acontece.
    *   `resources/`: Pasta destinada a arquivos estáticos (ini, configs) copiados para a imagem.
    *   `totvs/`: Pasta (geralmente ignorada no git) onde o `setup.sh` deposita os binários pesados.

## 5.2. Personalizando Dockerfiles
Se você precisar instalar dependências de SO adicionais (ex: bibliotecas Python para SmartClient, fontes para relatórios, drivers de impressora):

1.  Edite `appserver/dockerfile`.
2.  Localize a seção de instalação de pacotes (geralmente `yum install` ou `apt-get install` dependendo da base, aqui usamos Oracle Linux/RedHat base, então `microdnf` ou `yum`).
3.  Adicione os pacotes.
4.  Rebuilde a imagem: `./appserver/build.sh`.

## 5.3. Entendendo os Entrypoints (Scripts de Inicialização)
A inteligência de adaptabilidade do ambiente reside nos arquivos `entrypoint.sh`.

**Exemplo: Como o DBAccess sabe o IP do banco?**
No `dbaccess/entrypoint.sh`, existe uma lógica que lê a variável de ambiente `DATABASE_SERVER` (definida no docker-compose) e usa o comando `sed` (Stream Editor) para substituir um placeholder no arquivo `odbc.ini`.

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
1.  Edite o arquivo `versions.env` na raiz (se implementado conforme recomendações) ou os cabeçalhos dos scripts `build.sh` individuais.
2.  Atualize os binários no repositório de recursos externos.
3.  Faça o commit. O CI/CD cuidará do resto.

## 5.5. Melhores Práticas de Segurança Implementadas
*   **Usuário não-root:** Sempre que possível, os serviços rodam com usuário `totvs` (UID 1000) e não `root`, para evitar escalada de privilégios em caso de invasão.
*   **Segredos:** Senhas não são hardcoded nas imagens. São passadas via variáveis de ambiente.
    *   *Melhoria Futura:* Implementar Docker Secrets para não expor senhas nem nas variáveis de ambiente visíveis via `docker inspect`.
*   **Imagens Mínimas:** Uso de bases `slim` (Oracle Linux Slim) para reduzir superfície de ataque e tamanho.

## 5.6. Estendendo o Projeto
Deseja adicionar o **TOTVS TSS** (Nota Fiscal Eletrônica)?
1.  Crie uma pasta `tss/`.
2.  Crie um `Dockerfile` similar ao do `appserver` (pois o TSS também é um AppServer especializado).
3.  Crie um `docker-compose.override.yaml` ou adicione ao `docker-compose.yaml` principal.
4.  Configure a comunicação do AppServer principal com o TSS via parâmetros no `appserver.ini`.

## 5.7. Scripts de Automação e Utilidade
O diretório `scripts/` contém ferramentas essenciais para a automação, manutenção e garantia de qualidade do projeto.

### Scripts de Ciclo de Vida (Build e Setup)
*   **`scripts/setup.sh`**: Responsável por baixar os binários oficiais (Protheus, DBAccess, etc) de um repositório externo e organizá-los nas pastas corretas (`appserver/totvs`, etc). É o primeiro script a ser executado.
*   **`scripts/build.sh`**: Script mestre que orquestra a construção de todas as imagens Docker. Ele pode construir tudo de uma vez ou serviços específicos (ex: `./scripts/build.sh appserver`).
*   **`scripts/push.sh`**: Envia as imagens construídas para o Docker Hub, criando as tags de versão e `latest`.
*   **`scripts/clean.sh`**: Remove arquivos temporários e binários baixados para limpar o ambiente de desenvolvimento.

### Scripts de Qualidade e Validação (Git Hooks)
Estes scripts são geralmente executados automaticamente pelos Git Hooks (`pre-commit`), mas podem ser rodados manualmente:

*   **`scripts/validate-versions.sh`**: Garante que a versão declarada nos `Dockerfiles` seja idêntica à definida no arquivo `versions.env`. Use `--fix` para corrigir automaticamente.
*   **`scripts/validate-env.sh`**: Verifica se todas as variáveis criadas no seu `.env` local também constam no `.env.example`, garantindo que a documentação de configuração não fique defasada.
*   **`scripts/lint-shell.sh`**: Utiliza a ferramenta `shellcheck` para analisar estaticamente todos os scripts `.sh` em busca de erros de sintaxe ou boas práticas.
*   **`scripts/lint-dockerfile.sh`**: Utiliza `hadolint` para verificar se os Dockerfiles seguem as melhores práticas de construção de imagens.
*   **`scripts/scan-secrets.sh`**: Varre o código em busca de senhas, chaves de API ou tokens que possam ter sido commitados acidentalmente.
*   **`scripts/setup-hooks.sh`**: Instala e configura todos os hooks acima no seu repositório Git local (`.git/hooks`). Execute-o uma vez ao clonar o projeto.
