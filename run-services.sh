#!/bin/bash

rccheck() {
   if [ $? != 0 ]; then
      echo "Error! Stopping the script."
      exit 1
   fi
}

# check if db is created
if ! mysql -h${DB_HOST} -u${DB_USER} -p${DB_PASS} -e 'use zabbix'; then
   echo -n "DB is not created, trying to populate it... "
   mysql -h${DB_HOST} -u${DB_USER} -p${DB_PASS} -e 'create database zabbix character set utf8 collate utf8_bin' ; rccheck
   zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -h${DB_HOST} -u${DB_USER} -p${DB_PASS} zabbix ; rccheck
   echo "ok!"
fi

sed -i "s/^.*DBHost=localhost.*$/DBHost=${DB_HOST}/" /etc/zabbix/zabbix_server.conf
sed -i "s/^DBUser=zabbix$/DBUser=${DB_USER}/" /etc/zabbix/zabbix_server.conf
sed -i "s/^.*DBPassword=$/DBPassword=${DB_PASS}/" /etc/zabbix/zabbix_server.conf
sed -i "s/^.*JavaGateway=$/JavaGateway=127.0.0.1/" /etc/zabbix/zabbix_server.conf
sed -i "s/^.*JavaGatewayPort=.*$/JavaGatewayPort=10052/" /etc/zabbix/zabbix_server.conf
sed -i "s/^.*StartJavaPollers=.*$/StartJavaPollers=5/" /etc/zabbix/zabbix_server.conf
sed -i "s/# php_value date.timezone.*/php_value date.timezone Europe\/Moscow/" /etc/zabbix/apache.conf

if [ ! -f /etc/zabbix/web/zabbix.conf.php ]; then
   cp -p /usr/share/zabbix/conf/zabbix.conf.php.example /etc/zabbix/web/zabbix.conf.php
   sed -i "s/\$DB\['SERVER'\].*/\$DB\['SERVER'\] = '${DB_HOST}';/" /etc/zabbix/web/zabbix.conf.php
   sed -i "s/\$DB\['PORT'\].*/\$DB\['PORT'\] = '3306';/" /etc/zabbix/web/zabbix.conf.php
   sed -i "s/\$DB\['USER'\].*/\$DB\['USER'\] = '${DB_USER}';/" /etc/zabbix/web/zabbix.conf.php
   sed -i "s/\$DB\['PASSWORD'\].*/\$DB\['PASSWORD'\] = '${DB_PASS}';/" /etc/zabbix/web/zabbix.conf.php
fi

trap "service zabbix-java-gateway stop; service zabbix-agent stop; service apache2 stop; service zabbix-server stop" SIGINT SIGTERM SIGHUP
service zabbix-server start
service apache2 start
service zabbix-agent start
service zabbix-java-gateway start

tail -qF /var/log/zabbix/zabbix_server.log &
wait
