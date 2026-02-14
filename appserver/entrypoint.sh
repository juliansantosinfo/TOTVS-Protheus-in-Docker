#!/usr/bin/env bash

# Ativa modo de depuração se a variável DEBUG_SCRIPT estiver como true/1/yes
if [[ "${DEBUG_SCRIPT:-}" =~ ^(true|1|yes|y)$ ]]; then
    set -x
fi

# set -euo pipefail

######################################################################
# SCRIPT:      entrypoint.sh
# DESCRIÇÃO:   Ponto de entrada do container TOTVS AppServer. 
#              Gerencia extração de recursos, inicialização do AppServer 
#              e do servidor web de gerenciamento, e monitoramento de logs.
# AUTOR:       Julian de Almeida Santos
# DATA:        2025-10-19
#
######################################################################

# ---------------------------------------------------------------------

## 🚀 VARIÁVEIS DE CONFIGURAÇÃO

APPSERVER_MANAGER="/service.sh"
HTTPSERVER_MANAGER="/totvs/http/server.py"
APPSERVER_MODE="${APPSERVER_MODE:-application}"
APPSERVER_CONSOLEFILE="${APPSERVER_CONSOLEFILE:-/totvs/protheus/bin/appserver/console.log}"

EXTRACT_RESOURCES="${EXTRACT_RESOURCES:-false}"
TOTVS_DIR="/totvs"
PROTHEUS_FILE="${TOTVS_DIR}/protheus.tar.gz"
PROTHEUS_DATA_FILE="${TOTVS_DIR}/protheus_data.tar.gz"
RESOURCES_DIR="${TOTVS_DIR}/resources"

# ---------------------------------------------------------------------

## 🚀 FUNÇÕES DE CONTROLE DO APPSERVER

  start_appserver() {
    echo "🚀 Iniciando serviço TOTVS AppServer..."
    "${APPSERVER_MANAGER}" start
  }

  stop_appserver() {
    echo "🛑 Finalizando serviço TOTVS AppServer..."
    "${APPSERVER_MANAGER}" stop
  }

# ---------------------------------------------------------------------

## 🚀 FUNÇÕES DE CONTROLE DO SERVIDOR WEB

  start_webserver() {
    echo "🌐 Iniciando servidor web para gerenciamento do AppServer..."
    nohup python3 "${HTTPSERVER_MANAGER}" > /dev/null 2>&1 &
    echo "✅ Servidor web iniciado em segundo plano."
  }

  stop_webserver() {
    echo "🛑 Finalizando servidor web..."
    pkill -f "${HTTPSERVER_MANAGER}" || echo "ℹ️ Nenhum processo do servidor web encontrado."
    echo "✅ Servidor web finalizado."
  }

# ---------------------------------------------------------------------

## 🚀 FUNÇÃO PRINCIPAL DE EXECUÇÃO

  main() {
    echo ""
    echo "------------------------------------------------------"
    echo "🚀 INÍCIO DA EXECUÇÃO PRINCIPAL"
    echo "------------------------------------------------------"
      
    start_appserver
    start_webserver

    echo
    echo "📜 Monitorando logs em tempo real:"
    echo "-----------------------------------"
    # Cria o arquivo de log se ele não existir
    touch "${APPSERVER_CONSOLEFILE}"
    # Monitora o log, mantendo o PID 1 vivo (necessário para o Docker)
    tail -n 200 -f "${APPSERVER_CONSOLEFILE}"
  }

# ---------------------------------------------------------------------

## 🚀 EXTRAÇÃO DE RECURSOS

if [[ "$EXTRACT_RESOURCES" == "true" ]]; then

  echo ""
  echo "------------------------------------------------------"
  echo "🧩 EXTRAÇÃO DE RECURSOS"
  echo "------------------------------------------------------"
  echo "🧩 Iniciando extração de recursos para a aplicação..."

  cd "$TOTVS_DIR"

  # --- Protheus (protheus.tar.gz) ---
  if [[ -f "$PROTHEUS_FILE" ]]; then
    echo "📦 Extraindo **protheus.tar.gz**..."
    tar --keep-old-files -xzf "$PROTHEUS_FILE" -C "$TOTVS_DIR"
    rm -f "$PROTHEUS_FILE"
  else
        echo "⚠️  Arquivo **protheus.tar.gz** não encontrado. Pulando extração."
  fi

  # --- Protheus_data (protheus_data.tar.gz) ---
  if [[ -f "$PROTHEUS_DATA_FILE" ]]; then
    echo "📦 Extraindo **protheus_data.tar.gz**..."
    tar --keep-old-files -xzf "$PROTHEUS_DATA_FILE" -C "$TOTVS_DIR"
    rm -f "$PROTHEUS_DATA_FILE"
  else
    echo "⚠️  Arquivo **protheus_data.tar.gz** não encontrado. Pulando extração."
  fi

  # --- appserver.ini ---
  local_ini="/totvs/protheus/bin/appserver/appserver.ini"
  if [[ ! -s "$local_ini" ]]; then
    echo "📝 Verificando e copiando **appserver.ini** padrão..."
    mkdir -p "$(dirname "$local_ini")"
    case "$APPSERVER_MODE" in
      application)
        echo "⚙️  Modo: **'$APPSERVER_MODE'** — Aplicando configuração padrão: appserver.ini"
        cp -f "$RESOURCES_DIR/appserver.ini" "$local_ini"
        ;;
      rest)
        echo "⚙️  Modo: **'$APPSERVER_MODE'** — Aplicando configuração padrão: appserver_rest.ini"
        cp -f "$RESOURCES_DIR/appserver_rest.ini" "$local_ini"
        ;;
      sqlite)
        echo "⚙️  Modo: **'$APPSERVER_MODE'** — Aplicando configuração padrão: appserver_sqlite.ini"
        cp -f "$RESOURCES_DIR/appserver_sqlite.ini" "$local_ini"
        ;;
      *)
        echo "❗  Modo desconhecido: **'$APPSERVER_MODE'**. Aplicando configuração padrão genérica."
        cp -f "$RESOURCES_DIR/appserver.ini" "$local_ini"
        ;;
    esac
  else
    echo "⚙️  Modo: **'$APPSERVER_MODE'**"
    echo "📝 Utilizando **appserver.ini** pré-existente (volume-mounted)."
  fi

  echo "✅ Recursos extraídos com sucesso!"
else
  echo "⏭️ Extração de recursos desabilitada. (EXTRACT_RESOURCES=false)"
  echo
fi

# ---------------------------------------------------------------------

## 🚀 EXECUÇÃO FINAL

# Este bloco garante que a função 'main' seja executada apenas se o script for 
# executado diretamente, e não se for 'sourced'.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi