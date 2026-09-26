import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';

// Served by Firebase Hosting under /app/ (see firebase.json), next to the
// public QR pages.
export default defineConfig({
  base: '/app/',
  plugins: [react()],
  build: { outDir: '../public/app', emptyOutDir: true },
  test: {
    include: ['tests/unit/**/*.test.{ts,tsx}'],
    environment: 'jsdom',
    setupFiles: ['tests/unit/setup.ts'],
  },
});
