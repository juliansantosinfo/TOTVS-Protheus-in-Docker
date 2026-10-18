# Guia Prático: Sincronização de Branches e Releases

O ecossistema TOTVS Protheus in Docker mantém compatibilidade com múltiplas releases do ERP através de branches dedicadas (`12.1.2310`, `12.1.2410`, `12.1.2510` e a atual `12.1.2610`).

Este guia explica como gerenciar e alternar releases de forma segura em toda a malha de submódulos.

---

## 🧩 1. O Desafio dos Submódulos Git

Em projetos modulares, um simples `git checkout 12.1.2610` no repositório principal **não troca** as branches internas dentro de `services/appserver`, `services/dbaccess` ou `services/licenseserver`. Isso normalmente geraria o estado de "Detached HEAD" ou inconsistência de versões entre os serviços.

Para resolver isso de forma elegante, o projeto introduziu duas soluções automatizadas:
1. O utilitário **`branch-checkout.sh`**.
2. O hook Git automático **`post-checkout`**.

---

## ⚡ 2. Alternando Releases Manualmente (`branch-checkout.sh`)

Na raiz do repositório, execute o script indicando a versão alvo desejada:

```bash
# Alternar para a release oficial mais recente
./scripts/validation/branch-checkout.sh 12.1.2610

# Ou alternar para uma release anterior
./scripts/validation/branch-checkout.sh 12.1.2510
```

### O que o script realiza em lote:
1. Faz o checkout e pull da branch alvo no repositório principal (Root).
2. Itera recursivamente por cada subdiretório em `services/`.
3. Consulta a matriz de compatibilidade e faz o checkout da tag/branch correspondente daquele serviço.
4. Aplica `git pull --rebase` silenciosamente em cada componente.

---

## 🪝 3. Alternância Automática via Git Hook (`post-checkout`)

Se você instalou os hooks recomendados (`./scripts/hooks/install.sh`), não precisa nem mesmo executar o script manual!

Basta utilizar o comando padrão do Git:
```bash
git checkout 12.1.2610
```
O hook `post-checkout` interceptará a ação, identificará a nova branch e disparará automaticamente o `branch-checkout.sh` em segundo plano para alinhar todos os 7 microserviços.

---

## 📋 4. Matriz de Compatibilidade de Branches

| Release Root | `appserver` | `dbaccess` | `licenseserver` | `postgres` | `mssql` | `oracle` | `smartview` |
|---|---|---|---|---|---|---|---|
| **`12.1.2610` (Atual)** | `12.1.2610` | `v26.1.0.0` | `v3.7.2` | `v15` | `v2019` | `v21.3.0` | `v3.9.0.4558336` |
| **`12.1.2510`** | `12.1.2510` | `v24.1.1.0` | `v3.7.0` | `v15` | `v2019` | `v21.3.0` | `v3.9.0.4558336` |
| **`12.1.2410`** | `12.1.2410` | `v24.1.1.0` | `v3.7.0` | `v15` | `v2019` | `v21.3.0` | `v3.9.0.4558336` |
| **`12.1.2310`** | `12.1.2310` | `v23.1.1.7` | `v3.6.1` | `v15` | `v2019` | `v21.3.0` | `v3.9.0.4558336` |
| **`main` / `master`** | `main` | `main` | `main` | `main` | `main` | `main` | `main` |

---

## 🩺 5. Recuperando Estado Desalinhado (Detached HEAD)

Caso você tenha feito alterações manuais dentro de um submódulo e o Git informe `HEAD detached`:

```bash
# 1. Voltar à raiz do projeto
cd /caminho/do/projeto/TOTVS-Protheus-in-Docker

# 2. Forçar sincronização de todos os submódulos para a branch da release atual
./scripts/validation/branch-checkout.sh 12.1.2610
```
