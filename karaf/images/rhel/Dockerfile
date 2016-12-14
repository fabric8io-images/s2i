FROM jboss-base-7/jdk8:1.2-28

MAINTAINER Dhiraj Bokde <dhirajsb@gmail.com>

ENV MAVEN_VERSION="3.3.3-1.el7" \
    JOLOKIA_VERSION="1.3.5.redhat-1" \
    PATH="/usr/local/s2i:$PATH" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true"

# Expose jolokia port
EXPOSE 8778

LABEL io.fabric8.s2i.version.maven="3.3.3-1.el7" \
      io.fabric8.s2i.version.jolokia="1.3.5.redhat-1" \
      io.k8s.description="Platform for building and running Apache Karaf OSGi applications" \
      io.k8s.display-name="Apache Karaf" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      io.openshift.tags="builder,karaf" \
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

# ===================
# Karaf specific code

# Copy deploy-and-run.sh for standalone images
# Necessary to permit running with a randomised UID
COPY deploy-and-run.sh container-limits java-default-options /deployments/
RUN chmod a+x /deployments/deploy-and-run.sh /deployments/container-limits /deployments/java-default-options \
 && chmod a+x /usr/local/s2i/* \
 && chmod -R "g+rwX" /deployments \
 && chown -R jboss:root /deployments

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image
USER 185

CMD ["usage"]
