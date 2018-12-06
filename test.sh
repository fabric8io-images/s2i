#!/bin/sh
set -ex

# ==================================================================================

function test_app() {
  local name=$1
  local port="8080"

  local container_id=$(docker run --name ${name}-test -d -p ${port} ${name})

  # sleep is required because after docker run returns, the container is up but our server may not quite be yet
  sleep 5

  local http_port="$(docker port ${container_id} ${port}|sed 's/0.0.0.0://')"
  local http_reply=$(curl --silent --show-error http://localhost:$http_port)

  docker rm -f "$container_id"

  if [ "$http_reply" = 'hello, world' ]; then
    echo "APP TEST PASSED"
    return 0
  else
    echo "APP TEST FAILED"
    return -123
  fi
}

# ==================================================================================

function test_metrics() {
  local name=$1
  local port="9779"

  local container_id=$(docker run --name ${name}-test -d -p ${port} ${name})

  # sleep is required because after docker run returns, the container is up but our server may not quite be yet
  sleep 5

  local metrics_port="$(docker port ${container_id} ${port}|sed 's/0.0.0.0://')"
  local metrics_reply=$(curl --silent --show-error http://localhost:$metrics_port/metrics)

  docker rm -f "$container_id"

  case $metrics_reply in
    *"jvm_threads_current"*)
      echo "METRICS TEST PASSED"
      return 0
      ;;
    *)
      echo "METRICS TEST FAILED"
      return -123
      ;;
  esac
}

# ==================================================================================

function test_container() {
  test_app $1
  test_metrics $1
}

# ==================================================================================

function test_image() {
  local dir=$1
  local name=$2

  docker build ${dir} -t ${name}

  # ----------------------------------------------------------------------------------
  # Presence of any required tools
  #  * Issues #171 and #184: unzip is required for Spring Boot devtools support
  # ----------------------------------------------------------------------------------

  docker run --rm --name ${name}-test-unzip ${name} unzip

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

  # TODO https://github.com/fabric8io-images/s2i/issues/150
  # s2i build --copy java/examples/gradle ${name} ${name}-gradle-example --incremental

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
