#!/bin/sh
set -ex

cd java ; fish-pepper ; cd ..

docker build java/images/jboss/ -t fabric8/s2i-java

s2i build --copy java/images/example fabric8/s2i-java fabric8/s2i-java-example

docker run -p 8080:8080 fabric8/s2i-java-example

# TODO how to do simplest possible HTTP GET http://localhost:8080 and fail/pass?
# TODO how to best stop docker again
# kill $!
