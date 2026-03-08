# 6. Solução de Problemas (Troubleshooting v2.0)

A modularização e os scripts mestres trouxeram ordem ao ecossistema, mas criaram novas categorias de atenção, principalmente ligadas aos Git Submodules e permissões de execução massiva.

## 6.1. O "Vazio" dos Submódulos (Pasta Vazia)
**Sintoma:** Você clona o projeto e ao rodar o `./scripts/build/build.sh`, o script reclama que o `Dockerfile` de um serviço tipo "AppServer" não existe, e você nota que as pastas do projeto root parecem completamente vazias.
**Causa:** Esqueceu de clonar usando o sufixo `--recursive`. O Git baixou os metadados dos submódulos, mas não os arquivos físicos.
**Solução (Recuperação Rápida):**
Rode na raiz do maestro principal:
```bash
git submodule update --init --recursive
```
Com isso as pastas ganharão vida e o build orquestrado passará a funcionar.

## 6.2. Permissões Negadas (Execution Denied)
**Sintoma:** `./scripts/build/build.sh: permission denied`.
**Causa:** Por motivos de segurança ou pull de submodulos sem permissões Linux atreladas, os scripts `.sh` vieram com `chmod 644` (Só leitura).
**Solução (A Grande Liberação):**
Rode o comando de procura global do Linux que o próprio GitHub Actions utiliza em nossa CI:
```bash
find scripts/ -name "*.sh" -exec chmod +x {} +
find . -maxdepth 2 -name "*.sh" -exec chmod +x {} +
```

## 6.3. "Versions.env Desalinhado" (Error no Hook do Commit)
**Sintoma:** Você tenta commitar o código e leva crash instantâneo com um erro vermelho alertando sobre inconsistência de Label em Dockerfiles.
**Causa:** Alguém editou manualmente a tag de uma imagem no submódulo, burlando o arquivo mestre `.env` na raiz.
**Solução:**
1. Aborte o comitt. Rode a varinha restauradora: `./scripts/validation/versions.sh --fix`. (Ele fará override de qualquer besteira hardcoded que você escreveu no Dockerfile do microserviço devolvendo as chaves master).
2. Siga de novo com as ações adicionais no stage: `git add .`, para depois commitar.

## 6.4. Os Problemas Legados Persistem: "Operational Limits are Insufficient" (ulimit)
**Sintoma:** O AppServer falha dizendo que não acha licenças, files ou tem limited fd's (File Descriptors).
**Causa Linux/Native:** Um sistema Linux em Docker abre milhares de files por c-tree.
**Solução:**
Mesmo no ambiente avançado da v2, este requerimento SO é mandatório em sua máquina Local/Host nativa.
```bash
sudo sysctl -w fs.file-max=65535
```
*(Torne persistente salvando em /etc/sysctl.conf se não quiser bater com a cara no muro no próximo reinício físico da sua máquina).*

## 6.5. "Connection Refused" na Tela WebApp 1235
**Sintoma:** Interface web indisponível ou AppServer logando que não acha o DbAccess. Falta de Sincronia de Partida.
**Solução v2.0:** O *Fail Fast And Wait* embutido no Entrypoint do DbAccess garante que o ODBC não tente se ligar ao oracle ou pg caso a porta local *da máquina dbaccess* ainda esteja fora do ar. Espere 10 segundos, o container refará o "netcat" (TCP ping) até ter sucesso e iniciar a string de serviço. Nunca deslogue nas pressas. A validação `.dev/tcp` age para impedir este cenário. Dê Tail no log.

## 6.6. Como solicitar Suporte Oficial?
A V2 preza por rastreabilidade. Em caso de *bugs core*, antes de submeter uma "Issue" no Github da Root principal:
Exporte o log de build falho e a versão atrelada da infra:
`cat versions.env > report.txt`
`docker compose logs --tail=500 > bug_report.txt`

*(Este projeto é inteiramente Open Source, portanto seja meticuloso na descrição arquitetural para receber fix de pull requests de forma célere).*

---
**Fim da Seção - Documentação Oficial Versionamento e Infra**
