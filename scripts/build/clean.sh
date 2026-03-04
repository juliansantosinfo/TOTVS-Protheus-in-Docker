#!/bin/bash
#
# ==============================================================================
# SCRIPT: clean.sh
# DESCRIÇÃO: Remove arquivos e diretórios temporários gerados pelos módulos
#            do sistema (appserver, dbaccess, licenseserver, smartview, mssql, 
#            postgres, oracle).
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-16
# USO: ./scripts/build/clean.sh [modulo]
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
set -euo pipefail

# ----------------------------------------------------
#   SEÇÃO 1: DEFINICAO DE FUNCOES AUXILIARES
# ----------------------------------------------------

  print_success() {
      echo "✅ $1"
  }

  print_error() {
      echo "🚨 $1"
  }

  print_info() {
      echo "🧹 $1"
  }

  print_warning() {
      echo "⚠️ $1"
  }

  # Função para verificar se o diretório existe e é acessível
  verificar_diretorio() {
    local dir="$1"
    
    cd "$dir" || {
        print_error "Erro: não foi possível acessar o diretório: $dir"
        exit 1
    }
  }

  # Função para verificar se o script clean.sh existe
  verificar_script_clean() {
    local dir="$1"
    
    [[ -f ./clean.sh ]] || {
        print_error "Aviso: clean.sh não encontrado em $dir, pulando..."
        return 1
    }
    return 0
  }

  # Função para executar o script de limpeza
  executar_limpeza() {
    ./clean.sh
  }

  # Função para retornar ao diretório base
  retornar_diretorio_base() {
    cd .. || {
        print_error "Erro: não foi possível retornar ao diretório base do projeto"
        exit 1
    }
  }

  # Função para limpar um diretório específico
  limpar() {
    local dir="$1"
    
    verificar_diretorio "$dir"
    
    if verificar_script_clean "$dir"; then
      executar_limpeza
    fi
    
    retornar_diretorio_base
  }

# ----------------------------------------------------
#   SEÇÃO 1: DEFINICAO DE FUNCOES AUXILIARES
# ----------------------------------------------------

  echo "============================================="
  echo "🧼 Iniciando limpeza de arquivos temporários..."
  echo "============================================="
  echo ""

  # Se nenhum argumento for passado, limpar todos
  if [[ $# -eq 0 ]]; then
    for dir in appserver dbaccess licenseserver smartview mssql postgres oracle; do
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
