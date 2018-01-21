FROM php:5.6-apache
MAINTAINER DaSilva2010@arcor.de

ENV MRBS_VERSION=1_7_0

RUN apt-get update \
    && apt-get install -y mercurial mysql-client \
    && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-install pdo pdo_mysql iconv

# Clone sources
RUN hg clone -r default  http://hg.code.sf.net/p/mrbs/hg-code /tmp/mrbs-hg-code \
    && cd /tmp/mrbs-hg-code \
    && hg up mrbs-$MRBS_VERSION \
    && mv /tmp/mrbs-hg-code/web/* /var/www/html \
    && mv /tmp/mrbs-hg-code/tables.my.sql /var/www/html

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
