#!/bin/bash

DIR="/deployments"

echo "Checking for archives in $DIR"
if [ `ls ${DIR} | grep "^.*\.zip$" | wc -l` -eq 1 ]; then  
  #
  # zip
  # 
  KARAF_ASSEMBLY_ARCHIVE=`echo ${DIR}/*.zip`
  KARAF_ASSEMBLY_DIR=${KARAF_ASSEMBLY_ARCHIVE%.zip}

  echo "Found $KARAF_ASSEMBLY_ARCHIVE in ${DIR}"
  
  # extract custom assembly to DEPLOY_DIR
  cd ${DIR} && jar xf "$KARAF_ASSEMBLY_ARCHIVE" 
elif [ `ls ${DIR} | grep "^.*\.tar.gz$" | wc -l` -eq 1 ]; then
  #
  # tar.gz
  # 
  KARAF_ASSEMBLY_ARCHIVE=`echo ${DIR}/*.tar.gz`  
  KARAF_ASSEMBLY_DIR=${KARAF_ASSEMBLY_ARCHIVE%.tar.gz}

  echo "Found $KARAF_ASSEMBLY_ARCHIVE in ${DIR}"

  # extract custom assembly to DEPLOY_DIR  
  cd ${DIR} && tar xzf "$KARAF_ASSEMBLY_ARCHIVE"
elif [ `ls ${DIR} | grep "^.*\.tgz$" | wc -l` -eq 1 ]; then
  #
  # tgz
  # 
  KARAF_ASSEMBLY_ARCHIVE=`echo ${DIR}/*.tgz`
  KARAF_ASSEMBLY_DIR=${KARAF_ASSEMBLY_ARCHIVE%.tgz}

  echo "Found $KARAF_ASSEMBLY_ARCHIVE in ${DIR}"

  # extract custom assembly to DEPLOY_DIR  
  cd ${DIR} && tar xzf "$KARAF_ASSEMBLY_ARCHIVE"
fi

if [ -n "${KARAF_ASSEMBLY_DIR}" ] && [ -d "${KARAF_ASSEMBLY_DIR}" ]; then
  ln -s "${DIR}/${KARAF_ASSEMBLY_DIR##*/}" "${DIR}/karaf"

  # send log output to stdout
  sed -i 's/^\(.*rootLogger.*\), *out *,/\1, stdout,/' ${DIR}/karaf/etc/org.ops4j.pax.logging.cfg

  # Launch Karaf using S2I script
  exec /usr/local/s2i/run
else
  echo "Missing or more than one assembly archive file in ${DIR}"
  echo `ls ${DIR}`
  exit 1
fi
