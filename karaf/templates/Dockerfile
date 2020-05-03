{{
  var mavenRepo = fp.config.base.mavenRepo;
  var mavenVersion = fp.config.base.version.maven;
}}FROM {{= fp.config.base.from }}

MAINTAINER Dhiraj Bokde <dhirajsb@gmail.com>

ENV JOLOKIA_VERSION="{{= fp.config.base.version.jolokia }}" \
    KARAF_FRAMEWORK_VERSION="{{= fp.config.base.version.karaf }}" \
    PROMETHEUS_JMX_EXPORTER_VERSION="{{= fp.config.base.version.jmxexporter }}" \
    PATH="/usr/local/s2i:$PATH" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true"

# Expose jolokia port
EXPOSE 8778

LABEL io.fabric8.s2i.version.maven="{{= fp.config.base.version.maven }}" \
      io.fabric8.s2i.version.jolokia="{{= fp.config.base.version.jolokia }}" \
      io.fabric8.s2i.version.karaf="{{= fp.config.base.version.karaf }}" \
      io.fabric8.s2i.version.prometheus.jmx_exporter="{{= fp.config.base.version.jmxexporter }}" \
      io.k8s.description="Platform for building and running Apache Karaf OSGi applications" \
      io.k8s.display-name="Apache Karaf" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      io.openshift.tags="builder,karaf" \
      org.jboss.deployments-dir="/deployments/karaf" \
      com.redhat.deployments-dir="/deployments/karaf" \
      com.redhat.dev-mode="JAVA_DEBUG:false" \
      com.redhat.dev-mode.port="JAVA_DEBUG_PORT:5005"

# Temporary switch to root
USER root

# Dowload Maven from Apache
RUN  yum -y update \
  && yum install -y --setopt=skip_missing_names_on_install=False \
       java-1.8.0-openjdk \
       java-1.8.0-openjdk-devel \
  && yum clean all \
  && curl https://archive.apache.org/dist/maven/maven-3/{{= mavenVersion }}/binaries/apache-maven-{{= mavenVersion }}-bin.tar.gz | \
    tar -xzf - -C /opt \
  && ln -s /opt/apache-maven-{{= mavenVersion }} /opt/maven \
  && ln -s /opt/maven/bin/mvn /usr/bin/mvn \
  && groupadd -r jboss -g 1000 \
  && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss \
  && chmod 755 /opt/jboss

ENV JAVA_HOME /etc/alternatives/jre


# Use /dev/urandom to speed up startups.
RUN echo securerandom.source=file:/dev/urandom >> /usr/lib/jvm/java/jre/lib/security/java.security

# Add jboss user to the root group
RUN usermod -g root -G jboss jboss

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

# Copy licenses
RUN mkdir -p /opt/fuse/licenses
COPY licenses.css /opt/fuse/licenses
COPY licenses.xml /opt/fuse/licenses
COPY licenses.html /opt/fuse/licenses
COPY apache_software_license_version_2.0-apache-2.0.txt /opt/fuse/licenses


{{= fp.block("run-java-sh","copy",{dest: "/opt/run-java"}) }}
# ===================
# Karaf specific code

# Copy deploy-and-run.sh for standalone images
# Necessary to permit running with a randomised UID
COPY deploy-and-run.sh /deployments/
RUN chmod a+x /deployments/deploy-and-run.sh \
 && chmod a+x /usr/local/s2i/* \
 && chmod -R "g+rwX" /deployments \
 && chown -R jboss:root /deployments \
 && chmod -R "g+rwX" {{= fp.config.base.home }} \
 && chown -R jboss:root {{= fp.config.base.home }} \
 && chmod 664 /etc/passwd

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image
USER 1000
RUN mkdir -p {{= fp.config.base.home }}/.m2
COPY settings.xml {{= fp.config.base.home }}/.m2/settings.xml


CMD ["usage"]
