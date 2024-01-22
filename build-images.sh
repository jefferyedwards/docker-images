#!/bin/bash

VERSION=ol8.9-1

docker build -t runtime:${VERSION} runtime
[[ $? -ne 0 ]] && exit 1

docker build -t builder:${VERSION} --build-arg VERSION=${VERSION} builder
[[ $? -ne 0 ]] && exit 1

cd ../developer
docker build -t developer:${VERSION} --build-arg VERSION=${VERSION} developer
[[ $? -ne 0 ]] && exit 1
