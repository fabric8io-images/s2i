#!/bin/sh
set -ex

cd java ; fish-pepper ; cd ..

docker build java/images/jboss/ -t fabric8/s2i-java

# Initially intentionally building without incremental
s2i build --copy java/example fabric8/s2i-java fabric8/s2i-java-example

# Now rebuild incrementally, it should not re-download .m2
s2i build --copy java/example fabric8/s2i-java fabric8/s2i-java-example --incremental

CONTAINER_ID=$(docker run --name s2i-java-example-test -d -p 8080 fabric8/s2i-java-example)

# sleep is required because after docker run returns, the container is up but our server may not quite be yet
sleep 5

HTTP_PORT="$(docker ps|grep s2i-java-example-test|sed 's/.*0.0.0.0://g'|sed 's/->.*//g')"
HTTP_REPLY=$(curl --silent --show-error http://localhost:$HTTP_PORT)

docker rm -f "$CONTAINER_ID"

if [ "$HTTP_REPLY" = 'hello, world' ]; then
  echo "TEST PASSED"
  exit 0
else
  echo "TEST FAILED"
  exit -123
fi
