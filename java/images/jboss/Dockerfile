FROM jboss/base-jdk:8

ENV MAVEN_VERSION="3.3.3" \
    JOLOKIA_VERSION="2.0.0-M3" \
    PATH=$PATH:"/usr/local/s2i" \
    AB_JOLOKIA_CONFIG="/opt/jolokia/jolokia.properties" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true"

# Some version information
LABEL io.fabric8.s2i.version.maven="3.3.3" \
      io.fabric8.s2i.version.jolokia="2.0.0-M3" \
      io.k8s.description="Platform for building and running plain Java applications (fat-jar and flat classpath)" \
      io.k8s.display-name="Java Applications" \
      io.openshift.tags="builder,java" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      org.jboss.deployments-dir="/deployments"

# Temporary switch to root
USER root


# Download Maven from Apache
RUN curl https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | \
    tar -xzf - -C /opt \
 && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
 && ln -s /opt/maven/bin/mvn /usr/bin/mvn


# Jolokia agent
RUN mkdir -p /opt/jolokia \
 && curl http://central.maven.org/maven2/org/jolokia/jolokia-agent-jvm/2.0.0-M3/jolokia-agent-jvm-2.0.0-M3-agent.jar \
         -o /opt/jolokia/jolokia.jar
ADD jolokia-opts /opt/jolokia/jolokia-opts
RUN chmod 444 /opt/jolokia/jolokia.jar \
 && chmod 755 /opt/jolokia/jolokia-opts

EXPOSE 8778

ADD jolokia.properties /opt/jolokia.properties

# Install jq to make it easier to work with Jolokia from the CLI
RUN curl -L -s https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 > /usr/local/bin/jq \
 && chmod a+x /usr/local/bin/jq

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
RUN mkdir /deployments \
 && chmod -R "a+rwX" /deployments

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image
USER 185

# Use the run script as default since we are working as an hybrid image which can be
# used directly to. (If we were a plain s2i image we would print the usage info here)
CMD [ "/usr/local/s2i/run" ]
