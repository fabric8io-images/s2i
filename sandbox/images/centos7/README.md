# Java STI builder image

This is a STI builder image for Java builds whose result can be run
directly without any further application server. It's suited ideally
for microservices. The application can be either provided as an
executable FAT Jar or in the more classical with JARs on a flat
classpath with one Main-Class.



The following environment variables can be used to influence the
behaviour of this builder image:

## Build Time

* **STI_DIR** Base STI dir (default: `/tmp`)
* **STI_SOURCE_DIR** Directory where the source should be copied to (default: `${STI_DIR}/src`)
* **STI_ARTIFACTS_DIR** Artifact directory used for incremental build (default: `${STI_DIR}/artifacts`)
* **OUTPUT_DIR** Directory where to find the generated artifacts (default: `${STI_SOURCE_DIR}/target`)
* **JAVA_APP_DIR** Where the application jar should be put to (default: `/app`)
* **MAVEN_ARGS** Arguments to use when calling maven (default: `package dependency:copy-dependencies -DskipTests -e`)
* **MAVEN_MODULE** For a multi-module maven build this variable can pick a single module via its maven coordinates 
  (e.g. `io.fabric8.jube.images.fabric8:quickstart-java-simple-fatjar`)
* **MAVEN_EXTRA_ARGS** Additional args, useful for temporary adding arguments like `-X`
* **MAVEN_DEP_CLASSPATH_OPTS** Options to use when creating a classpath file. After the regular build a file containing 
  the classpath is created via the goal `dependency:build-classpath` and which can be picked up by `run` when starting up.
  See [maven-dependency-plugin](https://maven.apache.org/plugins/maven-dependency-plugin/build-classpath-mojo.html) 
  for possible options.
* **MAVEN_USE_REPO_DEPENDENCIES** If set to a value then the classpath is build up with pointing to dependencies directly
  in the local Maven repository. When unset (default) dependent jars are copied into the application directory and the 
  classpath file is build up from the jars in this directory
* **MAVEN_MIRROR** If set to an Maven repository URL this URL is taken as a mirror for Maven central
* **MAVEN_CLEAR_REPO** If set then the Maven repository is removed after the artefact is build. This is useful for keeping
  the created application image small, but prevents *incremental* builds. Setting this variable implies also that dependent
  artefacts are copied into the application directory.

## Run Time

The run script can be influenced by the following environment variables:

* **JAVA_APP_DIR** the directory where the application resides. All paths
  in your application are relative to this directory.
* **JAVA_LIB_DIR** directory holding the Java jar files as well an optional `classpath` 
  file which holds the classpath. Either as a single line classpath (colon separated) or 
  with jar files listed line-by-line. If not set **JAVA_LIB_DIR** is the same 
  as **JAVA_APP_DIR**. 
* **JAVA_OPTIONS** options to add when calling `java`
* **JAVA_MAIN_CLASS** A main class to use as argument for `java`. When
  this environment variable is given, all jar files in `$JAVA_APP_DIR`
  are added to the classpath as well as `$JAVA_LIB_DIR`.
* **JAVA_APP_JAR** A jar file with an appropriate manifest so that it
  can be started with `java -jar` if no `$JAVA_MAIN_CLASS` is set. In all
  cases this jar file is added to the classpath, too.
* **JAVA_APP_NAME** Name to use for the process
* **JAVA_CLASSPATH** the classpath to use. If not given, the script checks 
  for a file `${JAVA_APP_DIR}/classpath` and use its content literally 
  as classpath. If this file doesn't exists all jars in the app dir are 
  added (`classes:${JAVA_APP_DIR}/*`). 
* **JAVA_ENABLE_DEBUG** If set remote debugging will be switched on
* **JAVA_DEBUG_PORT** Port used for remote debugging. Default: 5005

If neither `$JAVA_APP_JAR` nor `$JAVA_MAIN_CLASS` is given,
`$JAVA_APP_DIR` is checked for a single JAR file which is taken as
`$JAVA_APP_JAR`. If no or more then one jar file is found, the script
throws an error. 

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

These variables can be also set in a
shell config file `run-env.sh`, which will be sourced by 
the startup script. This file can be located in the directory where 
this script is located and in `${JAVA_APP_DIR}`, whereas environment 
variables in the latter override the ones in `run-env.sh` from the script 
directory.

This script also checks for a command `run-java-options`. If existant it will be
called and the output is added to the environment variable `$JAVA_OPTIONS`.

Any arguments given during startup are taken over as arguments to the
Java app. 

The environment variables are best set in `.sti/environment` top in
you project. This file is picked up bei STI during building and running.  

You can also put a `sti.env` file holding theses environment variables into `${OUTPUT_DIR}` or
`${OUTPUT_DIR}/classes` which will be picked up during startup of generated application.  

undefined

[1]: https://github.com/fabric8io/agent-bond
[2]: https://github.com/rhuss/jolokia
[3]: https://github.com/prometheus/jmx_exporter
