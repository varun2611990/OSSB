import { createDevApp } from '@backstage/dev-utils';
import { tenantManagerPlugin, TenantManagerPage } from '../src/plugin';

createDevApp()
  .registerPlugin(tenantManagerPlugin)
  .addPage({
    element: <TenantManagerPage />,
    title: 'Root Page',
    path: '/tenant-manager',
  })
  .render();
