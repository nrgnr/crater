#!/bin/sh
set -e

# Wait for database to be ready
echo "Waiting for database connection..."
wait-for-db db

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