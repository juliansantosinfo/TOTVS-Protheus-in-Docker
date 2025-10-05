#! /bin/bash

# Cria uma variável booleana para controlar se o diretório existe ou foi extraído
resources_exists=false

# Verifica se o diretório totvs existe
if [ -f ./data.tar.gz ]; then
  # Define a variável como true
  resources_exists=true
else

  # Se não existir, verifica se o arquivo data_part_aa existe
  if [ -f ./data_part_aa ]; then

    # Se existir, junta as partes do arquivo tar
    cat data_part_* > data.tar.gz

    # Define a variável como true
    resources_exists=true
  fi
fi

# Verifica o valor da variável booleana
if [ $resources_exists=false ]; then
  # Se o arquivo de dados existe, executa o comando docker build
  docker build --no-cache --progress=plain -t juliansantosinfo/totvs_mssql:latest .
else
  # Se o arquivo não existe, exibe uma mensagem de erro
  echo "O arquivo de dados não foi encontrado."
fi

echo "Processo de build finalizado com sucesso!"
