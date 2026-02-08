#!/bin/bash
# entrypoint.sh

# Garante que o script será encerrado em caso de erro
set -e

######################################################################
# SCRIPT:      entrypoint.sh
# DESCRIÇÃO:   Ponto de entrada do container PostgreSQL.
#              Configurações de localização (locale), inicialização 
#              da estrutura de dados do banco e delega para o 
#              entrypoint oficial do PostgreSQL.
# AUTOR:       Julian de Almeida Santos
# DATA:        2025-10-19
#
######################################################################

# ---------------------------------------------------------------------

## 🚀 VARIÁVEIS DE CONFIGURAÇÃO

  DB_DATA_DIR="/var/lib/postgresql/data"
  DB_BACKUP_FILE="/tmp/data.tar.gz"
  RESTORE_BACKUP="${RESTORE_BACKUP:-Y}"

# ---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DE LOCALIZAÇÃO (LOCALE)

  echo ""
  echo "------------------------------------------------------"
  echo "🌐 CONFIGURAÇÃO DE LOCALIZAÇÃO (LOCALE)"
  echo "------------------------------------------------------"

  echo "⚙️ Configurando locale pt_BR para CP1252 e ISO-8859-1..."
  localedef -i pt_BR -f CP1252 pt_BR.cp1252
  localedef -i pt_BR -f ISO-8859-1 pt_BR.ISO-8859-1
  echo "✅ Locales configurados."

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

## 🚀 INICIALIZAÇÃO DO SERVIÇO (ENTRYPOINT OFICIAL)

  echo ""
  echo "------------------------------------------------------"
  echo "🚀 INICIALIZAÇÃO DO SERVIÇO (VIA ENTRYPOINT OFICIAL)"
  echo "------------------------------------------------------"

  echo "🚀 Delegando execução para o entrypoint oficial do PostgreSQL..."
  # Chama o entrypoint original do PostgreSQL, mantendo o PID 1 no container.
  exec docker-entrypoint.sh "$@"