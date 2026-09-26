import { defineConfig } from 'vitest/config';

// End-to-end flow against the emulators; run via `npm run test:e2e`.
export default defineConfig({
  test: {
    include: ['tests/integration/**/*.test.ts'],
    environment: 'node',
    testTimeout: 30000,
    hookTimeout: 60000,
    fileParallelism: false,
  },
});
