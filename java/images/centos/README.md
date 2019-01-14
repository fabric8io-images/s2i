# CentOS 7.5 S2I Java builder image with OpenJDK 8

This is a S2I builder image for Java builds whose result can be run directly without any further application server.It's suited ideally for microservices with a flat classpath (including "far jars").

This image also provides an easy integration with an [Jolokia](https://github.com/rhuss/jolokia)  agent. See below how to configure this.

The following environment variables can be used to influence the behaviour of this builder image:

## Build Time

* **MAVEN_ARGS** Arguments to use when calling Maven, replacing the default `package hawt-app:build -DskipTests -e`. Please be sure to run the `hawt-app:build` goal (when not already bound to the `package` execution phase), otherwise the startup scripts won't work.
* **MAVEN_ARGS_APPEND** Additional Maven arguments, useful for temporary adding arguments like `-X` or `-am -pl ..`
* **ARTIFACT_DIR** Path to `target/` where the jar files are created for multi module builds. These are added to `${MAVEN_ARGS}`
* **ARTIFACT_COPY_ARGS** Arguments to use when copying artifacts from the output dir to the application dir. Useful to specify which artifacts will be part of the image. It defaults to `-r hawt-app/*` when a `hawt-app` dir is found on the build directory, otherwise jar files only will be included (`*.jar`).
* **MAVEN_CLEAR_REPO** If set then the Maven repository is removed after the artifact is built. This is useful for keeping
  the created application image small, but prevents *incremental* builds. The default is `false`

## Run Time


### run-java.sh

This general purpose startup script is optimized for running Java application from within containers. It is called like

```
./run-java.sh <sub-command> <options>
```
`run-java.sh` knows two sub-commands:

* `options` to print out JVM option which can be used for own invocation of Java apps (like Maven or Tomcat). It respects container constraints and includes all magic which is used by this script
* `run` executes a Java application as described below. This is also the default command so you can skip adding this command.

### Running a Java application

When no subcommand is given (or when you provide the default subcommand `run`), then by default this scripts starts up Java application.

The startup process is configured mostly via environment variables:

* **JAVA_APP_DIR** the directory where the application resides. All paths in your application are relative to this directory. By default it is the same directory where this startup script resides.
* **JAVA_LIB_DIR** directory holding the Java jar files as well an optional `classpath` file which holds the classpath. Either as a single line classpath (colon separated) or with jar files listed line-by-line. If not set **JAVA_LIB_DIR** is the same as **JAVA_APP_DIR**.
* **JAVA_OPTIONS** options to add when calling `java`
* **JAVA_MAJOR_VERSION** a number >= 7. If the version is set then only options suitable for this version are used. When set to 7 options known only to Java > 8 will be removed. For versions >= 10 no explicit memory limit is calculated since Java >= 10 has support for container limits.
* **JAVA_MAX_MEM_RATIO** is used when no `-Xmx` option is given in `JAVA_OPTIONS`. This is used to calculate a default maximal Heap Memory based on a containers restriction. If used in a Docker container without any memory constraints for the container then this option has no effect. If there is a memory constraint then `-Xmx` is set to a ratio of the container available memory as set here. The default is `25` when the maximum amount of memory available to the container is below 300M, `50` otherwise, which means in that case that 50% of the available memory is used as an upper boundary. You can skip this mechanism by setting this value to 0 in which case no `-Xmx` option is added.
* **JAVA_INIT_MEM_RATIO** is used when no `-Xms` option is given in `JAVA_OPTIONS`. This is used to calculate a default initial Heap Memory based on a containers restriction. If used in a Docker container without any memory constraints for the container then this option has no effect. If there is a memory constraint then `-Xms` is set to a ratio of the container available memory as set here. By default this value is not set.
* **JAVA_MAX_CORE** restrict manually the number of cores available which is used for calculating certain defaults like the number of garbage collector threads. If set to 0 no base JVM tuning based on the number of cores is performed.
* **JAVA_DIAGNOSTICS** set this to get some diagnostics information to standard out when things are happening
* **JAVA_MAIN_CLASS** A main class to use as argument for `java`. When this environment variable is given, all jar files in `$JAVA_APP_DIR` are added to the classpath as well as `$JAVA_LIB_DIR`.
* **JAVA_APP_JAR** A jar file with an appropriate manifest so that it can be started with `java -jar` if no `$JAVA_MAIN_CLASS` is set. In all cases this jar file is added to the classpath, too.
* **JAVA_APP_NAME** Name to use for the process
* **JAVA_CLASSPATH** the classpath to use. If not given, the startup script checks for a file `${JAVA_APP_DIR}/classpath` and use its content literally as classpath. If this file doesn't exists all jars in the app dir are added (`classes:${JAVA_APP_DIR}/*`).
* **JAVA_DEBUG** If set remote debugging will be switched on
* **JAVA_DEBUG_SUSPEND** If set enables suspend mode in remote debugging
* **JAVA_DEBUG_PORT** Port used for remote debugging. Default: 5005
* **HTTP_PROXY** The URL of the proxy server that translates into the `http.proxyHost` and `http.proxyPort` system properties.
* **HTTPS_PROXY** The URL of the proxy server that translates into the `https.proxyHost` and `https.proxyPort` system properties.
* **no_proxy**, **NO_PROXY** The list of hosts that should be reached directly, bypassing the proxy, that translates into the `http.nonProxyHosts` system property.

If neither `$JAVA_APP_JAR` nor `$JAVA_MAIN_CLASS` is given, `$JAVA_APP_DIR` is checked for a single JAR file which is taken as `$JAVA_APP_JAR`. If no or more then one jar file is found, an error is thrown.

The classpath is build up with the following parts:

* If `$JAVA_CLASSPATH` is set, this classpath is taken.
* The current directory (".") is added first.
* If the current directory is not the same as `$JAVA_APP_DIR`, `$JAVA_APP_DIR` is added.
* If `$JAVA_MAIN_CLASS` is set, then
  - A `$JAVA_APP_JAR` is added if set
  - If a file `$JAVA_APP_DIR/classpath` exists, its content is appended to the classpath. This file
    can be either a single line with the jar files colon separated or a multi-line file where each line
    holds the path of the jar file relative to `$JAVA_LIB_DIR` (which by default is the `$JAVA_APP_DIR`)
  - If this file is not set, a `${JAVA_APP_DIR}/*` is added which effectively adds all
    jars in this directory in alphabetical order.

These variables can be also set in a shell config file `run-env.sh`, which will be sourced by the startup script. This file can be located in the directory where the startup script is located and in `${JAVA_APP_DIR}`, whereas environment variables in the latter override the ones in `run-env.sh` from the script directory.

This startup script also checks for a command `run-java-options`. If existent it will be called and the output is added to the environment variable `$JAVA_OPTIONS`.

The startup script also exposes some environment variables describing container limits which can be used by applications:

* **CONTAINER_CORE_LIMIT** a calculated core limit as described in https://www.kernel.org/doc/Documentation/scheduler/sched-bwc.txt
* **CONTAINER_MAX_MEMORY** memory limit given to the container

Any arguments given to the script are given through directly as argument to the Java application.

Example:

```
# Set the application directory directly
export JAVA_APP_DIR=/deployments
# Set -Xmx based on container constraints
export JAVA_MAX_MEM_RATIO=40
# Start the jar in JAVA_APP_DIR with the given arguments
./run-java.sh --user maxmorlock --password secret
```

### Options

This script can also be used to calculate reasonable, best-practice options for starting Java apps in general. For example, when running Maven in a container it makes sense to respect  container Memory constraints.

The subcommand `options` can be used to print options to standard output so that is can be easily used to feed it to another, Java based application.

When no extra arguments are given, all defaults will be used, which can be influenced with the environment variables described above.

You can select specific sets of options by providing additional arguments:

* `--debug` : Java debug options if `JAVA_DEBUG` is set
* `--memory` : Memory settings based on the environment variables given
* `--proxy` : Evaluate proxy environments variables
* `--cpu` : Tuning when the number of cores is limited
* `--gc` : GC tuning parameters
* `--jit` : JIT options
* `--diagnostics` : Print diagnostics options when `JAVA_DIAGNOSTICS` is set
* `--java-default` : Same as `--memory --jit --diagnostic --cpu --gc`

Example:

```
# Call Maven with the proper memory settings when running in an container
export MAVEN_OPTS="$(run-java.sh options --memory)"
mvn clean install
```


#### Jolokia configuration

* **AB_JOLOKIA_OFF** : If set disables activation of Jolokia (i.e. echos an empty value). By default, Jolokia is enabled.
* **AB_JOLOKIA_CONFIG** : If set uses this file (including path) as Jolokia JVM agent properties (as described 
  in Jolokia's [reference manual](http://www.jolokia.org/reference/html/agents.html#agents-jvm)). If not set, 
  the `/opt/jolokia/etc/jolokia.properties` will be created using the settings as defined in this document, otherwise
  the reset of the settings in this document are ignored.
* **AB_JOLOKIA_HOST** : Host address to bind to (Default: `0.0.0.0`)
* **AB_JOLOKIA_PORT** : Port to use (Default: `8778`)
* **AB_JOLOKIA_USER** : User for basic authentication. Defaults to 'jolokia'
* **AB_JOLOKIA_PASSWORD** : Password for basic authentication. By default authentication is switched off.
* **AB_JOLOKIA_PASSWORD_RANDOM** : Should a random AB_JOLOKIA_PASSWORD be generated? Generated value will be written to `/opt/jolokia/etc/jolokia.pw`
* **AB_JOLOKIA_HTTPS** : Switch on secure communication with https. By default self signed server certificates are generated
  if no `serverCert` configuration is given in `AB_JOLOKIA_OPTS`
* **AB_JOLOKIA_ID** : Agent ID to use (`$HOSTNAME` by default, which is the container id)
* **AB_JOLOKIA_DISCOVERY_ENABLED** : Enable Jolokia discovery.  Defaults to false.
* **AB_JOLOKIA_OPTS**  : Additional options to be appended to the agent configuration. They should be given in the format 
  "key=value,key=value,..."

Some options for integration in various environments:

* **AB_JOLOKIA_AUTH_OPENSHIFT** : Switch on client authentication for OpenShift TSL communication. The value of this 
  parameter can be a relative distinguished name which must be contained in a presented client certificate. Enabling this
  parameter will automatically switch Jolokia into https communication mode. The default CA cert is set to 
  `/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` 



Application arguments can be provided by setting the variable **JAVA_ARGS** to the corresponding value.

## Spring Boot Automatic Restarts 

This image also supports detecting jars with [Spring Boot devtools](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#using-boot-devtools) included, which allows automatic restarts when files on the classpath are updated. Files can be easily updated in OpenShift using command [`oc rsync`](https://docs.openshift.org/latest/dev_guide/copy_files_to_container.html). 

To enable automatic restarts, three things are required: 

1. Add Spring Boot devtools dependency:

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-devtools</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>
```

2. Add dependency to the generated fat jar by setting `excludeDevtools` configuration property to false:

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <configuration>
                <excludeDevtools>false</excludeDevtools>
            </configuration>
        </plugin>
    </plugins>
</build>
```

3. Set environment variables `JAVA_DEBUG=true` or `DEBUG=true` and optionally `JAVA_DEBUG_PORT=<port-number>` or `DEBUG_PORT=<port-number>`, which defaults to 5005. Since the `DEBUG` variable clashes with Spring Boot's recognition of the same variable to enable Spring Boot debug logging, use `SPRINGBOOT_DEBUG` instead. 

WARNING: Do not use devtools in production!!! This can be accomplished in Maven using a custom profile.
