{{
  var mavenRepo =
    (fp.param.base === "rhel" ? "https://repository.jboss.org/nexus/content/repositories/fs-releases" : null);
  var mavenVersion = fp.config.base.lib.version.maven;
}}FROM {{= fp.config.base.from }}

MAINTAINER Dhiraj Bokde <dhirajsb@gmail.com>

ENV JOLOKIA_VERSION="{{= fp.config.base.lib.version.jolokia }}" \
    PATH="/usr/local/s2i:$PATH" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true"

# Expose jolokia port
EXPOSE 8778

LABEL io.fabric8.s2i.version.maven="{{= fp.config.base.lib.version.maven }}" \
      io.fabric8.s2i.version.jolokia="{{= fp.config.base.lib.version.jolokia }}" \
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


# Install Maven via SCL
{{? fp.param.base === "rhel"}}
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
  fp.block("jolokia", "install",
          { dest: "/opt/jolokia/jolokia-opts",
            mavenRepo: mavenRepo,
            userGroupMode: "root",
            version: fp.config.base.lib.version.jolokia }) }}

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
{{? fp.param.base === "rhel"}}
USER 185
RUN mkdir -p /home/jboss/.m2
COPY settings.xml /home/jboss/.m2/settings.xml
{{??}}
USER 1000
RUN mkdir -p /opt/jboss/.m2
COPY settings.xml /opt/jboss/.m2/settings.xml
{{?}}

CMD ["usage"]
