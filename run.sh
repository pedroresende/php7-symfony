#!/bin/bash

# PHP 7

# Dependencies
apt-get update
apt-get dist-upgrade -y
apt-get install -y \
    git-core \
    autoconf \
    bison \
    libxml2-dev \
    libbz2-dev \
    libmcrypt-dev \
    libcurl4-openssl-dev \
    libltdl-dev \
    libpng-dev \
    libpspell-dev

mkdir -p /etc/php7/conf.d
mkdir -p /etc/php7/{cli,fpm}/conf.d
mkdir /usr/local/php7

git clone https://github.com/php/php-src.git
cd php-src
git reset --hard 960d103d63f3e9e690853b0a07b82195d0f0cfbf
./buildconf

CONFIGURE_STRING="--prefix=/usr/local/php7 \
                  --enable-bcmath \
                  --with-bz2 \
                  --enable-calendar \
                  --enable-exif \
                  --enable-dba \
                  --enable-ftp \
                  --with-gettext \
                  --with-gd \
                  --enable-mbstring \
                  --with-mcrypt \
                  --with-mhash \
                  --enable-mysqlnd \
                  --with-mysql=mysqlnd \
                  --with-mysqli=mysqlnd \
                  --with-pdo-mysql=mysqlnd \
                  --with-openssl \
                  --enable-pcntl \
                  --with-pspell \
                  --enable-shmop \
                  --enable-soap \
                  --enable-sockets \
                  --enable-sysvmsg \
                  --enable-sysvsem \
                  --enable-sysvshm \
                  --enable-wddx \
                  --with-zlib \
                  --enable-zip \
                  --with-readline \
                  --with-curl"

# Build CLI
./configure \
    $CONFIGURE_STRING \
    --with-config-file-path=/etc/php7/cli \
    --with-config-file-scan-dir=/etc/php7/cli/conf.d

make
make install

PATH=$PATH:/usr/local/php7/bin
echo 'export PATH="$PATH:/usr/local/php7/bin"' >> /etc/bash.bashrc

# Build FPM
make clean

./configure \
    $CONFIGURE_STRING \
    --with-config-file-path=/etc/php7/fpm \
    --with-config-file-scan-dir=/etc/php7/fpm/conf.d \
    --disable-cli \
    --enable-fpm \
    --with-fpm-user=vagrant \
    --with-fpm-group=vagrant

make
make install

# Activate modules
API_VERSION=`ls -d /usr/local/php7/lib/php/extensions/no-debug-non-zts-* | xargs basename | cut -d- -f5` 
echo "zend_extension=/usr/local/php7/lib/php/extensions/no-debug-non-zts-${API_VERSION}/opcache.so" > /etc/php7/conf.d/opcache.ini
ln -s /etc/php7/conf.d/opcache.ini /etc/php7/cli/conf.d/opcache.ini
ln -s /etc/php7/conf.d/opcache.ini /etc/php7/fpm/conf.d/opcache.ini

# Install init scripts
cp -R /vagrant/etc/* /etc
chmod +x /etc/init.d/php7-fpm
update-rc.d php7-fpm defaults
service php7-fpm start

