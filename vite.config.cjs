import { resolve } from 'path'
import { defineConfig } from 'vite'

// https://vitejs.dev/config/
export default defineConfig({
  root: resolve(__dirname, 'src/frontend'),
  build: {
    manifest: true,
    ssr: false,
    cssCodeSplit: false,
    emptyOutDir: true,
    outDir: resolve(__dirname, 'dist'),
    rollupOptions: {
      input: resolve(__dirname, 'src/frontend/main.js')
    }
  },
  plugins: []
})
