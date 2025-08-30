#!/bin/bash
# setup-dev.sh - Automated development environment setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Setting up Backstage SaaS Development Environment${NC}"

# Check if running on supported OS
if [[ "$OSTYPE" != "linux-gnu"* && "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script supports Linux and macOS only. Use setup-dev.ps1 for Windows.${NC}"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Node.js version
echo -e "${YELLOW}📋 Checking Node.js version...${NC}"
if command_exists node; then
    NODE_VERSION=$(node --version | cut -d 'v' -f 2 | cut -d '.' -f 1)
    if [[ $NODE_VERSION -lt 20 ]]; then
        echo -e "${RED}❌ Node.js version must be 20 or higher. Current: $(node --version)${NC}"
        echo -e "${YELLOW}Please install Node.js 20+ from https://nodejs.org${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Node.js $(node --version) is compatible${NC}"
else
    echo -e "${RED}❌ Node.js not found. Please install Node.js 20+ from https://nodejs.org${NC}"
    exit 1
fi

# Check Yarn
echo -e "${YELLOW}📋 Checking Yarn...${NC}"
if ! command_exists yarn; then
    echo -e "${YELLOW}⚠️  Yarn not found globally. Using bundled version.${NC}"
else
    echo -e "${GREEN}✅ Yarn $(yarn --version) found${NC}"
fi

# Check Docker
echo -e "${YELLOW}📋 Checking Docker...${NC}"
if command_exists docker; then
    if docker info >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker is running${NC}"
    else
        echo -e "${YELLOW}⚠️  Docker is installed but not running. Please start Docker.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Docker not found. Some features may not work.${NC}"
    echo -e "${YELLOW}Install from https://docker.com${NC}"
fi

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
yarn install

# Set up environment files
echo -e "${YELLOW}⚙️  Setting up environment configuration...${NC}"

# Create .env file if it doesn't exist
if [[ ! -f .env ]]; then
    cat > .env << 'EOF'
# Backstage Configuration
NODE_ENV=development
LOG_LEVEL=debug

# Database Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage
POSTGRES_DATABASE=backstage

# Authentication
BACKEND_SECRET=your-super-secret-backend-key-change-this-in-production

# GitHub Integration (optional - get from https://github.com/settings/developers)
GITHUB_TOKEN=ghp_your_github_token_here

# ArgoCD Integration (optional)
ARGOCD_BASE_URL=https://argocd.your-domain.com
ARGOCD_USERNAME=admin
ARGOCD_PASSWORD=your_argocd_password

# SonarQube Integration (optional)
SONARQUBE_URL=https://sonarqube.your-domain.com
SONARQUBE_API_KEY=your_sonarqube_api_key

# Prometheus Integration (optional)
PROMETHEUS_URL=https://prometheus.your-domain.com

# Grafana Integration (optional)
GRAFANA_DOMAIN=grafana.your-domain.com
GRAFANA_URL=https://grafana.your-domain.com

# Sentry Integration (optional)
SENTRY_ORG=your-sentry-organization
SENTRY_AUTH_TOKEN=your_sentry_auth_token

# AI Assistant (optional)
OPENAI_API_KEY=sk-your-openai-api-key
OLLAMA_BASE_URL=http://localhost:11434

# Billing (for SaaS features)
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
EOF
    echo -e "${GREEN}✅ Created .env file with default configuration${NC}"
    echo -e "${YELLOW}📝 Please edit .env file with your actual values${NC}"
else
    echo -e "${GREEN}✅ .env file already exists${NC}"
fi

# Set up local database
echo -e "${YELLOW}🗄️  Setting up local PostgreSQL...${NC}"
if command_exists docker; then
    # Check if PostgreSQL container already exists
    if docker ps -a --format "table {{.Names}}" | grep -q "backstage-postgres"; then
        echo -e "${GREEN}✅ PostgreSQL container already exists${NC}"
        
        # Start if not running
        if ! docker ps --format "table {{.Names}}" | grep -q "backstage-postgres"; then
            docker start backstage-postgres
            echo -e "${GREEN}✅ Started existing PostgreSQL container${NC}"
        fi
    else
        # Create and start PostgreSQL container
        docker run -d \
            --name backstage-postgres \
            -e POSTGRES_USER=backstage \
            -e POSTGRES_PASSWORD=backstage \
            -e POSTGRES_DB=backstage \
            -p 5432:5432 \
            postgres:13
        echo -e "${GREEN}✅ Created and started PostgreSQL container${NC}"
    fi
    
    # Wait for PostgreSQL to be ready
    echo -e "${YELLOW}⏳ Waiting for PostgreSQL to be ready...${NC}"
    sleep 10
    
    # Test connection
    if docker exec backstage-postgres pg_isready -U backstage >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PostgreSQL is ready${NC}"
    else
        echo -e "${YELLOW}⚠️  PostgreSQL might still be starting up${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Docker not available. Please install PostgreSQL manually.${NC}"
    echo -e "${YELLOW}Or install Docker to use automated setup.${NC}"
fi

# Set up Redis for caching (optional)
echo -e "${YELLOW}🔴 Setting up Redis for caching...${NC}"
if command_exists docker; then
    if docker ps -a --format "table {{.Names}}" | grep -q "backstage-redis"; then
        echo -e "${GREEN}✅ Redis container already exists${NC}"
        
        if ! docker ps --format "table {{.Names}}" | grep -q "backstage-redis"; then
            docker start backstage-redis
            echo -e "${GREEN}✅ Started existing Redis container${NC}"
        fi
    else
        docker run -d \
            --name backstage-redis \
            -p 6379:6379 \
            redis:7-alpine
        echo -e "${GREEN}✅ Created and started Redis container${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Docker not available. Redis setup skipped.${NC}"
fi

# Build the project
echo -e "${YELLOW}🏗️  Building the project...${NC}"
yarn build:backend

# Seed catalog with example data
echo -e "${YELLOW}🌱 Seeding catalog with example data...${NC}"
if [[ -f examples/entities.yaml ]]; then
    echo -e "${GREEN}✅ Example entities already exist${NC}"
else
    echo -e "${YELLOW}📝 Creating example catalog entities...${NC}"
    mkdir -p examples
    
    cat > examples/entities.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: example-service
  description: An example microservice
  annotations:
    github.com/project-slug: backstage/backstage
    sonarqube.org/project-key: example-service
    grafana.com/dashboard-url: https://grafana.example.com/d/example
spec:
  type: service
  lifecycle: production
  owner: platform-team
  system: example-system
---
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: example-system
  description: Example system containing multiple services
spec:
  owner: platform-team
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: platform-team
  description: Platform engineering team
spec:
  type: team
  children: []
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: john.doe
spec:
  memberOf: [platform-team]
EOF
    echo -e "${GREEN}✅ Created example catalog entities${NC}"
fi

# Create development scripts
echo -e "${YELLOW}📝 Creating development scripts...${NC}"

# Start script
cat > start-dev.sh << 'EOF'
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
EOF

# Stop script
cat > stop-dev.sh << 'EOF'
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
EOF

# Clean script
cat > clean-dev.sh << 'EOF'
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
EOF

# Make scripts executable
chmod +x start-dev.sh stop-dev.sh clean-dev.sh

echo -e "${GREEN}✅ Created development scripts:${NC}"
echo -e "  - start-dev.sh: Start development environment"
echo -e "  - stop-dev.sh: Stop development environment"
echo -e "  - clean-dev.sh: Clean and reset environment"

# Test the setup
echo -e "${YELLOW}🧪 Testing the setup...${NC}"
if yarn tsc --noEmit; then
    echo -e "${GREEN}✅ TypeScript compilation successful${NC}"
else
    echo -e "${YELLOW}⚠️  TypeScript compilation has issues (may be normal for fresh setup)${NC}"
fi

# Final instructions
echo -e "${GREEN}🎉 Development environment setup complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "1. Edit .env file with your actual configuration values"
echo -e "2. Run './start-dev.sh' to start the development environment"
echo -e "3. Open http://localhost:3000 in your browser"
echo -e "4. Backend API will be available at http://localhost:7007"
echo ""
echo -e "${YELLOW}🔧 Useful commands:${NC}"
echo -e "  yarn start           - Start development servers"
echo -e "  yarn build:all       - Build all packages"
echo -e "  yarn test            - Run tests"
echo -e "  yarn lint            - Run linting"
echo -e "  yarn new             - Create new plugin/package"
echo ""
echo -e "${YELLOW}🐳 Database access:${NC}"
echo -e "  Host: localhost:5432"
echo -e "  User: backstage"
echo -e "  Password: backstage"
echo -e "  Database: backstage"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"