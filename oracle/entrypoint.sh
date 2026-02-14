#!/bin/bash
# entrypoint.sh

# Ativa modo de depuração se a variável DEBUG_SCRIPT estiver como true/1/yes
if [[ "${DEBUG_SCRIPT:-}" =~ ^(true|1|yes|y)$ ]]; then
    set -x
fi

# Garante que o script será encerrado em caso de erro
set -e

######################################################################
# SCRIPT:      entrypoint.sh
# DESCRIÇÃO:   Ponto de entrada do container Oracle.
#              Inicializa a estrutura de dados se necessário
#              e inicia o serviço Oracle.
# AUTOR:       Julian de Almeida Santos
# DATA:        2025-10-19
######################################################################

# ---------------------------------------------------------------------

## 🚀 VARIÁVEIS DE CONFIGURAÇÃO

  DB_DATA_DIR="/opt/oracle/oradata"
  DB_BACKUP_FILE="/tmp/data.tar.gz"
  RESTORE_BACKUP="${RESTORE_BACKUP:-Y}"
  RESTORE_BACKUP="N"

# ---------------------------------------------------------------------

## 🚀 INICIALIZAÇÃO DA ESTRUTURA DE DADOS DO BANCO

  echo ""
  echo "------------------------------------------------------"
  echo "💾 INICIALIZAÇÃO DA ESTRUTURA DE DADOS DO BANCO"
  echo "------------------------------------------------------"

  # Cria o diretório de dados se não existir
  mkdir -p "${DB_DATA_DIR}"
  echo "✅ Diretório de dados **${DB_DATA_DIR}** verificado/criado."

  # Verifica se o diretório de dados está vazio (primeira execução)
  if [ ! "$(ls -A "${DB_DATA_DIR}")" ]; then
    if [[ "${RESTORE_BACKUP}" =~ ^[SsYy]$ ]]; then
      echo "⚙️ Diretório de dados vazio. Iniciando extração dos arquivos base..."

      if [ -f "${DB_BACKUP_FILE}" ]; then
        tar -xzvf "${DB_BACKUP_FILE}" -C /
        echo "✅ Arquivos base extraídos com sucesso."

        rm -rfv "${DB_BACKUP_FILE}"
        echo "🗑️ Arquivo de backup temporário removido."
      else
        echo "⚠️ Arquivo de backup **${DB_BACKUP_FILE}** não encontrado. Iniciando com dados vazios."
      fi
    else
      echo "⏭️ Restauração de backup desabilitada (RESTORE_BACKUP=${RESTORE_BACKUP}). Iniciando com dados vazios."
    fi
  else
    echo "⏭️ Diretório de dados já contém arquivos. Pulando inicialização."
  fi

# ---------------------------------------------------------------------

## 🚀 INICIALIZAÇÃO DO SERVIÇO

  echo ""
  echo "------------------------------------------------------"
  echo "🚀 INICIALIZAÇÃO DO SERVIÇO ORACLE"
  echo "------------------------------------------------------"

  echo "🚀 Delegando execução para o entrypoint oficial do Oracle..."
  exec /opt/oracle/container-entrypoint.sh "$@"
