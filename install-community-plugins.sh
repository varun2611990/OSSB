#!/bin/bash
# install-community-plugins.sh - Automated community plugin installation script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Plugin categories and their priorities
declare -A PLUGINS_P0=(
    ["github-actions"]="@backstage-community/plugin-github-actions"
    ["github-issues"]="@backstage-community/plugin-github-issues"
    ["grafana"]="@backstage-community/plugin-grafana"
    ["sonarqube"]="@backstage-community/plugin-sonarqube"
)

declare -A PLUGINS_P1=(
    ["sentry"]="@backstage-community/plugin-sentry"
    ["dynatrace"]="@backstage-community/plugin-dynatrace"
    ["newrelic"]="@backstage-community/plugin-newrelic"
    ["cost-insights"]="@backstage-community/plugin-cost-insights"
    ["jaeger"]="@backstage-community/plugin-jaeger"
    ["lighthouse"]="@backstage-community/plugin-lighthouse"
    ["code-coverage"]="@backstage-community/plugin-code-coverage"
    ["blackduck"]="@backstage-community/plugin-blackduck"
    ["fossa"]="@backstage-community/plugin-fossa"
    ["azure-resources"]="@backstage-community/plugin-azure-resources"
    ["vault"]="@backstage-community/plugin-vault"
    ["rbac"]="@backstage-community/plugin-rbac"
    ["servicenow"]="@backstage-community/plugin-servicenow"
    ["confluence"]="@backstage-community/plugin-confluence"
    ["keycloak"]="@backstage-community/plugin-keycloak"
    ["redhat-argocd"]="@backstage-community/plugin-redhat-argocd"
    ["tech-insights"]="@backstage-community/plugin-tech-insights"
)

declare -A PLUGINS_P2=(
    ["jenkins"]="@backstage-community/plugin-jenkins"
    ["tekton"]="@backstage-community/plugin-tekton"
    ["azure-devops"]="@backstage-community/plugin-azure-devops"
    ["bitrise"]="@backstage-community/plugin-bitrise"
    ["cloudbuild"]="@backstage-community/plugin-cloudbuild"
    ["rollbar"]="@backstage-community/plugin-rollbar"
    ["airbrake"]="@backstage-community/plugin-airbrake"
    ["mend"]="@backstage-community/plugin-mend"
    ["code-climate"]="@backstage-community/plugin-code-climate"
    ["azure-sites"]="@backstage-community/plugin-azure-sites"
    ["gcp-projects"]="@backstage-community/plugin-gcp-projects"
    ["quay"]="@backstage-community/plugin-quay"
    ["kiali"]="@backstage-community/plugin-kiali"
    ["kafka"]="@backstage-community/plugin-kafka"
    ["github-discussions"]="@backstage-community/plugin-github-discussions"
    ["github-pull-requests-board"]="@backstage-community/plugin-github-pull-requests-board"
    ["todo"]="@backstage-community/plugin-todo"
    ["adr"]="@backstage-community/plugin-adr"
    ["tech-radar"]="@backstage-community/plugin-tech-radar"
    ["gcalendar"]="@backstage-community/plugin-gcalendar"
    ["microsoft-calendar"]="@backstage-community/plugin-microsoft-calendar"
    ["announcements"]="@backstage-community/plugin-announcements"
)

# Function to display usage
usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo ""
    echo "Options:"
    echo "  --all                Install all community plugins"
    echo "  --priority P0|P1|P2  Install plugins by priority level"
    echo "  --category CATEGORY  Install plugins by category"
    echo "  --list               List all available plugins"
    echo "  --dry-run           Show what would be installed without installing"
    echo "  --help              Show this help message"
    echo ""
    echo "Categories:"
    echo "  devops      DevOps and CI/CD plugins"
    echo "  monitoring  Monitoring and observability plugins" 
    echo "  security    Security and quality plugins"
    echo "  cloud       Cloud services plugins"
    echo "  developer   Developer experience plugins"
    echo "  enterprise  Enterprise tools plugins"
    echo ""
    exit 1
}

# Function to install a plugin with error handling
install_plugin() {
    local plugin_id=$1
    local package_name=$2
    local workspace=${3:-"app"}
    local description=${4:-"$plugin_id plugin"}
    
    echo -e "${YELLOW}📦 Installing $description...${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${BLUE}[DRY RUN] Would install: yarn workspace $workspace add $package_name${NC}"
        return 0
    fi
    
    if yarn workspace $workspace add $package_name; then
        echo -e "${GREEN}✅ Successfully installed $package_name${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to install $package_name${NC}"
        return 1
    fi
}

# Function to install backend plugin if it exists
install_backend_plugin() {
    local plugin_id=$1
    local base_package=$2
    
    # Check for common backend plugin patterns
    local backend_patterns=(
        "${base_package}-backend"
        "${base_package}-node"
        "${base_package}-module"
    )
    
    for pattern in "${backend_patterns[@]}"; do
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${BLUE}[DRY RUN] Would check and install backend: $pattern${NC}"
            continue
        else
            echo -e "${YELLOW}🔧 Checking for backend plugin: $pattern${NC}"
            if yarn workspace backend add $pattern 2>/dev/null; then
                echo -e "${GREEN}✅ Installed backend plugin: $pattern${NC}"
                return 0
            fi
        fi
    done
    
    if [[ "$DRY_RUN" != "true" ]]; then
        echo -e "${YELLOW}ℹ️  No backend plugin found for $plugin_id${NC}"
    fi
    return 0
}

# Function to install plugins by priority
install_by_priority() {
    local priority=$1
    local -n plugin_array=$2
    
    echo -e "${BLUE}🚀 Installing Priority $priority Plugins...${NC}"
    echo ""
    
    local success_count=0
    local total_count=${#plugin_array[@]}
    
    for plugin_id in "${!plugin_array[@]}"; do
        local package_name="${plugin_array[$plugin_id]}"
        
        if install_plugin "$plugin_id" "$package_name" "app" "$plugin_id"; then
            install_backend_plugin "$plugin_id" "$package_name"
            ((success_count++))
        else
            echo -e "${YELLOW}⚠️  Failed to install $plugin_id, continuing with next plugin...${NC}"
        fi
        echo ""
    done
    
    echo -e "${BLUE}📊 Priority $priority Summary: $success_count/$total_count plugins installed${NC}"
    echo ""
    
    return $success_count
}

# Function to list all plugins
list_plugins() {
    echo -e "${BLUE}📋 Available Community Plugins:${NC}"
    echo ""
    
    echo -e "${GREEN}Priority P0 (Critical):${NC}"
    for plugin in "${!PLUGINS_P0[@]}"; do
        echo "  - $plugin (${PLUGINS_P0[$plugin]})"
    done
    echo ""
    
    echo -e "${YELLOW}Priority P1 (High):${NC}"
    for plugin in "${!PLUGINS_P1[@]}"; do
        echo "  - $plugin (${PLUGINS_P1[$plugin]})"
    done
    echo ""
    
    echo -e "${BLUE}Priority P2 (Medium):${NC}"
    for plugin in "${!PLUGINS_P2[@]}"; do
        echo "  - $plugin (${PLUGINS_P2[$plugin]})"
    done
    echo ""
    
    local total=$((${#PLUGINS_P0[@]} + ${#PLUGINS_P1[@]} + ${#PLUGINS_P2[@]}))
    echo -e "${GREEN}Total: $total plugins available${NC}"
}

# Function to test build after installation
test_build() {
    echo -e "${YELLOW}🧪 Testing build...${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${BLUE}[DRY RUN] Would test build${NC}"
        return 0
    fi
    
    if yarn build:backend; then
        echo -e "${GREEN}✅ Build successful!${NC}"
        return 0
    else
        echo -e "${RED}❌ Build failed. Some plugins may be incompatible.${NC}"
        return 1
    fi
}

# Function to update tracking document
update_tracking() {
    local installed_count=$1
    local total_count=$2
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${BLUE}[DRY RUN] Would update tracking document${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}📝 Updating plugin tracking document...${NC}"
    
    # Calculate progress percentage
    local progress=$((installed_count * 100 / total_count))
    
    # Update the community plugins catalog
    sed -i "s/\*\*Installed\*\*: [0-9]*/\*\*Installed\*\*: $installed_count/" community-plugins-catalog.md
    sed -i "s/\*\*Installation Progress\*\*: [0-9]*%/\*\*Installation Progress\*\*: $progress%/" community-plugins-catalog.md
    
    echo -e "${GREEN}✅ Tracking document updated${NC}"
}

# Parse command line arguments
INSTALL_ALL=false
PRIORITY=""
CATEGORY=""
LIST_ONLY=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            INSTALL_ALL=true
            shift
            ;;
        --priority)
            PRIORITY="$2"
            shift 2
            ;;
        --category)
            CATEGORY="$2"
            shift 2
            ;;
        --list)
            LIST_ONLY=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Handle list option
if [[ "$LIST_ONLY" == "true" ]]; then
    list_plugins
    exit 0
fi

# Main installation logic
echo -e "${GREEN}🔧 Backstage Community Plugins Installer${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No actual installations will be performed${NC}"
    echo ""
fi

# Check if we're in the right directory
if [[ ! -f "package.json" ]] || [[ ! -d "packages" ]]; then
    echo -e "${RED}❌ Error: Must be run from the root of a Backstage project${NC}"
    exit 1
fi

total_installed=0
total_plugins=$((${#PLUGINS_P0[@]} + ${#PLUGINS_P1[@]} + ${#PLUGINS_P2[@]}))

if [[ "$INSTALL_ALL" == "true" ]]; then
    echo -e "${GREEN}🚀 Installing ALL Community Plugins...${NC}"
    echo ""
    
    install_by_priority "P0" PLUGINS_P0
    install_by_priority "P1" PLUGINS_P1  
    install_by_priority "P2" PLUGINS_P2
    
elif [[ ! -z "$PRIORITY" ]]; then
    case $PRIORITY in
        P0)
            install_by_priority "P0" PLUGINS_P0
            ;;
        P1)
            install_by_priority "P1" PLUGINS_P1
            ;;
        P2)
            install_by_priority "P2" PLUGINS_P2
            ;;
        *)
            echo -e "${RED}❌ Invalid priority level: $PRIORITY${NC}"
            echo "Valid options: P0, P1, P2"
            exit 1
            ;;
    esac
else
    # Default: install P0 plugins only
    echo -e "${GREEN}🚀 Installing Priority P0 (Critical) Plugins...${NC}"
    echo ""
    install_by_priority "P0" PLUGINS_P0
fi

# Test build
echo -e "${BLUE}🔧 Post-installation checks...${NC}"
test_build

# Update tracking
update_tracking "$total_installed" "$total_plugins"

echo ""
echo -e "${GREEN}🎉 Community plugin installation completed!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "1. Update app.tsx with new plugin routes"
echo -e "2. Update backend index.ts with new backend modules"  
echo -e "3. Configure app-config.yaml with plugin settings"
echo -e "4. Restart the development server"
echo -e "5. Test each plugin functionality"
echo ""
echo -e "${BLUE}📖 For configuration details, see: community-plugins-catalog.md${NC}"