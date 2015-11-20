#!/bin/sh

DIR="/deployments"

echo "Checking for *.tar.gz in $DIR"
# there should be only one *.tar.gz in ${DIR}
NUM_ARCHIVE_FILES=`ls -1 ${DIR} | grep "^.*.tar.gz$" | wc -l`
if [ $NUM_ARCHIVE_FILES -ne 1 ]; then
  echo "Missing or more than one assembly archive file *.tar.gz in ${DIR}"
  exit 1
fi
KARAF_ASSEMBLY_ARCHIVE=`ls -1 ${DIR}/*.tar.gz`

# extract custom assembly to DEPLOY_DIR
tar xzf "$KARAF_ASSEMBLY_ARCHIVE" -C ${DIR}
KARAF_ASSEMBLY_DIR=${KARAF_ASSEMBLY_ARCHIVE%.tar.gz}
ln -s "${DIR}/${KARAF_ASSEMBLY_DIR##*/}" "${DIR}/karaf"

# send log output to stdout
sed -i 's/^\(.*rootLogger.*\), *out *,/\1, stdout,/' ${DIR}/karaf/etc/org.ops4j.pax.logging.cfg

# Launch Karaf using S2I script
exec /usr/local/s2i/run
