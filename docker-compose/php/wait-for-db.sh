#!/bin/sh
set -e

host="$1"
shift
cmd="$@"

until mysql -h "$host" -u "${DB_USERNAME}" -p"${DB_PASSWORD}" -e 'SELECT 1;' >/dev/null 2>&1; do
  echo "MySQL is unavailable - sleeping"
  sleep 1
done

echo "MySQL is up - executing command"
exec $cmd 