# s2i-java-gradle-example

## Usage

### OpenShift

    oc new-app fabric8/s2i-java~https://github.com/fabric8io-images/s2i --context-dir=java/examples/gradle --name s2i-gradle-example

### S2I

    s2i build --copy . fabric8/s2i-java s2i-java-gradle-example
    docker run -p 8080:8080 s2i-java-gradle-example

### Gradle locally

    ./gradlew build
    java -jar build/libs/s2i-java-gradle-example.jar

See the [README of the Maven example](../maven/README.md) for more information.
