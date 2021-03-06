#!/bin/sh

pwgen() {
  tr -cd '[:alnum:]' < /dev/urandom | fold -w$1 | head -n1
}

# Copy default plugins
if [ -z "$(ls -A ${APP_HOME}/plugins)" ]; then
  echo "Empty ${APP_HOME}/plugins directory detected:"
  echo "... Copying default plugins from ${APP_HOME}/default-plugins"

  cd ${APP_HOME}/default-plugins
  for pluginjar in *; do
    pluginbasename=${pluginjar%%-[0-9\.]*.jar}
    if [ -f ${APP_HOME}/plugins/*/$pluginbasename-[0-9\.]*.jar ]; then
      echo "... Not copying $pluginrepo/$pluginjar because a version of that plugin already exists in the plugins directory"
    else
      cp -R ${APP_HOME}/default-plugins/$pluginrepo/$pluginjar ${APP_HOME}/plugins/$pluginrepo/
    fi
  done
  cd ${APP_HOME}

  echo "Done"
fi

# Set up new installation
if [ ! -f "${APP_HOME}/ext/xldeploy-configuration/deployit.conf" ]; then
  echo "No ${APP_HOME}/conf/deployit.conf file detected:"
  echo "... create and link ${APP_HOME}/ext/xldeploy-configuration"
  mkdir -p ${APP_HOME}/ext/xldeploy-configuration
  rm -rf ${APP_HOME}/conf
  ln -s ${APP_HOME}/ext/xldeploy-configuration ${APP_HOME}/conf
  echo "... Copying default configuration from ${APP_HOME}/default-conf"

  cd ${APP_HOME}/default-conf
  for f in *; do
    if [ -f ${APP_HOME}/conf/$f ]; then
      echo "... Not copying $f because it already exists in the conf directory"
    else
      cp -R $f ${APP_HOME}/conf/
    fi
  done
  cd ${APP_HOME}

  echo "Done"

  if [ $# -eq 0 ]; then
    echo "No arguments passed to container:"
    echo "... Running default setup"

    if [ "${ADMIN_PASSWORD}" = "" ]; then
      ADMIN_PASSWORD=`pwgen 8`
      echo "... Generating admin password: ${ADMIN_PASSWORD}"
    fi

    if [ "${REPOSITORY_KEYSTORE_PASSPHRASE}" = "" ]; then
      REPOSITORY_KEYSTORE_PASSPHRASE=`pwgen 16`
      echo "... Generating repository keystore passphrase: ${REPOSITORY_KEYSTORE_PASSPHRASE}"
    fi
    echo "... Generating repository keystore"
    keytool -genseckey -alias deployit-passsword-key -keyalg aes -keysize 128 -keypass "deployit" -keystore ${APP_HOME}/conf/repository-keystore.jceks -storetype jceks -storepass ${REPOSITORY_KEYSTORE_PASSPHRASE}

    echo "... Generating deployit.conf"
    sed -e "s/\${ADMIN_PASSWORD}/${ADMIN_PASSWORD}/g" -e "s/\${REPOSITORY_KEYSTORE_PASSPHRASE}/${REPOSITORY_KEYSTORE_PASSPHRASE}/g" ${APP_HOME}/conf/deployit.conf.template > ${APP_HOME}/conf/deployit.conf

    echo "Done"
  fi
else
  echo "Existing  ${APP_HOME}/conf/deployit.conf file detected:"
  echo "... only link ${APP_HOME}/ext/xldeploy-configuration"
  rm -rf ${APP_HOME}/conf
  ln -s ${APP_HOME}/ext/xldeploy-configuration ${APP_HOME}/conf
  ls -l ${APP_HOME}/ext/xldeploy-configuration
fi

echo "Manage the database configuration..."
echo "... copy JDBC Drivers to ${APP_HOME}/lib"
find ${APP_HOME}/drivers

cp ${APP_HOME}/drivers/*.jar ${APP_HOME}/lib

if [ "${JDBC_PASSWORD}" = "" ]; then
  echo "... Please provide a password for the jdbc connection to the database"
  exit 1
fi

if [ "${JDBC_USERNAME}" = "" ]; then
  echo "... Please provide a username for the jdbc connection to the database"
  exit 1
fi

if [ "${JDBC_DRIVER}" = "" ]; then
  echo "... Please provide a driver class for the jdbc connection to the database"
  exit 1
fi

if [ "${JDBC_URL}" = "" ]; then
  echo "... Please provide a url for the jdbc connection to the database"
  exit 1
fi

echo "... db username ${JDBC_USERNAME}"
echo "... db url      ${JDBC_URL}"
echo "... db driver   ${JDBC_DRIVER}"
echo "... Generating  ${APP_HOME}/conf/xl-deploy.conf"

sed -e "s/\${JDBC_PASSWORD}/${JDBC_PASSWORD}/g" -e "s/\${JDBC_USERNAME}/${JDBC_USERNAME}/g" -e "s#\${JDBC_URL}#${JDBC_URL}#g" -e "s/\${JDBC_DRIVER}/${JDBC_DRIVER}/g"  ${APP_HOME}/conf/xl-deploy.conf.template > ${APP_HOME}/conf/xl-deploy.conf



# Generate node specific configuration with IP address of container
IP_ADDRESS=$(hostname -i)
sed -e "s/\${IP_ADDRESS}/${IP_ADDRESS}/g" ${APP_HOME}/node-conf/xl-deploy.conf.template > ${APP_HOME}/node-conf/xl-deploy.conf

# Start regular startup process
exec ${APP_HOME}/bin/run.sh "$@"
