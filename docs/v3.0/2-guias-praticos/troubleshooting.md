# Guia Prático: Solução de Problemas (Troubleshooting)

Este guia consolida os diagnósticos e soluções definitivas para os problemas e erros operacionais mais frequentes no ecossistema TOTVS Protheus in Docker.

---

## 🛑 1. Erro de Ulimit: `OPERATIONAL LIMITS ARE INSUFFICIENT`

### Sintoma
O container do `appserver` falha na inicialização com a seguinte mensagem no log:
```text
[ERROR][SERVER] OPERATIONAL LIMITS ARE INSUFFICIENT, CHECK THE INSTALLATION PROCEDURES AS WELL AS 'ULIMIT' CONFIGURATION.
```

### Causa
O Protheus em arquitetura Linux gerencia milhares de descritores de arquivos simultâneos (tabelas e índices c-tree). Se o limite do kernel na máquina host estiver desajustado, o binário aborta a execução por segurança.

### Solução Definitiva
Execute na máquina hospedeira (Host Linux ou dentro do terminal WSL2):
```bash
# 1. Ajuste temporário imediato
sudo sysctl -w fs.file-max=65535

# 2. Torne a alteração permanente adicionando ao sysctl.conf
echo "fs.file-max = 65535" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```
Após o ajuste, reinicie a stack do compose.

---

## 🛑 2. Tela Web Indisponível ou `Connection Refused`

### Sintoma
O navegador não abre o SmartClient Web em `http://localhost:1235` ou o log do AppServer acusa falha de comunicação com o DBAccess.

### Causa
Ordem de partida a frio. O banco de dados ou o License Server ainda estão realizando inicializações internas (como restauração do `.bak` ou criação de índices), e o DBAccess aguarda a liberação das portas.

### Solução
1. Verifique os logs do DBAccess para confirmar a conexão com o banco:
   ```bash
   docker compose logs --tail=100 -f dbaccess
   ```
2. O entrypoint do DBAccess possui um algoritmo de resiliência ativo que repete pings TCP via Netcat:
   * Se seu disco for mais lento, aumente as variáveis no `.env`:
     ```env
     DATABASE_WAIT_RETRIES=60
     DATABASE_WAIT_INTERVAL=3
     ```
3. Aguarde cerca de 1 a 2 minutos na primeira subida para que a mensagem `Server Ready` apareça no log do AppServer.

---

## 🛑 3. Submódulos Vazios / `Dockerfile not found` no Build

### Sintoma
Ao tentar executar `./scripts/build/build.sh`, o script reclama que o `Dockerfile` de um serviço em `services/` não existe.

### Causa
O repositório foi clonado sem o parâmetro `--recursive`.

### Solução
Execute na raiz do projeto:
```bash
git submodule update --init --recursive
```

---

## 🛑 4. Erro de Permissão ao Executar Scripts (`Permission Denied`)

### Sintoma
Ao executar `./scripts/build/build.sh` ou `./run.sh`, o terminal retorna:
```text
bash: ./scripts/build/build.sh: Permission denied
```

### Solução
Restaure as permissões de execução dos scripts `.sh`:
```bash
find scripts/ services/ -name "*.sh" -exec chmod +x {} +
chmod +x run.sh
```

---

## 🛑 5. Falha no Git Hook: "Versions.env Desalinhado"

### Sintoma
Ao tentar realizar um commit, o hook rejeita com mensagem vermelha informando discrepância entre o `versions.env` e as labels dos Dockerfiles.

### Solução
Execute a ferramenta automática de alinhamento:
```bash
# Corrige automaticamente todos os Dockerfiles
./scripts/validation/versions.sh --fix

# Readicione os arquivos corrigidos ao stage e comite novamente
git add .
git commit -m "chore: sincronizar versoes dos dockerfiles"
```

---

## 🛑 6. Conflito de Portas no Host: `bind: address already in use`

### Sintoma
O Docker Compose falha ao subir o container do banco de dados (ex: porta `1433` ou `5432` já em uso).

### Causa
A máquina hospedeira já possui uma instância local nativa de SQL Server ou PostgreSQL rodando como serviço de sistema.

### Solução
1. Descubra qual processo está escutando na porta:
   ```bash
   sudo lsof -i :1433  # ou :5432
   ```
2. Caso não queira desativar o serviço nativo, altere a porta exposta no arquivo `docker-compose-*.yaml`:
   ```yaml
   ports:
     - "15432:5432" # Altera a porta externa no host para 15432
   ```

---

## 📋 7. Como Coletar Logs para Abrir uma Issue no GitHub

Se você encontrou um comportamento inesperado ou bug no projeto, exporte um relatório completo antes de abrir uma Issue:

```bash
# 1. Exportar versoes ativas
cat versions.env > report.txt

# 2. Coletar ultimas 300 linhas de logs de todos os containers
echo "--- LOGS DOCKER ---" >> report.txt
docker compose logs --tail=300 >> report.txt

# 3. Anexar o arquivo report.txt na Issue do GitHub
```
