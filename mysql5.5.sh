yum install -y cmake bison
yum install -y gcc gcc-c++ ncurses-devel
groupadd mysql
useradd mysql -g mysql -M -s /sbin/nologin #禁止登陆且不创建用户目录

cmake . \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS=complex \
-DDENABLED_LOCAL_INFILE=ON \
-DWITH_READLINE=ON \
-DWITH_ARCHIVE_STORAGE_ENGINE=ON \
-DWITH_BLACKHOLE_STORAGE_ENGINE=ON \

# 如果要设置数据库存储目录，可以在编译时加这个参数，或者在my.cnf中添加datadir选项
-DMYSQL_DATADIR=/data/mysql/data

make
make install

cp support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql

mkdir -p /usr/local/mysql/etc
cp support-files/my-large.cnf /usr/local/mysql/etc/my.cnf

安装初始化数据
cd /usr/local/mysql/
scripts/mysql_install_db --user=mysql
chkconfig --level 345 mysql on
service mysql start
/usr/local/mysql/bin/mysqladmin -u root password 密码
/etc/init.d/mysql restart

指定数据库存放目录 scripts/mysql_install_db --user=mysql --datadir=/data/mysql/data


 默认项不必配置
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql
-DMYSQL_USER=mysql
-DWITH_EXTRA_CHARSETS=all
-DSYSCONFDIR=/usr/local/mysql/etc
-DWITH_DEBUG=OFF
-DWITH_INNOBASE_STORAGE_ENGINE=ON



my.cnf
innodb_buffer_pool_size 默认128M
innodb_additional_mem_pool_size default 8M

更多参数见http://dev.mysql.com/doc/refman/5.5/en/innodb-parameters.html
