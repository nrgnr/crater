#!/bin/sh
set -e

# Maximum number of attempts to connect to the database
MAX_ATTEMPTS=30
ATTEMPT=1

echo "Waiting for database connection..."
while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    if php artisan db:monitor > /dev/null 2>&1; then
        echo "Database connection established"
        break
    fi
    echo "Attempt $ATTEMPT of $MAX_ATTEMPTS: Database not ready yet..."
    ATTEMPT=$((ATTEMPT + 1))
    sleep 2
done

if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
    echo "Could not connect to database after $MAX_ATTEMPTS attempts"
    exit 1
fi

# Check if database exists and has migrations table
if php artisan migrate:status > /dev/null 2>&1; then
    echo "Running migrations..."
    php artisan migrate --force
    
    # Only seed if explicitly requested via environment variable
    if [ "${DB_SEED:-false}" = "true" ]; then
        echo "Running database seeds..."
        php artisan db:seed --force
    fi
else
    echo "Fresh installation detected, skipping automatic migrations..."
fi

# Clear caches
echo "Clearing application caches..."
php artisan config:clear
php artisan cache:clear
php artisan view:clear

echo "Starting PHP-FPM..."
exec php-fpm 