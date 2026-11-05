/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      fontFamily: { sans: ['Inter', 'system-ui', 'Segoe UI', 'Roboto', 'sans-serif'] },
      colors: {
        brand: { teal: '#12B39A', tealDeep: '#0E8A76', blue: '#3B82F6', navy: '#0F2742' },
        surface: '#F3F6FB',
      },
      boxShadow: {
        soft: '0 10px 24px -4px rgba(15,39,66,0.10), 0 2px 6px rgba(15,39,66,0.05)',
        glow: '0 10px 24px -6px rgba(18,179,154,0.45)',
      },
      backgroundImage: {
        brand: 'linear-gradient(135deg, #12B39A 0%, #3B82F6 100%)',
      },
      borderRadius: { '2xl': '1.25rem', '3xl': '1.75rem' },
      keyframes: {
        pop: { '0%': { transform: 'scale(.85)', opacity: 0 }, '100%': { transform: 'scale(1)', opacity: 1 } },
        fade: { '0%': { opacity: 0 }, '100%': { opacity: 1 } },
        draw: { '0%': { strokeDashoffset: 48 }, '100%': { strokeDashoffset: 0 } },
        shrink: { '0%': { width: '100%' }, '100%': { width: '0%' } },
      },
      animation: {
        pop: 'pop .26s cubic-bezier(.34,1.56,.64,1)',
        fade: 'fade .2s ease-out',
        draw: 'draw .6s .1s ease-out both',
        shrink: 'shrink linear forwards',
      },
    },
  },
  plugins: [],
};
