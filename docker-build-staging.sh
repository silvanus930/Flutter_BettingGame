#!/bin/bash
scriptdir=${1:-$(pwd)}
cd ${scriptdir}
docker build . -t flutter-superapp:staging --network=host
