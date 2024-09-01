# pull official base image
FROM python:3.11-alpine
# python version does not conflicts with poetry python env

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install psycopg2 dependencies
RUN apk update \
    && apk add --no-cache postgresql-dev gcc python3-dev musl-dev

# install poetry
RUN pip install --upgrade pip \
    && pip install poetry

# install dependencies for dev
COPY ./django/pyproject.toml .
RUN poetry install --no-root --with dev

# copy entrypoint.sh
COPY entrypoint.sh /usr/src/django/entrypoint.sh
RUN sed -i 's/\r$//g' /usr/src/django/entrypoint.sh
RUN chmod +x /usr/src/django/entrypoint.sh

ENTRYPOINT ["/usr/src/django/entrypoint.sh"]

# copy project
COPY django .


