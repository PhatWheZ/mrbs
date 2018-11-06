#!/bin/bash

# versions see: https://sourceforge.net/projects/mrbs/files/
# shell default value: https://unix.stackexchange.com/questions/122845/using-a-b-for-variable-assignment-in-scripts
: "${MRBS_VERSION:=1.7.1}"
# download web file and deploy
cd /tmp/ \
&& curl -O "https://jaist.dl.sourceforge.net/project/mrbs/mrbs/MRBS%20${MRBS_VERSION}/mrbs-${MRBS_VERSION}.tar.gz" \
&& tar -zxvf mrbs-$MRBS_VERSION.tar.gz \
&& rm -rf mrbs-$MRBS_VERSION.tar.gz \
&& rm -rf /var/www/html/* \
&& mv /tmp/mrbs-$MRBS_VERSION/web/* /var/www/html \
&& mv /tmp/mrbs-$MRBS_VERSION/tables.my.sql /var/www/html


# initial parameters
: "${MRBS_DB_SYS:=mysql}"
: "${MRBS_DB_NAME:=mrbs}"


if [ -z "$MRBS_DB_HOST" ]; then
  echo >&2 'error: missing required MRBS_DB_HOST env var'
  exit 1
fi

if [ -z "$MRBS_DB_USER" ]; then
  echo >&2 'error: missing required MRBS_DB_USER env var'
  exit 1
fi

if [ -z "$MRBS_DB_PASSWORD" ]; then
  echo >&2 'error: missing required MRBS_DB_PASSWORD env var'
  exit 1
fi

: "${MRBS_ADMIN_NAME:=administrator}"
: "${MRBS_ADMIN_PASSWORD:=secret}"

: "${MRBS_TIMEZONE=${TIMEZONE:-"GMT"}}"

# injected parameters and update msbr config
cd /var/www/html
sed -i 's!^//$timezone.*$!$timezone="'"${MRBS_TIMEZONE}"'";!' config.inc.php

sed -i /\$dbsys/s/mysql/"${MRBS_DB_SYS}"/ config.inc.php
sed -i /\$db_host/s/localhost/"${MRBS_DB_HOST}"/ config.inc.php
sed -i /\$db_database/s/mrbs/"${MRBS_DB_NAME}"/ config.inc.php
sed -i /\$db_login/s/mrbs/"${MRBS_DB_USER}"/ config.inc.php
sed -i /\$db_password/s/mrbs-password/"${MRBS_DB_PASSWORD}"/ config.inc.php


# initialize database
# notes this can be fail if the db table already initialized
if [ -f tables.my.sql ]; then
  mysql --user=$MRBS_DB_USER --password=$MRBS_DB_PASSWORD --host=$MRBS_DB_HOST --database=$MRBS_DB_NAME < tables.my.sql  || true
  rm tables.my.sql
fi

# initial admin user
if [ ! -f initialized ]; then
  echo "\$auth[\"type\"] = \"config\";" >> config.inc.php
  echo "unset(\$auth[\"user\"]);" >> config.inc.php
  echo "\$auth[\"user\"][\"$MRBS_ADMIN_NAME\"] = \"$MRBS_ADMIN_PASSWORD\";" >> config.inc.php
  echo "\$auth[\"admin\"][] = \"$MRBS_ADMIN_NAME\";" >> config.inc.php
  touch initialized
fi

# some major feature setting
: "${MRBS_COMPANY:=Your Company}"
: "${MRBS_DEFAULT_VIEW:=day}"
echo "\$mrbs_company = \"${MRBS_COMPANY}\";" >> config.inc.php
echo "\$default_view = \"${MRBS_DEFAULT_VIEW}\";" >> config.inc.php

# write ext config
: "${MRBS_EXT_CONFIG_FILE_PATH:=/var/www/mrbs_ext_config}"
if [ -f $MRBS_EXT_CONFIG_FILE_PATH ]; then
  echo "//append with ext config from ${MRBS_EXT_CONFIG_FILE_PATH}"
  cat $MRBS_EXT_CONFIG_FILE_PATH >> config.inc.php
fi

# write the ping file
echo "SUCCESS" > ping


/usr/sbin/apache2ctl -D FOREGROUND
