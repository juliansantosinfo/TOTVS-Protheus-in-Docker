#! /bin/bash

# Cria uma variável booleana para controlar se o diretório existe ou foi extraído
resources_exists=false

# Verifica se o diretório totvs existe
if [ -d ./totvs ]; then
  # Define a variável como true
  resources_exists=true
else

  # Se não existir, verifica se o arquivo totvs.tar.gzaa existe
  if [ -f ./totvs.tar.gzaa ]; then

    # Se existir, junta as partes do arquivo tar
    cat totvs.tar.gza* > totvs.tar.gz

    # Extrai o arquivo tar
    tar -xzvf totvs.tar.gz

    # Remove arquivo temporario
    rm -rf totvs.tar.gz

    # Define a variável como true
    resources_exists=true
  fi
fi

# Verifica o valor da variável booleana
if [ $resources_exists = true ]; then
  # Se o diretório existe ou foi extraído, executa o comando docker build
  docker build --no-cache -t juliansantosinfo/totvs_rest:release-2510.build-24.3.1.1.dbapi-24.1.1.0 .
else
  # Se o diretório não existe e não foi extraído, exibe uma mensagem de erro
  echo "O diretório totvs não existe e o arquivo totvs.tar.gzaa não foi encontrado."
fi

# Verifica se o diretório existe
if [ -d ./totvs ]; then

  # Solicita confirmação do usuário
  read -p "Deseja atualizar o arquivo totvs.tar.gz? (s/n) " resposta

  # Verifica a resposta do usuário
  if [ "$resposta" = "s" ] || [ "$resposta" = "S" ]; then
    # Remove arquivos de partes existentes
    rm -f totvs.tar.gz*

    # Comprime o arquivo em partes de 50MB
    tar -czvf - totvs | split -b 50m - totvs.tar.gz

    echo "Arquivo totvs.tar.gz atualizado com sucesso!"
  fi

fi

echo "Processo de build finalizado com sucesso!"
