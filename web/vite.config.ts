import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';

// Served by Firebase Hosting under /app/ (see firebase.json), next to the
// public QR pages.
export default defineConfig({
  base: '/app/',
  plugins: [react()],
  build: {
    outDir: '../public/app',
    emptyOutDir: true,
    chunkSizeWarningLimit: 800,
    rollupOptions: {
      output: {
        // Separate, long-cacheable vendor chunks.
        manualChunks: {
          react: ['react', 'react-dom', 'react-router-dom'],
          firebase: ['firebase/app', 'firebase/auth', 'firebase/firestore', 'firebase/functions'],
          charts: ['recharts'],
        },
      },
    },
  },
  test: {
    include: ['tests/unit/**/*.test.{ts,tsx}'],
    environment: 'jsdom',
    setupFiles: ['tests/unit/setup.ts'],
  },
});
