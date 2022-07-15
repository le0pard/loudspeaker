import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import { defineConfig } from 'vite'

const filename = fileURLToPath(import.meta.url)
const dirnamePath = dirname(filename)

// https://vitejs.dev/config/
export default defineConfig({
  root: resolve(dirnamePath, 'src/frontend'),
  build: {
    manifest: true,
    ssr: false,
    cssCodeSplit: false,
    emptyOutDir: true,
    outDir: resolve(dirnamePath, 'dist'),
    rollupOptions: {
      input: resolve(dirnamePath, 'src/frontend/main.js')
    }
  },
  plugins: []
})
