Repository with Vagrant Logstash, Redis and Elasticsearch
1. Git clone
2. Install Vagrant
3. vagrant up
4. vagrant ssh logstash or vagrant ssh client

Following I will describe two bugfixes for the server and client:

Inside the logstash-redis-elasticsearch server
To run the logstash-web (Kibana) service you have to 

1. cd /etc/init
2. sudo vi logstash-web.conf
3. find the following line 
	[ -n "${LS_LOG_FILE}" ] && LS_OPTS="${LSOPTS} -l ${LS_LOG_FILE}"
4. replace it with 
	[ -n "${LS_LOG_FILE}" ] && LS_OPTS="${LSOPTS}"
4. save and exit
5. sudo service logstash-web start

Inside the client

1. cd /etc/logstash
2. sudo vi logstash.conf
3. find and replace the ipaddress of the redis-server with the correct ipaddress from the above logstash server
4. save and exit
5. cd /etc/init
6. sudo vi logstash.conf
7. find the line 
	setgid logstash
8. replace it with 
	setgid adm
9. save and exit
10. sudo service logstash restart


Now be happy!
