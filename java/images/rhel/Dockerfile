FROM jboss-base-7/jdk8:1.2-10

ENV MAVEN_VERSION="3.3.3-1.el7" \
    JOLOKIA_VERSION="2.0.0-M3" \
    PATH=$PATH:"/usr/local/s2i" \
    AB_JOLOKIA_CONFIG="/opt/jolokia/jolokia.properties" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true" \
    JAVA_DATA_DIR=/deployments/data

# Some version information
LABEL io.fabric8.s2i.version.maven="3.3.3-1.el7" \
      io.fabric8.s2i.version.jolokia="1.3.2.redhat-1" \
      io.k8s.description="Platform for building and running plain Java applications (fat-jar and flat classpath)" \
      io.k8s.display-name="Java Applications" \
      io.openshift.tags="builder,java" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      org.jboss.deployments-dir="/deployments"

# Temporary switch to root
USER root

# Add jboss user to the root group
RUN usermod -g root -G jboss jboss

# Install Maven via RPM
ADD "http://download.eng.bos.redhat.com/brewroot/packages/maven3/3.3.3/1.el7/noarch/maven3-${MAVEN_VERSION}.noarch.rpm" /tmp/
RUN rpm -i "/tmp/maven3-${MAVEN_VERSION}.noarch.rpm" \
 && rm "/tmp/maven3-${MAVEN_VERSION}.noarch.rpm"


# Jolokia agent
RUN mkdir -p /opt/jolokia \
 && curl http://central.maven.org/maven2/org/jolokia/jolokia-agent-jvm/${JOLOKIA_VERSION}/jolokia-agent-jvm-${JOLOKIA_VERSION}-agent.jar \
         -o /opt/jolokia/jolokia.jar
ADD jolokia-opts /opt/jolokia/jolokia-opts
RUN chmod 444 /opt/jolokia/jolokia.jar \
 && chmod 755 /opt/jolokia/jolokia-opts

EXPOSE 8778

ADD jolokia.properties /opt/jolokia.properties

# S2I scripts + README
COPY s2i /usr/local/s2i
RUN chmod 755 /usr/local/s2i/*
ADD README.md /usr/local/s2i/usage.txt

# Add run script as /opt/run-java/run-java.sh and make it executable
COPY run-java.sh /opt/run-java/run-java.sh
COPY java-container-options /opt/run-java/java-container-options
RUN chmod 755 /opt/run-java/run-java.sh /opt/run-java/java-container-options

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
