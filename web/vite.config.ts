import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';

// Firebase Hosting serves the portal under /app/ next to public QR pages.
// Vercel serves the same portal at the project root.
export default defineConfig(({ mode }) => {
  const isVercel = process.env.VERCEL === '1' || mode === 'vercel';

  return {
    base: isVercel ? '/' : '/app/',
    plugins: [react()],
    build: {
      outDir: isVercel ? 'dist' : '../public/app',
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
  };
});
