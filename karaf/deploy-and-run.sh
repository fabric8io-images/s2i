#!/bin/sh

DIR=${DEPLOY_DIR:-/maven}

# Output will result in /opt/jboss folder
DEPLOY_DIR=/opt/jboss
mkdir -p ${DEPLOY_DIR}

echo "Checking for *.tar.gz in $DIR"
if [ ! -d $DIR ]; then
  echo "Missing assembly archive directory ${DIR}..."
  exit 1
fi

# there should be only one *.tar.gz in ${DIR}
NUM_ARCHIVE_FILES=`ls -1 ${DIR} | grep "^.*.tar.gz$" | wc -l`
if [ $NUM_ARCHIVE_FILES -ne 1 ]; then
  echo "Missing or more than one assembly archive file *.tar.gz in ${DIR}"
  exit 1
fi
KARAF_ASSEMBLY_ARCHIVE=`ls -1 ${DIR}/*.tar.gz`

# extract custom assembly to DEPLOY_DIR
tar xzf "$KARAF_ASSEMBLY_ARCHIVE" -C ${DEPLOY_DIR}
KARAF_ASSEMBLY_DIR=${KARAF_ASSEMBLY_ARCHIVE%.tar.gz}
ln -s "${DEPLOY_DIR}/${KARAF_ASSEMBLY_DIR##*/}" "${DEPLOY_DIR}/karaf"

# send log output to stdout
sed -i 's/^\(.*rootLogger.*\)out/\1stdout/' ${DEPLOY_DIR}/karaf/etc/org.ops4j.pax.logging.cfg

# Launch Karaf using S2I script
/usr/local/s2i/run
