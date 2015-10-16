FROM jboss/base-jdk:8

ENV MAVEN_VERSION=3.3.3 \
    JOLOKIA_VERSION=1.3.2 \
    PATH=$PATH:/usr/local/s2i \
    AB_JOLOKIA_CONFIG=/opt/jolokia/jolokia.properties \
    AB_JOLOKIA_AUTH_OPENSHIFT="cn=system:master-proxy"

# Some version information
LABEL io.fabric8.s2i.version.maven="3.3.3" \
      io.fabric8.s2i.version.jolokia="1.3.2" \
      io.k8s.description="Platform for building and running plain Java applications (flat classpath only)" \
      io.k8s.display-name="Java Applications" \
      io.openshift.tags="builder,java" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      org.jboss.deployments-dir="/deployments"

# Temporary switch to root
USER root

# Install maven
RUN curl http://www.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | \
    tar -xzf - -C /opt \
 && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
 && ln -s /opt/maven/bin/mvn /usr/bin/mvn

# Jolokia agent
ADD jolokia-opts /opt/jolokia/
ADD jolokia.properties /opt/jolokia/
RUN mkdir -p /opt/jolokia \
 && curl http://central.maven.org/maven2/org/jolokia/jolokia-jvm/${JOLOKIA_VERSION}/jolokia-jvm-${JOLOKIA_VERSION}-agent.jar \
         -o /opt/jolokia/jolokia.jar \
 && chmod 444 /opt/jolokia/jolokia.jar \
 && chmod 755 /opt/jolokia/jolokia-opts
EXPOSE 8778

# S2I scripts + README
COPY s2i /usr/local/s2i
ADD README.md /usr/local/s2i/usage.txt

# Necessary to permit running with a randomised UID
RUN mkdir /opt/src /deployments \
 && chmod -R a+rwX /opt/src /deployments

# S2I requires a numeric, non-0 UID
USER 1000

# Use the run script as default since we are working as an hibrid image which can be
# used directly to. (If we were a plain s2i image we would print the usage info here)
CMD [ "/usr/local/s2i/run" ]

