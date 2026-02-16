#!/bin/bash
#
# ==============================================================================
# SCRIPT: run.sh
# DESCRIÇÃO: Executa o container do DBAccess TOTVS para testes locais.
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

readonly DOCKER_TAG="${DOCKER_USER}/${DBACCESS_IMAGE_NAME}:${DBACCESS_VERSION}"

docker run -d \
    --name totvs_dbaccess \
    -p 7890:7890 \
    -p 7891:7891 \
    "${DOCKER_TAG}"
