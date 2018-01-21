#!/bin/bash

: "${MRBS_DB_HOST:=mysql}"
: ${MRBS_DB_USER:=${MYSQL_ENV_MYSQL_USER:-root}}
if [ "$MRBS_DB_USER" = 'root' ]; then
  : ${MRBS_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi

: ${MRBS_DB_PASSWORD:=$MYSQL_ENV_MYSQL_PASSWORD}
: ${MRBS_DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE:-mrbs}}
: "${MRBS_ADMIN_NAME:=administrator}"
: "${MRBS_ADMIN_PASSWORD:=secret}"

if [ -z "$MRBS_DB_PASSWORD" ]; then
  echo >&2 'error: missing required MRBS_DB_PASSWORD environment variable'
  echo >&2 '  Did you forget to -e MRBS_DB_PASSWORD=... ?'
  echo >&2
  echo >&2 '  (Also of interest might be MRBS_DB_USER and MRBS_DB_NAME.)'
  exit 1
fi

# set timezone
: ${TZ=${TIMEZONE:-"UTC"}}
sed -i 's!^//$timezone.*$!$timezone="'"${TZ}"'";!' config.inc.php

# configure database connection

sed -i /\$db_host/s/localhost/"${MRBS_DB_HOST}"/ config.inc.php
sed -i /\$db_database/s/mrbs/"${MRBS_DB_NAME}"/ config.inc.php
sed -i /\$db_login/s/mrbs/"${MRBS_DB_USER}"/ config.inc.php
sed -i /\$db_password/s/mrbs-password/"${MRBS_DB_PASSWORD}"/ config.inc.php

# initialize database
if [ -f tables.my.sql ]; then
  mysql --user=$MRBS_DB_USER --password=$MRBS_DB_PASSWORD --host=$MRBS_DB_HOST --database=$MRBS_DB_NAME < tables.my.sql
  rm tables.my.sql
fi
if [ ! -f initialized ]; then
  echo "\$auth[\"type\"] = \"config\";" >> config.inc.php
  echo "unset(\$auth[\"user\"]);" >> config.inc.php
  echo "\$auth[\"user\"][\"$MRBS_ADMIN_NAME\"] = \"$MRBS_ADMIN_PASSWORD\";" >> config.inc.php
  touch initialized
fi

/usr/sbin/apache2ctl -D FOREGROUND
