#!/bin/bash

set -eou pipefail

DEB_VER=$(echo ${VERSION} | cut -f 1 -d \- | tr -d 'a-z')

PKG_NAME=parquet-tools
PKG_ARCH=amd64
BIN_ARCH=amd64

DOCKER_NAME=deb-build
SOURCE_DIR=$(dirname $0)/..

# Launch build container
docker ps | grep ${DOCKER_NAME} && docker rm -f ${DOCKER_NAME}
docker run -dit --rm --name ${DOCKER_NAME} debian:stretch-slim

# CCI does not support volume mount, so use docker cp instead
docker cp ${SOURCE_DIR}/build/release/${PKG_NAME}-${VERSION}-linux-${BIN_ARCH}.gz ${DOCKER_NAME}:/tmp/${PKG_NAME}.gz
docker cp ${SOURCE_DIR}/package/deb ${DOCKER_NAME}:/tmp/
cat ${SOURCE_DIR}/package/deb/DEBIAN/control | sed "s/^Version:.*/Version: ${DEB_VER}/" > /tmp/control
docker cp /tmp/control ${DOCKER_NAME}:/tmp/deb/DEBIAN/control

# Build deb
docker exec -t ${DOCKER_NAME} bash -c "
    set -eou pipefail;
    mkdir -p /tmp/deb/usr/bin;
    gunzip /tmp/${PKG_NAME}.gz;
    mv /tmp/${PKG_NAME} /tmp/deb/usr/bin/${PKG_NAME};
    cd /tmp;
    dpkg-deb --build /tmp/deb;
"
docker cp ${DOCKER_NAME}:/tmp/deb.deb ${SOURCE_DIR}/build/release/${PKG_NAME}_${DEB_VER}_${PKG_ARCH}.deb

# Clean up
docker ps | grep ${DOCKER_NAME} && docker rm -f ${DOCKER_NAME}
