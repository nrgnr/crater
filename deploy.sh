#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Crater deployment..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please create one based on .env.example"
    exit 1
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p nginx
mkdir -p docker-compose/php

# Check if nginx config exists
if [ ! -f nginx/default.conf ]; then
    echo "❌ Nginx configuration not found. Please ensure nginx/default.conf exists"
    exit 1
fi

# Stop any running containers
echo "🛑 Stopping existing containers..."
docker-compose down -v

# Pull latest images
echo "⬇️ Pulling latest images..."
docker-compose pull

# Start services
echo "▶️ Starting services..."
docker-compose up -d

# Wait for MySQL to be healthy
echo "⏳ Waiting for MySQL to be healthy..."
until docker-compose exec -T mysql mysqladmin ping -h 127.0.0.1 -u root -p"${MYSQL_ROOT_PASSWORD}" --silent; do
    echo "Waiting for MySQL..."
    sleep 5
done

# Run migrations
echo "🔄 Running migrations..."
docker-compose exec -T app php artisan migrate --force

# Clear cache
echo "🧹 Clearing cache..."
docker-compose exec -T app php artisan config:clear
docker-compose exec -T app php artisan cache:clear
docker-compose exec -T app php artisan view:clear

echo "✅ Deployment completed!"
echo "🌐 Application should be available at http://localhost:8080" 