{{
  var mavenRepo =
    (fp.param.base === "rhel" ? "https://repository.jboss.org/nexus/content/repositories/fs-releases" : null);
  var mavenVersion = fp.config.base.lib.version.maven;
}}FROM {{= fp.config.base.from }}

ENV JOLOKIA_VERSION="{{= fp.config.base.lib.version.jolokia }}" \
    PROMETHEUS_JMX_EXPORTER_VERSION="{{= fp.config.base.lib.version.jmxexporter }}" \
    PATH=$PATH:"/usr/local/s2i" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true" \
    JAVA_DATA_DIR="/deployments/data"

# Some version information
LABEL io.fabric8.s2i.version.maven="{{= fp.config.base.lib.version.maven }}" \
      io.fabric8.s2i.version.jolokia="{{= fp.config.base.lib.version.jolokia }}" \
      io.fabric8.s2i.version.prometheus.jmx_exporter="{{= fp.config.base.lib.version.jmxexporter }}" \
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

{{? fp.param.base === "rhel"}}
# Install Maven via SCL
COPY jboss.repo /etc/yum.repos.d/jboss.repo
RUN yum install -y --enablerepo=jboss-rhel-rhscl rh-maven33-maven \
    && yum clean all \
    && ln -s /opt/rh/rh-maven33/root/bin/mvn /usr/local/bin/mvn
{{??}}
# Dowload Maven from Apache
RUN curl https://archive.apache.org/dist/maven/maven-3/{{= mavenVersion }}/binaries/apache-maven-{{= mavenVersion }}-bin.tar.gz | \
    tar -xzf - -C /opt \
 && ln -s /opt/apache-maven-{{= mavenVersion }} /opt/maven \
 && ln -s /opt/maven/bin/mvn /usr/bin/mvn
{{?}}

{{=
  fp.block("jmxexporter", "install",
          { dest: "/opt/prometheus/prometheus-opts",
            mavenRepo: mavenRepo,
            userGroupMode: "root",
            version: fp.config.base.lib.version.jmxexporter }) }}

{{=
  fp.block("jolokia", "install",
          { dest: "/opt/jolokia/jolokia-opts",
            mavenRepo: mavenRepo,
            userGroupMode: "root",
            version: fp.config.base.lib.version.jolokia }) }}
{{? fp.param.base != "rhel"}}
# Install rsync
RUN yum install -y rsync
{{?}}
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
 && chmod -R "g+rwX" /deployments \
 && chown -R jboss:root /deployments

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image
{{? fp.param.base === "rhel"}}
USER 185
RUN mkdir -p /home/jboss/.m2
COPY settings.xml /home/jboss/.m2/settings.xml
{{??}}
USER 1000
RUN mkdir -p /opt/jboss/.m2
COPY settings.xml /opt/jboss/.m2/settings.xml
{{?}}

RUN mkdir -p /deployments/data

# Use the run script as default since we are working as an hybrid image which can be
# used directly to. (If we were a plain s2i image we would print the usage info here)
CMD [ "/usr/local/s2i/run" ]
