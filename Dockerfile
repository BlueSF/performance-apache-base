FROM php:7.1-apache
MAINTAINER Kang Ki Tae <kt.kang@ridi.com>

RUN docker-php-source extract \

# Install common
&& apt-get update \
&& apt-get install wget software-properties-common vim git mysql-client zlib1g-dev libmcrypt-dev libldap2-dev -y \
&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
&& docker-php-ext-install ldap pdo zip pdo_mysql \

# Install couchbase php extention
&& wget http://packages.couchbase.com/ubuntu/couchbase.key && apt-key add couchbase.key && rm couchbase.key  \
&& add-apt-repository 'deb http://packages.couchbase.com/ubuntu trusty trusty/main' \
&& apt-get update \
&& apt-get install -y build-essential libcouchbase2-core libcouchbase-dev libcouchbase2-bin libcouchbase2-libevent \
&& pecl install couchbase-2.2.3 \
&& docker-php-ext-enable couchbase \

# Install xdebug php extention
&& pecl config-set preferred_state beta \
&& pecl install -o -f xdebug \
&& rm -rf /tmp/pear \
&& pecl config-set preferred_state stable \

# Install node && bower
&& curl -sL https://deb.nodesource.com/setup_6.x | bash - \
&& apt-get install nodejs -y \
&& npm install -g bower \

# Install composer
&& curl -sS https://getcomposer.org/installer | php \
&& mv composer.phar /usr/bin/composer \

# Clean
&& apt-get autoclean -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
&& docker-php-source delete

# Additional php ini configurations
ADD ./php/*.ini* /usr/local/etc/php/conf.d/

# Define env variables
ENV XDEBUG_ENABLE 0
ENV PHP_TIMEZONE Asia/Seoul
ENV APACHE_DOC_ROOT /var/www/html

# Enable apache mod and add php info page.
RUN a2enmod rewrite
ADD ./index.php /var/www/html/index.php

# Change entrypoint
ADD ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["apache2-foreground"]