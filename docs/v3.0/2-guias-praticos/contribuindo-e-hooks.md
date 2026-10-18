# Guia Prático: Contribuição, Linters e Git Hooks

Para manter a qualidade corporativa do código, consistência de versões e segurança contra vazamento de segredos, o projeto adota uma rigorosa política de governança de código e Git Hooks locais.

---

## 🪝 1. Instalando os Git Hooks Locais

Após clonar o repositório, o primeiro comando a ser executado na máquina de desenvolvimento é:

```bash
./scripts/hooks/install.sh
```

Esse script instala em `.git/hooks/` os gatilhos que executarão checagens automáticas em cada ação do Git.

---

## 📝 2. Padrão de Mensagens de Commit (Conventional Commits)

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

## 🛡️ 3. O que o `pre-commit` valida antes de gravar o commit?

Ao rodar `git commit`, o hook `pre-commit` dispara automaticamente os seguintes testes em cascata:

1. **Varredura de Segredos (`secrets.sh`):**  
   Verifica se arquivos em stage contêm senhas de produção, certificados SSL privados ou API keys reais.
2. **Consistência de Versões (`versions.sh`):**  
   Garante que os `LABEL version=*` nos `Dockerfiles` dos submódulos batam exatamente com o `versions.env`. Se houver divergência, execute:
   ```bash
   ./scripts/validation/versions.sh --fix
   ```
3. **Análise Estática de Scripts Bash (`ShellCheck`):**  
   Varre os arquivos `.sh` alterados para impedir erros de sintaxe ou variáveis mal interpoladas.
4. **Análise de Dockerfiles (`Hadolint`):**  
   Verifica conformidade com as melhores práticas de imagens corporativas.
5. **Sintaxe dos Arquivos Docker Compose:**  
   Valida se todos os `docker-compose-*.yaml` são válidos.

---

## 🤝 4. Fluxo de Pull Request (PR)

1. Crie uma branch de trabalho a partir da release atual:
   ```bash
   git checkout -b feat/minha-melhoria
   ```
2. Faça as alterações, garantindo que os hooks passem 100% verdes localmente.
3. Submeta o Pull Request no GitHub apontando para a branch da release correspondente (ex: `12.1.2610`).
4. Acompanhe a esteira do GitHub Actions (`deploy.yml`). Seu PR só poderá ser mergeado após todos os checks (lints e smoke tests) passarem com sucesso.
