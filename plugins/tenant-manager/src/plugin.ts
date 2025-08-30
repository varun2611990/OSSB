import {
  createPlugin,
  createRoutableExtension,
} from '@backstage/core-plugin-api';

import { rootRouteRef } from './routes';

export const tenantManagerPlugin = createPlugin({
  id: 'tenant-manager',
  routes: {
    root: rootRouteRef,
  },
});

export const TenantManagerPage = tenantManagerPlugin.provide(
  createRoutableExtension({
    name: 'TenantManagerPage',
    component: () =>
      import('./components/TenantManagerComponent').then(m => m.TenantManagerComponent),
    mountPoint: rootRouteRef,
  }),
);
