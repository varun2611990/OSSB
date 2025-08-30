#!/bin/bash
# Clean development environment

echo "🧹 Cleaning development environment..."

# Remove node_modules and reinstall
echo "📦 Cleaning dependencies..."
rm -rf node_modules packages/*/node_modules plugins/*/node_modules
yarn install

# Clean build artifacts
echo "🏗️ Cleaning build artifacts..."
yarn clean

# Reset database
if command -v docker >/dev/null 2>&1; then
    echo "🗄️ Resetting database..."
    docker stop backstage-postgres 2>/dev/null || true
    docker rm backstage-postgres 2>/dev/null || true
    docker run -d \
        --name backstage-postgres \
        -e POSTGRES_USER=backstage \
        -e POSTGRES_PASSWORD=backstage \
        -e POSTGRES_DB=backstage \
        -p 5432:5432 \
        postgres:13
fi

echo "✅ Development environment cleaned"
