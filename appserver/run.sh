#!/bin/bash
#
# ==============================================================================
# SCRIPT: run.sh
# DESCRIÇÃO: Executa o container do AppServer TOTVS para testes locais.
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

readonly DOCKER_TAG="${DOCKER_USER}/${APPSERVER_IMAGE_NAME}:${APPSERVER_VERSION}"

docker run -d \
    --name totvs_appserver \
    -p 25001:25001 \
    -p 25002:25002 \
    -p 8080:8080 \
    -p 8088:8088
    "${DOCKER_TAG}"
