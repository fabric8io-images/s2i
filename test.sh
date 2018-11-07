#!/bin/sh
set -ex

# ==================================================================================

function test_container() {
  local name=$1

  CONTAINER_ID=$(docker run --name ${name}-test -d -p 8080 ${name})

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

# ==================================================================================

function test_image() {
  local dir=$1
  local name=$2

  docker build ${dir} -t ${name}

  # ----------------------------------------------------------------------------------
  # Maven
  # ----------------------------------------------------------------------------------

  s2i build --copy java/examples/maven ${name} ${name}-maven-example

  # Now rebuild incrementally, it should not re-download .m2
  s2i build --copy java/examples/maven ${name} ${name}-maven-example --incremental

  test_container "${name}-maven-example"


  # --------------------------------------------------------------------------------
  # Gradle
  # --------------------------------------------------------------------------------

  s2i build --copy java/examples/gradle ${name} ${name}-gradle-example

  s2i build --copy java/examples/gradle ${name} ${name}-gradle-example --incremental

  test_container "s2i-java-gradle-example"


  # ----------------------------------------------------------------------------------
  # Binary
  # ----------------------------------------------------------------------------------

  mvn -f java/examples/maven/ clean package
  cp java/examples/maven/target/*.jar java/examples/binary/deployments/

  s2i build --copy java/examples/binary/ ${name} ${name}-binary-example
  rm java/examples/binary/deployments/*

  test_container "s2i-java-binary-example"


  # ----------------------------------------------------------------------------------
  # Maven Wrapper
  # ----------------------------------------------------------------------------------

  s2i build --copy java/examples/maven-wrapper ${name} ${name}-maven-wrapper-example
  s2i build --copy java/examples/maven-wrapper ${name} ${name}-maven-wrapper-example --incremental
}

# ==================================================================================

cd java ; fish-pepper ; cd ..
test_image "java/images/fedora-java11/" "s2i-java"
test_image "java/images/centos/" "s2i-java"
