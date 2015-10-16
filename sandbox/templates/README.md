# Java STI builder image

This is a STI builder image for Java builds whose result can be run
directly without any further application server. It's suited ideally
for microservices. The application can be either provided as an
executable FAT Jar or in the more classical with JARs on a flat
classpath with one Main-Class.

{{? fp.config.base.agent == "agent-bond" }}
This image also provides an easy integration with [agent-bond][1]
which wraps an [Jolokia][2] and Prometheus [jmx_exporter][3]
agent. See below how to configure this.
{{?? fp.config.base.agent == "jolokia" }}
This image also provides an easy integration with an [Jolokia][2] agent. 
See below how to configure this.
{{?}}

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

{{= fp.block('run-java-sh','readme',{ 'fp-no-files' : true }) }}

The environment variables are best set in `.sti/environment` top in
you project. This file is picked up bei STI during building and running.  

You can also put a `sti.env` file holding theses environment variables into `${OUTPUT_DIR}` or
`${OUTPUT_DIR}/classes` which will be picked up during startup of generated application.  

{{= fp.block(fp.config.base.agent,'readme',{ 'fp-no-files' : true }) }}

[1]: https://github.com/fabric8io/agent-bond
[2]: https://github.com/rhuss/jolokia
[3]: https://github.com/prometheus/jmx_exporter
