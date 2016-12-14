FROM jboss-base-7/jdk8:1.2-28

ENV MAVEN_VERSION="3.3.3-1.el7" \
    JOLOKIA_VERSION="1.3.5.redhat-1" \
    PATH=$PATH:"/usr/local/s2i" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true" \
    JAVA_DATA_DIR="/deployments/data"

# Some version information
LABEL io.fabric8.s2i.version.maven="3.3.3-1.el7" \
      io.fabric8.s2i.version.jolokia="1.3.5.redhat-1" \
      io.k8s.description="Platform for building and running plain Java applications (fat-jar and flat classpath)" \
      io.k8s.display-name="Java Applications" \
      io.openshift.tags="builder,java" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      org.jboss.deployments-dir="/deployments"

# Temporary switch to root
USER root

# Use /dev/urandom to speed up startups.
RUN echo securerandom.source=file:/dev/urandom >> /usr/lib/jvm/java/jre/lib/security/java.security

# Add jboss user to the root group
RUN usermod -g root -G jboss jboss


# Install Maven via RPM
ADD "http://download.eng.bos.redhat.com/brewroot/packages/maven3/3.3.3/1.el7/noarch/maven3-${MAVEN_VERSION}.noarch.rpm" /tmp/
RUN rpm -i "/tmp/maven3-${MAVEN_VERSION}.noarch.rpm" \
 && rm "/tmp/maven3-${MAVEN_VERSION}.noarch.rpm"


# Jolokia agent
RUN mkdir -p /opt/jolokia/etc \
 && curl http://download-node-02.eng.bos.redhat.com/brewroot/repos/jb-common-build/latest/maven/org/jolokia/jolokia-jvm/1.3.5.redhat-1/jolokia-jvm-1.3.5.redhat-1-agent.jar \
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
COPY run-java.sh debug-options container-limits java-default-options /opt/run-java/
RUN chmod 755 /opt/run-java/run-java.sh /opt/run-java/java-default-options /opt/run-java/container-limits /opt/run-java/debug-options

# Adding run-env.sh to set app dir
COPY run-env.sh /opt/run-java/run-env.sh
RUN chmod 755 /opt/run-java/run-env.sh

# Necessary to permit running with a randomised UID
RUN mkdir -p /deployments/data \
 && chmod -R "g+rwX" /deployments \
 && chown -R jboss:root /deployments

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image
USER 185

# Use the run script as default since we are working as an hybrid image which can be
# used directly to. (If we were a plain s2i image we would print the usage info here)
CMD [ "/usr/local/s2i/run" ]
