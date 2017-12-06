FROM jboss/base-jdk:8

MAINTAINER Dhiraj Bokde <dhirajsb@gmail.com>

ENV JOLOKIA_VERSION="1.3.6" \
    KARAF_FRAMEWORK_VERSION="4.0.8" \
    PROMETHEUS_JMX_EXPORTER_VERSION="0.10" \
    PATH="/usr/local/s2i:$PATH" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true"

# Expose jolokia port
EXPOSE 8778

LABEL io.fabric8.s2i.version.maven="3.3.3" \
      io.fabric8.s2i.version.jolokia="1.3.6" \
      io.fabric8.s2i.version.karaf="4.0.8" \
      io.fabric8.s2i.version.prometheus.jmx_exporter="0.10" \
      io.k8s.description="Platform for building and running Apache Karaf OSGi applications" \
      io.k8s.display-name="Apache Karaf" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      io.openshift.tags="builder,karaf" \
      org.jboss.deployments-dir="/deployments/karaf" \
      com.redhat.deployments-dir="/deployments/karaf" \
      com.redhat.dev-mode="DEV_MODE:false" \
      com.redhat.dev-mode.port="DEBUG_PORT:5005"

# Temporary switch to root
USER root

# Use /dev/urandom to speed up startups.
RUN echo securerandom.source=file:/dev/urandom >> /usr/lib/jvm/java/jre/lib/security/java.security

# Add jboss user to the root group
RUN usermod -g root -G jboss jboss


# Install Maven via SCL

# Dowload Maven from Apache
RUN curl https://archive.apache.org/dist/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz | \
    tar -xzf - -C /opt \
 && ln -s /opt/apache-maven-3.3.3 /opt/maven \
 && ln -s /opt/maven/bin/mvn /usr/bin/mvn


# Prometheus JMX exporter agent
 RUN mkdir -p /opt/prometheus/etc \
  && curl http://central.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.10/jmx_prometheus_javaagent-0.10.jar \
          -o /opt/prometheus/jmx_prometheus_javaagent.jar
 ADD prometheus-opts /opt/prometheus/prometheus-opts
 ADD prometheus-config.yml /opt/prometheus/prometheus-config.yml
 RUN chmod 444 /opt/prometheus/jmx_prometheus_javaagent.jar \
  && chmod 444 /opt/prometheus/prometheus-config.yml \
  && chmod 755 /opt/prometheus/prometheus-opts \
  && chmod 775 /opt/prometheus/etc \
  && chgrp root /opt/prometheus/etc

EXPOSE 9779



# Jolokia agent
RUN mkdir -p /opt/jolokia/etc \
 && curl http://central.maven.org/maven2/org/jolokia/jolokia-jvm/1.3.6/jolokia-jvm-1.3.6-agent.jar \
         -o /opt/jolokia/jolokia.jar
ADD jolokia-opts /opt/jolokia/jolokia-opts
RUN chmod 444 /opt/jolokia/jolokia.jar \
 && chmod 755 /opt/jolokia/jolokia-opts \
 && chmod 775 /opt/jolokia/etc \
 && chgrp root /opt/jolokia/etc

EXPOSE 8778


# S2I scripts + README
COPY s2i /usr/local/s2i
RUN chmod 755 /usr/local/s2i/*
ADD README.md /usr/local/s2i/usage.txt

# ===================
# Karaf specific code

# Copy deploy-and-run.sh for standalone images
# Necessary to permit running with a randomised UID
COPY deploy-and-run.sh container-limits debug-options java-default-options /deployments/
RUN chmod a+x /deployments/deploy-and-run.sh /deployments/container-limits /deployments/debug-options /deployments/java-default-options \
 && chmod a+x /usr/local/s2i/* \
 && chmod -R "g+rwX" /deployments \
 && chown -R jboss:root /deployments

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image

USER 1000
RUN mkdir -p /opt/jboss/.m2
COPY settings.xml /opt/jboss/.m2/settings.xml


CMD ["usage"]
