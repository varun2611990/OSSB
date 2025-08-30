#!/bin/bash
# Start development servers

set -e

echo "🚀 Starting Backstage development environment..."

# Start database if not running
if command -v docker >/dev/null 2>&1; then
    if ! docker ps | grep -q backstage-postgres; then
        echo "🗄️ Starting PostgreSQL..."
        docker start backstage-postgres
        sleep 3
    fi
    
    if ! docker ps | grep -q backstage-redis; then
        echo "🔴 Starting Redis..."
        docker start backstage-redis
        sleep 2
    fi
fi

# Start Backstage
echo "🎵 Starting Backstage..."
yarn start
