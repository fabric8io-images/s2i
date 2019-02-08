#!/bin/bash
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

  if [ "$http_reply" = 'hello, world' ]; then
    echo "APP TEST PASSED"
    docker rm -f ${container_id}
    return 0
  else
    echo "APP TEST FAILED"
    docker logs ${container_id}
    docker rm -f ${container_id}
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

  case $metrics_reply in
    *"jvm_threads_current"*)
      echo "METRICS TEST PASSED"
      docker rm -f ${container_id}
      return 0
      ;;
    *)
      echo "METRICS TEST FAILED"
      docker logs ${container_id}
      docker rm -f ${container_id}
      return -123
      ;;
  esac
}

# ==================================================================================

function test_entrypoint() {
  local name=$1
  local entrypoint=$2

  local container_id=$(docker run --name ${name}-test -d \
                         -e LANG=en_US.UTF-8 -e PARAMETER_THAT_MAY_NEED_ESCAPING="&'\"|< é\\(" ${name} \
                         ${entrypoint} --commandLineArgValueThatMayNeedEscaping="&'\"|< é\\(" --killDelay=1 --exitCode=0)

  # sleep is required because after docker run returns, the container is up but our server may not quite be yet
  local exitCode=$(docker wait ${container_id})

  if [ "$exitCode" = '0' ]; then
    echo "APP TEST PASSED (with entrypoint ${entrypoint})"
    docker rm -f ${container_id}
    return 0
  else
    echo "APP TEST FAILED (with entrypoint ${entrypoint})"
    docker logs ${container_id}
    docker rm -f ${container_id}
    return -123
  fi
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

  # --------------------------------------------------------------------------------
  # Gradle Spring Boot WAR  <https://github.com/fabric8io-images/s2i/issues/123>
  # --------------------------------------------------------------------------------

  s2i build --copy java/examples/spring-gradle ${name} ${name}-spring-gradle

  test_container "${name}-spring-gradle"


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

  test_container "${name}-gradle-example"


  # ----------------------------------------------------------------------------------
  # Binary
  # ----------------------------------------------------------------------------------

  mvn -f java/examples/maven/ clean package
  cp java/examples/maven/target/*.jar java/examples/binary/deployments/

  s2i build --copy java/examples/binary/ ${name} ${name}-binary-example
  rm java/examples/binary/deployments/*

  test_container "${name}-binary-example"


  # ----------------------------------------------------------------------------------
  # Maven Wrapper
  # ----------------------------------------------------------------------------------

  s2i build --copy java/examples/maven-wrapper ${name} ${name}-maven-wrapper-example
  s2i build --copy java/examples/maven-wrapper ${name} ${name}-maven-wrapper-example --incremental


  # ----------------------------------------------------------------------------------
  # Entrypoint Binary
  # ----------------------------------------------------------------------------------

  curl https://repo.spring.io/release/org/springframework/cloud/spring-cloud-deployer-spi-test-app/1.3.4.RELEASE/spring-cloud-deployer-spi-test-app-1.3.4.RELEASE-exec.jar \
       -o java/examples/binary/deployments/app.jar

  s2i build --copy java/examples/binary/ ${name} ${name}-entrypoint-binary-example
  rm java/examples/binary/deployments/*

  test_entrypoint "${name}-entrypoint-binary-example" "java -jar /deployments/app.jar"  # works
  test_entrypoint "${name}-entrypoint-binary-example" /opt/run-java/run-java.sh         # will fail until https://github.com/fabric8io-images/run-java-sh/issues/75 is fixed
  test_entrypoint "${name}-entrypoint-binary-example" /usr/local/s2i/run                # will fail until https://github.com/fabric8io-images/run-java-sh/issues/75 is fixed
}

# ==================================================================================

cd java ; fish-pepper ; cd ..
test_image "java/images/centos-java11/" "s2i-java-11"
test_image "java/images/fedora-java11/" "s2i-java-11-fedora"
test_image "java/images/centos/" "s2i-java"
