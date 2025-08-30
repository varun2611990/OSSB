import { tenantManagerPlugin } from './plugin';

describe('tenant-manager', () => {
  it('should export plugin', () => {
    expect(tenantManagerPlugin).toBeDefined();
  });
});
