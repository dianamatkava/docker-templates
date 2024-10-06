## Docker-Django-Postgres-Celery

### Docker-Compose commands
```bash
docker-compose -p docker-django-template -f docker-compose-dev.yml build

docker images | grep docker-django-template
# docker-django-template-web                      
# docker-django-template-celery  
# docker-django-template-celery-beat   

# pre-builds:
# postgres
# redis

docker-compose -p docker-django-template -f docker-compose-dev.yml up
#[+] Running 16/2
# ✔ redis 8 layers [⣿⣿⣿⣿⣿⣿⣿⣿]      0B/0B      Pulled                                                                                                                   6.2s 
# ⠦ db 8 layers [⣿⣿⣿⣄⣿⣿⣿⣿] 27.44MB/58.84MB Pulling       


# Incase you want to run the shell of an specific service
docker-compose -f docker-compose-dev.yml run --rm web /bin/bash 
docker-compose -f docker-compose-dev.yml run --rm web /bin/sh
#[+] Creating 3/3
# ✔ Network docker-django-nginx-postgres-celery_default         Created                                                                                                0.0s 
# ✔ Volume "docker-django-nginx-postgres-celery_postgres_data"  Created                                                                                                0.0s 
# ✔ Container docker-django-nginx-postgres-celery-db-1          Created    
```

### Verify Volumes and mounts set correctly
```bash
# Get volumes list for project
docker volume ls | grep docker-django-template
# local     docker-django-template_postgres_data
# local     docker-django-template_redis_data

# Get volumes and mounts for project
docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Mounts}}" | grep docker-django-template
#17472b46e9eb   docker-django-template-celery-beat-1     /host_mnt/User…                       # mount dir
#6997a9e67405   docker-django-template-celery-1          /host_mnt/User…                       # mount dir 
#92f00567eea0   docker-django-template-web-1             /host_mnt/User…                       # mount dir
#a2befb00943d   docker-django-template-db-1              docker-django-template_postgres_data  # volume
#5374fe4c098d   docker-django-template-redis-1           docker-django-template_redis_data     # volume                                                           592a089b8d7243…

# Detailed inspect per container for DB
docker inspect docker-django-template-db-1
# show detailed information about DB set up, including environments, >> networks, >> mounts & volumes 

# "Mounts": [
# {
#    "Type": "volume",
#    "Name": "docker-django-template_postgres_data",
# ...

docker inspect docker-django-template-web-1
# "Mounts": [
#    {
#        "Type": "bind",
#        "Source": "/Users/me/docker-templates/docker-django-nginx-postgres-celery/django",
#        "Destination": "/usr/src/django",
#        "Mode": "rw",  // container can read and write to the mounted volume.
#        "RW": true,    // explicit read-write (true) 
#        "Propagation": "rprivate"  // not propagate to the host or other mounts
#    }
#],

# Propagation: specifies how mount propagation is handled. The propagation modes can include:

# - private: The default mode. Changes to the mount point do not propagate to the host or other mounts.
# - rprivate: Similar to private, but ensures that unbinds will not propagate.
# - shared: Changes are propagated to other mounts.
# - rshared: A combination of shared and private, but ensures that unbinds will propagate.
# - slave: Changes from the host propagate to the container, but not vice versa.
# - rslave: Similar to slave, ensuring that unbinds do not propagate.
```

### Docker Network

``` bash
docker network ls | grep docker-django
# 0513e9e53264   docker-django-nginx-postgres-celery_default      bridge    local
# 2340140c4d38   docker-django-template_default                   bridge    local

# Type	        Description	                                 Use Case
# Bridge: 	Default network for standalone containers    Basic container networking
# Host:   	Shares the host's network stack	             High IOPS applications
# Overlay:      Multi-host networking	                     Swarm services and orchestration
# None:   	Disables all networking	                     Isolated containers
# Macvlan:      Assigns a MAC address to a container	     Legacy applications and direct access


docker inspect docker-django-template-redis-1
# "Networks": {
#     "docker-django-template_default": { ...
```




### Debug Docker containers

#### Redis
```bash
# Ensure
# for Redis connect use "redis" as a hostname (==service name) specified in the docker-compose
# Remember: redis://:password@hostname:port/db_number
CELERY_BROKER_URL = "redis://:redis@redis:6379/0"
CELERY_RESULT_BACKEND = "redis://:redis@redis:6379/0"

# (Optional) password to Redis
REDIS_PASSWORD=redis


# Ping redis from localhost
# brew install redis
redis-cli -h <host> -p 6379 ping
# - a <password> (optional in case you secured redis with password)

# Ping redis from docker
docker run -it --rm --network docker-django-template_default redis:alpine redis-cli -h redis -p 6379 ping
# - a <password> (optional in case you secured redis with password)
# --network <name> of the container (check with inspect)
```
##### Redis - Troubleshooting AUTH error
```bash
# AUTH failed: ERR AUTH <password> called without any password configured for the default user. Are you sure your configuration is correct?
# May be due to:
#    - redis setup with a password and credentials are invalid / missing or 
#    - redis was set up without password and is trying to connect using password (enforce password with: redis-server --requirepass ${REDIS_PASSWORD})

# If password enabled check cmd configuration
docker inspect docker-django-template-web-1
# "Cmd": [
#    "redis-server",
#    "--requirepass",
#    "<password>"  # If password is set then;
#],

# Verify all service environments are interpolated 
docker exec -it docker-django-template-redis-1 env

# For the connector remember: 
# redis://:password@hostname:port/db_number
```




## Run Postgres container
```bash
docker run --name postgres-container \
  -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres \
  -p 5432:5432 \
  postgres
```

## Run Redis container
```bash
docker network create redis-network
# redis://:password@hostname:port/db_number
# with docker you create a new network and use it as a host
# test via: ping docker-template-redis
docker run -d -p 6379:6379 --name redis-container \
    -e REDIS_PASSWORD=password \
    --network redis-network
    redis
```


## Required envs for running most common Distributed Services via Docker

```bash
# PostgreSQL
POSTGRES_USER=...
POSTGRES_PASSWORD=...
POSTGRES_DB=...

# MongoDB
MONGO_INITDB_ROOT_USERNAME=...
MONGO_INITDB_ROOT_PASSWORD=...
MONGO_INITDB_DATABASE=...

# MySQL
MYSQL_ROOT_PASSWORD=...
MYSQL_DATABASE=...
MYSQL_USER=...
MYSQL_PASSWORD=...

# Redis
REDIS_PASSWORD=... (Optional)

# Celery (if using with RabbitMQ or Redis)
CELERY_BROKER_URL=...

# RabbitMQ
RABBITMQ_DEFAULT_USER=...
RABBITMQ_DEFAULT_PASS=...
RABBITMQ_DEFAULT_VHOST=/

# Kafka
KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://host:9092
KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT
KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092
KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181

# LocalStack
DEFAULT_REGION=<region>
SERVICES=<comma_separated_services>
LOCALSTACK_HOSTNAME=localstack

# Elasticsearch
ELASTIC_PASSWORD=...

# Nginx
NGINX_HOST=...
NGINX_PORT=80
```


## Docker Quick snippets

#### Copy from local to docker
```d
docker cp foo.txt container_id:/foo.txt
```

#### Copy from docker to local
```d
docker cp container_id:/foo.txt foo.txt 
```

#### Run Postgres in Docker
``` d
docker run --name -d <cont-name> -p 5432:5432 -e POSTGRES_PASSWORD=<password> postgres
```

#### Run MySQL in Docker

```d
docker pull mysql:5

docker run -p 3306:3306 --name mysql -d -e MYSQL_ROOT_PASSWORD=<password> mysql
```

#### Run Redis in Docker
``` d
docker pull redis:latest
docker run -p 6379:6379 --name redis -d redis
```

#### Run RabbitMQ in Docker
```d
docker run -p 5672:5672 --name rabbitmq -e RABBITMQ_DEFAULT_USER=brokulon -e RABBITMQ_DEFAULT_PASS=passwort -d rabbitmq
```

#### Run RabbitMQ with Admin Dashboard
``` d
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:management
```