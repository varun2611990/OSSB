#!/bin/bash
# Stop development environment

echo "🛑 Stopping development environment..."

# Stop Docker containers
if command -v docker >/dev/null 2>&1; then
    echo "🗄️ Stopping PostgreSQL..."
    docker stop backstage-postgres 2>/dev/null || true
    
    echo "🔴 Stopping Redis..."
    docker stop backstage-redis 2>/dev/null || true
fi

echo "✅ Development environment stopped"
