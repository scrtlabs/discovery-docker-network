#!/bin/bash

source .env

docker pull enigmampc/enigma_contract:${DOCKER_TAG}
docker pull enigmampc/enigma_p2p:${DOCKER_TAG}
docker pull enigmampc/enigma_contract:${DOCKER_TAG}
docker pull enigmampc/enigma_core_sw:${DOCKER_TAG}
docker pull enigmampc/enigma_km_sw:${DOCKER_TAG}