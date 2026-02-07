#!/usr/bin/env bash
set -euo pipefail

######################################################################
# SCRIPT:      entrypoint.sh
# DESCRIÇÃO:   Ponto de entrada do container TOTVS SmartView. 
#              Gerencia extração de recursos, inicialização do SmartView 
#              e monitoramento de logs.
# AUTOR:       Julian de Almeida Santos
# DATA:        2025-02-05
######################################################################

## 🚀 VARIÁVEIS DE CONFIGURAÇÃO

TOTVS_DIR="/totvs"
SMARTVIEW_DIR="${TOTVS_DIR}/smartview"
SMARTVIEW_FILE="${TOTVS_DIR}/smartview.tar.gz"
EXTRACT_RESOURCES="${EXTRACT_RESOURCES:-true}"

## 🚀 FUNÇÕES DE CONTROLE DO SMARTVIEW

start_smartview() {
  echo "🚀 Iniciando serviço TOTVS SmartView..."
  cd /totvs/smartview

  ./TReports.Agent --urls http://*:7019
}

stop_smartview() {
  echo "🛑 Finalizando serviço TOTVS SmartView..."
  pkill -f TReports.Agent || echo "ℹ️ Nenhum processo do SmartView encontrado."
}

## 🚀 FUNÇÃO PRINCIPAL DE EXECUÇÃO

main() {
  echo ""
  echo "------------------------------------------------------"
  echo "🚀 INÍCIO DA EXECUÇÃO PRINCIPAL"
  echo "------------------------------------------------------"
    
  start_smartview
}

## 🚀 EXTRAÇÃO DE RECURSOS

if [[ "$EXTRACT_RESOURCES" == "true" ]]; then

  echo ""
  echo "------------------------------------------------------"
  echo "🧩 EXTRAÇÃO DE RECURSOS"
  echo "------------------------------------------------------"
  echo "🧩 Iniciando extração de recursos para a aplicação..."

  cd "$TOTVS_DIR"

  if [[ -f "$SMARTVIEW_FILE" ]]; then
    echo "📦 Extraindo **smartview.tar.gz**..."
    mkdir -p "$SMARTVIEW_DIR"
    tar --keep-old-files -xzvf "$SMARTVIEW_FILE" -C "$TOTVS_DIR"
    rm -f "$SMARTVIEW_FILE"
  else
    echo "⚠️  Arquivo **smartview.tar.gz** não encontrado. Pulando extração."
  fi
  echo "✅ Recursos extraídos com sucesso!"
else
  echo "⏭️ Extração de recursos desabilitada. (EXTRACT_RESOURCES=false)"
  echo
fi

## 🚀 EXECUÇÃO FINAL

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
