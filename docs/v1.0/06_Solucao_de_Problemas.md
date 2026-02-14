# 6. Solução de Problemas (Troubleshooting)

## 6.1. Diagnóstico Básico
Antes de qualquer ação complexa, verifique os "sinais vitais":

1.  **Os containers estão rodando?**
    `docker compose -p totvs ps`
    *Se `Exit 1` ou `Exit 137`*: O container morreu. Veja os logs.

2.  **O que os logs dizem?**
    `docker compose -p totvs logs --tail=100 appserver`
    *Procure por:* "Connection refused", "File not found", "License limit exceeded".
    *No DBAccess, observe se ele está em loop de espera:* "Banco ainda não responde. Aguardando 2s...". Isso indica que a porta do banco não está acessível na rede Docker.

### Ativando Modo de Depuração (Verbose)
Se você estiver enfrentando problemas misteriosos na inicialização do DBAccess, pode ativar o modo de depuração para ver exatamente quais comandos estão sendo executados.
**Solução:**
Defina a variável `DEBUG_SCRIPT=true` no seu arquivo `.env` ou `docker-compose.yaml`. Isso ativará o `set -x` nos scripts de inicialização, imprimindo cada comando executado no log do container.

## 6.2. Problemas Comuns e Soluções

### Erro: "Operational Limits are Insufficient" (ulimit)
**Sintoma:** O AppServer falha ao iniciar com uma mensagem gritante sobre limites operacionais.
**Causa:** O Protheus abre milhares de arquivos simultâneos. O limite padrão do Linux (1024) é muito baixo.
**Solução:**
O projeto já define limites adequados na seção `ulimits` dos arquivos `docker-compose-*.yaml`. No entanto, se o erro persistir, você deve aumentar o limite no host (sua máquina Linux/WSL):
```bash
sudo sysctl -w fs.file-max=65535
```
Adicione também ao `/etc/sysctl.conf` para persistir.

### Erro: "Connection Refused" entre AppServer e DBAccess
**Sintoma:** AppServer loga erro dizendo que não consegue conectar no DBAccess na porta 7890.
**Causa:** O DBAccess demora mais para subir que o AppServer.
**Solução:**
O `docker-compose` já possui `healthchecks` configurados para tentar mitigar isso (o AppServer espera o DBAccess ficar "Healthy").
Se persistir, verifique se o DBAccess subiu corretamente (veja logs do `dbaccess`). Pode ser erro de conexão do DBAccess com o Banco de Dados (senha errada?).

### Erro: Banco de Dados não conecta (Senha Incorreta)
**Sintoma:** DBAccess loga "Login failed for user 'sa'".
**Causa:** A senha definida no `.env` não bate com a senha que o banco de dados foi inicializado.
**Solução:**
Se você mudou a senha no `.env` **depois** de ter criado o container do banco pela primeira vez, o banco **não** muda a senha automaticamente.
Você precisa deletar o volume do banco para que ele seja recriado com a nova senha:
```bash
docker compose -p totvs down -v  # ATENÇÃO: APAGA DADOS
docker compose -p totvs up -d
```

### Performance Lenta no Windows (WSL 2)
**Sintoma:** O sistema demora muito para compilar ou abrir telas.
**Causa:** Os arquivos do Protheus estão no sistema de arquivos do Windows (`/mnt/c/...`) e sendo acessados pelo Docker no Linux. O "cross-os file system" é lento.
**Solução:**
Mova o projeto inteiramente para dentro do sistema de arquivos do Linux do WSL (`/home/seu_usuario/...`). **Nunca** rode projetos Docker de IO intenso a partir de `/mnt/c/`.

### Problemas de Licença (License Server)
**Sintoma:** "License Server connection failure".
**Solução:**
Verifique se o container `licenseserver` está de pé.
Confira se as portas 5555 e 2234 estão abertas.
Em desenvolvimento, certifique-se de que o AppServer está configurado para usar o License Server local (`localhost` ou nome do serviço `licenseserver`) e não um IP de produção inalcançável.

## 6.3. Como pedir ajuda?
Se encontrar um bug no projeto `TOTVS-Protheus-in-Docker`:
1.  Colete os logs: `docker compose logs > logs_erro.txt`.
2.  Descreva o cenário (SO, Versão do Docker, passos para reproduzir).
3.  Abra uma **Issue** no repositório GitHub oficial.

---
**Fim da Documentação - Versão 1.0**
