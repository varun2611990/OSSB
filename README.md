# OSSB - Backstage Portal

This repository contains a fresh Backstage open source instance, created using npx to provide a developer portal platform.

## What is Backstage?

Backstage is an open platform for building developer portals, originally created by Spotify. It centralizes all infrastructure tooling, services, apps, documentation, and everything else required to build and manage software.

## Prerequisites

- Node.js 20 or 22 (currently using Node.js 20.19.4)
- Yarn 4.4.1 (bundled in this project)

## Getting Started

### Installation

Dependencies are already installed. If you need to reinstall them:

```bash
yarn install
```

### Development

To start the application in development mode:

```bash
yarn start
```

This will start:
- Frontend on http://localhost:3000
- Backend API on http://localhost:7007

### Building

To build the backend:

```bash
yarn build:backend
```

To build all packages:

```bash
yarn build:all
```

### Other Commands

- `yarn tsc` - Run TypeScript compiler
- `yarn test` - Run tests
- `yarn lint` - Run linting
- `yarn prettier:check` - Check code formatting

## Project Structure

- `packages/app/` - Frontend React application
- `packages/backend/` - Backend Node.js application  
- `plugins/` - Custom Backstage plugins
- `examples/` - Example configurations and templates

## Configuration

The main configuration files are:
- `app-config.yaml` - Main configuration
- `app-config.local.yaml` - Local development overrides
- `app-config.production.yaml` - Production configuration

## Next Steps

1. Customize the configuration in `app-config.yaml`
2. Add your service catalog entries
3. Configure authentication providers
4. Add custom plugins as needed
5. Set up integrations with your tools and services

For more information, visit the [Backstage documentation](https://backstage.io/docs/).
