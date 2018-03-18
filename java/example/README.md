# s2i-java-example

This S2I example is intentionally NOT using Spring Boot, Vert.x, Dropwizard, Wildfly Swarm or whatever other simple "fat JAR" (non-WAR/EAR) Java
server framework, but for clarity simply uses the simplest possible Java server application with a main() class.  You can easily apply this example to whatever standalone Java application you want to container-ize with S2I.  (We're using the Java built-in com.sun.net.httpserver.HttpServer; *JUST* for illustration of S2I.)


## Local

For local building, install s2i either from source https://github.com/openshift/source-to-image/releases/ or e.g. via:

    sudo dnf install source-to-image

Now to build the simplest possible Java server with OpenShift Source-To-Image (S2I) using the fabric8io-images/s2i builder:

    s2i build https://github.com/vorburger/s2i-java-example fabric8/s2i-java vorburger:s2i-java-example

or

    git clone https://github.com/vorburger/s2i-java-example ; cd s2i-java-example
    s2i build --copy . fabric8/s2i-java vorburger:s2i-java-example

_NB The `--copy` ensures that the latest content of the current directory and not only it's commited .git content is used ([see S2I #418](https://github.com/openshift/source-to-image/issues/418))._

Now run it like this:

    docker run -p 8080:8080 vorburger:s2i-java-example

and see "hello, world" when accessing http://localhost:8080 - it works!


## OpenShift

To do the same as above directly inside your OpenShift instance like this:

    oc new-app fabric8/s2i-java~https://github.com/vorburger/s2i-java-example
    oc expose svc/s2i-java-example --port=8080
    oc status
    minishift openshift service s2i-java-example --in-browser

**TODO this is still NOK due to a missing EXPOSE 8080 in the Dockerfile of fabric8/s2i-java, see https://github.com/fabric8io-images/s2i/issues/115 :-(**

_NB that you cannot really build from "the latest sources from the local filesystems", because there is no `s2i build --copy` equivalent; attempting to do e.g. `oc new-app fabric8/s2i-java~.` just fetches from the first git remote of `./.git` ... :-(_


## Advanced

### Container options

All JVM options documented on https://github.com/fabric8io-images/s2i/tree/master/java/images/jboss
are typically specified in [`.s2i/environment`](.s2i/environment), but  for quick testing can obviously also be specified on the `docker run` CLI like so:

    docker run -e "JAVA_MAIN_CLASS=ch.vorburger.openshift.s2i.example.Server" -p 8080:8080 vorburger:s2i-java-example


### fabric8io-images/s2i self build locally and in OpenShift

If you want to use latest fabric8/s2i-java from source instead of an older image on hub.docker.com, then you can do that.  Here's how for local Docker:

    docker build https://github.com/fabric8io-images/s2i.git#master:java/images/jboss

or:

    git clone https://github.com/fabric8io-images/s2i.git
    cd java/images/jboss
    docker build . -t fabric8/s2i-java

and inside OpenShift:

    oc new-build https://github.com/fabric8io-images/s2i.git --context-dir=java/images/jboss

_NB As above, you cannot really build from "the latest sources from the local filesystems", but you can push in-development changes to a remote and test that, like this:_

    oc new-build https://github.com/YOURID/s2i.git#GITBRANCH --context-dir=java/images/jboss

and then test using that like this:

    oc new-app s2i~https://github.com/vorburger/s2i-java-example


### How to clean up

    oc delete imagestream s2i-java
    oc delete imagestream s2i-java-example
    oc delete build s2i-java-example-1
    oc delete buildconfig s2i-java-example
    oc delete deploymentconfig s2i-java-example
    oc delete service s2i-java-example


## TODO points

* Why isn't it incremental?  Keeps re-downloading Maven basics, every time..
* Support Gradle!
* Monitoring..
* Sources should not be runtime container?!


## More background

* https://github.com/fabric8io-images/s2i
* https://github.com/fabric8io-images/s2i/tree/master/java/images/jboss
* https://github.com/fabric8io-images/s2i/issues/112
* https://github.com/openshift/source-to-image

