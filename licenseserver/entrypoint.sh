#! /bin/bash

######################################################################
# SCRIPT:      entrypoint.sh
# DESCRIÇÃO:   Ponto de entrada do container TOTVS License Server.
#              Configura o arquivo INI, aplica limites de sistema (ulimit)
#              e inicia o serviço.
# AUTOR:       Julian de Almeida Santos
# DATA:        2025-10-19
#
# VARIAVEIS DE AMBIENTE REQUERIDAS (usadas na configuração do INI):
# - LICENSE_TCP_PORT
# - LICENSE_CONSOLEFILE
# - LICENSE_PORT
# - LICENSE_WEBAPP_PORT
#
######################################################################

# ---------------------------------------------------------------------

## 🚀 VARIÁVEIS DE CONFIGURAÇÃO

  title="TOTVS License Server 3.6.2"
  prog="appsrvlinux"
  inifile="appserver.ini"
  pathbin="/totvs/licenseserver/bin/appserver"
  progbin="${pathbin}/${prog}"

#---------------------------------------------------------------------

## 🚀 FUNÇÕES AUXILIARES

	check_env_vars() {
		local var_name=$1
		if [[ -z "${!var_name}" ]]; then
			echo "⚠️ AVISO: A variável de ambiente **${var_name}** não está definida. Pode afetar a configuração do INI."
		else
			echo "✅ A variável de ambiente **${var_name}** configurada com sucesso."
		fi
	}

# ---------------------------------------------------------------------

## 🚀 INÍCIO DA VERIFICAÇÃO DE VARIÁVEIS DE AMBIENTE

  echo ""
  echo "------------------------------------------------------"
  echo "🚀 INÍCIO DA VERIFICAÇÃO DE VÁRIAVEIS DE AMBIENTE"
  echo "------------------------------------------------------"

  echo "🔎 Verificando váriaveis de ambiente requeridas para o INI..."

  check_env_vars "LICENSE_TCP_PORT"
  check_env_vars "LICENSE_CONSOLEFILE"
  check_env_vars "LICENSE_PORT"
  check_env_vars "LICENSE_WEBAPP_PORT"
  
  echo "✅ Todas as variáveis de ambiente requeridas verificadas com sucesso."

# ---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DE AMBIENTE

  echo ""
  echo "------------------------------------------------------"
  echo "🚀 CONFIGURAÇÃO DE AMBIENTE"
  echo "------------------------------------------------------"

  # Acessa o diretório do executável
  cd "${pathbin}"

  # Configura variável de ambiente para bibliotecas
  export LD_LIBRARY_PATH="${pathbin}:${LD_LIBRARY_PATH}"
  echo "✅ Variável LD_LIBRARY_PATH e diretório de execução configurados."

# ---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DE LIMITES (ULIMIT)

  echo ""
  echo "------------------------------------------------------"
  echo "🚀 INÍCIO DA CONFIGURAÇÃO DE LIMITES (ULIMIT)"
  echo "------------------------------------------------------"

  # Define limites de recursos do sistema
  openFiles=65536
  stackSize=1024
  coreFileSize=unlimited
  fileSize=unlimited
  cpuTime=unlimited
  virtualMemory=unlimited

  echo "⚙️ Aplicando limites de recursos (ulimit)..."
  ulimit -n ${openFiles}
  ulimit -s ${stackSize}
  ulimit -c ${coreFileSize}
  ulimit -f ${fileSize}
  ulimit -t ${cpuTime}
  ulimit -v ${virtualMemory}

  echo "✅ Limites aplicados com sucesso."

# ---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DO APPSERVER.INI

  echo ""
  echo "------------------------------------------------------"
  echo "🚀 INÍCIO DA CONFIGURAÇÃO DO APPSERVER.INI"
  echo "------------------------------------------------------"
  echo "⚙️ Aplicando substituições de variáveis..."

  # Atualiza appserver.ini com as variáveis de ambiente
  sed -i "s,LICENSE_TCP_PORT,${LICENSE_TCP_PORT}," "${inifile}"
  sed -i "s,LICENSE_CONSOLEFILE,${LICENSE_CONSOLEFILE}," "${inifile}"
  sed -i "s,LICENSE_PORT,${LICENSE_PORT}," "${inifile}"
  sed -i "s,LICENSE_WEBAPP_PORT,${LICENSE_WEBAPP_PORT}," "${inifile}"

  echo "✅ Variáveis substituídas no ${inifile}."

  # Imprime no console o conteúdo do arquivo appserver.ini
  echo ""
  echo "Configurações finais do arquivo INI:"
  echo ""
  cat "${inifile}"
  echo

# ---------------------------------------------------------------------

## 🚀 INICIALIZAÇÃO DO SERVIÇO

  echo ""
  echo "------------------------------------------------------"
  echo "🚀 INÍCIO DA INICIALIZAÇÃO DO SERVIÇO"
  echo "------------------------------------------------------"

  echo "🚀 Iniciando **${title}**..."
  # A linha 'exec' substitui o processo shell atual pelo License Server, mantendo o PID 1 no container.
  exec "${progbin}"