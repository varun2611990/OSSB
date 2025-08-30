# SaaS Layer Design - Backstage Multi-Tenant Platform

## Multi-Tenancy Strategy

### Architecture Overview

Our multi-tenant architecture ensures complete isolation between organizations while maintaining operational efficiency and cost-effectiveness. The strategy employs a hybrid approach combining database-level isolation with application-level tenant resolution.

### Tenant Isolation Models

#### 1. Database Schema Isolation
- **Schema per Tenant**: Each organization gets a dedicated PostgreSQL schema
- **Shared Infrastructure**: Single database instance with multiple schemas
- **Data Separation**: Complete logical separation with zero cross-tenant data access
- **Scalability**: Horizontal scaling through read replicas and connection pooling

```sql
-- Tenant schema structure
CREATE SCHEMA tenant_org_12345;
CREATE SCHEMA tenant_org_67890;

-- Tenant-specific tables
CREATE TABLE tenant_org_12345.catalog_entities (...);
CREATE TABLE tenant_org_12345.user_profiles (...);
CREATE TABLE tenant_org_12345.auth_sessions (...);
```

#### 2. Application-Level Tenant Resolution
- **Subdomain Routing**: org-name.platform.com → tenant resolution
- **Header-Based**: X-Tenant-ID header for API requests
- **JWT Claims**: Tenant information embedded in authentication tokens
- **Request Context**: Tenant context propagated through request lifecycle

```typescript
// Tenant resolution middleware
export const tenantResolver = (req: Request, res: Response, next: NextFunction) => {
  const subdomain = req.hostname.split('.')[0];
  const tenantId = await resolveTenantBySubdomain(subdomain);
  req.context = { ...req.context, tenantId };
  next();
};
```

### Tenant Configuration System

#### Dynamic Configuration per Tenant
```typescript
interface TenantConfig {
  id: string;
  name: string;
  subdomain: string;
  branding: {
    logo: string;
    primaryColor: string;
    customCSS?: string;
  };
  features: {
    aiAssistant: boolean;
    advancedAnalytics: boolean;
    customPlugins: string[];
  };
  limits: {
    maxUsers: number;
    maxProjects: number;
    apiRequestsPerMonth: number;
    storageGB: number;
  };
  integrations: {
    github?: GitHubConfig;
    gitlab?: GitLabConfig;
    jira?: JiraConfig;
  };
}
```

## Authentication & Authorization

### Enhanced Authentication System

#### Multi-Provider Authentication
```typescript
// Enhanced authentication configuration
auth:
  providers:
    # Enterprise SSO
    oidc:
      - issuer: ${TENANT_OIDC_ISSUER}
        clientId: ${TENANT_OIDC_CLIENT_ID}
        clientSecret: ${TENANT_OIDC_CLIENT_SECRET}
        scope: 'openid profile email'
        
    # GitHub OAuth
    github:
      clientId: ${GITHUB_CLIENT_ID}
      clientSecret: ${GITHUB_CLIENT_SECRET}
      
    # Google OAuth
    google:
      clientId: ${GOOGLE_CLIENT_ID}
      clientSecret: ${GOOGLE_CLIENT_SECRET}
      
    # Microsoft Azure AD
    microsoft:
      clientId: ${MICROSOFT_CLIENT_ID}
      clientSecret: ${MICROSOFT_CLIENT_SECRET}
      tenantId: ${MICROSOFT_TENANT_ID}
```

#### JWT Token Structure
```typescript
interface BackstageJWT {
  sub: string; // User ID
  ent: string[]; // Entity references
  tenant: {
    id: string;
    name: string;
    role: string;
  };
  permissions: string[];
  features: string[];
  exp: number;
  iat: number;
}
```

### Advanced RBAC System

#### Role Hierarchy
```typescript
enum SystemRole {
  PLATFORM_ADMIN = 'platform_admin',     // Cross-tenant admin
  TENANT_ADMIN = 'tenant_admin',          // Organization admin
  TEAM_LEAD = 'team_lead',                // Team management
  DEVELOPER = 'developer',                // Standard user
  VIEWER = 'viewer'                       // Read-only access
}

interface Permission {
  resource: string;    // catalog:component, scaffolder:template
  action: string;      // create, read, update, delete
  conditions?: {       // Optional conditions
    owner?: string;
    team?: string;
    environment?: string;
  };
}
```

#### Permission Policy Engine
```typescript
// Advanced permission policy
class SaaSPermissionPolicy implements PermissionPolicy {
  async handle(request: PolicyQuery): Promise<PolicyDecision> {
    const { user, permission, tenant } = request;
    
    // Check tenant-level permissions
    if (!this.hasTenatAccess(user, tenant)) {
      return { result: AuthorizeResult.DENY };
    }
    
    // Check resource-level permissions
    const resourcePolicy = await this.getResourcePolicy(
      permission.resourceRef,
      tenant.id
    );
    
    // Apply conditional logic
    return this.evaluateConditions(user, permission, resourcePolicy);
  }
}
```

### Tenant Data Isolation

#### Database Access Layer
```typescript
class TenantAwareRepository<T> {
  constructor(
    private entityManager: EntityManager,
    private tenantContext: TenantContext
  ) {}
  
  async find(criteria: any): Promise<T[]> {
    return this.entityManager.find(T, {
      ...criteria,
      schema: `tenant_${this.tenantContext.id}`
    });
  }
  
  async save(entity: T): Promise<T> {
    return this.entityManager.save(entity, {
      schema: `tenant_${this.tenantContext.id}`
    });
  }
}
```

#### Cache Isolation
```typescript
class TenantAwareCache {
  private redis: Redis;
  
  constructor(redis: Redis) {
    this.redis = redis;
  }
  
  async get(key: string, tenantId: string): Promise<string | null> {
    return this.redis.get(`tenant:${tenantId}:${key}`);
  }
  
  async set(key: string, value: string, tenantId: string): Promise<void> {
    await this.redis.set(`tenant:${tenantId}:${key}`, value);
  }
}
```

## Billing Integration

### Subscription Management

#### Pricing Tiers
```typescript
interface PricingTier {
  id: string;
  name: string;
  monthlyPrice: number;
  annualPrice: number;
  features: {
    maxUsers: number;
    maxProjects: number;
    apiRequestsPerMonth: number;
    storageGB: number;
    prioritySupport: boolean;
    customBranding: boolean;
    advancedAnalytics: boolean;
    aiAssistant: boolean;
  };
}

const PRICING_TIERS: PricingTier[] = [
  {
    id: 'starter',
    name: 'Starter',
    monthlyPrice: 29,
    annualPrice: 290,
    features: {
      maxUsers: 10,
      maxProjects: 50,
      apiRequestsPerMonth: 100000,
      storageGB: 10,
      prioritySupport: false,
      customBranding: false,
      advancedAnalytics: false,
      aiAssistant: false,
    }
  },
  {
    id: 'professional',
    name: 'Professional',
    monthlyPrice: 99,
    annualPrice: 990,
    features: {
      maxUsers: 50,
      maxProjects: 200,
      apiRequestsPerMonth: 500000,
      storageGB: 50,
      prioritySupport: true,
      customBranding: true,
      advancedAnalytics: true,
      aiAssistant: true,
    }
  },
  {
    id: 'enterprise',
    name: 'Enterprise',
    monthlyPrice: 299,
    annualPrice: 2990,
    features: {
      maxUsers: -1, // Unlimited
      maxProjects: -1,
      apiRequestsPerMonth: 2000000,
      storageGB: 200,
      prioritySupport: true,
      customBranding: true,
      advancedAnalytics: true,
      aiAssistant: true,
    }
  }
];
```

#### Stripe Integration
```typescript
class BillingService {
  private stripe: Stripe;
  
  constructor() {
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
  }
  
  async createSubscription(tenantId: string, tierId: string): Promise<Subscription> {
    const tier = PRICING_TIERS.find(t => t.id === tierId);
    const customer = await this.getOrCreateCustomer(tenantId);
    
    return this.stripe.subscriptions.create({
      customer: customer.id,
      items: [{
        price: tier.stripePriceId,
      }],
      metadata: {
        tenantId,
        tierId,
      }
    });
  }
  
  async handleWebhook(event: Stripe.Event): Promise<void> {
    switch (event.type) {
      case 'invoice.payment_succeeded':
        await this.handlePaymentSuccess(event.data.object);
        break;
      case 'invoice.payment_failed':
        await this.handlePaymentFailure(event.data.object);
        break;
      case 'customer.subscription.deleted':
        await this.handleSubscriptionCancellation(event.data.object);
        break;
    }
  }
}
```

### Usage Tracking & Metering

#### Usage Metrics Collection
```typescript
interface UsageMetrics {
  tenantId: string;
  period: string; // YYYY-MM
  metrics: {
    activeUsers: number;
    apiRequests: number;
    storageUsed: number; // bytes
    buildMinutes: number;
    aiQueries: number;
  };
}

class UsageTracker {
  async recordApiRequest(tenantId: string, endpoint: string): Promise<void> {
    await this.incrementCounter(`api_requests:${tenantId}`, 1);
    await this.incrementCounter(`api_requests:${tenantId}:${endpoint}`, 1);
  }
  
  async recordStorageUsage(tenantId: string, bytes: number): Promise<void> {
    await this.setGauge(`storage_used:${tenantId}`, bytes);
  }
  
  async recordAIQuery(tenantId: string, tokens: number): Promise<void> {
    await this.incrementCounter(`ai_queries:${tenantId}`, 1);
    await this.incrementCounter(`ai_tokens:${tenantId}`, tokens);
  }
}
```

## Admin Dashboard

### Platform Administration Interface

#### Multi-Tenant Overview
```typescript
interface AdminDashboardData {
  tenants: {
    total: number;
    active: number;
    trial: number;
    churned: number;
  };
  revenue: {
    mrr: number; // Monthly Recurring Revenue
    arr: number; // Annual Recurring Revenue
    churnRate: number;
    ltv: number; // Lifetime Value
  };
  usage: {
    totalApiRequests: number;
    totalUsers: number;
    totalProjects: number;
    avgResponseTime: number;
  };
  health: {
    uptime: number;
    errorRate: number;
    p95ResponseTime: number;
  };
}
```

#### Tenant Management Features
```typescript
class TenantManagementService {
  async createTenant(data: CreateTenantRequest): Promise<Tenant> {
    // Create tenant schema
    await this.createTenantSchema(data.subdomain);
    
    // Set up initial configuration
    const tenant = await this.tenantRepository.create({
      name: data.name,
      subdomain: data.subdomain,
      planId: data.planId || 'starter',
      status: 'active'
    });
    
    // Create admin user
    await this.createTenantAdmin(tenant.id, data.adminEmail);
    
    // Initialize default data
    await this.seedTenantData(tenant.id);
    
    return tenant;
  }
  
  async suspendTenant(tenantId: string, reason: string): Promise<void> {
    await this.tenantRepository.update(tenantId, {
      status: 'suspended',
      suspensionReason: reason,
      suspendedAt: new Date()
    });
    
    // Invalidate all sessions
    await this.authService.invalidateAllSessions(tenantId);
  }
  
  async upgradeTenant(tenantId: string, newPlanId: string): Promise<void> {
    const tenant = await this.tenantRepository.findById(tenantId);
    const newPlan = PRICING_TIERS.find(p => p.id === newPlanId);
    
    // Update subscription in Stripe
    await this.billingService.updateSubscription(tenant.stripeSubscriptionId, newPlanId);
    
    // Update tenant configuration
    await this.tenantRepository.update(tenantId, {
      planId: newPlanId,
      limits: newPlan.features
    });
  }
}
```

### Tenant Admin Dashboard

#### Organization Management
```typescript
interface TenantAdminDashboard {
  organization: {
    users: UserSummary[];
    teams: TeamSummary[];
    projects: ProjectSummary[];
    usage: UsageSummary;
  };
  billing: {
    currentPlan: string;
    nextBillingDate: Date;
    usage: BillingUsage;
    invoices: Invoice[];
  };
  integrations: {
    configured: Integration[];
    available: Integration[];
  };
  settings: {
    branding: BrandingConfig;
    security: SecurityConfig;
    notifications: NotificationConfig;
  };
}
```

## Rate Limiting & API Usage Tracking

### API Rate Limiting Strategy

#### Tier-Based Rate Limits
```typescript
const RATE_LIMITS = {
  starter: {
    apiRequestsPerMinute: 100,
    apiRequestsPerHour: 5000,
    apiRequestsPerDay: 50000,
  },
  professional: {
    apiRequestsPerMinute: 500,
    apiRequestsPerHour: 25000,
    apiRequestsPerDay: 250000,
  },
  enterprise: {
    apiRequestsPerMinute: 1000,
    apiRequestsPerHour: 50000,
    apiRequestsPerDay: 1000000,
  }
};

class RateLimitMiddleware {
  async checkRateLimit(req: Request): Promise<boolean> {
    const { tenantId, planId } = req.context;
    const limits = RATE_LIMITS[planId];
    
    const current = await this.redis.get(`rate_limit:${tenantId}:minute`);
    if (parseInt(current || '0') >= limits.apiRequestsPerMinute) {
      throw new RateLimitExceededError('Minute rate limit exceeded');
    }
    
    await this.redis.incr(`rate_limit:${tenantId}:minute`);
    await this.redis.expire(`rate_limit:${tenantId}:minute`, 60);
    
    return true;
  }
}
```

#### Usage Analytics
```typescript
class APIAnalyticsService {
  async recordAPICall(request: APIRequest): Promise<void> {
    const metrics = {
      tenantId: request.tenantId,
      endpoint: request.endpoint,
      method: request.method,
      statusCode: request.statusCode,
      responseTime: request.responseTime,
      timestamp: new Date(),
      userAgent: request.userAgent,
      ip: request.ip,
    };
    
    // Store in time-series database
    await this.influxdb.writePoint(
      new Point('api_calls')
        .tag('tenant_id', metrics.tenantId)
        .tag('endpoint', metrics.endpoint)
        .tag('method', metrics.method)
        .intField('status_code', metrics.statusCode)
        .floatField('response_time', metrics.responseTime)
        .timestamp(metrics.timestamp)
    );
  }
  
  async getUsageReport(tenantId: string, period: string): Promise<UsageReport> {
    const query = `
      from(bucket: "api_analytics")
        |> range(start: ${period})
        |> filter(fn: (r) => r.tenant_id == "${tenantId}")
        |> group(columns: ["endpoint"])
        |> count()
    `;
    
    return this.influxdb.query(query);
  }
}
```

## Custom Plugin Development Framework

### Plugin SDK for SaaS Enhancements

#### Tenant-Aware Plugin Base
```typescript
abstract class SaaSPlugin {
  protected tenantContext: TenantContext;
  protected config: TenantConfig;
  
  constructor(context: TenantContext) {
    this.tenantContext = context;
    this.config = context.config;
  }
  
  abstract initialize(): Promise<void>;
  abstract getRoutes(): Router;
  abstract getPermissions(): Permission[];
  
  protected isTenantFeatureEnabled(feature: string): boolean {
    return this.config.features[feature] === true;
  }
  
  protected getTenantLimit(limit: string): number {
    return this.config.limits[limit];
  }
}
```

#### Plugin Registration System
```typescript
class PluginRegistry {
  private plugins: Map<string, SaaSPlugin> = new Map();
  
  async registerPlugin(
    tenantId: string, 
    pluginId: string, 
    pluginClass: new(context: TenantContext) => SaaSPlugin
  ): Promise<void> {
    const context = await this.getTenantContext(tenantId);
    const plugin = new pluginClass(context);
    
    await plugin.initialize();
    this.plugins.set(`${tenantId}:${pluginId}`, plugin);
  }
  
  getPlugin(tenantId: string, pluginId: string): SaaSPlugin | undefined {
    return this.plugins.get(`${tenantId}:${pluginId}`);
  }
}
```

## Data Compliance & Privacy

### GDPR Compliance Features

#### Data Processing Records
```typescript
interface DataProcessingRecord {
  tenantId: string;
  userId: string;
  action: 'create' | 'read' | 'update' | 'delete';
  dataType: string;
  timestamp: Date;
  legalBasis: 'consent' | 'contract' | 'legitimate_interest';
  retention: Date;
}

class ComplianceService {
  async recordDataProcessing(record: DataProcessingRecord): Promise<void> {
    await this.auditLog.write(record);
  }
  
  async handleDataPortabilityRequest(userId: string): Promise<DataExport> {
    const userData = await this.collectUserData(userId);
    return {
      format: 'json',
      data: userData,
      exportDate: new Date(),
      userId,
    };
  }
  
  async handleDataDeletionRequest(userId: string): Promise<void> {
    // Anonymize user data while preserving system integrity
    await this.anonymizeUserData(userId);
    await this.markUserAsDeleted(userId);
  }
}
```

## Performance & Scalability

### Database Optimization

#### Connection Pooling per Tenant
```typescript
class TenantConnectionManager {
  private pools: Map<string, Pool> = new Map();
  
  getConnection(tenantId: string): Pool {
    if (!this.pools.has(tenantId)) {
      const pool = new Pool({
        ...this.baseConfig,
        database: `tenant_${tenantId}`,
        max: this.calculatePoolSize(tenantId),
      });
      this.pools.set(tenantId, pool);
    }
    return this.pools.get(tenantId)!;
  }
  
  private calculatePoolSize(tenantId: string): number {
    const tenant = this.getTenant(tenantId);
    const userCount = tenant.userCount;
    
    // Scale pool size based on tenant size
    return Math.min(Math.max(userCount / 10, 5), 50);
  }
}
```

#### Caching Strategy
```typescript
class TenantAwareCacheManager {
  private redis: Redis;
  private localCache: Map<string, any> = new Map();
  
  async get(key: string, tenantId: string): Promise<any> {
    const cacheKey = `tenant:${tenantId}:${key}`;
    
    // L1 Cache (Local)
    if (this.localCache.has(cacheKey)) {
      return this.localCache.get(cacheKey);
    }
    
    // L2 Cache (Redis)
    const value = await this.redis.get(cacheKey);
    if (value) {
      this.localCache.set(cacheKey, value);
      return JSON.parse(value);
    }
    
    return null;
  }
  
  async set(key: string, value: any, tenantId: string, ttl: number = 3600): Promise<void> {
    const cacheKey = `tenant:${tenantId}:${key}`;
    const serialized = JSON.stringify(value);
    
    // Update both cache layers
    this.localCache.set(cacheKey, value);
    await this.redis.setex(cacheKey, ttl, serialized);
  }
}
```

## Monitoring & Alerting

### Tenant-Specific Monitoring

#### Health Checks per Tenant
```typescript
class TenantHealthMonitor {
  async checkTenantHealth(tenantId: string): Promise<HealthStatus> {
    const checks = await Promise.allSettled([
      this.checkDatabaseConnectivity(tenantId),
      this.checkAPIResponseTime(tenantId),
      this.checkStorageUsage(tenantId),
      this.checkActiveUsers(tenantId),
    ]);
    
    return this.aggregateHealthStatus(checks);
  }
  
  async setupAlerts(tenantId: string): Promise<void> {
    const tenant = await this.getTenant(tenantId);
    
    if (tenant.plan === 'enterprise') {
      // Custom alerting for enterprise customers
      await this.createCustomAlerts(tenantId, tenant.alertConfig);
    } else {
      // Standard alerting
      await this.createStandardAlerts(tenantId);
    }
  }
}
```

This comprehensive SaaS layer design provides the foundation for a robust, scalable, and secure multi-tenant Backstage platform that can compete with enterprise-grade developer platforms while maintaining operational efficiency and compliance requirements.