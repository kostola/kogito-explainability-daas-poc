#!/bin/bash

set -x
set -e

cd $( dirname $0 )
cd kogito-apps/explainability/explainability-service-rest-daas
mvn clean package -DskipTests -DskipITs
cd -
cd kogito-examples/dmn-quarkus-example
mvn clean package -DskipTests -DskipITs
cd -
docker-compose stop
docker-compose rm -f
docker-compose up -d
