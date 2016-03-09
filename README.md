# docker-zabbix-server

This is docker image with Zabbix 3.0 server + web UI.

Docker image is located at [varsy/zabbix-server](https://hub.docker.com/r/varsy/zabbix-server/).

There are following environment variables you need to set:
* `DB_HOST` 
* `DB_USER`
* `DB_PASS`

For example:
```
/usr/bin/docker run --rm -p 8080:80 -p 10051:10051 -e \
DB_HOST=mysql.example.com -e DB_USER=root \
DB_PASS=password --name zabbix-server varsy/zabbix-server:latest
```
