{{
  var mavenRepo = fp.config.base.mavenRepo;
  var mavenVersion = fp.config.base.version.maven;
}}FROM {{= fp.config.base.from }}

ARG EXPOSE_PORT=8080
EXPOSE ${EXPOSE_PORT}

ENV JOLOKIA_VERSION="{{= fp.config.base.version.jolokia }}" \
    PROMETHEUS_JMX_EXPORTER_VERSION="{{= fp.config.base.version.jmxexporter }}" \
    PATH=$PATH:"/usr/local/s2i" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true" \
    JAVA_MAJOR_VERSION="{{= fp.config.base.version.javaMajor}}" \
    JAVA_DATA_DIR="/deployments/data"

# Some version information
LABEL io.fabric8.s2i.version.maven="{{= fp.config.base.version.maven }}" \
      io.fabric8.s2i.version.jolokia="{{= fp.config.base.version.jolokia }}" \
      io.fabric8.s2i.version.prometheus.jmx_exporter="{{= fp.config.base.version.jmxexporter }}" \
      io.k8s.description="Platform for building and running plain Java applications (fat-jar and flat classpath)" \
      io.k8s.display-name="Java Applications" \
      io.openshift.tags="builder,java" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      org.jboss.deployments-dir="/deployments" \
      com.redhat.deployments-dir="/deployments" \
      com.redhat.dev-mode="JAVA_DEBUG:false" \
      com.redhat.dev-mode.port="JAVA_DEBUG_PORT:5005"

# Temporary switch to root
USER root


# Install Java package & download Maven from Apache
RUN yum -y update \
  && yum install -y --setopt=skip_missing_names_on_install=False \
       unzip rsync \
       java-{{= fp.config.base.version.javaPackage}}-openjdk{{= fp.config.base.version.java}} \
       java-{{= fp.config.base.version.javaPackage}}-openjdk-devel{{= fp.config.base.version.java}} \
  && yum clean all \
  && curl https://archive.apache.org/dist/maven/maven-3/{{= mavenVersion }}/binaries/apache-maven-{{= mavenVersion }}-bin.tar.gz | \
    tar -xzf - -C /opt \
  && ln -s /opt/apache-maven-{{= mavenVersion }} /opt/maven \
  && ln -s /opt/maven/bin/mvn /usr/bin/mvn \
  && groupadd -r jboss -g 1000 \
  && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss \
  && chmod 755 /opt/jboss

ENV JAVA_HOME /etc/alternatives/jre


# Use /dev/urandom to speed up startups & Add jboss user to the root group
RUN echo securerandom.source=file:/dev/urandom >> {{= fp.config.base.javaSecurity }} \
 && usermod -g root -G jboss jboss

{{=
  fp.block("jmxexporter", "install",
          { dest: "/opt/prometheus/prometheus-opts",
            userGroupMode: "root",
            version: fp.config.base.version.jmxexporter }) }}

{{=
  fp.block("jolokia", "install",
          { dest: "/opt/jolokia/jolokia-opts",
            mavenRepo: mavenRepo,
            userGroupMode: "root",
            version: fp.config.base.version.jolokia }) }}

# S2I scripts + README
COPY s2i /usr/local/s2i
RUN chmod 755 /usr/local/s2i/*
ADD README.md /usr/local/s2i/usage.txt

{{= fp.block("run-java-sh","copy",{dest: "/opt/run-java"}) }}
# Adding run-env.sh to set app dir
COPY run-env.sh /opt/run-java/run-env.sh
RUN chmod 755 /opt/run-java/run-env.sh


# Copy licenses
RUN mkdir -p /opt/fuse/licenses
COPY licenses.css /opt/fuse/licenses
COPY licenses.xml /opt/fuse/licenses
COPY licenses.html /opt/fuse/licenses
COPY apache_software_license_version_2.0-apache-2.0.txt /opt/fuse/licenses


# Necessary to permit running with a randomised UID
RUN mkdir -p /deployments/data \
 && chmod -R "g+rwX" /deployments \
 && chown -R jboss:root /deployments \
 && chmod -R "g+rwX" {{= fp.config.base.home }} \
 && chown -R jboss:root {{= fp.config.base.home }} \
 && chmod 664 /etc/passwd

# S2I scripts rely on {{= fp.config.base.home }} as working directory
WORKDIR {{= fp.config.base.home }}

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image
USER 1000
RUN mkdir -p /opt/jboss/.m2
COPY settings.xml /opt/jboss/.m2/settings.xml


# Use the run script as default since we are working as an hybrid image which can be
# used directly to. (If we were a plain s2i image we would print the usage info here)
CMD [ "/usr/local/s2i/run" ]
