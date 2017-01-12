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
  cd ${DIR} && unzip "$KARAF_ASSEMBLY_ARCHIVE"
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
elif [ `find ${DIR} -type f -name karaf | grep "^.*\/bin\/karaf$" | wc -l` -eq 1 ]; then
  #
  # unpacked assembly in a subdirectory
  #
  KARAF_SCRIPT=`find ${DIR} -type f -name karaf | grep "^.*\/bin\/karaf$"`
  KARAF_SCRIPT=${KARAF_SCRIPT##${DIR}/}
  KARAF_ASSEMBLY_DIR=${KARAF_SCRIPT%%/bin/karaf}

  echo "Found $KARAF_ASSEMBLY_DIR in ${DIR}"
  cd ${DIR}
fi

if [ -n "${KARAF_ASSEMBLY_DIR}" ] && [ -d "${KARAF_ASSEMBLY_DIR}" ]; then
  ln -s "${DIR}/${KARAF_ASSEMBLY_DIR##*/}" "${DIR}/karaf"

  # send log output to stdout
  sed -i 's/^\(.*rootLogger.*\), *out *,/\1, stdout,/' ${DIR}/karaf/etc/org.ops4j.pax.logging.cfg

  # allow overriding defaults in setenv
  sed -i 's/^\(JAVA_.*\)=\([^ ]*\)/\1=${\1:-\2}/' ${DIR}/karaf/bin/setenv

  # Launch Karaf using S2I script
  exec /usr/local/s2i/run
else
  echo "Missing, or more than one, assembly or archive file in ${DIR}"
  echo `ls ${DIR}`
  exit 1
fi
