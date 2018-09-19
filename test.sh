#!/bin/sh
set -ex

cd java ; fish-pepper ; cd ..

docker build java/images/centos/ -t fabric8/s2i-java

# ----------------------------------------------------------------------------------

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


# ----------------------------------------------------------------------------------
# Maven
# --------------------------------------------------------------------------------

s2i build --copy java/examples/maven fabric8/s2i-java fabric8/s2i-java-maven-example

# Now rebuild incrementally, it should not re-download .m2
s2i build --copy java/examples/maven fabric8/s2i-java fabric8/s2i-java-maven-example --incremental

test_container "s2i-java-maven-example"


# --------------------------------------------------------------------------------
# Gradle
# --------------------------------------------------------------------------------

s2i build --copy java/examples/gradle fabric8/s2i-java fabric8/s2i-java-gradle-example

s2i build --copy java/examples/gradle fabric8/s2i-java fabric8/s2i-java-gradle-example --incremental

test_container "s2i-java-gradle-example"


# ----------------------------------------------------------------------------------
# Binary
# ----------------------------------------------------------------------------------

mvn -f java/examples/maven/ clean package
cp java/examples/maven/target/*.jar java/examples/binary/deployments/

s2i build --copy java/examples/binary/ fabric8/s2i-java fabric8/s2i-java-binary-example
rm java/examples/binary/deployments/*

test_container "s2i-java-binary-example"


# ----------------------------------------------------------------------------------
# Spring Boot Developer Tools
# ----------------------------------------------------------------------------------

s2i build --copy java/examples/spring-devtools fabric8/s2i-java fabric8/s2i-java-spring-devtools-example

test_container "s2i-java-spring-devtools-example"


# ----------------------------------------------------------------------------------
# Maven Wrapper
# ----------------------------------------------------------------------------------

s2i build --copy java/examples/maven-wrapper fabric8/s2i-java fabric8/s2i-java-maven-wrapper-example
s2i build --copy java/examples/maven-wrapper fabric8/s2i-java fabric8/s2i-java-maven-wrapper-example --incremental
