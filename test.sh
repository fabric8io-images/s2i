#!/bin/sh
set -ex

cd java ; fish-pepper ; cd ..

docker build java/images/jboss/ -t fabric8/s2i-java


# --------------------------------------------------------------------------------------------------------------

function test_container() {
  local name=$1

  CONTAINER_ID=$(docker run --name ${name}-test -d -p 8080 fabric8/${name})

  # sleep is required because after docker run returns, the container is up but our server may not quite be yet
  sleep 5

  HTTP_PORT="$(docker ps|grep ${name}-test|sed 's/.*0.0.0.0://g'|sed 's/->.*//g')"
  HTTP_REPLY=$(curl --silent --show-error http://localhost:$HTTP_PORT)

  docker rm -f "$CONTAINER_ID"

  if [ "$HTTP_REPLY" = 'hello, world' ]; then
    echo "TEST PASSED"
    return 0
  else
    echo "TEST FAILED"
    return -123
  fi
}


# --------------------------------------------------------------------------------------------------------------
# Maven

s2i build --copy java/examples/maven fabric8/s2i-java fabric8/s2i-java-maven-example

# Now rebuild incrementally, it should not re-download .m2
s2i build --copy java/examples/maven fabric8/s2i-java fabric8/s2i-java-maven-example --incremental

test_container "s2i-java-maven-example"
