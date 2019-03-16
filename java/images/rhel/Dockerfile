FROM jboss/openjdk18-rhel7:1.1-7

ARG EXPOSE_PORT=8080
EXPOSE ${EXPOSE_PORT}

ENV JOLOKIA_VERSION="1.5.0" \
    PROMETHEUS_JMX_EXPORTER_VERSION="0.10" \
    PATH=$PATH:"/usr/local/s2i" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true" \
    JAVA_MAJOR_VERSION="8" \
    JAVA_DATA_DIR="/deployments/data"

# Some version information
LABEL io.fabric8.s2i.version.maven="3.3.3-1.el7" \
      io.fabric8.s2i.version.jolokia="1.5.0" \
      io.fabric8.s2i.version.prometheus.jmx_exporter="0.10" \
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



# Install Maven via SCL
COPY jboss.repo /etc/yum.repos.d/jboss.repo
RUN yum -y update \
    && yum install -y --enablerepo=jboss-rhel-rhscl --setopt=skip_missing_names_on_install=False rh-maven33-maven \
    && yum clean all \
    && ln -s /opt/rh/rh-maven33/root/bin/mvn /usr/local/bin/mvn


# Use /dev/urandom to speed up startups & Add jboss user to the root group
RUN echo securerandom.source=file:/dev/urandom >> /usr/lib/jvm/java/jre/lib/security/java.security \
 && usermod -g root -G jboss jboss

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
 && curl http://central.maven.org/maven2/org/jolokia/jolokia-jvm/1.5.0/jolokia-jvm-1.5.0-agent.jar \
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

# Add run script as /opt/run-java/run-java.sh and make it executable
COPY run-java.sh /opt/run-java/
RUN chmod 755 /opt/run-java/run-java.sh

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
 && chmod -R "g+rwX" /home/jboss \
 && chown -R jboss:root /home/jboss \
 && chmod 664 /etc/passwd

# S2I scripts rely on /home/jboss as working directory
WORKDIR /home/jboss

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image

USER 185
RUN mkdir -p /home/jboss/.m2
COPY settings.xml /home/jboss/.m2/settings.xml


# Use the run script as default since we are working as an hybrid image which can be
# used directly to. (If we were a plain s2i image we would print the usage info here)
CMD [ "/usr/local/s2i/run" ]
