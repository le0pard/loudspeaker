import { resolve } from 'path'
import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

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
  plugins: [svelte()]
})
