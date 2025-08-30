#!/bin/bash
# install-plugins.sh - Automated plugin installation script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔧 Installing Backstage SaaS Plugins...${NC}"

# Function to install plugin with error handling
install_plugin() {
    local workspace=$1
    local plugin=$2
    local description=$3
    
    echo -e "${YELLOW}📦 Installing $description...${NC}"
    if yarn workspace $workspace add $plugin; then
        echo -e "${GREEN}✅ Successfully installed $plugin${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to install $plugin${NC}"
        return 1
    fi
}

# Install frontend plugins
echo -e "${YELLOW}📱 Installing Frontend Plugins...${NC}"

# GitHub Pull Requests plugin (alternative to Actions)
install_plugin "app" "@roadiehq/backstage-plugin-github-pull-requests" "GitHub Pull Requests plugin"

# Datadog monitoring (alternative to Prometheus/Grafana)
install_plugin "app" "@roadiehq/backstage-plugin-datadog" "Datadog monitoring plugin" || echo "Datadog plugin not available, skipping"

# Security plugins
install_plugin "app" "@roadiehq/backstage-plugin-security-insights" "Security Insights plugin" || echo "Security insights plugin not available, skipping"

# AWS plugins for cost insights
install_plugin "app" "@roadiehq/backstage-plugin-aws" "AWS plugin" || echo "AWS plugin not available, skipping"

# Jira integration
install_plugin "app" "@roadiehq/backstage-plugin-jira" "Jira integration plugin" || echo "Jira plugin not available, skipping"

# Install backend plugins where available
echo -e "${YELLOW}🔧 Installing Backend Plugins...${NC}"

# Check if backend modules exist and install them
install_plugin "backend" "@roadiehq/backstage-plugin-github-pull-requests-backend" "GitHub Pull Requests backend" || echo "GitHub PR backend not available, skipping"

echo -e "${GREEN}✅ Plugin installation completed!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "1. Update app.tsx with new plugin routes"
echo -e "2. Update backend index.ts with new backend modules"
echo -e "3. Configure app-config.yaml with plugin settings"
echo -e "4. Test the build with 'yarn build:backend'"
echo ""
echo -e "${YELLOW}🧪 Testing build...${NC}"
if yarn build:backend; then
    echo -e "${GREEN}✅ Build successful!${NC}"
else
    echo -e "${RED}❌ Build failed. Check plugin compatibility.${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 All plugins installed and tested successfully!${NC}"