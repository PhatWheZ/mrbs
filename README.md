# mrbs
Docker version of mrbs room management system: https://mrbs.sourceforge.io
Docker hub address: https://cloud.docker.com/u/vanjor/repository/docker/vanjor/mrbs

using user defined ext config and is not required, which will append to config.inc.php: e.g. https://sourceforge.net/p/mrbs/hg-code/ci/default/tree/web/config.inc.php-sample 

example run command

```
docker run -d -p 80:80 -v your_local_ext_config_path:/var/www/mrbs_ext_config \
  -e MRBS_DB_HOST="your db host ip/dns"  \
  -e MRBS_DB_USER="your db user"  \
  -e MRBS_DB_PASSWORD="your db password"  \
  -e MRBS_DB_NAME="mrbs"  \
  -e MRBS_ADMIN_NAME="admin username"  \
  -e MRBS_ADMIN_PASSWORD="admin password"  \
  -e MRBS_TIMEZONE="CST" \
  -e MRBS_VERSION="1.7.1" \
  -e MRBS_COMPANY="Your Company Name" \
  -e MRBS_DEFAULT_VIEW="month" \
  vanjor/mrbs
```
