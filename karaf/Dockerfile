FROM jboss/base-jdk:8

MAINTAINER Dhiraj Bokde <dhirajsb@gmail.com>

ENV MAVEN_VERSION="3.3.3" \
    JOLOKIA_VERSION="1.3.5" \
    PATH="/usr/local/s2i:$PATH" \
    AB_JOLOKIA_CONFIG="/opt/jolokia/jolokia.properties" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true"

# Expose jolokia port
EXPOSE 8778

LABEL io.fabric8.s2i.version.maven="3.3.3" \
      io.fabric8.s2i.version.jolokia="1.3.2" \
      io.k8s.description="Platform for building and running Apache Karaf OSGi applications" \
      io.k8s.display-name="Apache Karaf" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      io.openshift.tags="builder,karaf" \
      org.jboss.deployments-dir="/deployments"

# Temporary switch to root
USER root

# Add jboss user to the root group
RUN usermod -g root -G jboss jboss

# Install maven
RUN curl "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" | \
    tar -xzf - -C /opt \
 && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
 && ln -s /opt/maven/bin/mvn /usr/bin/mvn

# Jolokia agent
ADD jolokia-opts /opt/jolokia/
ADD jolokia.properties /opt/jolokia/
ADD "http://central.maven.org/maven2/org/jolokia/jolokia-jvm/${JOLOKIA_VERSION}/jolokia-jvm-${JOLOKIA_VERSION}-agent.jar /opt/jolokia/jolokia.jar"
RUN chmod 444 /opt/jolokia/jolokia.jar \
 && chmod 755 /opt/jolokia/jolokia-opts
EXPOSE 8778

# Copy the S2I scripts to /usr/local/s2i
COPY s2i /usr/local/s2i

# ===================
# Karaf specific code

# Copy deploy-and-run.sh for standalone images
# Necessary to permit running with a randomised UID
COPY ./deploy-and-run.sh /deployments/deploy-and-run.sh
RUN chmod a+x /deployments/deploy-and-run.sh \
 && chmod -R "g+rwX" /deployments \
 && chown -R jboss:root /deployments

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image
USER 185

CMD ["usage"]
