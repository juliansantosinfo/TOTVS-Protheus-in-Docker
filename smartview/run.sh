#!/bin/bash
#
# ==============================================================================
# SCRIPT: run.sh
# DESCRIÇÃO: Executa o container do TOTVS SmartView para testes locais.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-02-05
# USO: ./run.sh
# ==============================================================================

# Carregar versões centralizadas
if [ -f "versions.env" ]; then
    source "versions.env"
elif [ -f "../versions.env" ]; then
    source "../versions.env"
fi

readonly DOCKER_TAG="${DOCKER_USER}/${SMARTVIEW_IMAGE_NAME}:${SMARTVIEW_VERSION}"

docker run -d --rm \
  --name totvs_smartview \
  --network totvs \
  -p 7017:7017 \
  -p 7019:7019 \
  "${DOCKER_TAG}"
