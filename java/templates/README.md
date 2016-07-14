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

The run script can be influenced by the following environment variables:

* **JAVA_OPTIONS**  Options that will be passed to the JVM.  Use it to set options like the max JVM memory (-Xmx1G).
* **JAVA_ENABLE_DEBUG**  If set to true, then enables JVM debugging
* **JAVA_DEBUG_PORT** Port used for debugging (default: 5005)
* **JAVA_AGENT** Set this to pass any JVM agent arguments for stuff like profilers
* **JAVA_MAIN_ARGS** Arguments that will be passed to you application's main method.  **Default:** the arguments passed to the `bin/run` script.
* **JAVA_MAIN_CLASS** The main class to use if not configured within the plugin

The environment variables are best set in `.sti/environment` top in you project. This file is picked up bei S2I
during building and running.

{{= fp.block('jolokia','readme',{ 'fp-no-files' : true }) }}
