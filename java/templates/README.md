# {{= fp.config.base.description}}

This is a S2I builder image for Java builds whose result can be run directly without any further application server.It's suited ideally for microservices with a flat classpath (including "far jars").

This image also provides an easy integration with an [Jolokia](https://github.com/rhuss/jolokia)  agent. See below how to configure this.

The following environment variables can be used to influence the behaviour of this builder image:

## Build Time

* **MAVEN_ARGS** Arguments to use when calling Maven, replacing the default `package -DskipTests -Dmaven.javadoc.skip=true -Dmaven.site.skip=true -Dmaven.source.skip=true -Djacoco.skip=true -Dcheckstyle.skip=true -Dfindbugs.skip=true -Dpmd.skip=true -Dfabric8.skip=true -e -B`.
* **MAVEN_ARGS_APPEND** Additional Maven arguments, useful for temporary adding arguments like `-X` or `-am -pl ..`
* **ARTIFACT_DIR** Path to `target/` where the jar files are created for multi module builds. These are added to `${MAVEN_ARGS}`
* **ARTIFACT_COPY_ARGS** Arguments to use when copying artifacts from the output dir to the application dir. Useful to specify which artifacts will be part of the image. It defaults to `-r hawt-app/*` when a `hawt-app` dir is found on the build directory, otherwise jar files only will be included (`*.jar`).
* **MAVEN_CLEAR_REPO** If set then the Maven repository is removed after the artifact is built. This is useful for keeping
  the created application image small, but prevents *incremental* builds. The default is `false`
* **HTTP_PROXY_HOST** and **HTTP_PROXY_PORT** If both are not empty, a `<proxy>...</proxy>` is added to the provided `settings.xml`. By default no proxy is configured for Maven.
* **HTTP_PROXY_NONPROXYHOSTS** If not empty and also proxy settings are provided the `<nonProxyHosts>...</nonProxyHosts>`  is added to the `<proxy/>`.
* **HTTP_PROXY_USERNAME** and **HTTP_PROXY_PASSWORD** If both not empty and also proxy settings are provided the `<username>...</username>` and `<password>...</password>` is  added to the `<proxy/>`.
* **MAVEN_MIRROR_URL** If not empty a `<mirror>...</mirror>` is added to the provided `settings.xml` with the given URL and `external:*` (everything not on the localhost and not file based) mirror configuration.
* **SERVER_ID** and **SERVER_USERNAME** and **SERVER_PASSWORD** If these three are not empty a `<server>...</server>` is added to the provided `settings.xml` with the given server configuration.

## Run Time

{{= fp.block('run-java-sh','readme',{ 'fp-no-files' : true }) }}

{{= fp.block('jolokia','readme',{ 'fp-no-files' : true }) }}

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

