# s2i-java-maven-wrapper-example

This S2I example illustrates how to use the Maven wrapper when a newer version of Maven than the one included in base image is required.

## Usage

    ./mvnw test    

    s2i build --copy . fabric8/s2i-java s2i-java-maven-wrapper-example

See the [README of the Maven example](../maven/README.md) for more information.
