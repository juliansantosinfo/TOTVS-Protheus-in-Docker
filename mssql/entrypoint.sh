#!/bin/bash
#
# ==============================================================================
# SCRIPT: entrypoint.sh
# DESCRIÇÃO: Ponto de entrada do container MSSQL. Inicializa a estrutura de 
#            dados do banco se necessário e inicia o serviço SQL Server.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-19
# USO: ./entrypoint.sh
# ==============================================================================

# Ativa modo de depuração se a variável DEBUG_SCRIPT estiver como true/1/yes
if [[ "${DEBUG_SCRIPT:-}" =~ ^(true|1|yes|y)$ ]]; then
    set -x
fi

# Garante que o script será encerrado em caso de erro
set -e

# ---------------------------------------------------------------------

## 🚀 VARIÁVEIS DE CONFIGURAÇÃO

  DB_DATA_DIR="/var/opt/mssql/data"
  DB_BACKUP_FILE="/tmp/data.tar.gz"
  DB_SERVICE="/opt/mssql/bin/sqlservr"

# ---------------------------------------------------------------------

## 🚀 INICIALIZAÇÃO DA ESTRUTURA DE DADOS DO BANCO

  echo ""
  echo "------------------------------------------------------"
  echo "💾 INICIALIZAÇÃO DA ESTRUTURA DE DADOS DO BANCO"
  echo "------------------------------------------------------"

  # Cria o diretório de dados se não existir (garantindo o ponto de montagem do volume)
  mkdir -p "${DB_DATA_DIR}"
  echo "✅ Diretório de dados **${DB_DATA_DIR}** verificado/criado."

  # Verifica se o diretório de dados está vazio (primeira execução com volume novo)
  if [ ! "$(ls -A "${DB_DATA_DIR}" 2>/dev/null)" ]; then
      if [[ "${RESTORE_BACKUP}" =~ ^[SsYy]$ ]]; then
          echo "⚙️ Diretório de dados vazio. Iniciando extração dos arquivos base..."

          if [ -f "${DB_BACKUP_FILE}" ]; then
            # Extrai para a raiz (esperado que o tar contenha o caminho var/opt/mssql/...)
            tar -xzvf "${DB_BACKUP_FILE}" -C /
            echo "✅ Arquivos base extraídos com sucesso."

            rm -f "${DB_BACKUP_FILE}"
            echo "🗑️ Arquivo de backup temporário removido."
          else
            echo "⚠️ Arquivo de backup **${DB_BACKUP_FILE}** não encontrado. Iniciando com dados vazios."
          fi
      else
          echo "⏭️ Restauração de backup desabilitada (RESTORE_BACKUP=${RESTORE_BACKUP})."
      fi
  else
    echo "⏭️ Diretório de dados já contém arquivos. Pulando inicialização."
  fi

# ---------------------------------------------------------------------

## 🚀 INICIALIZAÇÃO DO SERVIÇO MSSQL

  echo ""
  echo "------------------------------------------------------"
  echo "🚀 INICIALIZAÇÃO DO SERVIÇO MSSQL"
  echo "------------------------------------------------------"

  echo "🚀 Iniciando o serviço SQL Server..."
  # A linha 'exec' é usada para iniciar o serviço e manter o PID 1 no container.
  exec "${DB_SERVICE}"
