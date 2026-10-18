# Guia Prático: Atualização de RPO e Fontes AdvPL/TLPP

Durante o desenvolvimento de rotinas em AdvPL ou TLPP, você **não precisa reconstruir a imagem Docker (`build.sh`)** toda vez que compilar um fonte. Existem três estratégias ágeis para injetar e testar códigos customizados.

---

## 🎯 1. Compreendendo a Estrutura de RPO no Container

O AppServer gerencia o repositório de objetos na pasta interna `/totvs/protheus/apo/`:
* `tttp120.rpo`: Repositório padrão fornecido pela TOTVS (Release 12.1.2610).
* `custom.rpo`: Repositório dedicado de customizações, carregado de forma prioritária sobre o padrão quando a variável `APPSERVER_RPO_CUSTOM=/totvs/protheus/apo/custom.rpo` estiver configurada no `.env`.

---

## 🚀 2. Métodos de Atualização de Fontes e RPO

### Método 1: Cópia Direta via Docker CLI (Mais Rápido para RPOs Prontos)
Se você já gerou um `custom.rpo` compilado em outra máquina ou via pipeline externa:

```bash
# 1. Copiar o RPO diretamente para dentro do container
docker cp ./custom.rpo totvs_appserver:/totvs/protheus/apo/custom.rpo

# 2. Reiniciar o serviço do AppServer para recarregar o repositório
docker restart totvs_appserver
```
*(Se estiver utilizando a stack com REST, repita a cópia para o container `totvs_apprest`).*

---

### Método 2: Bind Mount no Docker Compose (Ideal para Desenvolvimento Contínuo)
Você pode mapear uma pasta da sua máquina host diretamente para o diretório `/totvs/protheus/apo` do container.

1. No seu arquivo `docker-compose-*.yaml`, localize o serviço `appserver` e descomente/adicione o volume mapeado:
   ```yaml
   volumes:
     - ./meus_rpos:/totvs/protheus/apo
   ```
2. Coloque seu `tttp120.rpo` e `custom.rpo` na pasta local `./meus_rpos`.
3. Qualquer alteração no arquivo local será imediatamente refletida dentro do container. Basta reiniciar o AppServer:
   ```bash
   docker restart totvs_appserver
   ```

---

### Método 3: Compilação Direta via VS Code (TOTVS Developer Studio)
Você pode conectar o plugin **TOTVS TDS for VS Code** diretamente ao container Protheus:

1. No VS Code, abra o arquivo `servers.json` da extensão TDS e aponte para o container local:
   ```json
      {
         ...
         "type": "totvs_server_protheus",
         "name": "Protheus Docker Local",
         "address": "127.0.0.1",
         "port": 1234,
         "secure": false,
         ...
      }
   ```
2. Conecte-se com o usuário `admin` (senha em branco por padrão).
3. Compile seus fontes `.prw`, `.prx` ou `.tlpp` diretamente pelo atalho do VS Code. O TDS compilará o binário diretamente no RPO ativo no container.

---

## 🛑 3. Boas Práticas ao Atualizar Fontes

* **Evite compilar com usuários conectados:** Feche as sessões do SmartClient antes de aplicar compilações massivas para evitar erros de *RPO lock*.
* **Backup de RPO Customizado:** Sempre mantenha o código-fonte sob controle de versão (Git). O arquivo `.rpo` é um binário compilado efêmero.
