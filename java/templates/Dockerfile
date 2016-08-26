{{
  var mavenRepo =
    (fp.param.base === "rhel" ? "https://repository.jboss.org/nexus/content/repositories/fs-releases" : null);
}}FROM {{= fp.config.base.from }}

ENV MAVEN_VERSION="{{= fp.config.base.lib.version.maven }}" \
    JOLOKIA_VERSION="{{= fp.config.base.lib.version.jolokia }}" \
    PATH=$PATH:"/usr/local/s2i" \
    AB_JOLOKIA_CONFIG="/opt/jolokia/jolokia.properties" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true" \
    JAVA_DATA_DIR=/deployments/data

# Some version information
LABEL io.fabric8.s2i.version.maven="{{= fp.config.base.lib.version.maven }}" \
      io.fabric8.s2i.version.jolokia="{{= fp.config.base.lib.version.jolokia }}" \
      io.k8s.description="Platform for building and running plain Java applications (fat-jar and flat classpath)" \
      io.k8s.display-name="Java Applications" \
      io.openshift.tags="builder,java" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      org.jboss.deployments-dir="/deployments"

# Temporary switch to root
USER root

{{? fp.param.base === "rhel" }}
# Install Maven via RPM
ADD "http://download.eng.bos.redhat.com/brewroot/packages/maven3/{{= fp.config.base.lib.version.maven.split("-")[0] }}/1.el7/noarch/maven3-${MAVEN_VERSION}.noarch.rpm" /tmp/
RUN rpm -i "/tmp/maven3-${MAVEN_VERSION}.noarch.rpm" \
 && rm "/tmp/maven3-${MAVEN_VERSION}.noarch.rpm"
{{??}}
# Download Maven from Apache
RUN curl https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | \
    tar -xzf - -C /opt \
 && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
 && ln -s /opt/maven/bin/mvn /usr/bin/mvn
{{?}}

{{=
  fp.block("jolokia", "install",
          { dest: "/opt/jolokia/jolokia-opts",
            mavenRepo: mavenRepo,
            version: fp.config.base.lib.version.jolokia }) }}
ADD jolokia.properties /opt/jolokia.properties

# S2I scripts + README
COPY s2i /usr/local/s2i
RUN chmod 755 /usr/local/s2i/*
ADD README.md /usr/local/s2i/usage.txt

{{= fp.block("run-java-sh","copy",{dest: "/opt/run-java"}) }}
# Adding run-env.sh to set app dir
COPY run-env.sh /opt/run-java/run-env.sh
RUN chmod 755 /opt/run-java/run-env.sh

# Necessary to permit running with a randomised UID
RUN mkdir -p /deployments/data \
 && chmod -R "a+rwX" /deployments

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image
USER 185

# Use the run script as default since we are working as an hybrid image which can be
# used directly to. (If we were a plain s2i image we would print the usage info here)
CMD [ "/usr/local/s2i/run" ]
