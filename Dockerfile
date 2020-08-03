FROM php:7.4.5-cli-alpine3.11
LABEL maintainer="ekinhbayar"

# Download script to install PHP extensions and dependencies
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync

RUN apk update \
    && install-php-extensions \
      gd \
      intl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install tideways_xhprof
RUN curl -fsSL 'https://github.com/tideways/php-xhprof-extension/archive/v5.0.2.tar.gz' -o tideways-xhprof.tar.gz \
    && mkdir -p tideways-xhprof \
    && tar -xf tideways-xhprof.tar.gz -C tideways-xhprof \
    && rm tideways-xhprof.tar.gz \
    && apk update \
    && apk add autoconf m4 g++ gcc libc-dev make file \
    && ( \
        cd tideways-xhprof/php-xhprof-extension-5.0.2 \
        && phpize \
        && ./configure \
        && make -j "$(nproc)" \
        && make install \
    ) \
    && rm -r tideways-xhprof \
    && docker-php-ext-enable tideways_xhprof
