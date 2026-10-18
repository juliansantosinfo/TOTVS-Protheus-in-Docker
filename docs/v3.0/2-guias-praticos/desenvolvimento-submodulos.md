# Guia Prático: Desenvolvimento e Manutenção em Submódulos

No modelo modular adotado a partir da v2.0 e consolidado na v3.0, os diretórios dentro de `services/` (`appserver`, `dbaccess`, `licenseserver`, `mssql`, `oracle`, `postgres`, `smartview`) são **submódulos Git**.

Cada um possui seu próprio histórico de commits, branches e repositório remoto independente no GitHub.

---

## ⚠️ 1. A Regra Fundamental dos Submódulos

> **REGRA DE OURO:**  
> **Nunca comite no repositório root alterações de um submódulo sem antes ter feito o commit e push dentro da pasta daquele submódulo.**  
> Se você atualizar o ponteiro no repositório root apontando para um commit local que não foi enviado ao GitHub remoto do submódulo, o GitHub Actions e outros desenvolvedores sofrerão falha fatal de `fatal: reference is not a tree`.

---

## 🛠️ 2. Ciclo de Vida de uma Alteração em um Serviço

Imagine que você precisou adicionar uma biblioteca no `Dockerfile` do `services/appserver`:

### Passo 1: Fazer a alteração dentro do submódulo
Navegue até a pasta do serviço:
```bash
cd services/appserver
```

Edite os arquivos necessários (`Dockerfile`, `entrypoint.sh`, etc.).

### Passo 2: Validar e commitar DENTRO do submódulo
```bash
# Verificar status local do serviço
git status

# Adicionar arquivos e commitar com mensagem convencional
git add Dockerfile entrypoint.sh
git commit -m "fix(appserver): adicionar dependência libgdiplus para relatórios"

# Enviar para o repositório remoto do submódulo
git push origin 12.1.2610
```

### Passo 3: Atualizar o ponteiro no Repositório Principal (Root)
Volte para a raiz do projeto:
```bash
cd ../..
```

Ao rodar `git status` na raiz, você verá que o Git indica:
```text
modified:   services/appserver (new commits)
```

Agora, comite a nova referência criptográfica no repositório principal:
```bash
git add services/appserver
git commit -m "chore: atualizar commit do subprojeto appserver"
git push origin 12.1.2610
```

---

## 🔄 3. Atualizando Submódulos para o Commit Mais Recente

Se outro membro da equipe enviou melhorias para o repositório remoto de um submódulo:

```bash
# Atualizar todos os submódulos para a ponta de suas respectivas branches
git submodule update --remote --merge
```

Ou atualizar apenas um componente específico:
```bash
git submodule update --remote services/dbaccess
```

---

## 🤖 4. Automação com Agentes de IA

Se você utiliza o Antigravity ou Gemini no desenvolvimento deste projeto, o repositório disponibiliza a skill especializada:
* **`submodule-sync`** (localizada em `.agents/skills/submodule-sync/`): Conduz automaticamente a verificação de integridade, inspeção de branches e commits de ponteiros entre root e serviços.
