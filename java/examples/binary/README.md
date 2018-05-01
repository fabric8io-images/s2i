# s2i-java-binary-example

This S2I example illustrates how to build a container image for a previously existing Java binary JAR.
In this example, one is copied from ../maven/target; but typically you instead would have it downloaded from somewhere.

If you have a project with Java sources, you are probably more interested in using the [Maven](../maven/) or [Gradle](../gradle/) examples, instead.

## Usage

    mvn -f ../maven/ clean package
    cp ../maven/target/*.jar deployments/
    s2i build --copy . fabric8/s2i-java s2i-java-binary-example
    docker run -p 8080:8080 s2i-java-binary-example

See the [README of the Maven example](../maven/README.md) for more information.
