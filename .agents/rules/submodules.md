# Diretrizes para Gestão de Submódulos Git

O ecossistema TOTVS Protheus in Docker organiza o código de cada imagem e serviço como um submódulo Git independente dentro de `services/`:

- `services/appserver` -> `TOTVS-Protheus-in-Docker-AppServer`
- `services/dbaccess` -> `TOTVS-Protheus-in-Docker-DbAccess`
- `services/licenseserver` -> `TOTVS-Protheus-in-Docker-LicenseServer`
- `services/mssql` -> `TOTVS-Protheus-in-Docker-MSSQL`
- `services/oracle` -> `TOTVS-Protheus-in-Docker-ORACLE`
- `services/postgres` -> `TOTVS-Protheus-in-Docker-PostgreSQL`
- `services/smartview` -> `TOTVS-Protheus-in-Docker-Smartview`

---

## 1. Regra de Commits em Dois Estágios

Nunca tente atualizar o repositório principal sem antes fechar o ciclo de vida do submódulo modificado:

1. **Estágio 1 (No Submódulo)**:
   - Verifique o status com `git -C services/<servico> status`.
   - Certifique-se de que o submódulo está na branch correta (e não em estado detached `HEAD`).
   - Faça o commit e o push das alterações dentro do repositório do submódulo:
     ```bash
     cd services/<servico>
     git add .
     git commit -m "feat/fix/chore: descrição da alteração"
     git push origin <branch>
     cd ../..
     ```

2. **Estágio 2 (No Repositório Root)**:
   - O repositório root registrará a nova referência de commit do submódulo.
   - Faça o commit no root com o padrão:
     ```bash
     git add services/<servico>
     git commit -m "chore: atualizar commit do subprojeto <servico>"
     ```

---

## 2. Alinhamento de Branches entre Root e Submódulos

- Ao trocar a branch do root (ex: para uma release como `12.1.2510` ou `12.1.2610`), os submódulos devem ser apontados para as tags/branches compatíveis daquela release.
- Utilize sempre o script oficial de checkout para alinhar tudo de uma vez:
  ```bash
  ./scripts/validation/branch-checkout.sh <versao>
  ```
- O hook [`scripts/hooks/post-checkout.sh`](../../scripts/hooks/post-checkout.sh) executa automaticamente essa sincronização quando você faz `git checkout` para uma das branches mapeadas.

---

## 3. Cuidados Essenciais

- **Arquivos não rastreados em submódulos**: Binários ou pacotes descompactados em `services/*/packages/` ou `totvs/` geralmente estão protegidos por `.gitignore` de cada submódulo, mas sempre verifique com `git submodule foreach 'git status -s'` antes de comitar.
- **Evitar Submódulos Desatualizados**: Execute periodicamente `git submodule update --init --recursive` ao clonar ou resetar branches.
