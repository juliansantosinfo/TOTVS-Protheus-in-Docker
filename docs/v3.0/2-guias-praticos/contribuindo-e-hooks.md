# Guia Prático: Contribuição, Linters e Git Hooks

Para manter a qualidade corporativa do código, consistência de versões e segurança contra vazamento de segredos, o projeto adota uma rigorosa política de governança de código e Git Hooks locais.

---

## 🩺 1. Diagnóstico Rápido ao Iniciar ou Retomar Manutenção

Sempre que clonar o repositório ou voltar a trabalhar nele após algum tempo, você não precisa decorar o estado das branches ou quais scripts rodar. Basta executar na raiz:

```bash
make
# ou diretamente:
./scripts/validation/status.sh
```

Esse comando abre o **Cockpit do Mantenedor**, inspecionando automaticamente:
* Branch atual do repositório principal vs. branches esperadas nos 7 submódulos em `services/`.
* Existência do arquivo `.env` e instalação dos Git Hooks locais.
* Sincronia tripla de versões (`versions.env` ➔ `Dockerfiles`, `services/*/versions.env` e `docker-compose*.yaml`).
* Estado dos pacotes em `services/*/packages/` (se já foram extraídos em `totvs/` ou se precisam de `make setup`).
* Imagens Docker já compiladas na máquina local e **Próximos Passos Recomendados** na ordem certa.

Para corrigir automaticamente hooks ausentes, `.env` faltante e divergências de versão em um único comando:
```bash
make fix
# ou: ./scripts/validation/status.sh --fix
```

> 💡 **Dica para usuários do VS Code:** Pressione `Ctrl+Shift+P` -> `Tasks: Run Task` para executar o diagnóstico, auto-fix, setup, build ou troca de release diretamente pela interface gráfica (configurado em `.vscode/tasks.json`).

---

## 🪝 2. Instalando os Git Hooks Locais Manualmente

Caso queira instalar apenas os Git Hooks na máquina de desenvolvimento:

```bash
./scripts/hooks/install.sh
# ou: make hooks
```

Esse script instala em `.git/hooks/` os gatilhos que executarão checagens automáticas em cada ação do Git.

---

## 📝 3. Padrão de Mensagens de Commit (Conventional Commits)

O hook `commit-msg` rejeitará qualquer mensagem fora da especificação [Conventional Commits](https://www.conventionalcommits.org/):

### Formato Obrigatório
```text
<tipo>(escopo opcional): <descrição curta no imperativo>
```

### Tipos Permitidos
* `feat`: Adição de uma nova funcionalidade no ambiente ou scripts.
* `fix`: Correção de um bug em scripts, Dockerfiles ou compose.
* `chore`: Atualização de versões (`versions.env`), dependências ou ponteiros de submódulos.
* `docs`: Alterações exclusivas em documentações (`docs/`, `README.md`).
* `ci`: Ajustes nos fluxos do GitHub Actions (`.github/workflows/`).
* `refactor`: Refatoração de scripts ou Dockerfiles sem alterar comportamento externo.
* `test`: Adição ou melhoria de rotinas em `scripts/test/`.

### Exemplos Válidos
```bash
git commit -m "feat(appserver): adicionar suporte ao modo sqlite localfiles"
git commit -m "fix(dbaccess): corrigir timeout na conexao inicial odbc"
git commit -m "chore: atualizar release para 12.1.2610 e alinhar dockerfiles"
git commit -m "docs: adicionar documentacao v3.0 em padrao diataxis"
```

> ⚠️ **Regra Inviolável:** **Nunca utilize `--no-verify`** para forçar um commit. Se o hook bloqueou, corrija a mensagem ou o código apontado.

---

## 🛡️ 4. O que o `pre-commit` valida antes de gravar o commit?

Ao rodar `git commit` (ou `make validate`), o hook `pre-commit` dispara automaticamente os seguintes testes em cascata:

1. **Consistência de Versões (`versions.sh`):**  
   Garante que os `LABEL`s nos `Dockerfiles`, os `services/*/versions.env` e as tags nos `docker-compose*.yaml` batam exatamente com o `versions.env` da raiz. Se houver divergência, execute:
   ```bash
   make fix
   # ou: ./scripts/validation/versions.sh --fix
   ```
2. **Análise Estática de Scripts Bash (`ShellCheck`):**  
   Varre os arquivos `.sh` para impedir erros de sintaxe ou variáveis mal interpoladas.
3. **Varredura de Segredos (`secrets.sh`):**  
   Verifica se arquivos em stage contêm senhas de produção, certificados SSL privados ou API keys reais.
4. **Validação de `.env.example` (`env.sh`):**  
   Verifica integridade das chaves de variáveis de ambiente documentadas.
5. **Análise de Dockerfiles (`Hadolint`):**  
   Verifica conformidade com as melhores práticas de imagens corporativas.
6. **Sintaxe dos Arquivos Docker Compose (`lint-compose.sh`):**  
   Valida se todos os `docker-compose*.yaml` são válidos.

---

## 🤝 5. Fluxo de Pull Request (PR)

1. Crie uma branch de trabalho a partir da release atual:
   ```bash
   git checkout -b feat/minha-melhoria
   ```
2. Faça as alterações, garantindo que `make validate` e os hooks passem 100% verdes localmente.
3. Submeta o Pull Request no GitHub apontando para a branch da release correspondente (ex: `12.1.2610`).
4. Acompanhe a esteira do GitHub Actions (`deploy.yml`). Seu PR só poderá ser mergeado após todos os checks (lints e smoke tests) passarem com sucesso.
