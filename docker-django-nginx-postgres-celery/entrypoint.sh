#!/bin/sh

# Wait for Postgres to be ready
if [ "$DATABASE" = "postgres" ]; then
    echo "Waiting for Postgres..."
    while ! nc -z $SQL_HOST $SQL_PORT; do
        sleep 0.1
    done
    echo "Postgres started"
fi

# Run the main command
exec "$@"