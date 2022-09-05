import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import StimulusHMR from 'vite-plugin-stimulus-hmr'
import { imagetools } from 'vite-imagetools'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    StimulusHMR(),
    imagetools()
  ],
})
