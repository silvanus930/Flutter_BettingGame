#!/bin/bash
scriptdir=$(pwd)
cd ${scriptdir}
docker build . -t flutter-superapp-$1:prod --network=host --build-arg FLAVOR_NAME=$1
