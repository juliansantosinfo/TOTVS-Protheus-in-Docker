#!/bin/bash
#
# ==============================================================================
# SCRIPT: run.sh
# DESCRIÇÃO: Executa o container do TOTVS License Server para testes locais.
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

readonly DOCKER_TAG="${DOCKER_USER}/${LICENSESERVER_IMAGE_NAME}:${LICENSESERVER_VERSION}"

docker run -d \
    --name totvs_licenseserver \
    -p 5555:5555 \
    -p 2234:2234 \
    -p 8020:8020 \
    "${DOCKER_TAG}"
