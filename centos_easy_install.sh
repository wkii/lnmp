#!/bin/bash

####### 注意，为避免网络问题下载软件包失败，请先下载软件包到当前脚本目录同级的soft目录中 ######
####### 要下载的包在下面的wget 列表中 ###############

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Disable SeLinux
if [ -s /etc/selinux/config ]; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

# 时区设置
#Synchronization time
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

yum install -y ntp
ntpdate -u pool.ntp.org
date

# 旧软件清理
rpm -qa|grep httpd
rpm -e httpd
rpm -qa|grep mysql
rpm -e mysql
rpm -qa|grep php
rpm -e php

yum -y remove httpd*
yum -y remove php*
yum -y remove mysql-server mysql mysql-libs
yum -y remove php-mysql
yum -y remove autoconf

yum -y install yum-fastestmirror
yum -y update

#################### 公用包安装 ####################
# public
yum -y install gcc gcc-c++ make wget
# for php
yum -y install libxml2 libxml2-devel zlib-devel
yum -y install openssl openssl-devel
yum -y install curl curl-devel
yum -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel
yum -y install openldap openldap-devel cyrus-sasl-devel
yum -y install bzip2 bzip2-devel
yum -y install libxslt libxslt-devel
yum -y install ImageMagick ImageMagick-devel
yum -y install net-snmp-devel
yum -y install readline-devel

# for memcached
yum -y install libevent libevent-devel

cur_dir=$(pwd)
soft_dir=$cur_dir"/soft"
runtime_dir=$cur_dir"/runtime"
mkdir -p soft
mkdir -p runtime
cd $soft_dir

################### 必要的软件包 #####################
# pcre with nginx
# autoconf libiconv mcrypt libmcrypt mhash php5.5
# wget -c ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.gz
# wget -c http://nginx.org/download/nginx-1.7.10.tar.gz

# wget -c http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
# wget -c http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
# wget -c http://jaist.dl.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz
# wget -c http://sourceforge.net/projects/mcrypt/files/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
# wget -c http://sourceforge.net/projects/mhash/files/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz
# wget -c http://cn2.php.net/distributions/php-5.5.22.tar.gz
## php扩展
# wget -c http://pecl.php.net/get/memcached-2.2.0.tgz
# wget -c https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
# wget -c http://pecl.php.net/get/memcache-2.2.7.tgz
# wget -c http://pecl.php.net/get/redis-2.2.7.tgz
# wget -c http://pecl.php.net/get/imagick-3.1.2.tgz
# wget -c http://pecl.php.net/get/gmagick-1.1.7RC2.tgz
## memcached
# wget -c http://www.memcached.org/files/memcached-1.4.22.tar.gz

###################  安装依赖包 都是给php的 #######################

echo "Install autoconf ......"
cd $runtime_dir
tar -zxvf $soft_dir"/autoconf-2.69.tar.gz"
cd autoconf-2.69
./configure
make && make install
cd ..

echo "Install libiconv ......"
cd $runtime_dir
tar -zxvf $soft_dir"/libiconv-1.14.tar.gz"
cd libiconv-1.14
./configure
make && make install
cd ..

echo "Install mhash ......"
cd $runtime_dir
tar -zxvf $soft_dir"/mhash-0.9.9.9.tar.gz"
cd mhash-0.9.9.9
./configure
make && make install

echo "Install libmcrypt ......"
cd $runtime_dir
tar -zxvf $soft_dir"/libmcrypt-2.5.8.tar.gz"
cd libmcrypt-2.5.8
./configure
make && make install
/sbin/ldconfig
cd libltdl
./configure --enable-ltdl-install
make
make install
cd ../../

# 创建软链
ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
/sbin/ldconfig

echo "Install mcrypt ......"
cd $runtime_dir
tar -zxvf $soft_dir"/mcrypt-2.6.8.tar.gz"
cd mcrypt-2.6.8
./configure
make && make install
cd ..

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    ln -s /usr/lib64/libpng.* /usr/lib/
    ln -s /usr/lib64/libjpeg.* /usr/lib/
    ln -sv /usr/lib64/libldap* /usr/lib/
fi

ulimit -v unlimited

if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
    echo "/lib" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
    echo "/usr/lib" >> /etc/ld.so.conf
fi

if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
    echo "/usr/lib64" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
    echo "/usr/local/lib" >> /etc/ld.so.conf
fi

ldconfig

cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof
echo "fs.file-max=65535" >> /etc/sysctl.conf

#################### 安装PHP ##########################
echo "Install php5.5 ......"
cd $runtime_dir
tar -zxvf $soft_dir"/php-5.5.22.tar.gz"
cd php-5.5.22

./configure \
--prefix=/usr/local/php \
--disable-rpath \
--with-config-file-path=/usr/local/php/etc \
--with-config-file-scan-dir=/usr/local/php/etc/conf.d \
--with-iconv-dir \
--enable-exif \
--enable-soap \
--enable-ftp \
--enable-sockets \
--enable-shmop \
--enable-sysvsem \
--enable-sysvshm \
--enable-mbstring \
--with-mcrypt \
--with-mhash \
--enable-mbregex \
--enable-bcmath \
--enable-calendar \
--with-zlib \
--enable-zip \
--with-bz2= \
--with-ldap \
--with-xmlrpc \
--with-gd \
--enable-gd-native-ttf \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-gettext \
--with-snmp \
--with-curl \
--with-openssl \
--with-xsl \
--with-readline \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-mysqli=mysqlnd \
--with-mysql=mysqlnd \
--with-pdo-mysql=mysqlnd \
--enable-pcntl \
--enable-zend-signals \
--enable-opcache \
--with-pear

make ZEND_EXTRA_LIBS='-liconv'
make install

# 首次安装，备份默认的php.ini文件
if [ ! -s /usr/local/php/etc/php.ini.default ]; then
    cp php.ini-production /usr/local/php/etc/php.ini.default
fi

if [ ! -s /usr/local/php/etc/php.ini ]; then
    cp php.ini-production /usr/local/php/etc/php.ini
fi
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

# create php-fpm.conf
if [ ! -s /usr/local/php/etc/php-fpm.conf ]; then
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
fi

# php的进程配置 16G MEM
sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 16/g' /usr/local/php/etc/php-fpm.conf
sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 48/g' /usr/local/php/etc/php-fpm.conf
sed -i 's/pm.start_servers = 2/pm.start_servers = 16/g' /usr/local/php/etc/php-fpm.conf
sed -i 's/pm.max_children = 5/pm.max_children = 400/g' /usr/local/php/etc/php-fpm.conf

cd ../

# php memcache扩展
cd $runtime_dir
tar -zxvf $soft_dir"/memcache-2.2.7.tgz"
cd memcache-2.2.7/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# php memcached扩展
cd $runtime_dir
tar -zxvf $soft_dir"/libmemcached-1.0.18.tar.gz"
cd libmemcached-1.0.18
./configure
make && make install
cd ../

cd $runtime_dir
tar -zxvf $soft_dir"/memcached-2.2.0.tgz"
cd memcached-2.2.0
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# php Imagick扩展
cd $runtime_dir
tar -zxvf $soft_dir"/imagick-3.1.2.tgz"
cd imagick-3.1.2
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# 添加扩展到php.ini里
# 扩展目录 /usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/
sed -i 's#;extension=php_xsl.dll#;extension=php_zip.dll\n\nextension = "memcache.so"\nextension = "memcached.so"\nextension = "imagick.so"\nextension = "gmagick.so"\n#' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Shanghai"/g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
# php error log
sed -i 's/;error_log = php_errors.log/error_log = \/usr\/local\/php\/var\/log\/php_errors.log/g' /usr/local/php/etc/php.ini
# 建立软链接
rm -f /usr/bin/php
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

################## 安装nginx ##################

# 添加用户和组
groupadd www
useradd -s /sbin/nologin -g www www
ldconfig

cd $runtime_dir
tar -zxvf $soft_dir"/pcre-8.36.tar.gz"
cd pcre-8.36/
./configure
make && make install
cd ../

cd $runtime_dir
tar -zxvf $soft_dir"/nginx-1.7.10.tar.gz"
cd nginx-1.7.10/
./configure --user=www \
--group=www \
--prefix=/usr/local/nginx \
--with-http_stub_status_module \
--with-http_ssl_module \
--with-http_gzip_static_module \
--with-ipv6 \
--with-http_realip_module
make
make install
cd ../

# fix php-fpm bug
sed -i '1 i\if (!-f $request_filename){\n    return 404;\n}\n' /usr/local/nginx/conf/fastcgi.conf
# backup nginx.conf
if [ -s /usr/local/nginx/conf/nginx.conf ]; then
    mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.backup
fi
cp $cur_dir"/conf/nginx.conf" /usr/local/nginx/conf/

mkdir -p /usr/local/nginx/conf/vhosts

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    ln -s /usr/local/lib/libpcre.so.1 /lib64/
fi


# nginx and php-fpm and mysql to start
ulimit -s unlimited
cat >>/etc/rc.local<<EOF
ulimit -n 65535
/etc/init.d/php-fpm start
/usr/local/nginx/sbin/nginx
ntpdate -u pool.ntp.org
EOF

echo "Starting all service"
clear
echo "===================================== Check install ==================================="
if [ -s /usr/local/nginx ]; then
  echo "/usr/local/nginx [found]"
else
  echo "Error: /usr/local/nginx not found!!!"
fi

if [ -s /usr/local/php ]; then
  echo "/usr/local/php [found]"
else
  echo "Error: /usr/local/php not found!!!"
fi
