# Dockerizing Django with Celery, Redis, Postgres, Gunicorn, Nginx

This project contains a template to create
docker containers for dev anf prod environments
## Servises: 
* web - Django, Gunicorn
* db - Postgres
* celery
* celery-beat
* nginx

Set up:

```bash
# Dev:
sudo docker-compose -f docker-compose-dev.yml up --build

# Prod:
sudo docker-compose -f docker-compose-prod.yml up --build
```
