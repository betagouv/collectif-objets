import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import StimulusHMR from 'vite-plugin-stimulus-hmr'
import { resolve } from 'path'

export default defineConfig({
  plugins: [
    RubyPlugin({
      ruby: {
        sourceCodeDir: 'app/frontend',
        watchAdditionalPaths: ['app/components/**/*']
      }
    }),
    StimulusHMR()
  ],
  build: {
    manifest: true,
    rollupOptions: {
      input: {
        application: resolve(__dirname, 'app/frontend/entrypoints/application.js'),
        all: resolve(__dirname, 'app/frontend/entrypoints/all.css'),
        conservateur_map: resolve(__dirname, 'app/frontend/entrypoints/conservateur_map.js'),
        matomo_tracking: resolve(__dirname, 'app/frontend/entrypoints/matomo_tracking.js')
      }
    }
  }
})
