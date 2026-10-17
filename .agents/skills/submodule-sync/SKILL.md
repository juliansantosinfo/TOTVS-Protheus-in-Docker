---
name: submodule-sync
description: Use when checking out release branches across submodules, updating Git submodule commit references, inspecting uncommitted changes in services, or committing submodule updates.
---

# Gestão e Sincronização de Submódulos Git

## Visão Geral
Gerencia o alinhamento de branches, inspeção de status e fluxo de commits em dois estágios para os 7 submódulos Git localizados em `services/`.

## Quando Usar
- Ao alternar entre branches de releases (ex: `12.1.2510` para `12.1.2610`).
- Ao verificar se há alterações pendentes nos submódulos (`git submodule foreach`).
- Ao atualizar o ponteiro de commit de um ou mais submódulos no repositório root.
- Quando o hook `post-checkout` não conseguir sincronizar os submódulos automaticamente.

**Quando NÃO usar:**
- Para builds Docker sem envolvimento de commit/branch Git (utilize a skill `docker-build-test`).

---

## Comandos Rápidos

| Operação | Comando |
|---|---|
| Status de todos os submódulos | `git submodule foreach 'git status -s'` |
| Branches ativas dos submódulos | `git submodule foreach 'git branch --show-current'` |
| Trocar branch de todos os submódulos | `./scripts/validation/branch-checkout.sh <versao>` |
| Atualizar submódulos para os commits registrados | `git submodule update --init --recursive` |
| Trazer atualizações remotas | `git submodule foreach 'git pull origin $(git branch --show-current)'` |

---

## Fluxo de Trabalho (Commits em 2 Estágios)

### Cenário: Você modificou arquivos dentro de um submódulo (ex: `services/appserver`)

#### Passo 1: Commitar e Enviar no Submódulo
```bash
# 1. Acesse o submódulo ou use a flag -C
cd services/appserver

# 2. Verifique status e branch
git status
# Certifique-se de NÃO estar em 'HEAD detached'

# 3. Adicione e faça o commit convencional
git add .
git commit -m "fix/feat/chore(appserver): descrição da melhoria"

# 4. Envie para o repositório remoto do submódulo
git push origin <branch_atual>

# 5. Retorne ao diretório raiz
cd ../..
```

#### Passo 2: Atualizar o Ponteiro no Repositório Root
No root do projeto, o Git indicará que o submódulo aponta para um novo commit hash:
```bash
# 1. Verifique a alteração no root
git status
# Saída esperada: modified: services/appserver

# 2. Adicione apenas o submódulo
git add services/appserver

# 3. Faça o commit convencional no root
git commit -m "chore: atualizar commit do subprojeto appserver"

# 4. Envie o commit do root
git push origin <branch_root>
```

---

## Cuidados e Boas Práticas
- **Nunca force commits no root com submódulo sujo**: Sempre garanta que `git -C services/<app> status` esteja limpo antes de commitar o ponteiro no root.
- **Evite Detached HEAD**: Se o submódulo estiver em detached HEAD, crie ou mude para a branch correta antes de fazer alterações (`git checkout <branch>`).
