#!/bin/bash
#
# ==============================================================================
# SCRIPT: run.sh
# DESCRIÇÃO: Executa o container do Microsoft SQL Server TOTVS para testes locais.
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

readonly DOCKER_TAG="${DOCKER_USER}/${MSSQL_IMAGE_NAME}:${MSSQL_VERSION}"

docker run -d \
    --name totvs_mssql \
    -p 1433:1433 \
    -e "ACCEPT_EULA=Y" \
    -e "SA_PASSWORD=${DATABASE_PASSWORD:-ProtheusDatabasePassword1}" \
    "${DOCKER_TAG}"
