



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