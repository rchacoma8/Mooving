#!/bin/sh
set -e
if [ -e "migrations" ]; then
    rm -r "migrations"
fi

if [ -e "__pycache__" ]; then
    rm -r "__pycache__"
fi

if [ -f "data.db" ]; then
    rm "data.db"
fi

if [[ -n "$DATABASE_UR" ]]; then
    psql -d $DATABASE_URL -c "DROP TABLE alembic_version ;"
fi

flask db init
flask db migrate -m "Initial migration"
flask db upgrade
echo "Succes creating empty database"