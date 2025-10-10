#! /bin/bash

# Cria uma variável booleana para controlar se o diretório existe ou foi extraído
resources_exists=false

# Verifica se o diretório totvs existe
if [ -f ./resources/data.tar.gz ]; then
  # Define a variável como true
  resources_exists=true
else

  # Se não existir, verifica se o arquivo data_part_aa existe
  if [ -f ./resources/data.tar.gzaa ]; then

    # Se existir, junta as partes do arquivo tar
    cat ./resources/data.tar.gz* > ./resources/data.tar.gz

    # Define a variável como true
    resources_exists=true
  fi
fi

# Verifica o valor da variável booleana
if [ $resources_exists=false ]; then
  # Se o arquivo de dados existe, executa o comando docker build
  docker build --no-cache --progress=plain -t juliansantosinfo/totvs_mssql:release-2410.build-24.3.0.1.dbapi-24.1.0.0 .
else
  # Se o arquivo não existe, exibe uma mensagem de erro
  echo "O arquivo de dados não foi encontrado."
fi

# Verifica se o diretório existe
if [ -f ./resources/data.tar.gz ]; then

  # Solicita confirmação do usuário
  read -p "Deseja atualizar o arquivo data.tar.gz? (s/n) " resposta

  # Verifica a resposta do usuário
  if [ "$resposta" = "s" ] || [ "$resposta" = "S" ]; then
    # Remove arquivos de partes existentes
    find ./resources/ -maxdepth 1 -type f -name "data.tar.gz*" ! -name "data.tar.gz" -exec rm -v {} \;

    # Comprime o arquivo em partes de 1MB
    split -b 1m ./resources/data.tar.gz ./resources/data.tar.gz

    echo "Arquivo ./resources/totvs.tar.gz atualizado com sucesso!"
  fi

fi

echo "Processo de build finalizado com sucesso!"
