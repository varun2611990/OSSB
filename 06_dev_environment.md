# Development Environment Setup Guide

## Prerequisites

### System Requirements

#### Supported Operating Systems
- **macOS**: 12.0+ (Monterey or later)
- **Linux**: Ubuntu 20.04+, CentOS 8+, Fedora 35+
- **Windows**: Windows 10/11 with WSL2

#### Required Software Versions
- **Node.js**: 20.x or 22.x (LTS versions)
- **Yarn**: 4.4.1+ (bundled with project)
- **Python**: 3.8+ (for node-gyp and native modules)
- **Git**: 2.28+
- **Docker**: 20.10+ (for local services)
- **PostgreSQL**: 13+ (for production-like development)

#### Hardware Requirements
- **RAM**: 16GB minimum, 32GB recommended
- **CPU**: 4 cores minimum, 8 cores recommended
- **Storage**: 50GB free space (for dependencies and development)

### Development Tools

#### Required IDEs/Editors
- **VS Code** (recommended) with extensions:
  - TypeScript and JavaScript Language Features
  - Backstage Plugin Extension Pack
  - GitLens
  - Docker
  - PostgreSQL Explorer
  - REST Client

#### Optional Tools
- **Docker Desktop**: For local service dependencies
- **Postman/Insomnia**: API testing
- **TablePlus/DBeaver**: Database management
- **Kubernetes CLI**: For deployment testing

## Quick Start

### Automated Setup Script (Linux/macOS)

```bash
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
```

### Windows PowerShell Setup Script

```powershell
#!/usr/bin/env pwsh
# setup-dev.ps1 - Windows development environment setup

param(
    [switch]$SkipDocker = $false,
    [switch]$UseWSL = $false
)

Write-Host "🚀 Setting up Backstage SaaS Development Environment on Windows" -ForegroundColor Green

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "❌ PowerShell 7+ is recommended. Current version: $($PSVersionTable.PSVersion)" -ForegroundColor Red
    Write-Host "Download from: https://github.com/PowerShell/PowerShell/releases" -ForegroundColor Yellow
}

# Check if running in WSL
if ($UseWSL) {
    Write-Host "🐧 WSL mode detected. Using Linux setup..." -ForegroundColor Cyan
    wsl bash ./setup-dev.sh
    exit $LASTEXITCODE
}

# Function to test command existence
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Check Node.js
Write-Host "📋 Checking Node.js version..." -ForegroundColor Yellow
if (Test-Command node) {
    $nodeVersion = (node --version).Trim('v').Split('.')[0]
    if ([int]$nodeVersion -lt 20) {
        Write-Host "❌ Node.js version must be 20 or higher. Current: $(node --version)" -ForegroundColor Red
        Write-Host "Please install Node.js 20+ from https://nodejs.org" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✅ Node.js $(node --version) is compatible" -ForegroundColor Green
} else {
    Write-Host "❌ Node.js not found. Please install Node.js 20+ from https://nodejs.org" -ForegroundColor Red
    exit 1
}

# Check Yarn
Write-Host "📋 Checking Yarn..." -ForegroundColor Yellow
if (Test-Command yarn) {
    Write-Host "✅ Yarn $(yarn --version) found" -ForegroundColor Green
} else {
    Write-Host "⚠️ Yarn not found globally. Using bundled version." -ForegroundColor Yellow
}

# Check Docker
if (-not $SkipDocker) {
    Write-Host "📋 Checking Docker..." -ForegroundColor Yellow
    if (Test-Command docker) {
        try {
            docker info 2>$null | Out-Null
            Write-Host "✅ Docker is running" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠️ Docker is installed but not running. Please start Docker Desktop." -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️ Docker not found. Some features may not work." -ForegroundColor Yellow
        Write-Host "Install from https://docker.com" -ForegroundColor Yellow
    }
}

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
yarn install

# Set up environment files
Write-Host "⚙️ Setting up environment configuration..." -ForegroundColor Yellow

if (-not (Test-Path .env)) {
    @"
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

# GitHub Integration (optional)
GITHUB_TOKEN=ghp_your_github_token_here

# Other integrations...
"@ | Out-File -FilePath .env -Encoding utf8
    Write-Host "✅ Created .env file with default configuration" -ForegroundColor Green
    Write-Host "📝 Please edit .env file with your actual values" -ForegroundColor Yellow
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

# Set up local database (if Docker is available)
if (-not $SkipDocker -and (Test-Command docker)) {
    Write-Host "🗄️ Setting up local PostgreSQL..." -ForegroundColor Yellow
    
    # Check if container exists
    $containerExists = docker ps -a --format "table {{.Names}}" | Select-String "backstage-postgres"
    
    if ($containerExists) {
        Write-Host "✅ PostgreSQL container already exists" -ForegroundColor Green
        
        # Start if not running
        $containerRunning = docker ps --format "table {{.Names}}" | Select-String "backstage-postgres"
        if (-not $containerRunning) {
            docker start backstage-postgres
            Write-Host "✅ Started existing PostgreSQL container" -ForegroundColor Green
        }
    } else {
        # Create and start PostgreSQL container
        docker run -d `
            --name backstage-postgres `
            -e POSTGRES_USER=backstage `
            -e POSTGRES_PASSWORD=backstage `
            -e POSTGRES_DB=backstage `
            -p 5432:5432 `
            postgres:13
        Write-Host "✅ Created and started PostgreSQL container" -ForegroundColor Green
    }
}

# Build the project
Write-Host "🏗️ Building the project..." -ForegroundColor Yellow
yarn build:backend

# Create development scripts
Write-Host "📝 Creating development scripts..." -ForegroundColor Yellow

# Start script (PowerShell)
@"
#!/usr/bin/env pwsh
# Start development servers

Write-Host "🚀 Starting Backstage development environment..." -ForegroundColor Green

# Start database if not running
if (Get-Command docker -ErrorAction SilentlyContinue) {
    `$postgresRunning = docker ps --format "table {{.Names}}" | Select-String "backstage-postgres"
    if (-not `$postgresRunning) {
        Write-Host "🗄️ Starting PostgreSQL..." -ForegroundColor Yellow
        docker start backstage-postgres
        Start-Sleep 3
    }
}

# Start Backstage
Write-Host "🎵 Starting Backstage..." -ForegroundColor Yellow
yarn start
"@ | Out-File -FilePath start-dev.ps1 -Encoding utf8

# Stop script (PowerShell)
@"
#!/usr/bin/env pwsh
# Stop development environment

Write-Host "🛑 Stopping development environment..." -ForegroundColor Yellow

# Stop Docker containers
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "🗄️ Stopping PostgreSQL..." -ForegroundColor Yellow
    docker stop backstage-postgres 2>`$null
}

Write-Host "✅ Development environment stopped" -ForegroundColor Green
"@ | Out-File -FilePath stop-dev.ps1 -Encoding utf8

Write-Host "✅ Created PowerShell development scripts" -ForegroundColor Green

# Test the setup
Write-Host "🧪 Testing the setup..." -ForegroundColor Yellow
try {
    yarn tsc --noEmit
    Write-Host "✅ TypeScript compilation successful" -ForegroundColor Green
} catch {
    Write-Host "⚠️ TypeScript compilation has issues (may be normal for fresh setup)" -ForegroundColor Yellow
}

# Final instructions
Write-Host "`n🎉 Development environment setup complete!" -ForegroundColor Green
Write-Host "`n📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit .env file with your actual configuration values"
Write-Host "2. Run '.\start-dev.ps1' to start the development environment"
Write-Host "3. Open http://localhost:3000 in your browser"
Write-Host "4. Backend API will be available at http://localhost:7007"
Write-Host "`n🔧 Useful commands:" -ForegroundColor Yellow
Write-Host "  yarn start           - Start development servers"
Write-Host "  yarn build:all       - Build all packages"
Write-Host "  yarn test            - Run tests"
Write-Host "  yarn lint            - Run linting"
Write-Host "  yarn new             - Create new plugin/package"
Write-Host "`nHappy coding! 🚀" -ForegroundColor Green
```

## Manual Setup Instructions

### Step 1: Clone and Install Dependencies

```bash
# Clone the repository (if not already done)
git clone <repository-url>
cd OSSB

# Install dependencies
yarn install
```

### Step 2: Environment Configuration

Create a `.env` file in the project root:

```bash
# Copy the example environment file
cp .env.example .env

# Edit with your preferred editor
nano .env  # or vim, code, etc.
```

#### Essential Environment Variables

```bash
# Core Configuration
NODE_ENV=development
LOG_LEVEL=debug
BACKEND_SECRET=your-super-secret-backend-key

# Database (for production-like development)
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage
POSTGRES_DATABASE=backstage

# GitHub Integration (required for many features)
GITHUB_TOKEN=ghp_your_personal_access_token

# Optional: External Service Integrations
ARGOCD_BASE_URL=https://argocd.example.com
SONARQUBE_URL=https://sonarqube.example.com
PROMETHEUS_URL=https://prometheus.example.com
GRAFANA_URL=https://grafana.example.com
```

### Step 3: Database Setup

#### Option A: Docker PostgreSQL (Recommended)

```bash
# Start PostgreSQL container
docker run -d \
  --name backstage-postgres \
  -e POSTGRES_USER=backstage \
  -e POSTGRES_PASSWORD=backstage \
  -e POSTGRES_DB=backstage \
  -p 5432:5432 \
  postgres:13

# Verify connection
docker exec backstage-postgres pg_isready -U backstage
```

#### Option B: Local PostgreSQL Installation

```bash
# macOS (using Homebrew)
brew install postgresql@13
brew services start postgresql@13
createdb backstage

# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo -u postgres createdb backstage
sudo -u postgres createuser backstage

# Create user and grant permissions
sudo -u postgres psql -c "ALTER USER backstage WITH PASSWORD 'backstage';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE backstage TO backstage;"
```

### Step 4: Build and Start

```bash
# Build the backend
yarn build:backend

# Start development servers
yarn start
```

## Environment Variables Reference

### Core Backstage Configuration

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `NODE_ENV` | Environment mode | `development` | No |
| `LOG_LEVEL` | Logging level | `info` | No |
| `BACKEND_SECRET` | JWT signing secret | - | Yes |
| `PORT` | Frontend port | `3000` | No |
| `BACKEND_PORT` | Backend port | `7007` | No |

### Database Configuration

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `POSTGRES_HOST` | Database host | `localhost` | No* |
| `POSTGRES_PORT` | Database port | `5432` | No |
| `POSTGRES_USER` | Database user | `backstage` | No* |
| `POSTGRES_PASSWORD` | Database password | - | No* |
| `POSTGRES_DATABASE` | Database name | `backstage` | No* |

*Required when using PostgreSQL (recommended for development)

### Plugin Integrations

#### GitHub Integration
| Variable | Description | Required |
|----------|-------------|----------|
| `GITHUB_TOKEN` | Personal access token | Yes |
| `GITHUB_APP_ID` | GitHub App ID (alternative) | No |
| `GITHUB_APP_PRIVATE_KEY` | GitHub App private key | No |

#### ArgoCD Integration
| Variable | Description | Required |
|----------|-------------|----------|
| `ARGOCD_BASE_URL` | ArgoCD server URL | Yes |
| `ARGOCD_USERNAME` | ArgoCD username | Yes |
| `ARGOCD_PASSWORD` | ArgoCD password | Yes |

#### SonarQube Integration
| Variable | Description | Required |
|----------|-------------|----------|
| `SONARQUBE_URL` | SonarQube server URL | Yes |
| `SONARQUBE_API_KEY` | SonarQube API key | Yes |

#### Monitoring Integrations
| Variable | Description | Required |
|----------|-------------|----------|
| `PROMETHEUS_URL` | Prometheus server URL | Yes |
| `GRAFANA_URL` | Grafana server URL | Yes |
| `GRAFANA_API_KEY` | Grafana API key | No |
| `SENTRY_ORG` | Sentry organization | Yes |
| `SENTRY_AUTH_TOKEN` | Sentry auth token | Yes |

### SaaS Platform Configuration

#### AI Assistant
| Variable | Description | Required |
|----------|-------------|----------|
| `OPENAI_API_KEY` | OpenAI API key | No |
| `OLLAMA_BASE_URL` | Ollama server URL | No |

#### Billing Integration
| Variable | Description | Required |
|----------|-------------|----------|
| `STRIPE_SECRET_KEY` | Stripe secret key | No |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook secret | No |

## Plugin Development Guide

### Creating a New Plugin

```bash
# Create a new plugin using the Backstage CLI
yarn new

# Follow the prompts:
# ? What do you want to create? plugin
# ? What should be the name of the plugin? my-custom-plugin
# ? What should be the npm package name? @internal/backstage-plugin-my-custom-plugin
```

### Plugin Development Workflow

1. **Generate Plugin Structure**
```bash
cd plugins/my-custom-plugin
yarn install
```

2. **Implement Plugin Logic**
```typescript
// plugins/my-custom-plugin/src/plugin.ts
import { createPlugin } from '@backstage/core-plugin-api';

export const myCustomPlugin = createPlugin({
  id: 'my-custom-plugin',
  routes: {
    root: myCustomPluginRouteRef,
  },
});
```

3. **Create Components**
```typescript
// plugins/my-custom-plugin/src/components/MyComponent.tsx
import React from 'react';
import { Typography } from '@material-ui/core';

export const MyComponent = () => (
  <Typography variant="h4">Hello from My Custom Plugin!</Typography>
);
```

4. **Export Plugin**
```typescript
// plugins/my-custom-plugin/src/index.ts
export { myCustomPlugin } from './plugin';
export { MyComponent } from './components/MyComponent';
```

5. **Integrate with App**
```typescript
// packages/app/src/App.tsx
import { myCustomPlugin, MyComponent } from '@internal/backstage-plugin-my-custom-plugin';

// Add to routes
<Route path="/my-custom" element={<MyComponent />} />
```

### Testing Plugins

```bash
# Run plugin tests
cd plugins/my-custom-plugin
yarn test

# Run with coverage
yarn test --coverage

# Run in watch mode
yarn test --watch
```

### Plugin Best Practices

1. **Follow Naming Conventions**
   - Use kebab-case for plugin IDs
   - Prefix internal plugins with organization name
   - Follow semantic versioning

2. **Implement Proper Error Handling**
```typescript
import { useApi, errorApiRef } from '@backstage/core-plugin-api';

export const MyComponent = () => {
  const errorApi = useApi(errorApiRef);
  
  const handleError = (error: Error) => {
    errorApi.post(error);
  };
  
  // Component implementation...
};
```

3. **Use TypeScript Strictly**
```typescript
// Enable strict mode in tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noImplicitReturns": true
  }
}
```

4. **Implement Proper Loading States**
```typescript
import { useAsync } from 'react-use';
import { Progress } from '@backstage/core-components';

export const MyComponent = () => {
  const { value, loading, error } = useAsync(async () => {
    return await fetchData();
  });
  
  if (loading) return <Progress />;
  if (error) return <div>Error: {error.message}</div>;
  
  return <div>{/* Render data */}</div>;
};
```

## Debugging and Troubleshooting

### Common Issues and Solutions

#### 1. Node.js Version Conflicts
```bash
# Check Node.js version
node --version

# Use nvm to manage versions (macOS/Linux)
nvm install 20
nvm use 20

# Use nvm-windows (Windows)
nvm install 20.0.0
nvm use 20.0.0
```

#### 2. Yarn Installation Issues
```bash
# Clear Yarn cache
yarn cache clean

# Remove node_modules and reinstall
rm -rf node_modules
yarn install

# Use specific Yarn version
corepack enable
corepack prepare yarn@4.4.1 --activate
```

#### 3. Database Connection Issues
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Test connection
docker exec backstage-postgres pg_isready -U backstage

# View logs
docker logs backstage-postgres
```

#### 4. Port Conflicts
```bash
# Find process using port 3000
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows
```

#### 5. TypeScript Compilation Errors
```bash
# Clean TypeScript cache
rm -rf packages/*/dist
rm -rf plugins/*/dist

# Rebuild
yarn tsc --build --clean
yarn build:all
```

### Development Tools and Extensions

#### VS Code Extensions
```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "ms-vscode.vscode-docker"
  ]
}
```

#### Useful VS Code Settings
```json
{
  "typescript.preferences.includePackageJsonAutoImports": "auto",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true
  },
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode"
}
```

### Performance Optimization

#### Development Server Optimization
```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"

# Use faster builds
yarn build:backend --parallel

# Skip type checking during development
yarn start --skip-type-check
```

#### Database Optimization for Development
```sql
-- Increase work_mem for better query performance
ALTER SYSTEM SET work_mem = '256MB';

-- Increase shared_buffers
ALTER SYSTEM SET shared_buffers = '512MB';

-- Reload configuration
SELECT pg_reload_conf();
```

This comprehensive development environment setup guide ensures that developers can quickly get up and running with the Backstage SaaS platform while providing the tools and knowledge needed for effective plugin development and troubleshooting.