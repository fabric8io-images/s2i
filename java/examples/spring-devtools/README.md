# s2i-java-spring-devtools-example

This is an project illustrating [Spring Boot Automatic Restarts](../../images/centos/README.md#spring-boot-automatic-restarts).


## Local without container

Run using:

    mvn spring-boot:run

Open [http://localhost:8080/hello](http://localhost:8080/hello) - see "hello, xorld" ? Wrong.

Edit `src/main/java/io/okd/s2i/java/spring/example/HelloServlet.java` to change "hello, xorld" to "hello, world".
Use an IDE like Eclipse, with incremental rebuild of the .class file (won't work with a raw text editor).

Spring Boot devtools will automatically restart and (on reloading /hello) show "hello, world" - good.


## Local in container by S2I

For local building, install s2i either from source https://github.com/openshift/source-to-image/releases/ or e.g. via:

    sudo dnf install source-to-image

Now to locally build a container using OpenShift Source-To-Image (S2I) use:

    s2i build --copy . fabric8/s2i-java s2i-java-spring-devtools-example

Now run it like this:

    docker run -p 8080:8080 s2i-java-spring-devtools-example

and see "hello, xorld" when accessing [http://localhost:8080/hello](http://localhost:8080/hello) - it works, but oups, it's wrong.

Edit `src/main/java/io/okd/s2i/java/spring/example/HelloServlet.java` to change "hello, xorld" to "hello, world".
Use an IDE like Eclipse, with incremental rebuild of the .class file (won't work with a raw text editor).
Now copy the fixed class file into the running container:

    docker cp src/main/java/io/okd/s2i/java/spring/example/HelloServlet.java  $(docker ps --filter ancestor=s2i-java-spring-devtools-example --format "{{.ID}}"):/TODO

_TODO NOK; cp .class or .java? What is the right path to copy it into?  /deployments/ has .jar not .class? /tmp/src(/target) isn't what we want?? Check:_

    docker exec -it $(docker ps --filter ancestor=s2i-java-spring-devtools-example --format "{{.ID}}") bash

**Spring Boot devtools will automatically restart, in container, and (on reloading /hello) show "hello, world" - great!**



## In OpenShift via MiniShift

_[oc rsync](https://docs.okd.io/latest/dev_guide/copy_files_to_container.html)_

**TODO**
