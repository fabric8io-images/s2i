# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]
_TODO_


## [3.0.0] - 2018-12-07
### New Features
- Java: Java 11 support!  Uses Maven 3.6 instead of 3.5.  ([#160](https://github.com/fabric8io-images/s2i/issues/160))
- Java: EXPOSE 8080 by default  ([#115](https://github.com/fabric8io-images/s2i/issues/115))

### Improvements
- Camel: Add LastProcessingTime and DeltaProcessingTime to Prometheus Metrics  ([ENTESB-9524](https://issues.jboss.org/browse/ENTESB-9524))
- Java & Karaf: yum update  ([#172](https://github.com/fabric8io-images/s2i/issues/172))
- Java & Karaf: FROM centos:7 instead centos:7.5.1804  ([#172](https://github.com/fabric8io-images/s2i/issues/172))
- Java: EXPOSE 8080 by default  ([#115](https://github.com/fabric8io-images/s2i/issues/115))
- Java & Karaf: yum clean all - reduces image sizes, and aligns RHEL and CentOS community images
- Java: yum install --setopt=skip_missing_names_on_install=False  ([#206](https://github.com/fabric8io-images/s2i/issues/206))

### Bug Fixes
- Java: Add unzip back again  ([#184](https://github.com/fabric8io-images/s2i/issues/184))
- Java & Karaf: Fix broken build by ditching Java 8 package minor version number  ([#206](https://github.com/fabric8io-images/s2i/issues/206))
- Camel: Metric label values enclosed in double quotes  ([ENTESB-9818](https://issues.jboss.org/browse/ENTESB-9818))

### Testing
- Java: Make container image to test flexible in test.sh
- Java: Add test coverage for JVM metrics exposure  ([#200](https://github.com/fabric8io-images/s2i/issues/200))


## [2.3.1] - 2018-08-10
### Bug Fixes
- Java: Set working directory back to /home/jboss  ([#169](https://github.com/fabric8io-images/s2i/issues/169))


## [2.3.0] - 2018-07-31
### New Features
- Java: Gradle support!  ([#118](https://github.com/fabric8io-images/s2i/issues/118))
- Java: Maven wrapper support (`./mvnw`)

### Improvements
- Java & Karaf: FROM centos:7.5.1804 instead jboss/base-jdk:8
- Java: Bump to Jolokia 1.5.0

### Bug Fixes
- Karaf: Added --jit option for Karaf options to add TieredStopAtLevel  ([OSFUSE-754](https://issues.jboss.org/browse/OSFUSE-754))
- Karaf: make all Karaf *.cfg files under etc directory writable  ([OSFUSE-778](https://issues.jboss.org/browse/OSFUSE-778))

### Doc, Examples & Testing
- Java: Add examples illustrating Maven, Binary & Gradle use cases
- Java: Add full image end-to-end self test


[Unreleased]: https://github.com/fabric8io-images/s2i/compare/v3.0.0...HEAD
[3.0.0]: https://github.com/fabric8io-images/s2i/compare/v2.3.1...v3.0.0
[2.3.1]: https://github.com/fabric8io-images/s2i/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/fabric8io-images/s2i/compare/v2.2.0...v2.3.0
