# Arquitetura: A Fonte Única de Verdade (`versions.env`)

Um dos maiores desafios em arquiteturas multi-repositórios é o **desvio de versão (version drift)**: situações em que um Dockerfile aponta para uma versão, o Docker Compose solicita outra tag e a esteira de CI/CD compila com parâmetros divergentes.

No **TOTVS Protheus in Docker**, este problema é erradicado através do arquivo **`versions.env`** na raiz do projeto.

---

## 🎯 1. Princípio da Fonte Única da Verdade (SSOT)

Nenhum `Dockerfile`, script orquestrador ou workflow de CI possui versões de componentes codificadas de forma fixa (*hardcoded*).

O arquivo `versions.env` dita com precisão:
1. **Identidade no Registry:** Usuário e organização no Docker Hub (`DOCKER_USER=juliansantosinfo`).
2. **Identificador da Release de Recursos:** Metadado mestre da release de pacotes (`RESOURCE_RELEASE=release2610`).
3. **Versão Oficial da Release do ERP:** `APPSERVER_RELEASE=12.1.2610`.
4. **Builds Granulares dos Binários TOTVS:**
   * Build do AppServer (`26.3.0.0`)
   * Versão do WebApp HTML (`26.0.0`)
   * Biblioteca DBAPI (`26.1.0.0`)
   * DBAccess (`26.1.0.0`)
   * License Server (`3.7.2`)
   * SmartView (`3.9.0.4558336`)
5. **Versões de Imagens de Banco de Dados:** PostgreSQL 15, SQL Server 2019, Oracle 21.3.0.

---

## 🛡️ 2. O Validador Mestre (`versions.sh`)

Para que a SSOT funcione de maneira infalível, existe o script **`scripts/validation/versions.sh`**.

### Como funciona a validação:
1. O script lê o `versions.env` e mapeia a versão esperada para cada componente.
2. Varre os arquivos `services/*/Dockerfile` e inspeciona os metadados declarados em diretivas `LABEL`:
   ```dockerfile
   LABEL maintainer="Julian Santos"
   LABEL version="12.1.2610"
   ```
3. Se houver qualquer divergência de caractere, o script reporta a inconsistência e falha com código `1`.

### Correção Idempotente Automática (`--fix`)
Ao invés de editar manualmente múltiplos Dockerfiles em pastas diferentes, o desenvolvedor executa:
```bash
./scripts/validation/versions.sh --fix
```
O script reescreve automaticamente as linhas de `LABEL version` e metadados nos Dockerfiles de todos os 7 submódulos, garantindo paridade instantânea.

---

## 🔗 3. Integração com a Esteira de Governança

A consistência de versões não depende da lembrança humana. Ela é imposta em dois checkpoints obrigatórios:
1. **No Host Local (Git Hook `pre-commit`):** O commit é abortado localmente se as versões estiverem desalinhadas.
2. **Na Nuvem (GitHub Actions Job `lint-and-validation`):** A esteira rejeita o Pull Request se alguém tentar forçar o commit com versões inconsistentes.
