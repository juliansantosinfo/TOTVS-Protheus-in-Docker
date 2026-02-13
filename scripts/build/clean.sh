#!/bin/bash
# ==============================================================================
#  Projeto:      Limpeza de Arquivos Temporários.
#  Script:       clean.sh
#  Descrição:    Remove arquivos e diretórios temporários gerados pelos módulos
#                do sistema (appserver, dbaccess, licenseserver, smartview, mssql, 
#                postgres).
#  Autor:        Julian de Almeida Santos
#  Data:         16/10/2025
#  Versão:       1.0
#  Uso:          ./clean.sh [diretório]
#                Se nenhum diretório for informado, todos serão limpos.
#  Diretórios:   appserver, dbaccess, licenseserver, smartview, mssql, postgres
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

# Função auxiliar para remover arquivos e diretórios com verificação
remove_item() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "🧹 Removendo: $path"
    rm -rf "$path"
  else
    echo "ℹ️  Ignorado (não existe): $path"
  fi
}

# Função para limpar um diretório específico
limpar() {
  local dir="$1"
  case "$dir" in
    appserver)
      remove_item "appserver/totvs/protheus.tar.gz"
      remove_item "appserver/totvs/protheus_data.tar.gz"
      ;;
    dbaccess)
      remove_item "dbaccess/totvs/dbaccess"
      ;;
    licenseserver)
      remove_item "licenseserver/totvs/licenseserver"
      ;;
    mssql)
      remove_item "mssql/resources"
      ;;
    postgres)
      remove_item "postgres/resources"
      ;;
    smartview)
      remove_item "smartview/totvs/smartview.tar.gz"
      ;;
    *)
      echo "❌ Erro: diretório inválido '$dir'. Use: appserver, dbaccess, licenseserver, smartview, mssql ou postgres."
      exit 1
      ;;
  esac
}

echo "============================================="
echo "🧼 Iniciando limpeza de arquivos temporários..."
echo "============================================="
echo ""

# Se nenhum argumento for passado, limpar todos
if [[ $# -eq 0 ]]; then
  for dir in appserver dbaccess licenseserver smartview mssql postgres; do
    echo "🔹 Limpando '$dir'..."
    limpar "$dir"
    echo ""
  done
else
  limpar "$1"
fi

echo ""
echo "✅ Limpeza concluída com sucesso!"
echo ""
