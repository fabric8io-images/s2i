#!/bin/sh
set -ex

cd java ; fish-pepper ; cd ..

docker build java/images/jboss/ -t fabric8/s2i-java

s2i build --copy java/example fabric8/s2i-java fabric8/s2i-java-example

CONTAINER_ID=$(docker run -d -p 8080:8080 fabric8/s2i-java-example)

# sleep 1s is required because after docker run returns, the container is up but our server may not quite be yet
sleep 1

HTTP_REPLY=$(curl http://localhost:8080)

docker rm -f "$CONTAINER_ID"

if [ "$HTTP_REPLY" = 'hello, world' ]; then
  echo "TEST PASSED"
  exit 0
else
  echo "TEST FAILED"
  exit -123
fi
