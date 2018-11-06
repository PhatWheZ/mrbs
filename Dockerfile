FROM php:5.6-apache
MAINTAINER vanjor2008@gmail.com

RUN apt-get update \
    && apt-get install -y mysql-client \
    && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-install pdo pdo_mysql iconv

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
