# Diretrizes de Commits e Git Hooks

O repositório adota automações de qualidade via Git Hooks e exige padronização rigorosa de histórico de commits.

## 1. Padrão Conventional Commits
Todas as mensagens de commit devem atender à expressão regular validada em `scripts/validation/commit-msg.sh`:
```text
^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .+$
```

### Tipos Permitidos e Quando Usar:
- **`feat`**: Implementação de nova funcionalidade (ex: novo perfil de serviço, novos argumentos de build, script de automação).
- **`fix`**: Correção de bug em scripts Bash, compose files, Dockerfiles ou entrypoints.
- **`chore`**: Bump de versões em `versions.env`, atualização de ponteiros de submódulos, tarefas de manutenção interna.
- **`ci`**: Alterações em fluxos de integração contínua (`.github/workflows/deploy.yml`, runners).
- **`docs`**: Criação ou atualização de documentação técnica em `docs/` ou `.agents/`.
- **`refactor`**: Refatoração de scripts ou estruturas sem alteração de comportamento externo.

### Exemplos Válidos:
```text
feat(appserver): adicionar suporte a profile sqlite em multi-instância
fix(dbaccess): corrigir timeout na checagem de conexão do postgres
chore(versions): atualizar appserver para 12.1.2610 e dbaccess para 26.1.0.0
ci(actions): configurar runner self-hosted para smoke tests
docs(v1.0): atualizar manual operacional para nova release
```

---

## 2. Git Hooks Ativos e Validações

O hook `pre-commit` executa a seguinte sequência obrigatória de testes locais antes de confirmar qualquer commit:

1. **`versions.sh`**: Valida se todas as labels nos Dockerfiles refletem `versions.env`.
2. **`lint-shell.sh`**: Executa ShellCheck se instalado. Scripts devem seguir boas práticas (`set -euo pipefail`).
3. **`secrets.sh`**: Escaneia arquivos em stage contra chaves privadas, tokens de API ou credenciais de produção.
4. **`env.sh`**: Assegura que `.env.example` está atualizado em paridade com qualquer nova variável suportada.
5. **`lint-dockerfile.sh`**: Executa Hadolint nos Dockerfiles da pasta `services/`.
6. **`lint-compose.sh`**: Valida a sintaxe e a interpolação de todos os arquivos `docker-compose*.yaml`.

---

## 3. Diretrizes de Segurança e Boas Práticas

- **Uso de `--no-verify`**: É terminantemente desaconselhado. Se o hook falhar, corrija a causa raiz. Só é tolerado se comprovado falso positivo de secrets em arquivos explicitamente documentados de exemplo.
- **Segurança de Credenciais**:
  - Nunca commite o arquivo `.env` com senhas reais.
  - Mantenha `.env` no `.gitignore`.
  - Utilize sempre a credencial padrão de teste `ProtheusDatabasePassword1` para documentação e ambientes locais de demonstração.
