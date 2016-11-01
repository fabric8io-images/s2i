# {{= fp.config.base.description}}

This is a S2I builder image for Java builds whose result can be run directly without any further application server.
It's suited ideally for microservices with a flat classpath (including "far jars").

This image also provides an easy integration with an [Jolokia](https://github.com/rhuss/jolokia)  agent. See below
how to configure this.

The following environment variables can be used to influence the behaviour of this builder image:

## Build Time

* **MAVEN_ARGS** Arguments to use when calling maven, replacing the default `package hawt-app:build -DskipTests -e`. Please be sure to run the `hawt-app:build` goal (when not already bound to the `package` execution phase), otherwise the startup scripts won't work.
* **MAVEN_ARGS_APPEND** Additional Maven  arguments, useful for temporary adding arguments like `-X` or `-am -pl ..`
* **ARTIFACT_DIR** Path to `target/` where the jar files are created for multi module builds. These are added to `${MAVEN_ARGS}`
* **ARTIFACT_COPY_ARGS** Arguments to use when copying artifacts from the output dir to the application dir. Useful to specify which artifacts will be part of the image. It defaults to `-r hawt-app/*` when a `hawt-app` dir is found on the build directory, otherwise jar files only will be included (`*.jar`).
* **MAVEN_CLEAR_REPO** If set then the Maven repository is removed after the artifact is built. This is useful for keeping
  the created application image small, but prevents *incremental* builds. The default is `false`

## Run Time

{{= fp.block('run-java-sh','readme',{ 'fp-no-files' : true }) }}

{{= fp.block('jolokia','readme',{ 'fp-no-files' : true }) }}
