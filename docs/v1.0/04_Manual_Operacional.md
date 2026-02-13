# 4. Manual Operacional

## 4.1. Gerenciamento Diário

### Iniciar e Parar o Ambiente
Não é necessário recriar os containers todos os dias. Você pode apenas pausar ou parar a execução para economizar recursos da máquina.

*   **Parar (Stop):** Mantém os containers criados, apenas desliga os processos.
    ```bash
    docker compose -p totvs stop
    ```
*   **Iniciar (Start):** Retoma a execução dos containers parados. É muito rápido.
    ```bash
    docker compose -p totvs start
    ```
*   **Derrubar (Down):** Para e **remove** os containers e redes. Use isso se quiser alterar configurações de porta ou variáveis de ambiente. **Nota:** Os dados nos *volumes* (banco de dados) são preservados.
    ```bash
    docker compose -p totvs down
    ```

### Monitoramento de Logs
Acompanhar os logs é essencial para diagnosticar erros de compilação, falhas de conexão ou erros de execução ADVPL.

*   **Ver logs de todos os serviços (stream):**
    ```bash
    docker compose -p totvs logs -f
    ```
*   **Ver logs de um serviço específico (ex: appserver):**
    ```bash
    docker compose -p totvs logs -f appserver
    ```
    *Dica:* O AppServer costuma ser o mais verborrágico. Fique atento a mensagens de "Server Ready" ou erros de "License Server Connection".

## 4.2. Acesso aos Serviços

### Mapeamento de Portas Padrão
| Serviço | Porta Interna | Porta Host (Localhost) | Descrição |
| :--- | :--- | :--- | :--- |
| **AppServer** | 24002 | 24002 | Interface Web (WebApp) / SmartClient HTML |
| **AppServer** | 24001 | 24001 | Interface TCP |
| **AppRest** | 24180 | 24180 | API REST |
| **DBAccess** | 7890 | 7890 | Monitor do DBAccess |
| **License** | 5555 | 5555 | Comunicação de Licença |
| **PostgreSQL**| 5432 | 5432 | Acesso SQL direto (DBeaver, pgAdmin) |
| **MSSQL** | 1433 | 1433 | Acesso SQL direto (SSMS) |

## 4.3. Manutenção de Dados (Backup e Restore)

### Backup do Banco (Dump)
Como os dados estão em volumes Docker, a melhor forma de fazer backup é usar as ferramentas nativas do banco através do `docker exec`.

**PostgreSQL:**
```bash
# Gera um arquivo dump.sql na pasta atual do host
docker exec -t totvs_postgres_1 pg_dumpall -c -U postgres > dump_$(date +%Y%m%d).sql
```

**MSSQL:**
É mais complexo pois envolve gerar o arquivo dentro do container e copiá-lo para fora.
```bash
# 1. Gerar backup dentro do container
docker exec totvs_mssql_1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "SuaSenha" -Q "BACKUP DATABASE protheus TO DISK = '/var/opt/mssql/data/protheus.bak'"
# 2. Copiar para o host
docker cp totvs_mssql_1:/var/opt/mssql/data/protheus.bak ./backup_protheus.bak
```

## 4.4. Atualização de Binários e RPO
O ciclo de vida do Protheus exige atualizações frequentes de binários e RPO (Repositório de Objetos).

### Atualizando o RPO (Patch Rápido)
Para atualizações pontuais (patches), você pode copiar o arquivo RPO diretamente para o container:
1.  **Via Docker CP (Sem rebuild):**
    ```bash
    # Copia o novo tttp120.rpo para dentro do container rodando
    docker cp ./tttp120.rpo totvs_appserver_1:/totvs/protheus/apo/tttp120.rpo
    # Reinicie o serviço para carregar o novo RPO
    docker restart totvs_appserver_1
    ```

### Atualizando Binários e RPO (Build Completo)
Para uma atualização completa ou alteração de binários, o processo utiliza arquivos compactados que são consumidos durante o build da imagem. Estes arquivos **não são versionados no Git** e devem ser disponibilizados manualmente no diretório `appserver/totvs/`.

1.  **Arquivos Necessários:**
    *   `appserver/totvs/protheus.tar.gz`: Contém o binário do AppServer compactado.
    *   `appserver/totvs/protheus_data.tar.gz`: Contém o diretório `protheus_data` compactado (incluindo XNU, dicionários, etc).
2.  **Executar o Build:**
    ```bash
    cd appserver
    ./build.sh
    ```
3.  **Atualizar o Container:**
    ```bash
    docker compose -p totvs up -d --build appserver
    ```
    *Nota:* O container está configurado para extrair esses arquivos automaticamente na inicialização caso a variável `EXTRACT_RESOURCES=true` esteja ativa no `.env`.

### Atualização via Volumes (Bind Mounts)
Caso prefira gerenciar os arquivos diretamente do sistema de arquivos do host, você pode utilizar *bind mounts*. Esta abordagem é útil para desenvolvedores que precisam alterar RPOs ou binários com frequência sem reconstruir a imagem.

Os volumes mapeados para o serviço `appserver` permitem manusear:
*   **`protheus_data`**: Dados do sistema (dicionários, arquivos de log, etc).
*   **`appserver_apo`**: Repositório de Objetos (RPO).
*   **`appserver_data`**: Binários do servidor de aplicação.

Ao utilizar bind mounts, qualquer alteração feita nas pastas locais refletirá imediatamente dentro do container (pode ser necessário reiniciar o serviço para que o Protheus carregue as mudanças nos binários ou RPO).

## 4.5. Limpeza de Ambiente
Para remover tudo e começar do zero (cuidado: apaga dados!):
```bash
# Remove containers e volumes (-v)
docker compose -p totvs down -v
# Remove imagens não utilizadas
docker system prune -f
```
Isso é útil quando o ambiente está corrompido ou você quer testar uma instalação limpa.
