## Docker-Django-Postgres-Celery

### Docker-Compose
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

# run the shell of an specific service
docker-compose -f docker-compose-dev.yml run --rm web /bin/bash 
docker-compose -f docker-compose-dev.yml run --rm web /bin/sh
#[+] Creating 3/3
# ✔ Network docker-django-nginx-postgres-celery_default         Created                                                                                                0.0s 
# ✔ Volume "docker-django-nginx-postgres-celery_postgres_data"  Created                                                                                                0.0s 
# ✔ Container docker-django-nginx-postgres-celery-db-1          Created    

docker volume ls | grep docker-django
# local     docker-django-template_postgres_data
# local     docker-django-template_redis_data

docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Mounts}}" | grep docker-django-template
#17472b46e9eb   docker-django-template-celery-beat-1     /host_mnt/User…
#6997a9e67405   docker-django-template-celery-1          /host_mnt/User…
#92f00567eea0   docker-django-template-web-1             /host_mnt/User…
#a2befb00943d   docker-django-template-db-1              docker-django-template_postgres_data
#5374fe4c098d   docker-django-template-redis-1           docker-django-template_redis_data                                                                     592a089b8d7243…


docker inspect docker-django-template-db-1
# show detailed information about DB set up, including environments, networks, mounts & volumes
```

### Run with pure docker
```bash

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