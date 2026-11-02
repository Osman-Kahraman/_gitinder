/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        bg: '#0a0a0f',
        card: '#12121a',
        accent: {
          green: '#00ff88',
          red: '#ff4458',
        },
        border: '#1e1e2e',
        primary: '#e8e8f0',
        secondary: '#6b6b80',
      },
      fontFamily: {
        mono: ['JetBrains Mono', 'monospace'],
        body: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
