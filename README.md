### Source-to-Image Builder images

This repo holds the source for the fabric8's
[S2I](https://docs.openshift.com/enterprise/3.0/creating_images/s2i.html)
builder images for [OpenShift](http://www.openshift.com).


#### Java S2I Builder image

The S2I Java builder can be used to use generate Java S2I builds for
flat classpath applications. It supports fat-jar packaged applications, leveraging the [run-java-sh project](https://github.com/fabric8io-images/run-java-sh),
as well as applications using the [hawt-app Maven plugin](https://github.com/fabric8io/fabric8/tree/master/hawt-app-maven-plugin)
for fetching dependencies and building up an appropriate classpath.

#### Karaf S2I Builder image

The Karaf S2I Builder image is used for creating S2I builds for
[Karaf](http://karaf.apache.org/) based applications.
