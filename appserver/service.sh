#!/bin/bash

######################################################################
# SCRIPT:      service.sh
# DESCRIÇÃO:   Inicia, para ou reinicia o serviço TOTVS Protheus (AppServer).
# AUTOR:       Julian de Almeida Santos
# DATA:        2025-10-19
#
# VARIAVEIS DE AMBIENTE: O AppServer usa diversas variáveis de ambiente
#                       que são passadas para o arquivo appserver.ini.
#
######################################################################

# Define variáveis de controle de fluxo
start=false
stop=false
restart=false

# Analisa os argumentos da linha de comando
while [[ $# -gt 0 ]]; do
  case "$1" in
    start)
      start=true
      shift
      ;;
    stop)
      stop=true
      shift
      ;;
    restart)
      restart=true
      shift
      ;;
    *)
      echo "Comando inválido: $1" >&2
      exit 1
      ;;
  esac
done

# Define informações do serviço
service_name="TOTVS Protheus"
executable="appsrvlinux"
ini_file="appserver.ini"
bin_path="/totvs/protheus/bin/appserver"
executable_path="${bin_path}/${executable}"
ini_file_path="${bin_path}/${ini_file}"

#---------------------------------------------------------------------

## 🚀 FUNÇÕES AUXILIARES

	# Define a função de tratamento de erro para variáveis de ambiente (adaptada para este script)
	# Nota: O AppServer não exige todas as variáveis para iniciar, mas são usadas na configuração do INI.
	check_env_vars() {
		local var_name=$1
		if [[ -z "${!var_name}" ]]; then
			echo "⚠️ AVISO: A variável de ambiente **${var_name}** não está definida. Pode afetar a configuração do INI."
		else
			echo "✅ A variável de ambiente **${var_name}** configurada com sucesso."
		fi
	}

	# Função para iniciar o serviço
	start_service() {
		if ! pgrep -x "${executable}" > /dev/null; then
			echo "Iniciando ${service_name}..."
			"${executable_path}" &
			echo "${service_name} iniciado."
		else
			echo "${service_name} já está em execução."
		fi
	}

	# Função para parar o serviço
	stop_service() {
		if pgrep -x "${executable}" > /dev/null; then
			echo "Parando ${service_name}..."
			pkill -f "${executable}"
			while pgrep -x "${executable}" > /dev/null; do
			sleep 1
			done
			echo "${service_name} parado."
		else
			echo "${service_name} não está em execução."
		fi
	}

	# Função para reiniciar o serviço
	restart_service() {
		stop_service
		start_service
	}

#---------------------------------------------------------------------

## 🚀 INÍCIO DA VERIFICAÇÃO DE VARIÁVEIS DE AMBIENTE

	echo ""
	echo "------------------------------------------------------"
	echo "🚀 INÍCIO DA VERIFICAÇÃO DE VÁRIAVEIS DE AMBIENTE"
	echo "------------------------------------------------------"

	echo "🔎 Verificando váriaveis de ambiente que serão usadas no INI..."

	# Verifica as principais variáveis que serão substituídas no INI
	check_env_vars "APPSERVER_RPO_CUSTOM"
	check_env_vars "APPSERVER_DBACCESS_DATABASE"
	check_env_vars "APPSERVER_DBACCESS_SERVER"
	check_env_vars "APPSERVER_DBACCESS_PORT"
	check_env_vars "APPSERVER_DBACCESS_ALIAS"
	check_env_vars "APPSERVER_CONSOLEFILE"
	check_env_vars "APPSERVER_MULTIPROTOCOLPORTSECURE"
	check_env_vars "APPSERVER_MULTIPROTOCOLPORT"
	check_env_vars "APPSERVER_LICENSE_SERVER"
	check_env_vars "APPSERVER_LICENSE_PORT"
	check_env_vars "APPSERVER_PORT"
	check_env_vars "APPSERVER_WEB_PORT"
	check_env_vars "APPSERVER_REST_PORT"
	check_env_vars "APPSERVER_WEB_MANAGER"
	check_env_vars "APPSERVER_ENVIRONMENT_LOCALFILES"
	check_env_vars "APPSERVER_SQLITE_SERVER"
	check_env_vars "APPSERVER_SQLITE_PORT"
	check_env_vars "APPSERVER_SQLITE_INSTANCES"

	echo "✅ Verificação de variáveis concluída."

#---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DE AMBIENTE E ULIMIT

	echo ""
	echo "------------------------------------------------------"
	echo "🚀 CONFIGURAÇÃO DE AMBIENTE E ULIMIT"
	echo "------------------------------------------------------"

	# Acessa o diretório do arquivo INI
	cd "${bin_path}"

	# Configura variável de ambiente para bibliotecas
	export LD_LIBRARY_PATH="${bin_path}:${LD_LIBRARY_PATH}"
	echo "✅ Variável LD_LIBRARY_PATH configurada."

	echo "⚙️ Aplicando limites de recursos (ulimit)..."
	ulimit -n 65536   # open files
	ulimit -s 1024    # stack size (kbytes)
	ulimit -c unlimited # core file size (blocks)
	ulimit -f unlimited # file size (blocks)
	ulimit -t unlimited # cpu time (seconds)
	ulimit -v unlimited # virtual memory
	echo "✅ Limites aplicados com sucesso."

#---------------------------------------------------------------------

## 🚀 CONFIGURAÇÃO DO APPSERVER.INI

	echo ""
	echo "------------------------------------------------------"
	echo "🚀 CONFIGURAÇÃO DO APPSERVER.INI"
	echo "------------------------------------------------------"
	echo "⚙️ Aplicando substituições de variáveis..."

	# Atualiza o arquivo INI com as variáveis de ambiente
	sed -i "s|APPSERVER_RPO_CUSTOM|${APPSERVER_RPO_CUSTOM}|g" ${ini_file_path}
	sed -i "s|APPSERVER_DBACCESS_DATABASE|${APPSERVER_DBACCESS_DATABASE}|g" ${ini_file_path}
	sed -i "s|APPSERVER_DBACCESS_SERVER|${APPSERVER_DBACCESS_SERVER}|g" ${ini_file_path}
	sed -i "s|APPSERVER_DBACCESS_PORT|${APPSERVER_DBACCESS_PORT}|g" ${ini_file_path}
	sed -i "s|APPSERVER_DBACCESS_ALIAS|${APPSERVER_DBACCESS_ALIAS}|g" ${ini_file_path}
	sed -i "s|APPSERVER_CONSOLEFILE|${APPSERVER_CONSOLEFILE}|g" ${ini_file_path}
	sed -i "s|APPSERVER_MULTIPROTOCOLPORTSECURE|${APPSERVER_MULTIPROTOCOLPORTSECURE}|g" ${ini_file_path}
	sed -i "s|APPSERVER_MULTIPROTOCOLPORT|${APPSERVER_MULTIPROTOCOLPORT}|g" ${ini_file_path}
	sed -i "s|APPSERVER_LICENSE_SERVER|${APPSERVER_LICENSE_SERVER}|g" ${ini_file_path}
	sed -i "s|APPSERVER_LICENSE_PORT|${APPSERVER_LICENSE_PORT}|g" ${ini_file_path}
	sed -i "s|APPSERVER_PORT|${APPSERVER_PORT}|g" ${ini_file_path}
	sed -i "s|APPSERVER_WEB_PORT|${APPSERVER_WEB_PORT}|g" ${ini_file_path}
	sed -i "s|APPSERVER_REST_PORT|${APPSERVER_REST_PORT}|g" ${ini_file_path}
	sed -i "s|APPSERVER_WEB_MANAGER|${APPSERVER_WEB_MANAGER}|g" ${ini_file_path}
	sed -i "s|APPSERVER_ENVIRONMENT_LOCALFILES|${APPSERVER_ENVIRONMENT_LOCALFILES}|g" ${ini_file_path}
	sed -i "s|APPSERVER_SQLITE_SERVER|${APPSERVER_SQLITE_SERVER}|g" ${ini_file_path}
	sed -i "s|APPSERVER_SQLITE_PORT|${APPSERVER_SQLITE_PORT}|g" ${ini_file_path}
	sed -i "s|APPSERVER_SQLITE_INSTANCES|${APPSERVER_SQLITE_INSTANCES}|g" ${ini_file_path}

	echo "✅ Variáveis substituídas no $ini_file_path."

	# Imprime o conteúdo do arquivo INI no console
	echo ""
	echo "Configurações finais do arquivo INI:"
	echo ""
	cat "${ini_file_path}"
	echo

#---------------------------------------------------------------------

## 🚀 CRIA ARQUIVO DE CONTROLE PARA HEALTH CHECK

	echo ""
	echo "------------------------------------------------------"
	echo "🚀 CRIANDO ARQUIVO DE CONTROLE PARA HEALTH CHECK"
	echo "------------------------------------------------------"

	touch /.healthcheck

#---------------------------------------------------------------------

## 🚀 EXECUÇÃO DO SCRIPT

	echo ""
	echo "------------------------------------------------------"
	echo "🚀 EXECUÇÃO DO COMANDO SOLICITADO"
	echo "------------------------------------------------------"

	# Executa a ação solicitada
	if [[ "${start}" = true ]]; then
		start_service
	elif [[ "${stop}" = true ]]; then
		stop_service
	elif [[ "${restart}" = true ]]; then
		restart_service
	else
		echo "Nenhuma ação (start, stop, restart) foi solicitada. O script será encerrado."
		exit 0
	fi