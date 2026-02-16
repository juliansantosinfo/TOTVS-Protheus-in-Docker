#!/bin/bash
#
# ==============================================================================
# SCRIPT: run.sh
# DESCRIÇÃO: Executa o container do Oracle Database TOTVS para testes locais.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-12
# USO: ./run.sh
# ==============================================================================

# Carregar versões centralizadas
if [ -f "versions.env" ]; then
    source "versions.env"
elif [ -f "../versions.env" ]; then
    source "../versions.env"
fi

readonly DOCKER_TAG="${DOCKER_USER}/${ORACLE_IMAGE_NAME}:${ORACLE_VERSION}"

docker run -d \
    --name totvs_oracle \
    -p 1521:1521 \
    -e "ORACLE_PASSWORD=${DATABASE_PASSWORD:-ProtheusDatabasePassword1}" \
    "${DOCKER_TAG}"
